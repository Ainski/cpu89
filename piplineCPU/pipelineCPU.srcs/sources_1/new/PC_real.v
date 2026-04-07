/**
Different to th pcreg,this pc_real allowed to be halt.
*/

`timescale 1ns / 1ps
// PC寄存器模块
// 功能：存储当前指令地址并根据时钟信号更新

// module pcreg#(parameter initvalue=32'h00000000)(
//     input CLK,                  //下降沿有效
//     input rst,                  //高电平有效
//     input ena,
//     input [31:0] data_in,
//     output [31:0] data_out
// );
module PC_real(
    input CLK,       // 时钟信号
    input rst,      // 异步复位信号
    input ena,      // 写使能信号
    input [31:0] data_in,   // 输入数据（新PC值）
    input halt,
    output reg [31:0] data_out  // 输出数据（当前PC值）
);
reg halting;
always @(posedge CLK or posedge rst) begin
    if (rst) begin
        // 复位时PC初始化为起始地址0x00400000
        data_out <= 32'h00400000;
        halting <= 0;
    end else if (!ena || (halt||halting)) begin
        // 遇到halt指令时进入停止状态
        data_out <= data_out;
        halting <= halting;
    end else begin
        // 正常情况下更新PC值
        data_out <= data_in;
        halting <= halting;
    end
end
endmodule