# ERROR: [Simulator 45-7] No such file 'E:/Homeworks/ComputerSytemExperiement/cpu89/piplineCPU/pipelineCPU.srcs/sources_1/new/regfile.vE:/Homeworks/ComputerSytemExperiement/cpu89/piplineCPU/pipelineCPU.srcs/sources_1/new/regfile.v' in the design.

# ERROR: [USF-XSim-62] 'simulate' step failed with errors. Please check the Tcl console or log files for more information.
# ERROR: [Vivado 12-4473] Detected error while running simulation. Please correct the issue and retry this operation.

# 仿真出现如上神秘路径拼接，原因是
# 路径重复拼接（path double concatenation） 报错是该版本的已知仿真断点缓存 Bug，并非普通的文件丢失问题。
# 删除TempBreakPointFile.txt  即可

rm piplineCPU/pipelineCPU.sim/sim_1/behav/xsim/xsim.dir/test_behav/TempBreakPointFile.txt
echo "TempBreakPointFile.txt removed. Please rerun the simulation."