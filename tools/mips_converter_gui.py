import tkinter as tk
from tkinter import ttk, messagebox, scrolledtext
import struct

# ============================================================
# MIPS 指令集定义 (89 条指令)
# 基于 decoder.v 中的 {opcode[31:26], funct[5:0]} 12-bit key
# ============================================================

R_TYPE = {
    0b000000100000: ('add', 'R', 'rd, rs, rt'),
    0b000000100001: ('addu', 'R', 'rd, rs, rt'),
    0b000000100010: ('sub', 'R', 'rd, rs, rt'),
    0b000000100011: ('subu', 'R', 'rd, rs, rt'),
    0b000000100100: ('and', 'R', 'rd, rs, rt'),
    0b000000100101: ('or', 'R', 'rd, rs, rt'),
    0b000000100110: ('xor', 'R', 'rd, rs, rt'),
    0b000000100111: ('nor', 'R', 'rd, rs, rt'),
    0b000000101010: ('slt', 'R', 'rd, rs, rt'),
    0b000000101011: ('sltu', 'R', 'rd, rs, rt'),
    0b000000000000: ('sll', 'R', 'rd, rt, shamt'),
    0b000000000010: ('srl', 'R', 'rd, rt, shamt'),
    0b000000000011: ('sra', 'R', 'rd, rt, shamt'),
    0b000000000100: ('sllv', 'R', 'rd, rt, rs'),
    0b000000000110: ('srlv', 'R', 'rd, rt, rs'),
    0b000000000111: ('srav', 'R', 'rd, rt, rs'),
    0b000000001000: ('jr', 'R', 'rs'),
    0b000000001001: ('jalr', 'R', 'rd, rs'),
    0b000000010000: ('mfhi', 'R', 'rd'),
    0b000000010001: ('mthi', 'R', 'rs'),
    0b000000010010: ('mflo', 'R', 'rd'),
    0b000000010011: ('mtlo', 'R', 'rs'),
    0b000000001100: ('syscall', 'R', ''),
    0b000000001101: ('break', 'R', ''),
    0b010000011000: ('eret', 'R', ''),
    0b000000011010: ('div', 'R', 'rs, rt'),
    0b000000011011: ('divu', 'R', 'rs, rt'),
    0b000000011000: ('mult', 'R', 'rs, rt'),
    0b000000011001: ('multu', 'R', 'rs, rt'),
    0b000000110100: ('teq', 'R', 'rs, rt'),
    0b000000110000: ('tge', 'R', 'rs, rt'),
    0b000000110001: ('tgeu', 'R', 'rs, rt'),
    0b000000110010: ('tlt', 'R', 'rs, rt'),
    0b000000110011: ('tltu', 'R', 'rs, rt'),
    0b000000110110: ('tne', 'R', 'rs, rt'),
    0b000000001011: ('movn', 'R', 'rd, rs, rt'),
    0b000000001010: ('movz', 'R', 'rd, rs, rt'),
    0b011100100000: ('clz', 'R', 'rd, rs'),
    0b011100100001: ('clo', 'R', 'rd, rs'),
    0b011100000010: ('mul', 'R', 'rd, rs, rt'),
    0b011100000000: ('madd', 'R', 'rs, rt'),
    0b011100000001: ('maddu', 'R', 'rs, rt'),
    0b011100000100: ('msub', 'R', 'rs, rt'),
    0b011100000101: ('msubu', 'R', 'rs, rt'),
}

I_TYPE = {
    0b001000: ('addi', 'I', 'rt, rs, imm'),
    0b001001: ('addiu', 'I', 'rt, rs, imm'),
    0b001100: ('andi', 'I', 'rt, rs, imm'),
    0b001101: ('ori', 'I', 'rt, rs, imm'),
    0b001110: ('xori', 'I', 'rt, rs, imm'),
    0b001010: ('slti', 'I', 'rt, rs, imm'),
    0b001011: ('sltiu', 'I', 'rt, rs, imm'),
    0b001111: ('lui', 'I', 'rt, imm'),
    0b100011: ('lw', 'I', 'rt, offset(base)'),
    0b101011: ('sw', 'I', 'rt, offset(base)'),
    0b000100: ('beq', 'I', 'rs, rt, offset'),
    0b000101: ('bne', 'I', 'rs, rt, offset'),
    0b100100: ('lbu', 'I', 'rt, offset(base)'),
    0b100101: ('lhu', 'I', 'rt, offset(base)'),
    0b100000: ('lb', 'I', 'rt, offset(base)'),
    0b100001: ('lh', 'I', 'rt, offset(base)'),
    0b101000: ('sb', 'I', 'rt, offset(base)'),
    0b101001: ('sh', 'I', 'rt, offset(base)'),
    0b000111: ('bgtz', 'I', 'rs, offset'),
    0b000110: ('blez', 'I', 'rs, offset'),
    0b100010: ('lwl', 'I', 'rt, offset(base)'),
    0b100110: ('lwr', 'I', 'rt, offset(base)'),
    0b101010: ('swl', 'I', 'rt, offset(base)'),
    0b101110: ('swr', 'I', 'rt, offset(base)'),
    0b110000: ('ll', 'I', 'rt, offset(base)'),
    0b111000: ('sc', 'I', 'rt, offset(base)'),
}

