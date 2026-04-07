`timescale 1ns/1ps
/*
MEM 要求 ：
sh sb sw 这三条指令仅仅修改对应单元的字节，例如：
    初始存储器每个字为0xffffffff 对sh 0x1 1 
    存储器当中前四个字节会变成
    00 01 ff ff 而不会完成拓展 变成 00 01 00 00
*/
module PipeMEM(
    input clk,
    input rst,
    input flush_LLbit,
    input i_DMEM_wena,
    input [3:0] i_data_type,
    input i_CBW_sign,
    input i_CHW_sign,
    input [31:0] i_DMEM_wdata,
    input [31:0] i_alu_out,
    input [31:0] i_exe_out,
    input [31:0] i_DMEM_rdata,
    input ll_enable,
    input sc_enable,
    output [31:0] o_exe_out,
    output o_DMEM_wena,
    output [31:0] o_DMEM_addr,
    output [31:0] o_DMEM_rdata,
    output [31:0] o_DMEM_wdata
);
    parameter Wdata=4'd0,Hdata=4'd1,Bdata=4'd2,Ldata=4'd3,Rdata=4'd4;
    wire [31:0] rdata32;
    wire [15:0] rdata16;
    wire [7:0] rdata8;
    wire [31:0] D_CBW;
    wire [31:0] D_CHW;
    wire LLbit_o;
    LLbit_reg ll_locker(
        .clk(clk),
        .rst(rst),
        .flush(flush_LLbit),
        .mem_wena(i_DMEM_wena),
        .mem_waddr(o_DMEM_addr),
        .enable_ll(ll_enable),
        .mem_ll_addr(o_DMEM_addr),
        .enable_sc(sc_enable),
        .mem_sc_addr(o_DMEM_addr),
        .LLbit_o(LLbit_o)
    );
    cpmem CPMEM(
        .data_type(i_data_type),
        .exact_addr(i_alu_out),
        .appr_addr(o_DMEM_addr),
        .rdata32(rdata32),
        .rdata16(rdata16),
        .rdata8(rdata8),
        .rdata(i_DMEM_rdata),
        .wdata32(i_DMEM_wdata),
        .wdata16(i_DMEM_wdata[15:0]),
        .wdata8(i_DMEM_wdata[7:0]),
        .wdata(o_DMEM_wdata)
    );
    extend8 CBW(
        .a(rdata8),
        .sign(i_CBW_sign),
        .b(D_CBW)
    );
    extend16 CHW (
        .a(rdata16),
        .sign(i_CHW_sign),       
        .b(D_CHW)
    );
    // always@(*)
    // begin
    //     if (sc_enable) begin
    //         if (LLbit_o) begin
    //             o_DMEM_rdata <= 1;
    //         end else begin
    //             o_DMEM_rdata <= 0;
    //         end
    //     end else begin
    //         case(i_data_type)
    //             Wdata,Ldata,Rdata:begin
    //                 o_DMEM_rdata<=rdata32;
    //             end
    //             Hdata:begin
    //                 o_DMEM_rdata<=D_CHW;
    //             end
    //             Bdata:begin
    //                 o_DMEM_rdata<=D_CBW;
    //             end
    //         endcase
    //     end
    // end
    // 纯 assign + 三目运算符（?:）组合逻辑
    assign o_DMEM_rdata = 
                    sc_enable ? (LLbit_o ? 32'b1 : 32'b0)
                    : (i_data_type == Wdata || i_data_type == Ldata || i_data_type == Rdata) ? rdata32
                    : (i_data_type == Hdata) ? D_CHW
                    : (i_data_type == Bdata) ? D_CBW
                    : 32'b0; // 默认值，防止无定义
    assign o_DMEM_wena=(!sc_enable &&i_DMEM_wena )|| (sc_enable && i_DMEM_wena && LLbit_o);
    assign o_exe_out=i_exe_out;
endmodule