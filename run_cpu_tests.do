# ModelSim Batch Script for 5-Stage Pipeline CPU Testing (piplineCPU)
# 基于 piplineCPU 架构的自动化测试脚本

# Clean up any existing libraries and files
if {[file exists work]} {
    vdel -lib work -all
}
# Clean up any old result files if they exist
catch {file delete _246tb_ex10_result.txt}

# Create fresh working library
vlib work

# ============================================
# 1. 编译 IP 核文件
# ============================================
vlog -work work -quiet ./piplineCPU/pipelineCPU.gen/sources_1/ip/imem/simulation/dist_mem_gen_v8_0.v
vlog -work work -quiet ./piplineCPU/pipelineCPU.gen/sources_1/ip/imem/sim/imem.v

# ============================================
# 2. 编译所有 Verilog 源文件
# ============================================
vlog -work work -quiet ./piplineCPU/pipelineCPU.srcs/sources_1/new/alu.v
vlog -work work -quiet ./piplineCPU/pipelineCPU.srcs/sources_1/new/Asynchronous_D_FF.v
vlog -work work -quiet ./piplineCPU/pipelineCPU.srcs/sources_1/new/clo.v
vlog -work work -quiet ./piplineCPU/pipelineCPU.srcs/sources_1/new/clz.v
vlog -work work -quiet ./piplineCPU/pipelineCPU.srcs/sources_1/new/complement.v
vlog -work work -quiet ./piplineCPU/pipelineCPU.srcs/sources_1/new/cp0.v
vlog -work work -quiet ./piplineCPU/pipelineCPU.srcs/sources_1/new/cpmem.v
vlog -work work -quiet ./piplineCPU/pipelineCPU.srcs/sources_1/new/cpu.v
vlog -work work -quiet ./piplineCPU/pipelineCPU.srcs/sources_1/new/cu.v
vlog -work work -quiet ./piplineCPU/pipelineCPU.srcs/sources_1/new/decoder.v
vlog -work work -quiet ./piplineCPU/pipelineCPU.srcs/sources_1/new/direct.v
vlog -work work -quiet ./piplineCPU/pipelineCPU.srcs/sources_1/new/div.v
vlog -work work -quiet ./piplineCPU/pipelineCPU.srcs/sources_1/new/divider.v
vlog -work work -quiet ./piplineCPU/pipelineCPU.srcs/sources_1/new/extend.v
vlog -work work -quiet ./piplineCPU/pipelineCPU.srcs/sources_1/new/hi_lo_function.v
vlog -work work -quiet ./piplineCPU/pipelineCPU.srcs/sources_1/new/II.v
vlog -work work -quiet ./piplineCPU/pipelineCPU.srcs/sources_1/new/LLbit_reg.v
vlog -work work -quiet ./piplineCPU/pipelineCPU.srcs/sources_1/new/memory.v
vlog -work work -quiet ./piplineCPU/pipelineCPU.srcs/sources_1/new/mult.v
vlog -work work -quiet ./piplineCPU/pipelineCPU.srcs/sources_1/new/mux.v
vlog -work work -quiet ./piplineCPU/pipelineCPU.srcs/sources_1/new/npc.v
vlog -work work -quiet ./piplineCPU/pipelineCPU.srcs/sources_1/new/pcreg.v
vlog -work work -quiet ./piplineCPU/pipelineCPU.srcs/sources_1/new/PipeDEreg.v
vlog -work work -quiet ./piplineCPU/pipelineCPU.srcs/sources_1/new/PipeEMreg.v
vlog -work work -quiet ./piplineCPU/pipelineCPU.srcs/sources_1/new/PipeEXE.v
vlog -work work -quiet ./piplineCPU/pipelineCPU.srcs/sources_1/new/PipeID.v
vlog -work work -quiet ./piplineCPU/pipelineCPU.srcs/sources_1/new/PipeIF.v
vlog -work work -quiet ./piplineCPU/pipelineCPU.srcs/sources_1/new/PipeIR.v
vlog -work work -quiet ./piplineCPU/pipelineCPU.srcs/sources_1/new/PipeMEM.v
vlog -work work -quiet ./piplineCPU/pipelineCPU.srcs/sources_1/new/PipeMWreg.v
vlog -work work -quiet ./piplineCPU/pipelineCPU.srcs/sources_1/new/PipeWB.v
vlog -work work -quiet ./piplineCPU/pipelineCPU.srcs/sources_1/new/predictor.v
vlog -work work -quiet ./piplineCPU/pipelineCPU.srcs/sources_1/new/regfile.v
vlog -work work -quiet ./piplineCPU/pipelineCPU.srcs/sources_1/new/sccomp_dataflow.v
vlog -work work -quiet ./piplineCPU/pipelineCPU.srcs/sources_1/new/seg7x16.v
vlog -work work -quiet ./piplineCPU/pipelineCPU.srcs/sources_1/new/top.v

# Compile testbench
vlog -work work -quiet ./piplineCPU/pipelineCPU.srcs/sim_1/new/cpu_tb.v

# ============================================
# 3. 创建结果目录
# ============================================
set results_dir "./test_scripts/results"
if {![file exists $results_dir]} {
    file mkdir $results_dir
}

# ============================================
# 4. 自动发现所有测试文件
# ============================================
proc get_test_files {} {
    set hex_files [glob -nocomplain -directory "./testdata" "*.hex.txt"]
    set result {}

    foreach file $hex_files {
        set rel_file [string map {"./testdata/" "testdata/"} $file]
        lappend result $rel_file
    }

    set sorted_result [lsort $result]
    return $sorted_result
}

