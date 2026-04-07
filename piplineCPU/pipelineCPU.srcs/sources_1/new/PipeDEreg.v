`timescale 1ns/1ps
module PipeDEreg(
    input clk,
    input rst,
    input DMEM_wena,
    input [3:0] data_type,
    input CBW_sign,
    input CHW_sign,
    input [31:0] pc4,
    input [7:0] mux_rf,
    input mux_rf_DMEM,
    input [7:0] mux_alu,
    input [7:0] mux_hi,
    input [7:0] mux_lo,
    input rf_wena,
    input [3:0] mov_cond,
    input [4:0] rf_waddr,
    input [31:0] rf_rdata1,
    input [31:0] rf_rdata2,
    input [3:0] alu_aluc,
    input hi_ena,
    input [31:0] hi_odata,
    input lo_ena,
    input [31:0] lo_odata,
    input [3:0] hi_lo_func,
    input EXT1_n_c,
    input [31:0] ext5,
    input [31:0] ext16,
    input [31:0] cpr,
    input branch_inst,
    input branch_predict,
    input [3:0] branch_flag,
    input [31:0] branch_fail_pc,
    input blockade,
    input halt,
    output reg D_DMEM_wena,
    output reg [3:0] D_data_type,
    output reg D_CBW_sign,
    output reg D_CHW_sign,
    output reg [31:0] D_pc4,
    output reg [7:0] D_mux_rf,
    output reg D_mux_rf_DMEM,
    output reg [7:0] D_mux_alu,
    output reg [7:0] D_mux_hi,
    output reg [7:0] D_mux_lo,
    output reg D_rf_wena,
    output reg [3:0] D_mov_cond,
    output reg [4:0] D_rf_waddr,
    output reg [31:0] D_rf_rdata1,
    output reg [31:0] D_rf_rdata2,
    output reg [3:0] D_alu_aluc,
    output reg D_hi_ena,
    output reg [31:0] D_hi_odata,
    output reg D_lo_ena,
    output reg [31:0] D_lo_odata,
    output reg [3:0] D_hi_lo_func,
    output reg D_EXT1_n_c,
    output reg [31:0] D_ext5,
    output reg [31:0] D_ext16,
    output reg [31:0] D_cpr,
    output reg D_branch_inst,
    output reg D_branch_predict,
    output reg [3:0] D_branch_flag,
    output reg [31:0] D_branch_fail_pc
);
    /**
    这里代码有一个严重的bug
    分支预测失败时，各个阶段的接受如下
    ID 入口     EXE 入口    MEM 入口
    branch+2   branch+1   branch

    旧的代码无法在blockade 的情况下正确屏蔽所有的输入输出，我们选择直接输出所有的rst状态的code
    */
    always@(posedge clk or posedge rst)
    begin
        if(rst || halt || blockade)
        begin
            D_DMEM_wena<=0;
            D_data_type<=4'bz;
            D_CBW_sign<=1'bz;
            D_CHW_sign<=1'bz;
            D_pc4<=32'bz;
            D_mux_rf<=8'bz;
            D_mux_rf_DMEM<=1'bz;
            D_mux_alu<=8'bz;
            D_mux_hi<=8'bz;
            D_mux_lo<=8'bz;
            D_rf_wena<=0;
            D_mov_cond<=4'd0;
            D_rf_waddr<=5'bz;
            D_rf_rdata1<=32'bz;
            D_rf_rdata2<=32'bz;
            D_alu_aluc<=32'bz;
            D_hi_ena<=0;
            D_hi_odata<=32'bz;
            D_lo_ena<=0;
            D_lo_odata<=32'bz;
            D_hi_lo_func<=4'b0;
            D_EXT1_n_c<=1'bz;
            D_ext5<=32'bz;
            D_ext16<=32'bz;
            D_cpr<=32'bz;
            D_branch_inst<=0;
            D_branch_predict<=1'bz;
            D_branch_flag<=4'b0;
            D_branch_fail_pc<=32'bz;
        end
        else
        begin
            D_DMEM_wena<=blockade? 0:DMEM_wena;
            D_data_type<=data_type;
            D_CBW_sign<=CBW_sign;
            D_CHW_sign<=CHW_sign;
            D_pc4<=pc4;
            D_mux_rf<=mux_rf;
            D_mux_rf_DMEM<=mux_rf_DMEM;
            D_mux_alu<=mux_alu;
            D_mux_hi<=mux_hi;
            D_mux_lo<=mux_lo;
            D_rf_wena<=blockade? 0:rf_wena;
            D_mov_cond<=mov_cond;
            D_rf_waddr<=rf_waddr;
            D_rf_rdata1<=rf_rdata1;
            D_rf_rdata2<=rf_rdata2;
            D_alu_aluc<=alu_aluc;
            D_hi_ena<=blockade? 0:hi_ena;
            D_hi_odata<=hi_odata;
            D_lo_ena<=blockade? 0:lo_ena;
            D_lo_odata<=lo_odata;
            D_hi_lo_func<=hi_lo_func;
            D_EXT1_n_c<=EXT1_n_c;
            D_ext5<=ext5;
            D_ext16<=ext16;
            D_cpr<=cpr;
            D_branch_inst<=branch_inst;
            D_branch_predict<=branch_predict;
            D_branch_flag<=branch_flag;
            D_branch_fail_pc<=branch_fail_pc;
        end
    end
endmodule