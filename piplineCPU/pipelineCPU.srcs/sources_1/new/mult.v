`timescale 1ns/1ps

// ============================================================
// 模块1：无符号乘法�? (multu)
// 输入�?32位无符号�? a, b
// 输出�?64位乘�? prod
// 内部采用加法树结构，纯组合�?�辑
// ============================================================
module multu (
    input      [31:0] a,
    input      [31:0] b,
    output     [63:0] z
);
    // 生成 b 的每�?位对应的部分�?
    wire [63:0] stored0  = b[0]  ? {32'b0, a}            : 64'b0;
    wire [63:0] stored1  = b[1]  ? {31'b0, a, 1'b0}       : 64'b0;
    wire [63:0] stored2  = b[2]  ? {30'b0, a, 2'b0}       : 64'b0;
    wire [63:0] stored3  = b[3]  ? {29'b0, a, 3'b0}       : 64'b0;
    wire [63:0] stored4  = b[4]  ? {28'b0, a, 4'b0}       : 64'b0;
    wire [63:0] stored5  = b[5]  ? {27'b0, a, 5'b0}       : 64'b0;
    wire [63:0] stored6  = b[6]  ? {26'b0, a, 6'b0}       : 64'b0;
    wire [63:0] stored7  = b[7]  ? {25'b0, a, 7'b0}       : 64'b0;
    wire [63:0] stored8  = b[8]  ? {24'b0, a, 8'b0}       : 64'b0;
    wire [63:0] stored9  = b[9]  ? {23'b0, a, 9'b0}       : 64'b0;
    wire [63:0] stored10 = b[10] ? {22'b0, a, 10'b0}      : 64'b0;
    wire [63:0] stored11 = b[11] ? {21'b0, a, 11'b0}      : 64'b0;
    wire [63:0] stored12 = b[12] ? {20'b0, a, 12'b0}      : 64'b0;
    wire [63:0] stored13 = b[13] ? {19'b0, a, 13'b0}      : 64'b0;
    wire [63:0] stored14 = b[14] ? {18'b0, a, 14'b0}      : 64'b0;
    wire [63:0] stored15 = b[15] ? {17'b0, a, 15'b0}      : 64'b0;
    wire [63:0] stored16 = b[16] ? {16'b0, a, 16'b0}      : 64'b0;
    wire [63:0] stored17 = b[17] ? {15'b0, a, 17'b0}      : 64'b0;
    wire [63:0] stored18 = b[18] ? {14'b0, a, 18'b0}      : 64'b0;
    wire [63:0] stored19 = b[19] ? {13'b0, a, 19'b0}      : 64'b0;
    wire [63:0] stored20 = b[20] ? {12'b0, a, 20'b0}      : 64'b0;
    wire [63:0] stored21 = b[21] ? {11'b0, a, 21'b0}      : 64'b0;
    wire [63:0] stored22 = b[22] ? {10'b0, a, 22'b0}      : 64'b0;
    wire [63:0] stored23 = b[23] ? {9'b0, a, 23'b0}       : 64'b0;
    wire [63:0] stored24 = b[24] ? {8'b0, a, 24'b0}       : 64'b0;
    wire [63:0] stored25 = b[25] ? {7'b0, a, 25'b0}       : 64'b0;
    wire [63:0] stored26 = b[26] ? {6'b0, a, 26'b0}       : 64'b0;
    wire [63:0] stored27 = b[27] ? {5'b0, a, 27'b0}       : 64'b0;
    wire [63:0] stored28 = b[28] ? {4'b0, a, 28'b0}       : 64'b0;
    wire [63:0] stored29 = b[29] ? {3'b0, a, 29'b0}       : 64'b0;
    wire [63:0] stored30 = b[30] ? {2'b0, a, 30'b0}       : 64'b0;
    wire [63:0] stored31 = b[31] ? {1'b0, a, 31'b0}       : 64'b0;

    // 加法�?
    wire [63:0] add0_1   = stored0  + stored1;
    wire [63:0] add2_3   = stored2  + stored3;
    wire [63:0] add4_5   = stored4  + stored5;
    wire [63:0] add6_7   = stored6  + stored7;
    wire [63:0] add8_9   = stored8  + stored9;
    wire [63:0] add10_11 = stored10 + stored11;
    wire [63:0] add12_13 = stored12 + stored13;
    wire [63:0] add14_15 = stored14 + stored15;
    wire [63:0] add16_17 = stored16 + stored17;
    wire [63:0] add18_19 = stored18 + stored19;
    wire [63:0] add20_21 = stored20 + stored21;
    wire [63:0] add22_23 = stored22 + stored23;
    wire [63:0] add24_25 = stored24 + stored25;
    wire [63:0] add26_27 = stored26 + stored27;
    wire [63:0] add28_29 = stored28 + stored29;
    wire [63:0] add30_31 = stored30 + stored31;

    wire [63:0] add0t1_2t3    = add0_1   + add2_3;
    wire [63:0] add4t5_6t7    = add4_5   + add6_7;
    wire [63:0] add8t9_10t11  = add8_9   + add10_11;
    wire [63:0] add12t13_14t15= add12_13 + add14_15;
    wire [63:0] add16t17_18t19= add16_17 + add18_19;
    wire [63:0] add20t21_22t23= add20_21 + add22_23;
    wire [63:0] add24t25_26t27= add24_25 + add26_27;
    wire [63:0] add28t29_30t31= add28_29 + add30_31;

    wire [63:0] add0t3_4t7    = add0t1_2t3    + add4t5_6t7;
    wire [63:0] add8t11_12t15 = add8t9_10t11  + add12t13_14t15;
    wire [63:0] add16t19_20t23= add16t17_18t19+ add20t21_22t23;
    wire [63:0] add24t27_28t31= add24t25_26t27+ add28t29_30t31;

    wire [63:0] add0t7_8t15   = add0t3_4t7   + add8t11_12t15;
    wire [63:0] add16t23_24t31= add16t19_20t23+ add24t27_28t31;

    assign z = add0t7_8t15 + add16t23_24t31;
endmodule

// ============================================================
// 模块2：有符号乘法�? (mult)
// 输入�?32位有符号�? a, b
// 输出�?64位有符号乘积 prod
// 内部调用 multu 并处理符�?
// ============================================================
module mult (
    input [31:0] s_a,
    input [31:0] s_b,
    output [63:0] s_z
);
    wire        sign_a = s_a[31];
    wire        sign_b = s_b[31];
    wire [31:0] abs_a  = sign_a ? -s_a : s_a;
    wire [31:0] abs_b  = sign_b ? -s_b : s_b;
    wire [63:0] abs_prod;
    multu u_multu (
        .a   (abs_a),
        .b   (abs_b),
        .z   (abs_prod)
    );
    assign s_z = (sign_a ^ sign_b) ? -abs_prod : abs_prod;
endmodule