J_TYPE = {
    0b000010: ('j', 'J', 'target'),
    0b000011: ('jal', 'J', 'target'),
}

# 特殊 REGIMM 类型 (opcode=000001, rt 决定具体指令)
REGIMM = {
    0b00000: ('bltz', 'I', 'rs, offset'),
    0b10000: ('bltzal', 'I', 'rs, offset'),
    0b00001: ('bgez', 'I', 'rs, offset'),
    0b10001: ('bgezal', 'I', 'rs, offset'),
    0b01100: ('teqi', 'I', 'rs, imm'),
    0b01000: ('tgei', 'I', 'rs, imm'),
    0b01001: ('tgeiu', 'I', 'rs, imm'),
    0b01010: ('tlti', 'I', 'rs, imm'),
    0b01011: ('tltiu', 'I', 'rs, imm'),
    0b01110: ('tnei', 'I', 'rs, imm'),
}

# CP0 指令 (opcode=010000)
CP0 = {
    0b00000: ('mfc0', 'CP0', 'rt, rd'),
    0b00100: ('mtc0', 'CP0', 'rt, rd'),
}

REGISTERS = {
    'zero': 0, 'at': 1, 'v0': 2, 'v1': 3,
    'a0': 4, 'a1': 5, 'a2': 6, 'a3': 7,
    't0': 8, 't1': 9, 't2': 10, 't3': 11, 't4': 12, 't5': 13, 't6': 14, 't7': 15,
    's0': 16, 's1': 17, 's2': 18, 's3': 19, 's4': 20, 's5': 21, 's6': 22, 's7': 23,
    't8': 24, 't9': 25, 'k0': 26, 'k1': 27, 'gp': 28, 'sp': 29, 'fp': 30, 'ra': 31,
    '0': 0, '1': 1, '2': 2, '3': 3, '4': 4, '5': 5, '6': 6, '7': 7,
    '8': 8, '9': 9, '10': 10, '11': 11, '12': 12, '13': 13, '14': 14, '15': 15,
    '16': 16, '17': 17, '18': 18, '19': 19, '20': 20, '21': 21, '22': 22, '23': 23,
    '24': 24, '25': 25, '26': 26, '27': 27, '28': 28, '29': 29, '30': 30, '31': 31,
}

REG_BY_NUM = {v: k for k, v in REGISTERS.items() if isinstance(v, int) and k.isalpha()}

# 全局设置：寄存器显示格式
USE_REGISTER_NAME = True  # True=显示寄存器名，False=显示数字


def sign_extend(val, bits):
    if val & (1 << (bits - 1)):
        return val - (1 << bits)
    return val


def format_signed(val, bits=16):
    """格式化为有符号十进制"""
    return str(sign_extend(val, bits))


def format_hex(val, width=8):
    """格式化为十六进制"""
    return f'0x{val:0{width}x}'


def format_reg(reg_num):
    """根据全局设置格式化寄存器显示"""
    global USE_REGISTER_NAME
    if USE_REGISTER_NAME:
        return f'${REG_BY_NUM.get(reg_num, reg_num)}'
    else:
        return f'${reg_num}'


def parse_reg(s):
    """解析寄存器名称或数字为编号"""
    s = s.strip().lower().lstrip('$')
    if s in REGISTERS:
        return REGISTERS[s]
    raise ValueError(f'未知寄存器: {s}')


