`timescale 1ns / 1ps
// module regfile(
//     input clk,              //�½�����Ч
//     input rst,              //�ߵ�ƽ��Ч
//     input we,
//     input [4:0] raddr1,
//     input [4:0] raddr2,
//     input [4:0] waddr,
//     input [31:0] wdata,
//     output [31:0] rdata1,
//     output [31:0] rdata2
// );
//     wire [31:0] w;
//     wire [31:0] array_reg [31:0];
//     assign w=32'b00000000000000000000000000000001<<waddr;
//     assign array_reg[0] = 0;
//     pcreg r1 (clk,rst,we&w[1],wdata,array_reg[1]);
//     pcreg r2 (clk,rst,we&w[2],wdata,array_reg[2]);
//     pcreg r3 (clk,rst,we&w[3],wdata,array_reg[3]);
//     pcreg r4 (clk,rst,we&w[4],wdata,array_reg[4]);
//     pcreg r5 (clk,rst,we&w[5],wdata,array_reg[5]);
//     pcreg r6 (clk,rst,we&w[6],wdata,array_reg[6]);
//     pcreg r7 (clk,rst,we&w[7],wdata,array_reg[7]);
//     pcreg r8 (clk,rst,we&w[8],wdata,array_reg[8]);
//     pcreg r9 (clk,rst,we&w[9],wdata,array_reg[9]);
//     pcreg r10 (clk,rst,we&w[10],wdata,array_reg[10]);
//     pcreg r11 (clk,rst,we&w[11],wdata,array_reg[11]);
//     pcreg r12 (clk,rst,we&w[12],wdata,array_reg[12]);
//     pcreg r13 (clk,rst,we&w[13],wdata,array_reg[13]);
//     pcreg r14 (clk,rst,we&w[14],wdata,array_reg[14]);
//     pcreg r15 (clk,rst,we&w[15],wdata,array_reg[15]);
//     pcreg r16 (clk,rst,we&w[16],wdata,array_reg[16]);
//     pcreg r17 (clk,rst,we&w[17],wdata,array_reg[17]);
//     pcreg r18 (clk,rst,we&w[18],wdata,array_reg[18]);
//     pcreg r19 (clk,rst,we&w[19],wdata,array_reg[19]);
//     pcreg r20 (clk,rst,we&w[20],wdata,array_reg[20]);
//     pcreg r21 (clk,rst,we&w[21],wdata,array_reg[21]);
//     pcreg r22 (clk,rst,we&w[22],wdata,array_reg[22]);
//     pcreg r23 (clk,rst,we&w[23],wdata,array_reg[23]);
//     pcreg r24 (clk,rst,we&w[24],wdata,array_reg[24]);
//     pcreg r25 (clk,rst,we&w[25],wdata,array_reg[25]);
//     pcreg r26 (clk,rst,we&w[26],wdata,array_reg[26]);
//     pcreg r27 (clk,rst,we&w[27],wdata,array_reg[27]);
//     pcreg r28 (clk,rst,we&w[28],wdata,array_reg[28]);
//     pcreg r29 (clk,rst,we&w[29],wdata,array_reg[29]);
//     pcreg r30 (clk,rst,we&w[30],wdata,array_reg[30]);
//     pcreg r31 (clk,rst,we&w[31],wdata,array_reg[31]);
//     assign rdata1=array_reg[raddr1];
//     assign rdata2=array_reg[raddr2];
// endmodule


`timescale 1ns / 1ps
module regfile(
    input clk,
    input rst,
    input we,
    input [31:0] wdata,
    input [4:0] waddr,
    input [4:0]raddr1,
    input [4:0]raddr2,
    output [31:0] rdata2,
    output [31:0] rd,
    output [31:0] rdata1,
    output [31:0] regfile0,
    output [31:0] regfile1,
    output [31:0] regfile2,
    output [31:0] regfile3,
    output [31:0] regfile4,
    output [31:0] regfile5,
    output [31:0] regfile6,
    output [31:0] regfile7,
    output [31:0] regfile8,
    output [31:0] regfile9,
    output [31:0] regfile10,
    output [31:0] regfile11,
    output [31:0] regfile12,
    output [31:0] regfile13,
    output [31:0] regfile14,
    output [31:0] regfile15,
    output [31:0] regfile16,
    output [31:0] regfile17,
    output [31:0] regfile18,
    output [31:0] regfile19,
    output [31:0] regfile20,
    output [31:0] regfile21,
    output [31:0] regfile22,
    output [31:0] regfile23,
    output [31:0] regfile24,
    output [31:0] regfile25,
    output [31:0] regfile26,
    output [31:0] regfile27,
    output [31:0] regfile28,
    output [31:0] regfile29,
    output [31:0] regfile30,
    output [31:0] regfile31
);

    reg [31:0] array_reg[0:31];
    assign regfile0 = array_reg[0];
    assign regfile1 = array_reg[1];
    assign regfile2 = array_reg[2];
    assign regfile3 = array_reg[3];
    assign regfile4 = array_reg[4];
    assign regfile5 = array_reg[5];
    assign regfile6 = array_reg[6];
    assign regfile7 = array_reg[7];
    assign regfile8 = array_reg[8];
    assign regfile9 = array_reg[9];
    assign regfile10 = array_reg[10];
    assign regfile11 = array_reg[11];
    assign regfile12 = array_reg[12];
    assign regfile13 = array_reg[13];
    assign regfile14 = array_reg[14];
    assign regfile15 = array_reg[15];
    assign regfile16 = array_reg[16];
    assign regfile17 = array_reg[17];
    assign regfile18 = array_reg[18];
    assign regfile19 = array_reg[19];
    assign regfile20 = array_reg[20];
    assign regfile21 = array_reg[21];
    assign regfile22 = array_reg[22];
    assign regfile23 = array_reg[23];
    assign regfile24 = array_reg[24];
    assign regfile25 = array_reg[25];
    assign regfile26 = array_reg[26];
    assign regfile27 = array_reg[27];
    assign regfile28 = array_reg[28];
    assign regfile29 = array_reg[29];
    assign regfile30 = array_reg[30];
    assign regfile31 = array_reg[31];

    integer i;  // 声明循环变量
        
    always @(posedge clk or posedge rst) begin
        if (rst) begin
            for (i = 0; i < 32; i=i+1) begin
                array_reg[i] = 32'h0;  // 复位所有寄存器
            end
        end else if(!rst && waddr != 6'b0) begin  // 避免写入零寄存器
            array_reg[waddr] = wdata;
        end 
    end
    
    // 输出逻辑保持不变
    assign rt = array_reg[rdata2];
    assign rd = array_reg[waddr];
    assign rs = array_reg[rdata1];

endmodule