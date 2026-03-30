# 流水线 CPU 设计项目 (Pipeline CPU Design Project)

## 项目概述

这是一个基于 MIPS 架构的五级流水线 CPU 设计项目，支持 89 条 MIPS 指令。项目实现了带 2bit 分支预测器的动态流水线 CPU，支持 CP0 协处理器和时钟中断。

**实验信息**：
- **实验名称**：简单的流水线 CPU 设计与性能分析
- **课程**：同济大学计算机科学与技术学院《计算机系统结构》
- **作者**：程浩然 (学号 2351579)
- **授课教师**：秦国锋

主要功能：
- 支持 89 条 MIPS 指令
- 采用动态流水技术
- 内置 2bit 分支预测器
- 支持 CP0 协处理器
- 支持时钟中断
- 小端模式

## 项目架构目录

### 主要目录结构

```
cpu89/
├── piplineCPU/                     # Vivado 项目主目录
│   ├── pipelineCPU.xpr             # Vivado 项目文件
│   ├── pipelineCPU.srcs/           # 项目源文件
│   │   ├── sources_1/new/          # 核心 Verilog 源文件
│   │   ├── sim_1/                  # 仿真文件
│   │   ├── constrs_1/              # 约束文件
│   │   └── ip/                     # IP 核文件
│   ├── pipelineCPU.cache/          # Vivado 缓存
│   ├── pipelineCPU.hw/             # 硬件配置
│   ├── pipelineCPU.gen/            # 生成的文件
│   ├── pipelineCPU.ip_user_files/  # IP 用户文件
│   └── 测试文件/                    # 测试文件
├── test_scripts/                   # 自动化测试脚本
│   ├── vivado_auto_test.tcl        # Vivado 自动化测试脚本
│   ├── simple_modelsim_batch.do    # ModelSim 简化批处理脚本
│   ├── modelsim_basic_sim.do       # ModelSim 基本仿真脚本
│   └── results/                    # 测试结果目录
├── testdata/                       # 测试数据目录
├── tests/                          # 测试汇编代码
├── tools/                          # 工具脚本
│   └── hex_to_coe.py               # 十六进制转 COE 格式转换工具
├── report/                         # 实验报告相关文件
├── work/                           # 工作目录
├── log/                            # 日志目录
├── readme.md                       # 项目说明文件
├── run_cpu_tests.do                # ModelSim 批处理测试脚本
└── QWEN.md                         # Qwen 辅助开发说明文件
```

### 核心源文件说明 (piplineCPU/pipelineCPU.srcs/sources_1/new/)

- **top.v**: 顶层模块，集成 CPU 和板级资源
- **cpu.v**: CPU 核心模块，集成所有流水线阶段和控制单元
- **pcreg.v**: 程序计数器模块
- **npc.v**: 下一 PC 计算模块
- **alu.v**: 算术逻辑单元
- **regfile.v**: 寄存器文件
- **memory.v**: 数据存储器模块
- **cp0.v**: CP0 协处理器模块
- **cpmem.v**: CP0 寄存器存储
- **cu.v**: 控制单元
- **decoder.v**: 指令译码器
- **direct.v**: 定向模块
- **extend.v**: 立即数扩展模块
- **div.v / divider.v**: 除法器模块
- **mult.v**: 乘法器模块
- **clo.v**: 前导 1 计数器模块
- **clz.v**: 前导 0 计数器模块
- **complement.v**: 补码模块
- **hi_lo_function.v**: HI/LO 寄存器功能模块
- **LLbit_reg.v**: LLbit 寄存器（用于原子操作）
- **sccomp_dataflow.v**: 原子比较数据流模块
- **predictor.v**: 分支预测器模块
- **II.v**: 中断处理模块
- **mux.v**: 多路选择器模块
- **Asynchronous_D_FF.v**: 异步 D 触发器
- **seg7x16.v**: 七段数码管显示模块

### 流水线寄存器模块

- **PipeIF.v**: 取指级流水线寄存器 (IF)
- **PipeID.v**: 译码级流水线寄存器 (ID)
- **PipeIR.v**: 指令寄存器级流水线
- **PipeDEreg.v**: 译码 - 执行级流水线寄存器
- **PipeEXE.v**: 执行级流水线寄存器 (EX)
- **PipeEMreg.v**: 执行 - 访存级流水线寄存器
- **PipeMEM.v**: 访存级流水线寄存器 (MEM)
- **PipeMWreg.v**: 访存 - 写回级流水线寄存器
- **PipeWB.v**: 写回级流水线寄存器 (WB)