def parse_imm(s, bits=16):
    """解析立即数（支持十进制、0x十六进制）"""
    s = s.strip()
    if s.startswith('0x') or s.startswith('0X'):
        val = int(s, 16)
    else:
        val = int(s, 10)
    # 转换为无符号表示
    if val < 0:
        val = (1 << bits) + val
    return val & ((1 << bits) - 1)


def mask(bits):
    return (1 << bits) - 1


# ============================================================
# 机器码 -> 汇编
# ============================================================
def hex_to_asm(hex_str):
    global USE_REGISTER_NAME
    hex_str = hex_str.strip().lower().removeprefix('0x')
    inst = int(hex_str, 16) & 0xFFFFFFFF

    opcode = (inst >> 26) & 0x3F
    rs = (inst >> 21) & 0x1F
    rt = (inst >> 16) & 0x1F
    rd = (inst >> 11) & 0x1F
    shamt = (inst >> 6) & 0x1F
    funct = inst & 0x3F
    imm = inst & 0xFFFF
    target = inst & 0x3FFFFFF

    key12 = (opcode << 6) | funct

    # CP0 指令
    if opcode == 0b010000:
        if rt == 0b00000 and rd in CP0:
            mnem, _, fmt = CP0[rd]
            return f'{mnem} {format_reg(rt)}, {format_reg(rt)}'
        if rs == 0b00000 and rd == 0b00000:
            return f'mfc0 {format_reg(rt)}, $0'
        if rs == 0b00100 and rd == 0b00000:
            return f'mtc0 {format_reg(rt)}, $0'
        if funct == 0b011000:
            return 'eret'
        return f'cp0_unk 0x{inst:08x}'

    # REGIMM 类型
    if opcode == 0b000001:
        if rt in REGIMM:
            mnem, _, fmt = REGIMM[rt]
            offset = sign_extend(imm, 16)
            return f'{mnem} {format_reg(rs)}, {offset}'
        return f'regimm_unk 0x{inst:08x}'

    # R 型
    if opcode == 0b000000:
        if key12 in R_TYPE:
            mnem, _, fmt = R_TYPE[key12]
            if mnem in ('sll', 'srl', 'sra'):
                return f'{mnem} {format_reg(rd)}, {format_reg(rt)}, {shamt}'
            elif mnem in ('jr',):
                return f'{mnem} {format_reg(rs)}'
            elif mnem in ('jalr',):
                if rd == 31:
                    return f'{mnem} {format_reg(rs)}'
                return f'{mnem} {format_reg(rd)}, {format_reg(rs)}'
            elif mnem in ('syscall', 'break', 'eret'):
                return mnem
            elif mnem in ('mfhi', 'mflo'):
                return f'{mnem} {format_reg(rd)}'
            elif mnem in ('mthi', 'mtlo'):
                return f'{mnem} {format_reg(rs)}'
            elif mnem in ('clz', 'clo'):
                return f'{mnem} {format_reg(rd)}, {format_reg(rs)}'
            elif mnem in ('div', 'divu', 'mult', 'multu', 'madd', 'maddu', 'msub', 'msubu'):
                return f'{mnem} {format_reg(rs)}, {format_reg(rt)}'
            elif mnem in ('teq', 'tge', 'tgeu', 'tlt', 'tltu', 'tne'):
                return f'{mnem} {format_reg(rs)}, {format_reg(rt)}'
            elif mnem in ('mul', 'add', 'addu', 'sub', 'subu', 'and', 'or', 'xor', 'nor', 'slt', 'sltu'):
                return f'{mnem} {format_reg(rd)}, {format_reg(rs)}, {format_reg(rt)}'
            elif mnem in ('movn', 'movz'):
                return f'{mnem} {format_reg(rd)}, {format_reg(rs)}, {format_reg(rt)}'
            elif mnem in ('sllv', 'srlv', 'srav'):
                return f'{mnem} {format_reg(rd)}, {format_reg(rt)}, {format_reg(rs)}'
        return f'r_type_unk 0x{inst:08x}'

    # J 型
    if opcode in J_TYPE:
        mnem, _, fmt = J_TYPE[opcode]
        return f'{mnem} 0x{target:06x}'

    # I 型
    if opcode in I_TYPE:
        mnem, _, fmt = I_TYPE[opcode]
        if mnem in ('lw', 'lb', 'lh', 'lbu', 'lhu', 'lwl', 'lwr', 'll'):
            return f'{mnem} {format_reg(rt)}, {format_signed(imm)}({format_reg(rs)})'
        elif mnem in ('sw', 'sb', 'sh', 'swl', 'swr', 'sc'):
            return f'{mnem} {format_reg(rt)}, {format_signed(imm)}({format_reg(rs)})'
        elif mnem in ('beq', 'bne'):
            offset = sign_extend(imm, 16)
            return f'{mnem} {format_reg(rs)}, {format_reg(rt)}, {offset}'
        elif mnem in ('bgtz', 'blez', 'bgez', 'bltz', 'bgezal', 'bltzal', 'teqi', 'tgei', 'tgeiu', 'tlti', 'tltiu', 'tnei'):
            offset = sign_extend(imm, 16)
            return f'{mnem} {format_reg(rs)}, {offset}'
        elif mnem in ('addi', 'addiu', 'andi', 'ori', 'xori', 'slti', 'sltiu'):
            return f'{mnem} {format_reg(rt)}, {format_reg(rs)}, {format_signed(imm)}'
        elif mnem == 'lui':
            return f'{mnem} {format_reg(rt)}, 0x{imm:04x}'
        return f'i_type_unk 0x{inst:08x}'

    return f'unknown 0x{inst:08x}'


