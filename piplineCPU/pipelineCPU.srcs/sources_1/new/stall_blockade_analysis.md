# CPU 流水线 stall/blockade 信号分析

## 信号定义

### 外部输入
- `stall` - 外部暂停信号（cpu.v 第6行，输入端口）

### 内部信号
- `oID_stall` - PipeID 输出的 stall 信号（cpu.v 第134行）
- `oID_blockade` - PipeID 输出的 blockade 信号（cpu.v 第135行）
- `iIR_stall` - PipeIR 的 stall 输入（cpu.v 第60行）
- `iIR_blockade` - PipeIR 的 blockade 输入（cpu.v 第65行）
- `iID_stall` - PipeID 的 stall 输入（cpu.v 第101行）
- `iID_blockade` - PipeID 的 blockade 输入（cpu.v 第63行）
- `iDEreg_branch_predict_fail` - PipeDEreg 的分支预测失败信号（cpu.v 第243行）
- `iID_branch_predict_fail` - PipeID 的分支预测失败信号（cpu.v 第103行）
- `iIR_branch_predict_fail` - PipeIR 的分支预测失败信号（cpu.v 第64行）

---

## 信号连接关系

### 1. stall 信号流向

```
外部输入 stall
    │
    ├─ (cpu.v:460) iPC_ena = ~(stall | oID_stall)
    │   └─ 控制 PC 寄存器是否更新
    │
    ├─ (cpu.v:472) iIR_stall = stall | oID_stall
    │   └─ 输入到 PipeIR.stall
    │       └─ PipeIR 在 stall=1 时不更新 D_pc4/D_inst/D_blockade
    │
    └─ (cpu.v:500) iID_stall = stall
        └─ 输入到 PipeID.i_stall
            └─ PipeID 输出 o_stall（来自 direct 模块）
                └─ (cpu.v:203) oID_stall
                    └─ 反馈到 iPC_ena 和 iIR_stall
```

### 2. blockade 信号流向

```
PipeID.o_blockade (由 cu 生成)
    │
    └─ (cpu.v:204, 473) oID_blockade
        │
        ├─ (cpu.v:473) iIR_blockade = oID_blockade
        │   └─ 输入到 PipeIR.blockade (cpu.v:72)
        │       注意：还或上了 iIR_branch_predict_fail
        │       .blockade(iIR_blockade | iIR_branch_predict_fail)
        │       └─ PipeIR 在 clk 上升沿更新 D_blockade
        │           └─ iID_blockade
        │               └─ 输入到 PipeID.i_blockade (cpu.v:170)
        │                   注意：还或上了 iID_branch_predict_fail
        │                   .i_blockade(iID_blockade | iID_branch_predict_fail)
        │                       └─ PipeID 内部使用
        │
        └─ 直接输入到 PipeID.i_blockade (cpu.v:170)
            实际上是：iID_blockade | iID_branch_predict_fail
```

### 3. branch_predict_fail 信号流向

```
PipeEXE.oEXE_branch_predict_fail (来自执行阶段)
    │
    ├─ (cpu.v:467) iIF_branch_predict_fail = oEXE_branch_predict_fail
    │   └─ 输入到 PipeIF (影响 npc 选择)
    │
    ├─ (cpu.v:473) iIR_branch_predict_fail = oEXE_branch_predict_fail
    │   └─ 输入到 PipeIR (或入 blockade)
    │       .blockade(iIR_blockade | iIR_branch_predict_fail)
    │
    └─ (cpu.v:501) iID_branch_predict_fail = oEXE_branch_predict_fail
        └─ 输入到 PipeID (或入 i_blockade)
            .i_blockade(iID_blockade | iID_branch_predict_fail)
```

---

## PipeID 内部使用 (PipeID.v 第289-299行)

```verilog
// 所有输出都受 (i_blockade | i_stall | o_stall) 控制
assign o_DMEM_wena   = (i_blockade | i_stall | o_stall) ? 0 : DMEM_wena;
assign o_mux_pc      = (i_blockade | i_stall | o_stall) ? 0 : mux_pc;  // ← 问题所在！
assign o_rf_wena     = (i_blockade | i_stall | o_stall) ? 0 : rf_wena;
assign o_hi_ena      = (i_blockade | i_stall | o_stall) ? 0 : hi_ena;
assign o_lo_ena      = (i_blockade | i_stall | o_stall) ? 0 : lo_ena;
assign cpr_ena       = (i_blockade | i_stall | o_stall) ? 0 : cp0_mtc0;
assign cp0_exception = (i_blockade | i_stall | o_stall) ? 0 : cu_exception;
assign cp0_delay     = (i_blockade | i_stall | o_stall);
assign o_blockade    = (i_blockade | i_stall | o_stall) ? 0 : blockade;
assign o_branch_inst = (i_blockade | i_stall | o_stall) ? 0 : branch_inst;
assign o_branch_flag = (i_blockade | i_stall | o_stall) ? 4'b0000 : branch_flag;
```

