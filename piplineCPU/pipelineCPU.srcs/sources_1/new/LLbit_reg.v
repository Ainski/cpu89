`timescale 1ns / 1ps
module LLbit_reg(
	input clk,
	input rst,
	input flush,
    input mem_wena,
    input [31:0] mem_waddr ,
    input enable_ll,
	input [31:0] mem_ll_addr, 
    input enable_sc,
    input [31:0] mem_sc_addr,
	output LLbit_o
	
);
// module LLbit_reg(
// 	input clk,
// 	input rst,
// 	input flush, //写端口  
//     input mem_wena, //内存写入信号  
//     input [31:0] mem_waddr , //内存写入地址  
//     input enable_ll,  // 启动对每一个地址的监视  
// 	input [31:0] mem_ll_addr,// ll指令所加载的地址  
//     input enable_sc,  // 启动sc对这个地址进行写入  
//     input [31:0] mem_sc_addr,// sc指令所存放的地址  
// 	//读端口1
// 	output LLbit_o
	
// );
    reg is_used; // 标记了当前的 Locked_addr是否被监视
    reg [31:0] Locked_addr;
    always @ (posedge clk or posedge rst) begin
        if(rst||flush) begin
            is_used <=0;
            Locked_addr <= 32'b0;
        end else if (enable_ll) begin
            is_used <= 1;
            Locked_addr <= mem_ll_addr;
        end else if (enable_sc ) begin
            is_used <= 0;
            Locked_addr <= 32'b0;
        end else if (mem_wena && (mem_waddr == Locked_addr))begin
            is_used <=0 ;
            Locked_addr <= 32'b0;
        end else begin
            is_used <= is_used;
            Locked_addr <= Locked_addr;
        end

    end

    assign LLbit_o = !flush && !rst && is_used && enable_sc && (
        mem_sc_addr == Locked_addr
    );
endmodule