# ============================================================
# 汇编 -> 机器码
# ============================================================
def parse_asm_line(line):
    """解析单行汇编指令，返回 32 位机器码"""
    line = line.strip()
    if not line or line.startswith('#') or line.startswith('//'):
        return None

    # 移除注释
    if '#' in line:
        line = line[:line.index('#')].strip()
    if '//' in line:
        line = line[:line.index('//')].strip()

    # 移除标签（xxx:）
    if ':' in line and '(' not in line.split(':')[0]:
        parts = line.split(':', 1)
        if len(parts) == 2:
            line = parts[1].strip()

    if not line:
        return None

    # 分割操作数和参数
    # 处理 lw $t0, 0($t1) 这种格式
    if '(' in line:
        # 分离助记符和参数
        parts = line.split(None, 1)
        mnem = parts[0].lower()
        rest = parts[1] if len(parts) > 1 else ''
        # 解析 offset(base)
        comma_idx = rest.find(',')
        if comma_idx != -1:
            rt_str = rest[:comma_idx].strip()
            mem_str = rest[comma_idx + 1:].strip()
            # 解析 offset(base)
            paren_idx = mem_str.find('(')
            if paren_idx != -1:
                offset_str = mem_str[:paren_idx].strip()
                base_str = mem_str[paren_idx + 1:mem_str.rfind(')')].strip()
                rt = parse_reg(rt_str)
                base = parse_reg(base_str)
                offset = parse_imm(offset_str) if offset_str else 0
                return encode_load_store(mnem, rt, base, offset)
    else:
        parts = line.split(None, 1)
        mnem = parts[0].lower()
        rest = parts[1] if len(parts) > 1 else ''
        # 移除多余空格和逗号周围空格
        rest = rest.strip()

        return encode_instruction(mnem, rest)


def encode_load_store(mnem, rt, base, offset):
    opcodes = {
        'lw': 0b100011, 'sw': 0b101011, 'lb': 0b100000, 'sb': 0b101000,
        'lh': 0b100001, 'sh': 0b101001, 'lbu': 0b100100, 'lhu': 0b100101,
        'lwl': 0b100010, 'lwr': 0b100110, 'swl': 0b101010, 'swr': 0b101110,
        'll': 0b110000, 'sc': 0b111000,
    }
    if mnem not in opcodes:
        raise ValueError(f'未知指令: {mnem}')
    op = opcodes[mnem]
    return (op << 26) | (base << 21) | (rt << 16) | (offset & 0xFFFF)