---

## 问题分析：jalr + j 指令序列

### 测试程序
```assembly
0x00400010: jalr $30, $1    # 跳转到 $1, $30 = PC+4
0x00400014: j RIGHT         # 延迟槽指令（会被执行）
0x00400018: addi $3,$0,1    # jalr 的跳转目标
0x0040001C: addi $4,$0,1
0x00400020: addi $5,$0,1
0x00400024: jr $30          # 返回到 0x00400014
0x00400028: RIGHT: addi $6,$0,2
```

### 时间线追踪

#### T1: jalr 在 ID 阶段
- cu 输出: `mux_pc = mux_pc_Rs`, `blockade = 1`
- PipeID 输出: `o_blockade = 1`（假设无 stall）
- `o_mux_pc = mux_pc_Rs`

#### T2: jalr 进入 EX 阶段，j 进入 ID 阶段
- `oID_blockade = 1` 从 jalr 的 EX 阶段传播
- `iIR_blockade = oID_blockade = 1`（cpu.v:473）
- j 指令从 PipeIR 读入：`D_blockade = 1`
- `iID_blockade = 1`（j 指令的 blockade 来自上一条 jalr）
- PipeID 对 j 指令解码：
  - cu 输出: `mux_pc = mux_pc_II = 3`
  - 但是！`i_blockade = iID_blockade | iID_branch_predict_fail = 1 | 0 = 1`
  - `o_mux_pc = (1 | 0 | o_stall) ? 0 : 3 = 0` ← **PC 多路选择器被清零！**
  - `o_blockade = (1 | 0 | o_stall) ? 0 : blockade = 0`

#### T3: jalr 写回，j 进入 EX 阶段
- PC 更新: `npc = mux_npc = pc4`（因为 `o_mux_pc = 0` 选择了 PC+4）
- **J 指令没有跳转！PC 继续 +4**
- 执行 `addi $3,$0,1` 而不是跳到 RIGHT

#### T4-T5: 继续执行 addi $4, addi $5
- PC = 0x00400020, 0x00400024

#### T6: jr $30 执行
- `$30 = 0x00400014`（jalr 设置的返回地址）
- PC 跳回 0x00400014

#### T7: 回到 j RIGHT ← **死循环！**
- 再次遇到同样的问题：`i_blockade = 1`（来自 jalr 的延迟槽影响）
- `o_mux_pc` 再次被清零
- 再次执行 `addi $3`
- **无限循环！**

---

## 根本原因

**`o_mux_pc` 被 `i_blockade` 错误地清零。**

`i_blockade` 来自**前一条指令**的 blockade 信号，通过 PipeIR 传递。对于 J/JAL 这类无条件跳转指令，它们自己的 `blockade = 1` 是为了延迟下一条指令的取指。但是：

- 当前指令的 `o_mux_pc` 应该反映**当前指令**的控制意图
- 不应该被**前一条指令**的 blockade 影响

**当前问题**：`o_mux_pc = (i_blockade | i_stall | o_stall) ? 0 : mux_pc`

当 `i_blockade = 1` 时（来自前一条 jalr），即使当前是 J 指令且 `mux_pc = mux_pc_II = 3`，`o_mux_pc` 仍被清零。

---

## 建议修复

### 方案 1：移除 i_blockade 对 o_mux_pc 的影响
```verilog
assign o_mux_pc = (i_stall | o_stall) ? 0 : mux_pc;
```
**理由**：`i_blockade` 影响的是前一条指令的写回/内存操作，不应该影响当前指令的 PC 跳转。

### 方案 2：保留 i_blockade，但仅用于非跳转指令
```verilog
assign o_mux_pc = (i_blockade & ~is_jump | i_stall | o_stall) ? 0 : mux_pc;
```
**理由**：对于跳转指令，即使前一条有 blockade，也应该执行跳转。

### 方案 3：检查是否应该用 o_blockade 而不是清零
```verilog
assign o_mux_pc = (i_stall | o_stall) ? 0 : mux_pc;
// o_blockade 由其他逻辑处理
```

---

## 其他受影响的信号

同样的问题可能影响：
- `o_DMEM_wena` - 数据存储器写使能
- `o_rf_wena` - 寄存器文件写使能
- `o_hi_ena` / `o_lo_ena` - HI/LO 使能
- `o_branch_inst` - 分支指令标志
- `o_branch_flag` - 分支类型

但对于 J 指令（非分支），这些信号本应为 0 或无关值，所以主要问题集中在 `o_mux_pc`。