### 测试相关目录

#### test_scripts/
该目录包含所有自动化测试脚本，支持 Vivado 和 ModelSim 环境下的批处理测试：

- **vivado_auto_test.tcl**: Vivado 自动化测试脚本，自动遍历所有测试文件并进行批处理仿真
- **simple_modelsim_batch.do**: ModelSim 简化批处理脚本，依次运行所有测试
- **modelsim_basic_sim.do**: ModelSim 基本仿真脚本，用于快速单独测试
- **results/**: 存储测试结果的目录

#### testdata/
包含大量测试用例，覆盖各种 MIPS 指令：

- **数字_指令名称.hex.txt**: 测试程序的十六进制机器码
- **数字_指令名称.result.txt**: 对应的标准输出结果
- **数字_指令名称.txt**: 测试程序的汇编代码

目前包含超过 100 个测试用例，覆盖以下指令类型：
- 算术运算：add, addu, addi, addiu, sub, subu
- 逻辑运算：and, andi, or, ori, xor, xori, nor
- 移位运算：sll, sllv, srl, srlv, sra, srav, clz, clo
- 比较运算：slt, sltu, slti, sltiu
- 跳转分支：j, jal, jr, jalr, beq, bne, bgez, bgtz, blez, bltz, bltzal, bgezal
- 加载存储：lw, sw, lb, sb, lh, sh, lbu, lhu, lwl, lwr, swl, swr
- 乘除法：mult, multu, div, divu, madd, maddu, msub, msubu
- 原子操作：ll, sc
- 条件传送：movn, movz
- 特殊指令：mfc0, mtc0, mfhi, mthi, mflo, mtlo, syscall, break
- 其他：lui, nop 等

#### tests/
包含一些额外的手动测试文件：
- **test.asm**: 复杂的汇编测试程序

#### piplineCPU/测试文件/
包含板级测试文件：
- **mips_89_mars_board_switch_student.s**: 89 条 MIPS 指令的板级测试汇编程序
- **mips_89_mars_board_switch_student.coe**: 对应的 COE 格式机器码
- **bigendian_mips.coe**: 大端模式 MIPS 测试文件

### 工具目录 (tools/)

- **hex_to_coe.py**: 十六进制转 COE 格式转换工具，支持单文件、批量和交互式转换

### 报告目录 (report/)

包含实验报告相关的 LaTeX 文档和截图：
- **实验一.tex**: 实验报告 LaTeX 源文件
- **实验一.pdf**: 生成的 PDF 报告
- **screenshot*.png**: 实验截图
- **tongji_logo.png**: 同济大学 Logo

## 构建与测试

### 使用 ModelSim 进行测试
运行提供的批处理脚本来执行所有测试：
```bash
vsim -c -do "do run_cpu_tests.do; quit" > log
```

### 使用 Vivado 进行测试
在 Vivado 的 Tcl 控制台中运行：
```tcl
source test_scripts/vivado_auto_test.tcl
```

### 测试函数说明

测试程序由 11 个测试函数构成，测试内容覆盖 89 条 MIPS 指令、CP0 以及时钟中断：

| 测试函数 | 测试指令 | 错误码 |
|---------|---------|-------|
| 测试函数 1 | addi, addiu, andi, ori, slti, sltiu, lui, xori, and, beq, bne, j, jal, jr, lw, sw, mul, sll, sub | -1 |
| 测试函数 2 | mfhi, mflo, div, divu | -2 |
| 测试函数 3 | sb, lb, lbu, sh, lh, lhu, mthi, mtlo, mfhi, mflo, sltu, sllv, srav, srlv, sra, srl, subu, add, addu, slt, clz, clo | -3 |
| 测试函数 4 | jalr | -4 |
| 测试函数 5 | mult, multu, madd, maddu, msub, msubu | -5 |
| 测试函数 6 | movn, movz | -6 |
| 测试函数 7 | bgez, bgtz, blez, bltz, bltzal, bgezal | -7 |
| 测试函数 8 | lwl, lwr, swl, swr | -8 |
| 测试函数 9 | ll, sc | -9 |
| 测试函数 10 | CP0 相关指令（自陷指令、syscall、break、ret、mfc0、mtc0） | -10 |
| 测试函数 11 | 时钟中断 | - |

#### 测试结果说明

- **正确结果**：数码管低半字显示 0x0001，高半字随着时钟中断而计数
- **错误结果**：数码管显示 -1~-10 的错误码，或者数码管低半字显示 0x0001 但高半字不计数

## 开发约定

- 所有 Verilog 文件遵循标准命名规范，模块名与文件名保持一致
- 流水线设计严格按照 IF-ID-EX-MEM-WB 五个阶段进行划分
- 使用统一的信号命名约定，便于维护和理解
- 代码中包含详细的注释说明，特别是对于复杂的控制逻辑

## 环境要求

### 软件环境
- 开发环境：Vivado 2020.2
- 仿真环境：ModelSim PE 10.4c
- 测试环境：MARS 4.5（小端）、notepad++

### 硬件环境
- NEXYS 4 DDR Artix-7 开发板

## 注意事项

- CPU 采用小端模式
- 中断例程起始地址为 0x00400004
- 数码管显示地址为 0x10010000 的 DMEM 单元
- 项目使用延迟分支的方式执行分支和跳转指令

---

## 附录：关键技术说明（源自实验报告）

### 流水线寄存器功能

| 寄存器 | 存储内容 |
|--------|----------|
| IF/ID | 指令编码、当前 PC 值、分支目标 PC 地址 |
| ID/EX | 操作码与操作数信息、操作数 A/B、ALU 控制信号 |
| EX/MEM | ALU 运算结果、内存访问地址、读/写控制信号、待写入数据 |
| MEM/WB | 数据存储器读取结果、目标寄存器地址、写回使能信号 |

### 分支指令处理机制

- **第 0 周期**：IF_ID 寄存器输出 PC_bobl 信号为 1，触发分支检测逻辑
- **第 1 周期**：PC 保持当前值，IMEM 输出 NOP 指令，插入流水线气泡

### 冲突检测与处理流程

1. 冲突检测在译码 (ID) 阶段完成，激活 `detect_confict` 信号
2. PC 暂停一个时钟周期更新，向 ID_EX 模块传递 NOP 指令（流水线冒泡）
3. PC、IMEM 与 IF/ID 寄存器在冲突周期内保持原有值

### 数据前递机制（Tomasulo 算法）

控制器采用 **Tomasulo 算法** 实现动态调度：

**前递源**：
- `FWD_SRC_EX_ALU`：ALU 结果在 EX 阶段
- `FWD_SRC_EX_MULT`：乘除结果在 EX 阶段
- `FWD_SRC_MEM`：访存结果在 MEM 阶段

**冒险解决**：
- **RAW 冒险**：通过检查 `reg_status[rs]`和`reg_status[rt]` 判断源操作数就绪状态
- **结构冒险**：保留站满或功能单元忙时产生停顿信号
- **WAW 冒险**：通过寄存器重命名支持乱序完成

### 写锁机制

寄存器文件的写锁设计：
- 为待写入的寄存器添加写锁，直至写回阶段完成后释放
- 写锁寄存器 `reglock` 的低 2 位为计时器，高 2 位标识锁的类型（ALU 型/DMEM 型）
- 定时器归零时自动释放写锁（数据需 3 个周期完成传递）

### 异常处理

- 检测到 SYSCALL、BREAK 或 TEQ 时，设置异常原因编码 `cause` 和异常标志 `exception`
- 触发 CP0 异常处理例程，PC 跳转至 0x00000004
- ERET 指令从异常返回：PC ← EPC

### 性能分析

基于 1538 条指令的测试程序：

| 指标 | 单周期 CPU | 流水线 CPU | 比值 |
|------|-----------|-----------|------|
| 时钟周期 | T_single | T_single/5 | 5:1 |
| 所需周期数 | 1538 | 1542 (理想) | ≈1:1 |
| 总执行时间 | 1538×T | 308.4×T | **4.987:1** |

考虑实际冲突（多周期乘法器）后加速比约为 **4.47 倍**。