def encode_instruction(mnem, rest):
    # 解析参数
    args = [a.strip() for a in rest.split(',') if a.strip()]

    # 无参数指令
    no_arg_instr = {
        'syscall': (0b000000 << 6) | 0b001100,
        'break': (0b000000 << 6) | 0b001101,
        'eret': 0b010000 << 26 | 0b011000,
    }
    if mnem in no_arg_instr and not rest:
        return no_arg_instr[mnem]

    # CP0 指令
    if mnem == 'mfc0':
        if len(args) >= 1:
            rt = parse_reg(args[0])
            return (0b010000 << 26) | (0b00000 << 21) | (rt << 16)
        raise ValueError('mfc0 需要 rt 参数')
    if mnem == 'mtc0':
        if len(args) >= 1:
            rt = parse_reg(args[0])
            return (0b010000 << 26) | (0b00100 << 21) | (rt << 16)
        raise ValueError('mtc0 需要 rt 参数')

    # R 型 - 三个寄存器: rd, rs, rt 或 rd, rt, shamt
    r_type_3 = {
        'add': 0b100000, 'addu': 0b100001, 'sub': 0b100010, 'subu': 0b100011,
        'and': 0b100100, 'or': 0b100101, 'xor': 0b100110, 'nor': 0b100111,
        'slt': 0b101010, 'sltu': 0b101011, 'mul': 0b000010,
    }
    if mnem in r_type_3 and len(args) == 3:
        rd = parse_reg(args[0])
        rs = parse_reg(args[1])
        rt = parse_reg(args[2])
        return (0 << 26) | (rs << 21) | (rt << 16) | (rd << 11) | r_type_3[mnem]

    # R 型 - 两个寄存器 + shamt: rd, rt, shamt
    r_type_shamt = {
        'sll': 0b000000, 'srl': 0b000010, 'sra': 0b000011,
    }
    if mnem in r_type_shamt and len(args) == 3:
        rd = parse_reg(args[0])
        rt = parse_reg(args[1])
        shamt = int(args[2])
        return (0 << 26) | (0 << 21) | (rt << 16) | (rd << 11) | (shamt << 6) | r_type_shamt[mnem]

    # R 型 - 两个寄存器: rs, rt
    r_type_2 = {
        'div': 0b011010, 'divu': 0b011011,
        'mult': 0b011000, 'multu': 0b011001,
        'madd': 0b000000, 'maddu': 0b000001,
        'msub': 0b000100, 'msubu': 0b000101,
    }
    if mnem in r_type_2 and len(args) == 2:
        rs = parse_reg(args[0])
        rt = parse_reg(args[1])
        if mnem in ('madd', 'maddu', 'msub', 'msubu'):
            return (0b011100 << 26) | (rs << 21) | (rt << 16) | r_type_2[mnem]
        return (0 << 26) | (rs << 21) | (rt << 16) | r_type_2[mnem]

    # R 型 - 两个寄存器: rd, rs
    r_type_rd_rs = {
        'clz': 0b100000, 'clo': 0b100001,
    }
    if mnem in r_type_rd_rs and len(args) == 2:
        rd = parse_reg(args[0])
        rs = parse_reg(args[1])
        return (0b011100 << 26) | (rs << 21) | (rd << 11) | r_type_rd_rs[mnem]

    # R 型 - 两个寄存器: rd, rs, rt (movn, movz)
    r_type_3_mov = {
        'movn': 0b001011, 'movz': 0b001010,
    }
    if mnem in r_type_3_mov and len(args) == 3:
        rd = parse_reg(args[0])
        rs = parse_reg(args[1])
        rt = parse_reg(args[2])
        return (0 << 26) | (rs << 21) | (rt << 16) | (rd << 11) | r_type_3_mov[mnem]

    # R 型 - 两个寄存器: rd, rt, rs (sllv, srlv, srav)
    r_type_3_v = {
        'sllv': 0b000100, 'srlv': 0b000110, 'srav': 0b000111,
    }
    if mnem in r_type_3_v and len(args) == 3:
        rd = parse_reg(args[0])
        rt = parse_reg(args[1])
        rs = parse_reg(args[2])
        return (0 << 26) | (rs << 21) | (rt << 16) | (rd << 11) | r_type_3_v[mnem]

    # R 型 - trap 指令: rs, rt
    r_type_trap = {
        'teq': 0b110100, 'tge': 0b110000, 'tgeu': 0b110001,
        'tlt': 0b110010, 'tltu': 0b110011, 'tne': 0b110110,
    }
    if mnem in r_type_trap and len(args) == 2:
        rs = parse_reg(args[0])
        rt = parse_reg(args[1])
        return (0 << 26) | (rs << 21) | (rt << 16) | r_type_trap[mnem]

    # R 型 - 单寄存器
    if mnem == 'jr' and len(args) == 1:
        rs = parse_reg(args[0])
        return (0 << 26) | (rs << 21) | 0b001000

    if mnem == 'jalr':
        if len(args) == 1:
            rs = parse_reg(args[0])
            return (0 << 26) | (rs << 21) | (31 << 11) | 0b001001
        elif len(args) == 2:
            rd = parse_reg(args[0])
            rs = parse_reg(args[1])
            return (0 << 26) | (rs << 21) | (rd << 11) | 0b001001

    if mnem in ('mfhi', 'mflo') and len(args) == 1:
        rd = parse_reg(args[0])
        funct = 0b010000 if mnem == 'mfhi' else 0b010010
        return (0 << 26) | (rd << 11) | funct

    if mnem in ('mthi', 'mtlo') and len(args) == 1:
        rs = parse_reg(args[0])
        funct = 0b010001 if mnem == 'mthi' else 0b010011
        return (0 << 26) | (rs << 21) | funct

    # I 型 - 立即数指令: rt, rs, imm
    i_type_imm = {
        'addi': 0b001000, 'addiu': 0b001001,
        'andi': 0b001100, 'ori': 0b001101, 'xori': 0b001110,
        'slti': 0b001010, 'sltiu': 0b001011,
    }
    if mnem in i_type_imm and len(args) == 3:
        rt = parse_reg(args[0])
        rs = parse_reg(args[1])
        imm = parse_imm(args[2])
        return (i_type_imm[mnem] << 26) | (rs << 21) | (rt << 16) | (imm & 0xFFFF)

    # I 型 - 分支指令: rs, rt/无, offset
    if mnem in ('beq', 'bne') and len(args) == 3:
        rs = parse_reg(args[0])
        rt = parse_reg(args[1])
        offset = parse_imm(args[2])
        return ((0b000100 if mnem == 'beq' else 0b000101) << 26) | (rs << 21) | (rt << 16) | (offset & 0xFFFF)

    if mnem in ('bgtz', 'blez') and len(args) == 2:
        rs = parse_reg(args[0])
        offset = parse_imm(args[1])
        return ((0b000111 if mnem == 'bgtz' else 0b000110) << 26) | (rs << 21) | (offset & 0xFFFF)

    # REGIMM 分支: rs, offset
    regimm_instr = {
        'bltz': 0b00000, 'bltzal': 0b10000,
        'bgez': 0b00001, 'bgezal': 0b10001,
    }
    if mnem in regimm_instr and len(args) == 2:
        rs = parse_reg(args[0])
        offset = parse_imm(args[1])
        return (0b000001 << 26) | (rs << 21) | (regimm_instr[mnem] << 16) | (offset & 0xFFFF)

    # REGIMM trap: rs, imm
    regimm_trap = {
        'teqi': 0b01100, 'tgei': 0b01000, 'tgeiu': 0b01001,
        'tlti': 0b01010, 'tltiu': 0b01011, 'tnei': 0b01110,
    }
    if mnem in regimm_trap and len(args) == 2:
        rs = parse_reg(args[0])
        imm = parse_imm(args[1])
        return (0b000001 << 26) | (rs << 21) | (regimm_trap[mnem] << 16) | (imm & 0xFFFF)

    # I 型 - lui
    if mnem == 'lui' and len(args) == 2:
        rt = parse_reg(args[0])
        imm = parse_imm(args[1])
        return (0b001111 << 26) | (rt << 16) | (imm & 0xFFFF)

    # J 型
    if mnem in ('j', 'jal') and len(args) == 1:
        target_str = args[0].strip().lower()
        if target_str.startswith('0x'):
            target = int(target_str, 16) & 0x3FFFFFF
        else:
            target = int(target_str) & 0x3FFFFFF
        return ((0b000010 if mnem == 'j' else 0b000011) << 26) | target

    raise ValueError(f'无法解析指令: {mnem} {rest}')