set test_files [get_test_files]

puts "Found [llength $test_files] test files to run:"
foreach test_file $test_files {
    puts "  - $test_file"
}
puts ""

# ============================================
# 5. 单个测试运行过程
# ============================================
proc run_single_test {test_file results_dir} {
    set test_name [file rootname [file tail $test_file]]
    set test_name [string map {.hex ""} $test_name]

    puts "\n-----------------------------"
    puts "RUNNING TEST: $test_file"
    puts "-----------------------------"

    # Clean up old result files
    if {[file exists ./_246tb_ex10_result.txt]} {
        catch {file delete ./_246tb_ex10_result.txt}
    }

    # ========================================
    # 修改 IMEM 初始化文件
    # ========================================
    set imem_mif_path "./piplineCPU/pipelineCPU.ip_user_files/mem_init_files/imem.mif"
    set imem_mif_backup "./piplineCPU/pipelineCPU.ip_user_files/mem_init_files/imem.mif.bak"
    
    # Backup original MIF
    if {[file exists $imem_mif_path]} {
        file copy -force $imem_mif_path $imem_mif_backup
    }

    # 读取测试文件并生成新的 MIF 文件
    set test_fid [open $test_file r]
    set test_content [read $test_fid]
    close $test_fid

    # 创建新的 MIF 文件内容
    set mif_content "memory_initialization_radix = 16;\n"
    append mif_content "memory_initialization_vector =\n"
    
    # 处理测试文件内容，移除空行
    set test_lines [split $test_content "\n"]
    foreach line $test_lines {
        set trimmed_line [string trim $line]
        if {$trimmed_line != "" && [string first ";" $trimmed_line] == -1} {
            append mif_content "$trimmed_line\n"
        }
    }
    append mif_content ";"

    # 写入 MIF 文件
    set fid [open $imem_mif_path w]
    puts -nonewline $fid $mif_content
    close $fid

    # 重新编译 IMEM IP
    vlog -work work -quiet ./piplineCPU/pipelineCPU.gen/sources_1/ip/imem/simulation/dist_mem_gen_v8_0.v
    vlog -work work -quiet ./piplineCPU/pipelineCPU.gen/sources_1/ip/imem/sim/imem.v

    # ========================================
    # 6. 加载并运行仿真
    # ========================================
    vsim -quiet work.test

    # Run simulation for maximum 100000ns
    run 100000ns

    # ========================================
    # 7. 保存仿真结果
    # ========================================
    set sim_result_file "./_246tb_ex10_result.txt"
    set output_result_file "$results_dir/${test_name}_sim_result.txt"

    if {[file exists $sim_result_file]} {
        file copy -force $sim_result_file $output_result_file
        puts "Saved simulation result to: $output_result_file"
    } else {
        puts "Warning: Simulation result file not found: $sim_result_file"
    }

    # ========================================
    # 8. 恢复原始 MIF 文件
    # ========================================
    if {[file exists $imem_mif_backup]} {
        file copy -force $imem_mif_backup $imem_mif_path
        file delete $imem_mif_backup
    }

    # ========================================
    # 9. 复制标准结果文件
    # ========================================
    regsub {\.hex\.txt$} $test_file ".result.txt" std_result_file

    set output_std_result_file "$results_dir/${test_name}_std_result.txt"
    if {[file exists $std_result_file]} {
        file copy -force $std_result_file $output_std_result_file
        puts "Standard test result copied to: $output_std_result_file"
    } else {
        puts "Standard result file not found: $std_result_file"
        return 0
    }

    # ========================================
    # 10. 比较仿真结果与标准结果
    # ========================================
    set compare_result [catch {exec txt_compare --file1 $output_result_file --file2 $std_result_file --display detailed > "$results_dir/${test_name}_comparison_result.txt"} compare_output]

    set comp_file "$results_dir/${test_name}_comparison_result.txt"
    if {[file exists $comp_file]} {
        set comp_fid [open $comp_file r]
        set comp_content [read $comp_fid]
        close $comp_fid

        # Check if test passed
        set lines [split $comp_content "\n"]
        set success 0
        foreach line $lines {
            if {[string match "*在指定检查条件下完全一致.*" $line]} {
                set success 1
                break
            }
        }

        if {$success} {
            puts "RESULT: PASS - $test_file"
            return 1
        } else {
            puts "RESULT: FAIL - $test_file"
            puts "Comparison output:"
            puts "=================================================================================="
            puts $comp_content
            puts "=================================================================================="
            return 0
        }
    } else {
        puts "Comparison result file not found: $comp_file"
        return 0
    }
}

# ============================================
# 11. 运行所有测试
# ============================================
set total_tests [llength $test_files]
set pass_count 0

puts "Starting batch simulation for $total_tests tests..."

foreach test_file $test_files {
    set result [run_single_test $test_file $results_dir]
    if {$result == 1} {
        incr pass_count
    }
}

# ============================================
# 12. 生成最终摘要
# ============================================
set summary_text [subst "BATCH TEST SUMMARY\n==================================\nTotal tests: $total_tests\nPassed tests: $pass_count\nFailed tests: [expr $total_tests - $pass_count]\nSuccess rate: [format %.2f [expr double($pass_count)*100/double($total_tests)]]%\n=================================="]

puts "\n$summary_text"

# Write summary to file
set sum_fid [open "$results_dir/test_summary.txt" w]
puts $sum_fid $summary_text
close $sum_fid

puts "\nAll tests completed. Results saved in $results_dir/"
puts "Success rate: [format %.2f [expr double($pass_count)*100/double($total_tests)]]%"

# Quit ModelSim
quit
