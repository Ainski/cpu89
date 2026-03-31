`timescale 1ns/1ps
// module div(
//     input [31:0]s_dividend, //被除数
//     input [31:0]s_divisor,  //除数
//     output [31:0]s_q,       //商
//     output [31:0]s_r        //余数
// );
//     wire [31:0]u_dividend;
//     wire [31:0]u_divisor;
//     wire [31:0]u_q;
//     wire [31:0]u_r;
//     complement32 c_dividend(s_dividend[31],s_dividend,u_dividend);
//     complement32 c_divisor(s_divisor[31],s_divisor,u_divisor);
//     divu divison_unit(u_dividend,u_divisor,u_q,u_r);
//     wire s_same;
//     assign s_same = ~(s_dividend[31] ^ s_divisor[31]);
//     complement32 c_q(~s_same,u_q,s_q);
//     complement32 c_r(s_dividend[31],u_r,s_r);
// endmodule

// module divu(
//     input [31:0]dividend,   //被除数
//     input [31:0]divisor,    //除数
//     output [31:0]q,         //商
//     output [31:0]r          //余数
// );
//     wire [31:0] quotient_o;
//     wire [31:0] remainder_o;
//     DIV div_unit(
//         .data_valid_i(1'b1),
//         .dividend_i(dividend),
//         .divisor_i(divisor),
//         .quotient_o(quotient_o),
//         .remainder_o(remainder_o)
//     );
//     assign q = 
// endmodule
// //CODE GENERATOR WITH PYTHON
// //print("wire [63:0] answer0;")
// //for i in range(1,33):
// //    print("wire [63:0] answer"+str(i)+";")
// //    print("wire [63:0] next1_answer"+str(i)+";")
// //    print("wire [63:0] next2_answer"+str(i)+";")
// //print("assign answer0 = {32'h00000000,dividend};")
// //for i in range(1,33):
// //    print("assign next1_answer"+str(i)+" = {answer"+str(i-1)+"[62:0],1'b0};")
// //    print("assign next2_answer"+str(i)+" = next1_answer"+str(i)+" - {divisor[31:0],32'h00000000} + 1;")
// //    print("assign answer"+str(i)+" = next1_answer"+str(i)+"[63:32] >= divisor? next2_answer"+str(i)+":next1_answer"+str(i)+";")
// //print("assign q = answer32[31:0];")
// //print("assign r = answer32[63:32];")



// ============================================================
// 底层无符号除法器（参数化，恢复余数法）
// 输入：dividend, divisor (无符号)
// 输出：quotient, remainder, valid（除数非零时有效）
// ============================================================
module unsigned_divider #(
    parameter WIDTH = 32
) (
    input                    data_valid_i,
    input      [WIDTH-1:0]   dividend_i,
    input      [WIDTH-1:0]   divisor_i,
    output                   qr_valid_o,
    output     [WIDTH-1:0]   quotient_o,
    output     [WIDTH-1:0]   remainder_o
);
    wire [WIDTH-1:0] numwire [WIDTH-1:0];
    wire [WIDTH  :0] numtemp [WIDTH-1:0];
    wire [WIDTH-1:0] subwire [WIDTH-1:0];
    wire [WIDTH-1:0] ge;
    genvar i;

    assign numwire[WIDTH-1] = {{WIDTH-1{1'b0}}, dividend_i[WIDTH-1]};
    assign numtemp[WIDTH-1] = numwire[WIDTH-1] - divisor_i;
    assign ge[WIDTH-1]       = ~numtemp[WIDTH-1][WIDTH];
    assign subwire[WIDTH-1]  = ge[WIDTH-1] ? numtemp[WIDTH-1] : numtemp[WIDTH-1] + divisor_i;

    generate
        for (i = WIDTH-2; i >= 0; i = i-1) begin : shift_and_calculate
            assign numwire[i] = {subwire[i+1][WIDTH-2:0], dividend_i[i]};
            assign numtemp[i] = numwire[i] - divisor_i;
            assign ge[i]      = ~numtemp[i][WIDTH];
            assign subwire[i] = ge[i] ? numtemp[i] : numtemp[i] + divisor_i;
        end
    endgenerate

    assign qr_valid_o  = data_valid_i && (|divisor_i);
    assign quotient_o  = qr_valid_o ? ge : {WIDTH{1'b0}};
    assign remainder_o = qr_valid_o ? subwire[0] : {WIDTH{1'b0}};
endmodule

// ============================================================
// 模块3：无符号除法器 (divu)
// 输入：32位无符号数 dividend, divisor
// 输出：32位商 quotient，余数 remainder，有效标志 valid（除数非零）
// ============================================================
module divu (
    input      [31:0] dividend,
    input      [31:0] divisor,
    output     [31:0] q,
    output     [31:0] r,
    output            valid
);
    unsigned_divider #(.WIDTH(32)) u_div (
        .data_valid_i(1'b1),
        .dividend_i  (dividend),
        .divisor_i   (divisor),
        .qr_valid_o  (valid),
        .quotient_o  (q),
        .remainder_o (r)
    );
endmodule

// ============================================================
// 模块4：有符号除法器 (div)
// 输入：32位有符号数 dividend, divisor
// 输出：32位有符号商 quotient，余数 remainder（余数符号与被除数相同）
//       valid 标志（除数非零时有效）
// 处理边界：-2^31 / -1 产生商 2^31（0x80000000），余数 0
// ============================================================
module div (
    input  signed [31:0] s_dividend,
    input  signed [31:0] s_divisor,
    output signed [31:0] s_q,
    output signed [31:0] s_r,
    output               valid
);
    wire        sign_dividend = s_dividend[31];
    wire        sign_divisor  = s_divisor[31];
    wire        sign_quotient = sign_dividend ^ sign_divisor;
    wire [31:0] abs_dividend  = sign_dividend ? -s_dividend : s_dividend;
    wire [31:0] abs_divisor   = sign_divisor  ? -s_divisor  : s_divisor;

    // 使用 33 位无符号除法防止绝对值 2^31 溢出
    wire [32:0] ext_dividend = {1'b0, abs_dividend};
    wire [32:0] ext_divisor  = {1'b0, abs_divisor};
    wire [32:0] ext_quotient, ext_remainder;
    wire        ext_valid;

    unsigned_divider #(.WIDTH(33)) u_div33 (
        .data_valid_i(1'b1),
        .dividend_i  (ext_dividend),
        .divisor_i   (ext_divisor),
        .qr_valid_o  (ext_valid),
        .quotient_o  (ext_quotient),
        .remainder_o (ext_remainder)
    );

    assign valid   = ext_valid;
    // 商和余数取低32位，并根据原始符号调整
    assign s_q = sign_quotient ? -ext_quotient[31:0] : ext_quotient[31:0];
    assign s_r = sign_dividend ? -ext_remainder[31:0] : ext_remainder[31:0];
endmodule