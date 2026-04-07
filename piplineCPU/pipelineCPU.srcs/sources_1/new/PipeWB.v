`timescale 1ns/1ps
module PipeWB(
    input mux_rf_DMEM,
    input [31:0] exe_out,
    input [31:0] DMEM_rdata,
    output [31:0] rf_wdata
);
    mux2_32 MUX_RF_DMEM(
        .a(exe_out),
        .b(DMEM_rdata),
        .choose(mux_rf_DMEM),
        .c(rf_wdata)
    );
// initial begin
//     #10;
//     forever begin
//         $display("time %t | rf_wdata = %h", $time, rf_wdata);
//         $display("time %t | exe_out = %h", $time, exe_out);
//         $display("time %t | DMEM_rdata = %h", $time, DMEM_rdata);
//         $display("time %t | mux_rf_DMEM = %b", $time, mux_rf_DMEM);
//         $display("------------------------------------");
//         #10;
//     end 
// end
    
endmodule