---
author: ainski
time: 2025-12-10
teacher: qgf
---

# 流水线 CPU 设计项目

## 项目概述

本项目实现了支持 89 条 MIPS 指令的五级流水线 CPU，基于同济大学 CS《计算机系统实验》实验一要求设计。

主要特性：
- 支持 89 条 MIPS 指令
- 采用动态流水技术
- 内置 2bit 分支预测器
- 支持 CP0 协处理器
- 支持时钟中断
- 小端模式

## 运行集成化测试

```bash
vsim -c -do "do run_cpu_tests.do; quit" > log
```

## 项目架构

### 主要目录结构

```
cpu89/
├── piplineCPU/                     # Vivado 项目主目录
│   ├── pipelineCPU.xpr             # Vivado 项目文件
│   ├── pipelineCPU.srcs/           # 项目源文件
│   │   ├── sources_1/new/          # 核心 Verilog 源文件
│   │   ├── sim_1/                  # 仿真文件
│   │   └── constrs_1/              # 约束文件
│   ├── pipelineCPU.cache/          # Vivado 缓存
│   ├── pipelineCPU.hw/             # 硬件配置
│   └── 测试文件/                    # 板级测试文件
├── test_scripts/                   # 自动化测试脚本
├── testdata/                       # 测试数据目录
├── tests/                          # 测试汇编代码
├── tools/                          # 工具脚本
│   └── hex_to_coe.py               # 十六进制转 COE 格式转换工具
├── report/                         # 实验报告相关文件
├── work/                           # 工作目录
├── log/                            # 日志目录
├── readme.md                       # 项目说明文件
└── run_cpu_tests.do                # ModelSim 批处理测试脚本
```

### 核心模块

#### 顶层模块
- **top.v**: 板级顶层模块
- **cpu.v**: CPU 核心模块

#### 流水线阶段
- **pcreg.v**: 程序计数器
- **PipeIF.v**: 取指级流水线寄存器
- **PipeID.v**: 译码级流水线寄存器
- **PipeIR.v**: 指令寄存器级
- **PipeDEreg.v**: 译码 - 执行级流水线寄存器
- **PipeEXE.v**: 执行级流水线寄存器
- **PipeEMreg.v**: 执行 - 访存级流水线寄存器
- **PipeMEM.v**: 访存级流水线寄存器
- **PipeMWreg.v**: 访存 - 写回级流水线寄存器
- **PipeWB.v**: 写回级流水线寄存器

#### 功能模块
- **alu.v**: 算术逻辑单元
- **regfile.v**: 寄存器文件
- **memory.v**: 数据存储器
- **cp0.v**: CP0 协处理器
- **cu.v**: 控制单元
- **decoder.v**: 指令译码器
- **predictor.v**: 分支预测器
- **div.v / divider.v**: 除法器
- **mult.v**: 乘法器
- **clz.v / clo.v**: 前导零/一计数器
- **hi_lo_function.v**: HI/LO 寄存器功能
- **LLbit_reg.v**: LLbit 寄存器（原子操作）
- **II.v**: 中断处理模块

## 测试覆盖

测试程序由 11 个测试函数构成，覆盖 89 条 MIPS 指令、CP0 和时钟中断：

| 测试函数 | 测试内容 | 错误码 |
|---------|---------|-------|
| 1 | 基础指令 (addi, addiu, andi, ori, slti, lui, xori, and, beq, bne, j, jal, jr, lw, sw, mul, sll, sub) | -1 |
| 2 | HI/LO指令 (mfhi, mflo, div, divu) | -2 |
| 3 | 加载存储及移位 (sb, lb, lbu, sh, lh, lhu, mthi, mtlo, sltu, sllv, srav, srlv, sra, srl, subu, add, addu, slt, clz, clo) | -3 |
| 4 | jalr 指令 | -4 |
| 5 | 乘加乘减 (mult, multu, madd, maddu, msub, msubu) | -5 |
| 6 | 条件传送 (movn, movz) | -6 |
| 7 | 分支指令 (bgez, bgtz, blez, bltz, bltzal, bgezal) | -7 |
| 8 | 非对齐访问 (lwl, lwr, swl, swr) | -8 |
| 9 | 原子操作 (ll, sc) | -9 |
| 10 | CP0 指令 (syscall, break, ret, mfc0, mtc0) | -10 |
| 11 | 时钟中断 | - |

### 测试结果说明

- **正确结果**：数码管低半字显示 `0x0001`，高半字随着时钟中断而计数
- **错误结果**：数码管显示 `-1` ~ `-10` 的错误码，或低半字显示 `0x0001` 但高半字不计数

## 环境要求

### 软件环境
- 开发环境：Vivado 2016.2
- 仿真环境：ModelSim PE 10.4c
- 测试环境：MARS 4.5（小端）

### 硬件环境
- NEXYS 4 DDR Artix-7 开发板

## 已知问题

- lbsb, lh, sh 指令可能存在未修复的 bug
- 采用延迟分支的方式执行分支指令和跳转指令

## 参考资料

- 原始项目：https://github.com/ZhengBryan/TongjiCS-Undergraduate-Courses.git
- 参考实现：https://github.com/lingbai-kong/MIPS89-pipeline-CPU