# ============================================================
# 批量转换
# ============================================================
def batch_hex_to_asm(text):
    """批量十六进制转汇编"""
    lines = text.strip().split('\n')
    result = []
    for line in lines:
        line = line.strip()
        if not line or line.startswith('#') or line.startswith('//'):
            result.append(line)
            continue
        try:
            asm = hex_to_asm(line)
            result.append(f'{line:<14} -> {asm}')
        except Exception as e:
            result.append(f'{line:<14} -> 错误: {e}')
    return '\n'.join(result)


def batch_asm_to_hex(text):
    """批量汇编转十六进制"""
    lines = text.strip().split('\n')
    result = []
    for line in lines:
        line = line.strip()
        if not line or line.startswith('#') or line.startswith('//'):
            result.append(line)
            continue
        try:
            code = parse_asm_line(line)
            if code is not None:
                result.append(f'{line:<30} -> 0x{code:08x}')
            else:
                result.append(line)
        except Exception as e:
            result.append(f'{line:<30} -> 错误: {e}')
    return '\n'.join(result)


# ============================================================
# GUI 界面
# ============================================================
class MIPSConverterApp:
    def __init__(self, root):
        self.root = root
        self.root.title('MIPS 机器码 <-> 汇编指令转换器 (89 条指令)')
        self.root.geometry('900x700')
        self.root.resizable(True, True)

        # 设置样式
        style = ttk.Style()
        style.theme_use('clam')

        self._create_widgets()

    def _create_widgets(self):
        # 标题
        title_frame = ttk.Frame(self.root, padding='10')
        title_frame.pack(fill='x')
        title_label = ttk.Label(
            title_frame,
            text='MIPS 机器码 <-> 汇编指令转换器',
            font=('Microsoft YaHei', 16, 'bold')
        )
        title_label.pack()
        subtitle_label = ttk.Label(
            title_frame,
            text='支持 89 条 MIPS 指令 • 基于 Pipeline CPU 设计',
            font=('Microsoft YaHei', 9)
        )
        subtitle_label.pack()

        # 寄存器显示格式切换
        reg_format_frame = ttk.Frame(self.root, padding='5')
        reg_format_frame.pack(fill='x', padx=10, pady=2)

        reg_format_label = ttk.Label(reg_format_frame, text='寄存器显示格式:', font=('Microsoft YaHei', 9))
        reg_format_label.pack(side='left', padx=5)

        self.reg_format_var = tk.StringVar(value='name' if USE_REGISTER_NAME else 'number')
        
        def toggle_reg_format():
            global USE_REGISTER_NAME
            if self.reg_format_var.get() == 'name':
                USE_REGISTER_NAME = True
            else:
                USE_REGISTER_NAME = False
            # 如果有显示结果，刷新显示
            if hasattr(self, 'single_result') and self.single_result.cget('text'):
                self.convert_single()

        ttk.Radiobutton(
            reg_format_frame, 
            text='寄存器名 ($t0, $s1)', 
            variable=self.reg_format_var, 
            value='name',
            command=toggle_reg_format
        ).pack(side='left', padx=10)
        
        ttk.Radiobutton(
            reg_format_frame, 
            text='数字 ($8, $17)', 
            variable=self.reg_format_var, 
            value='number',
            command=toggle_reg_format
        ).pack(side='left', padx=10)

        # 单行转换区域
        single_frame = ttk.LabelFrame(self.root, text='单行转换', padding='10')
        single_frame.pack(fill='x', padx=10, pady=5)

        ttk.Label(single_frame, text='输入:', font=('Microsoft YaHei', 10)).pack(anchor='w')
        self.single_input = ttk.Entry(single_frame, font=('Consolas', 11), width=60)
        self.single_input.pack(fill='x', pady=2)
        self.single_input.bind('<Return>', lambda e: self.convert_single())

        btn_frame = ttk.Frame(single_frame)
        btn_frame.pack(fill='x', pady=5)

        ttk.Button(btn_frame, text='转换', command=self.convert_single).pack(side='left', padx=2)
        ttk.Button(btn_frame, text='清空', command=lambda: [self.single_input.delete(0, 'end'), self.single_result.config(text='')]).pack(side='left', padx=2)

        ttk.Label(single_frame, text='结果:', font=('Microsoft YaHei', 10)).pack(anchor='w')
        self.single_result = ttk.Label(single_frame, text='', font=('Consolas', 11), foreground='#0066cc', wraplength=850, justify='left')
        self.single_result.pack(fill='x', pady=2)

        # 批量转换区域
        batch_frame = ttk.LabelFrame(self.root, text='批量转换', padding='10')
        batch_frame.pack(fill='both', expand=True, padx=10, pady=5)

        # 输入输出文本框
        input_frame = ttk.Frame(batch_frame)
        input_frame.pack(side='left', fill='both', expand=True, padx=(0, 5))

        ttk.Label(input_frame, text='输入（每行一条）:', font=('Microsoft YaHei', 9)).pack(anchor='w')
        self.batch_input = scrolledtext.ScrolledText(input_frame, height=12, font=('Consolas', 10), wrap='none')
        self.batch_input.pack(fill='both', expand=True, pady=2)

        output_frame = ttk.Frame(batch_frame)
        output_frame.pack(side='right', fill='both', expand=True, padx=(5, 0))

        ttk.Label(output_frame, text='转换结果:', font=('Microsoft YaHei', 9)).pack(anchor='w')
        self.batch_output = scrolledtext.ScrolledText(output_frame, height=12, font=('Consolas', 10), wrap='none', state='disabled')
        self.batch_output.pack(fill='both', expand=True, pady=2)

        # 批量转换按钮
        batch_btn_frame = ttk.Frame(batch_frame)
        batch_btn_frame.pack(fill='x', pady=5)

        ttk.Button(batch_btn_frame, text='十六进制 -> 汇编', command=self.batch_hex_to_asm).pack(side='left', padx=2)
        ttk.Button(batch_btn_frame, text='汇编 -> 十六进制', command=self.batch_asm_to_hex).pack(side='left', padx=2)
        ttk.Button(batch_btn_frame, text='清空', command=self.clear_batch).pack(side='left', padx=2)
        ttk.Button(batch_btn_frame, text='复制结果', command=self.copy_result).pack(side='left', padx=2)

        # 指令集参考
        ref_frame = ttk.LabelFrame(self.root, text='支持的指令集 (89 条)', padding='10')
        ref_frame.pack(fill='x', padx=10, pady=5)

        ref_text = (
            'R型: add, addu, sub, subu, and, or, xor, nor, slt, sltu, '
            'sll, srl, sra, sllv, srlv, srav, jr, jalr, '
            'mfhi, mthi, mflo, mtlo, syscall, break, eret, '
            'div, divu, mult, multu, teq, tge, tgeu, tlt, tltu, tne, '
            'movn, movz, clz, clo, mul, madd, maddu, msub, msubu\n'
            'I型: addi, addiu, andi, ori, xori, slti, sltiu, lui, '
            'lw, sw, lb, sb, lh, sh, lbu, lhu, '
            'beq, bne, bgtz, blez, '
            'lwl, lwr, swl, swr, ll, sc\n'
            'REGIMM: bltz, bltzal, bgez, bgezal, teqi, tgei, tgeiu, tlti, tltiu, tnei\n'
            'J型: j, jal\n'
            'CP0: mfc0, mtc0, eret'
        )
        ref_label = ttk.Label(ref_frame, text=ref_text, font=('Microsoft YaHei', 8), wraplength=850, justify='left')
        ref_label.pack(anchor='w')

    def convert_single(self):
        text = self.single_input.get().strip()
        if not text:
            self.single_result.config(text='')
            return

        try:
            # 尝试判断输入类型
            clean_text = text.lower().removeprefix('0x').strip()
            if all(c in '0123456789abcdef' for c in clean_text) and len(clean_text) <= 8:
                # 十六进制 -> 汇编
                asm = hex_to_asm(text)
                self.single_result.config(text=f'{text:<14} -> {asm}')
            else:
                # 汇编 -> 十六进制
                code = parse_asm_line(text)
                if code is not None:
                    self.single_result.config(text=f'{text:<30} -> 0x{code:08x}')
                else:
                    self.single_result.config(text='无法解析该指令')
        except Exception as e:
            self.single_result.config(text=f'错误: {e}')

    def batch_hex_to_asm(self):
        text = self.batch_input.get('1.0', 'end').strip()
        if not text:
            return
        result = batch_hex_to_asm(text)
        self.batch_output.config(state='normal')
        self.batch_output.delete('1.0', 'end')
        self.batch_output.insert('1.0', result)
        self.batch_output.config(state='disabled')

    def batch_asm_to_hex(self):
        text = self.batch_input.get('1.0', 'end').strip()
        if not text:
            return
        result = batch_asm_to_hex(text)
        self.batch_output.config(state='normal')
        self.batch_output.delete('1.0', 'end')
        self.batch_output.insert('1.0', result)
        self.batch_output.config(state='disabled')

    def clear_batch(self):
        self.batch_input.delete('1.0', 'end')
        self.batch_output.config(state='normal')
        self.batch_output.delete('1.0', 'end')
        self.batch_output.config(state='disabled')

    def copy_result(self):
        result = self.batch_output.get('1.0', 'end').strip()
        if result:
            self.root.clipboard_clear()
            self.root.clipboard_append(result)
            self.root.update()


if __name__ == '__main__':
    root = tk.Tk()
    app = MIPSConverterApp(root)
    root.mainloop()
