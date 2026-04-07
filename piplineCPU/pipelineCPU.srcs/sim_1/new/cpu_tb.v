`timescale 10ps / 1ps
module test;
    reg         clk;
    reg         reset;
    wire [31:0] inst;
    wire [31:0] pc;
    wire [31:0] answer;
    wire [31:0] count;
    wire [31:0] compare;


    
    reg         ok;
    integer    done;
    sccomp_dataflow uut (clk,reset,inst,pc,answer,count,compare);
    assign halt = test.uut.sccpu.oID_halt;

  
    initial clk<=1;
    always #5 clk<=~clk;
    
    integer file_output;
    integer inst_count;
    reg [31:0] pc_WB;
    reg [31:0] pc_MEM;
    reg [31:0] pc_EXE;
    reg [31:0] pc_IF;
    reg [31:0] inst_WB;
    reg [31:0] inst_MEM;
    reg [31:0] inst_EXE;
    reg [31:0] inst_IF;
    initial
    begin
        //$readmemh("G:/document/semester6/ComputerSystemExperiment/PipelineCPU/test/68_t.hex.txt",test.uut.IMEM.regfiles);//输入文件路径
        //$readmemh("G:/document/semester6/ComputerSystemExperiment/PipelineCPU/test/DMEM.txt",test.uut.DMEM.regfiles);
        file_output=$fopen("_246tb_ex10_result.txt");//输出文件路径
        #1;
        reset<=1;
        #27;
        reset<=0;
        inst_count<=0;
        pc_WB<=0;
        pc_MEM<=0;
        pc_EXE<=0;
        pc_IF<=0;
        inst_WB<=0;
        inst_MEM<=0;
        inst_EXE<=0;
        inst_IF<=0;
        ok<=1;
        done<=5;
//        #1000;
//        $stop;
    end
    

    always@(posedge clk)
    begin
        if(ok&&halt)
            done<=done-1;
        if(done==0)begin
            /**
            在程序运行结束的时候，输出所有寄存器的内容，用于检查
            */
            $fdisplay(file_output,"regfile0: %h",test.uut.sccpu.ID.REGFILE.array_reg[0]);
            $fdisplay(file_output,"regfile1: %h",test.uut.sccpu.ID.REGFILE.array_reg[1]);
            $fdisplay(file_output,"regfile2: %h",test.uut.sccpu.ID.REGFILE.array_reg[2]);
            $fdisplay(file_output,"regfile3: %h",test.uut.sccpu.ID.REGFILE.array_reg[3]);
            $fdisplay(file_output,"regfile4: %h",test.uut.sccpu.ID.REGFILE.array_reg[4]);
            $fdisplay(file_output,"regfile5: %h",test.uut.sccpu.ID.REGFILE.array_reg[5]);
            $fdisplay(file_output,"regfile6: %h",test.uut.sccpu.ID.REGFILE.array_reg[6]);
            $fdisplay(file_output,"regfile7: %h",test.uut.sccpu.ID.REGFILE.array_reg[7]);
            $fdisplay(file_output,"regfile8: %h",test.uut.sccpu.ID.REGFILE.array_reg[8]);
            $fdisplay(file_output,"regfile9: %h",test.uut.sccpu.ID.REGFILE.array_reg[9]);
            $fdisplay(file_output,"regfile10: %h",test.uut.sccpu.ID.REGFILE.array_reg[10]);
            $fdisplay(file_output,"regfile11: %h",test.uut.sccpu.ID.REGFILE.array_reg[11]);
            $fdisplay(file_output,"regfile12: %h",test.uut.sccpu.ID.REGFILE.array_reg[12]);
            $fdisplay(file_output,"regfile13: %h",test.uut.sccpu.ID.REGFILE.array_reg[13]);
            $fdisplay(file_output,"regfile14: %h",test.uut.sccpu.ID.REGFILE.array_reg[14]);
            $fdisplay(file_output,"regfile15: %h",test.uut.sccpu.ID.REGFILE.array_reg[15]);
            $fdisplay(file_output,"regfile16: %h",test.uut.sccpu.ID.REGFILE.array_reg[16]);
            $fdisplay(file_output,"regfile17: %h",test.uut.sccpu.ID.REGFILE.array_reg[17]);
            $fdisplay(file_output,"regfile18: %h",test.uut.sccpu.ID.REGFILE.array_reg[18]);
            $fdisplay(file_output,"regfile19: %h",test.uut.sccpu.ID.REGFILE.array_reg[19]);
            $fdisplay(file_output,"regfile20: %h",test.uut.sccpu.ID.REGFILE.array_reg[20]);
            $fdisplay(file_output,"regfile21: %h",test.uut.sccpu.ID.REGFILE.array_reg[21]);
            $fdisplay(file_output,"regfile22: %h",test.uut.sccpu.ID.REGFILE.array_reg[22]);
            $fdisplay(file_output,"regfile23: %h",test.uut.sccpu.ID.REGFILE.array_reg[23]);
            $fdisplay(file_output,"regfile24: %h",test.uut.sccpu.ID.REGFILE.array_reg[24]);
            $fdisplay(file_output,"regfile25: %h",test.uut.sccpu.ID.REGFILE.array_reg[25]);
            $fdisplay(file_output,"regfile26: %h",test.uut.sccpu.ID.REGFILE.array_reg[26]);
            $fdisplay(file_output,"regfile27: %h",test.uut.sccpu.ID.REGFILE.array_reg[27]);
            $fdisplay(file_output,"regfile28: %h",test.uut.sccpu.ID.REGFILE.array_reg[28]);
            $fdisplay(file_output,"regfile29: %h",test.uut.sccpu.ID.REGFILE.array_reg[29]);
            $fdisplay(file_output,"regfile30: %h",test.uut.sccpu.ID.REGFILE.array_reg[30]);
            $fdisplay(file_output,"regfile31: %h",test.uut.sccpu.ID.REGFILE.array_reg[31]);
            $stop;
        end
        if(inst_count<4)
        begin
            inst_count<=inst_count+1;
            pc_IF<=pc;
            pc_EXE<=pc_IF;
            pc_MEM<=pc_EXE;
            pc_WB<=pc_MEM;
            inst_IF<=inst;
            inst_EXE<=inst_IF;
            inst_MEM<=inst_EXE;
            inst_WB<=inst_MEM;
        end
        else if(ok)
        begin
//            $fdisplay(file_output,"pc: %h",pc_WB);
            //$fdisplay(file_output,"pc: %h",pc_WB-32'h00400000);
//            $fdisplay(file_output,"instr: %h",inst_WB);
//            $fdisplay(file_output,"cpr12-status: %h",test.uut.sccpu.CP0.regfiles[12]);
//            $fdisplay(file_output,"cpr13-cause: %h",test.uut.sccpu.CP0.regfiles[13]);
//            $fdisplay(file_output,"cpr14-epc: %h",test.uut.sccpu.CP0.regfiles[14]);

            pc_IF<=pc;
            pc_EXE<=pc_IF;
            pc_MEM<=pc_EXE;
            pc_WB<=pc_MEM;
            inst_IF<=inst;
            inst_EXE<=inst_IF;
            inst_MEM<=inst_EXE;
            inst_WB<=inst_MEM;
        end
    end


    wire PipeWB_mux_rf_DMEM;
    wire [31:0] PipeWB_exe_out;
    wire [31:0] PipeWB_DMEM_rdata;
    wire [31:0] PipeWB_rf_wdata;
    wire [31:0] PipeEXE_alu_out;
    assign PipeWB_mux_rf_DMEM = test.uut.sccpu.WB.mux_rf_DMEM;
    assign PipeWB_exe_out = test.uut.sccpu.WB.exe_out;
    assign PipeWB_DMEM_rdata = test.uut.sccpu.WB.DMEM_rdata;
    assign PipeWB_rf_wdata = test.uut.sccpu.WB.rf_wdata;
    assign PipeEXE_alu_out = test.uut.sccpu.EXE.ALU.r;

    wire [31:0] mux_alu_rs;
    wire [31:0] mux_alu_rt;
    wire [31:0] mux_alu_ext5;
    wire [31:0] mux_alu_ext16;
    wire [31:0] mux_alu_pc;
    wire [7:0] mux_alu_mux;
    wire [31:0] mux_alu_a;
    wire [31:0] mux_alu_b;
    wire [31:0] regfile_0,regfile_1,regfile_2,regfile_3,regfile_4,regfile_5,regfile_6,regfile_7;
    wire [31:0] regfile_8,regfile_9,regfile_10,regfile_11,regfile_12,regfile_13,regfile_14,regfile_15;
    wire [31:0] regfile_16,regfile_17,regfile_18,regfile_19,regfile_20,regfile_21,regfile_22,regfile_23;
    wire [31:0] regfile_24,regfile_25,regfile_26,regfile_27,regfile_28,regfile_29,regfile_30,regfile_31;
    assign mux_alu_rs = test.uut.sccpu.EXE.MUX_ALU.rs;
    assign mux_alu_rt = test.uut.sccpu.EXE.MUX_ALU.rt;
    assign mux_alu_ext5 = test.uut.sccpu.EXE.MUX_ALU.ext5;
    assign mux_alu_ext16 = test.uut.sccpu.EXE.MUX_ALU.ext16;
    assign mux_alu_pc = test.uut.sccpu.EXE.MUX_ALU.pc;
    assign mux_alu_mux = test.uut.sccpu.EXE.MUX_ALU.mux;
    assign mux_alu_a = test.uut.sccpu.EXE.MUX_ALU.a;
    assign mux_alu_b = test.uut.sccpu.EXE.MUX_ALU.b;

    assign regfile_0 = test.uut.sccpu.ID.REGFILE.array_reg[0] ;
    assign regfile_1 = test.uut.sccpu.ID.REGFILE.array_reg[1] ;
    assign regfile_2 = test.uut.sccpu.ID.REGFILE.array_reg[2] ;
    assign regfile_3 = test.uut.sccpu.ID.REGFILE.array_reg[3] ;
    assign regfile_4 = test.uut.sccpu.ID.REGFILE.array_reg[4] ;
    assign regfile_5 = test.uut.sccpu.ID.REGFILE.array_reg[5] ;
    assign regfile_6 = test.uut.sccpu.ID.REGFILE.array_reg[6] ;
    assign regfile_7 = test.uut.sccpu.ID.REGFILE.array_reg[7] ;
    assign regfile_8 = test.uut.sccpu.ID.REGFILE.array_reg[8] ;
    assign regfile_9 = test.uut.sccpu.ID.REGFILE.array_reg[9] ;
    assign regfile_10 = test.uut.sccpu.ID.REGFILE.array_reg[10] ;
    assign regfile_11 = test.uut.sccpu.ID.REGFILE.array_reg[11] ;
    assign regfile_12 = test.uut.sccpu.ID.REGFILE.array_reg[12] ;
    assign regfile_13 = test.uut.sccpu.ID.REGFILE.array_reg[13] ;
    assign regfile_14 = test.uut.sccpu.ID.REGFILE.array_reg[14] ;
    assign regfile_15 = test.uut.sccpu.ID.REGFILE.array_reg[15] ;
    assign regfile_16 = test.uut.sccpu.ID.REGFILE.array_reg[16] ;
    assign regfile_17 = test.uut.sccpu.ID.REGFILE.array_reg[17] ;
    assign regfile_18 = test.uut.sccpu.ID.REGFILE.array_reg[18] ;
    assign regfile_19 = test.uut.sccpu.ID.REGFILE.array_reg[19] ;
    assign regfile_20 = test.uut.sccpu.ID.REGFILE.array_reg[20] ;
    assign regfile_21 = test.uut.sccpu.ID.REGFILE.array_reg[21] ;
    assign regfile_22 = test.uut.sccpu.ID.REGFILE.array_reg[22] ;
    assign regfile_23 = test.uut.sccpu.ID.REGFILE.array_reg[23] ;
    assign regfile_24 = test.uut.sccpu.ID.REGFILE.array_reg[24] ;
    assign regfile_25 = test.uut.sccpu.ID.REGFILE.array_reg[25] ;
    assign regfile_26 = test.uut.sccpu.ID.REGFILE.array_reg[26] ;
    assign regfile_27 = test.uut.sccpu.ID.REGFILE.array_reg[27] ;
    assign regfile_28 = test.uut.sccpu.ID.REGFILE.array_reg[28] ;
    assign regfile_29 = test.uut.sccpu.ID.REGFILE.array_reg[29] ;
    assign regfile_30 = test.uut.sccpu.ID.REGFILE.array_reg[30] ;
    assign regfile_31 = test.uut.sccpu.ID.REGFILE.array_reg[31] ;
    // wire[31:0] alu_a,alu_b,alu_r;
    // wire [3:0] aluc;
    // assign aluc = test.uut.sccpu.EXE.ALU.aluc;
    // assign alu_a = test.uut.sccpu.EXE.ALU.a;
    // assign alu_b = test.uut.sccpu.EXE.ALU.b;
    // assign alu_r = test.uut.sccpu.EXE.ALU.r;
    // wire branch_predict_success,branch_predict_fail;
    // assign branch_predict_success = test.uut.sccpu.ID.CONTROL_UNIT.branch_predict_success;
    // assign branch_predict_fail = test.uut.sccpu.ID.CONTROL_UNIT.branch_predict_fail;

    // wire [31:0] npc ;
    // assign npc = test.uut.sccpu.IF.MUX_PC.out;
    // wire [7:0] mux_pc_mux;
    // assign mux_pc_mux = test.uut.sccpu.IF.MUX_PC.mux;

    // wire i_blockade,i_stall,o_stall;
    // assign i_blockade = test.uut.sccpu.ID.i_blockade;
    // assign i_stall = test.uut.sccpu.ID.i_stall;
    // assign o_stall = test.uut.sccpu.ID.o_stall;

    // assign iID_blockade = test.uut.sccpu.iID_blockade;
    // assign iID_branch_predict_fail = test.uut.sccpu.iID_branch_predict_fail;


    // wire [31:0] o_cp0_rdata;
    // assign o_cp0_rdata = test.uut.sccpu.ID.o_cp0_rdata;

    // wire [31:0] exe_out;
    // assign exe_out = test.uut.sccpu.EXE.exe_out;
    
    // wire [4:0] rd ;
    // wire mtc0 ;
    // wire [31:0] wdata;
    // assign rd = test.uut.sccpu.ID.rd;
    // assign mtc0 = test.uut.sccpu.ID.cpr_ena;
    // assign wdata = test.uut.sccpu.ID.rf_rdata2;
    // assign iID_EXE_hi_ena=oDEreg_hi_ena;
    // assign iID_EXE_hi_idata=oEXE_hi_idata;
    // assign iID_EXE_lo_ena=oDEreg_lo_ena;
    // assign iID_EXE_lo_idata=oEXE_lo_idata;
    // assign iID_MEM_hi_ena=oEMreg_hi_ena;
    // assign iID_MEM_hi_idata=oEMreg_hi_idata;
    // assign iID_MEM_lo_ena=oEMreg_lo_ena;
    // assign iID_MEM_lo_idata=oEMreg_lo_idata;
    // assign iID_hi_ena=oMWreg_hi_ena;
    // assign iID_hi_idata=oMWreg_hi_idata;
    // assign iID_lo_ena=oMWreg_lo_ena;
    // assign iID_lo_idata=oMWreg_lo_idata;
    wire [31:0] iID_EXE_hi_idata,iID_EXE_lo_idata,iID_MEM_hi_idata,iID_MEM_lo_idata,iID_hi_idata,iID_lo_idata;
    assign iID_EXE_hi_ena = test.uut.sccpu.iID_EXE_hi_ena;
    assign iID_EXE_hi_idata = test.uut.sccpu.iID_EXE_hi_idata;
    assign iID_EXE_lo_ena = test.uut.sccpu.iID_EXE_lo_ena;
    assign iID_EXE_lo_idata = test.uut.sccpu.iID_EXE_lo_idata;
    assign iID_MEM_hi_ena = test.uut.sccpu.iID_MEM_hi_ena;
    assign iID_MEM_hi_idata = test.uut.sccpu.iID_MEM_hi_idata;
    assign iID_MEM_lo_ena = test.uut.sccpu.iID_MEM_lo_ena;
    assign iID_MEM_lo_idata = test.uut.sccpu.iID_MEM_lo_idata;
    assign iID_hi_ena = test.uut.sccpu.iID_hi_ena;
    assign iID_hi_idata = test.uut.sccpu.iID_hi_idata;
    assign iID_lo_ena = test.uut.sccpu.iID_lo_ena;
    assign iID_lo_idata = test.uut.sccpu.iID_lo_idata; 
    
    wire [63:0] mult_s_out;
    wire [31:0] mult_s_a ,mult_s_b;
    assign mult_s_out = test.uut.sccpu.EXE.MULT.s_z;
    assign mult_s_a = test.uut.sccpu.EXE.MULT.s_a;
    assign mult_s_b = test.uut.sccpu.EXE.MULT.s_b;


endmodule
module top_test;
    reg         clk;
    reg         reset;
    wire [7:0]  o_seg;
    wire [7:0]  o_sel;
    wire [31:0] debug;
    top prj(.clock_100MHZ(clk),.reset(reset),.sel(8'b0),.o_seg(o_seg),.o_sel(o_sel));
    initial clk<=0;
    always #1 clk<=~clk;
    initial
    begin
        reset<=1;
        # 10 reset<=0;
        # 10 reset<=1; 
        //# 100 $stop;
    end
endmodule