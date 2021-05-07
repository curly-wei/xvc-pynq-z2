# A Vivado script that demonstrates a very simple RTL-to-bitstream batch flow
#
# NOTE:  typical usage would be "vivado -mode tcl -source create_bft_batch.tcl" 
#
# ref: 
# https://tinyurl.com/p7y7wu3j
#
## STEP#0:  Prepare
#

#Define output directory area
set kOutputDir "./xvc_server_hw" 

#clean previois buildedcd folder and design
set kVivadoDefaultGenOutFolders { ".srcs" ".gen" ".Xil" "NA" }
set purged_dirs [ concat ${kVivadoDefaultGenOutFolders} ${kOutputDir} ]
foreach dir ${purged_dirs} {
  file delete -force [ glob -nocomplain ${dir} ]
}

# Create director for output objects
file mkdir ${kOutputDir}

#Define the name of top module
set kTopModuleName "top"

#Define name of xvc-bd (sub project)
set kBDName "xvc_system"

#Set project properties (create dummy(diskless) project)
set kFPGAPart "xc7z020clg400-1"
set_part ${kFPGAPart}
#set_property BOARD_PART "tul.com.tw:pynq-z2:part0:1.0" [current_project]
set_property TARGET_LANGUAGE Verilog [current_project]
set_property DEFAULT_LIB work [current_project]
# Regarding source_mgmt_mode, see
# https://tinyurl.com/4b7xyvxs
# and
# https://www.xilinx.com/support/answers/69846.html
# and
# https://www.xilinx.com/support/answers/63488.html
# If source_mgmt_mode hasn't set as 'All',
# then we can't compile axi_jtage with 'source code mode',
# axi_jtage only can be compile with 'locked ip mode'
set_property source_mgmt_mode All [current_project]

#Define directory of source code and IP
set kTopScriptDir "../src/hw/script/"
set kVerilogSrcDirs { "../src/hw/hdl/" }
set kXDCSrcDirs { "../src/hw/xdc/" }
set kIPSrcDirs { "../src/hw/ip/" }

# Define preset file for ps
set kPSPresetFile "${kTopScriptDir}/pynq-z2-ps-preset.tcl"

# Define script of bd-top file for ps
set kTopBDScriptFile "${kTopScriptDir}/bd_system.tcl"

#Set max-thread to build
proc num_threads_run {} {
  set kVivadoMaxCoreSupported 8
  set OS ${::tcl_platform(platform)}
  if { ${OS} == "Windows" } {
    set cpu_core_count [ expr ${::env(NUMBER_OF_PROCESSORS)}/2 ]
  } else {
    set cpu_core_count [ expr [exec nproc]/2 ]
  }
  if { ${cpu_core_count} > ${kVivadoMaxCoreSupported} } {
    set cpu_core_count  ${kVivadoMaxCoreSupported}
  }
  return ${cpu_core_count}
}

set_param general.maxThreads [num_threads_run]
puts "=================================================================="
puts "INFO: Max threads = [get_param general.maxThreads] "
puts "=================================================================="

## STEP#1: setup design sources and constraints
#
#Read-in verilog files from source folder
foreach dirs ${kVerilogSrcDirs} {
  set verilog_files [ glob -nocomplain "${dirs}/*.v" ]
  if { ${verilog_files} != "" } {
    read_verilog ${verilog_files}
    puts "=================================================================="
    puts "INFO: read-in verilog files: ${verilog_files}"
    puts "=================================================================="
  } 
}

# Read-in xdc files from source folder
foreach dirs ${kXDCSrcDirs} {
  set xdc_files [ glob -nocomplain "${dirs}/*.xdc" ]  
  if { ${xdc_files} != "" } {
    read_xdc ${xdc_files}
    puts "=================================================================="
    puts "INFO: read-in xdc files: ${xdc_files}"
    puts "=================================================================="
  }
}

# Read-in ip files from source folders
set has_ip_files 0
foreach dirs ${kIPSrcDirs} {
  set ip_files [ glob -nocomplain "${dirs}/*/*.xci" ]  
  if { ${ip_files} != "" } {
    read_ip ${ip_files}
    set ${has_ip_files} 1
    puts "=================================================================="
    puts "INFO: read-in ip files: ${ip_files}"
    puts "=================================================================="
  }
}

# Set ip repository path (not Xilinx ip, is 3rd party ip) if its exist
if { ${has_ip_files} == 1 } {
  set_property IP_REPO_PATHS ${kIPSrcDirs} [current_fileset]
  update_ip_catalog
}

# STEP#2: Create block diagram (bd) with ps(processor system) and jtag-axi
#
# Load ps preset
if { [ file exists ${kPSPresetFile} ] == 1 } {
  puts "=================================================================="
  puts "INFO: read-in files for ps preset: ${kPSPresetFile}"
  puts "=================================================================="
  source ${kPSPresetFile}
} else {
  error "ERROR: read-in files for ps preset: < ${kPSPresetFile} > fail. \
    This file is necessary, please check again"
}

# create the BD-Design
if { [ file exists ${kTopBDScriptFile} ] == 1 } {
  # read-in bd-created shell and execute it
  puts "=================================================================="
  puts "INFO: read-in files for top bd: ${kTopBDScriptFile}"
  puts "=================================================================="
  source ${kTopBDScriptFile}
  init_xcv_system_bd ${kBDName}
  create_root_design ""
  # if create bd succseefully, read-in and make wrapper
  set bd_file_and_path ".srcs/sources_1/bd/${kBDName}/${kBDName}.bd" 
} else {
  error "ERROR: read-in files for ps preset: < ${kTopBDScriptFile} > fail. \
    This file is necessary, please check again"
}

# create bd wrapper for top hw
# synth_checkpoint_mode refer to ug994-vivado-ip-subsystem
set_property synth_checkpoint_mode None [ get_files ${bd_file_and_path} ]
generate_target all [ get_files ${bd_file_and_path} ]
set top_bd_wrapper_name "${kBDName}_wrapper"
set top_bd_wrapper_path \
  ".gen/sources_1/bd/${kBDName}/hdl/${top_bd_wrapper_name}.v"
read_verilog ${top_bd_wrapper_path}

# STEP#3: 
# run synthesis, report utilization and timing estimates, 
# write checkpoint design
#
# Regarding reorder_files -auto
# See
# https://www.xilinx.com/support/answers/51688.html
#
puts "=================================================================="
puts "INFO: Run Synthesis"
puts "=================================================================="
reorder_files -auto
synth_design -top ${top_bd_wrapper_name} -part ${kFPGAPart} -flatten rebuilt 

puts "=================================================================="
puts "INFO: Genetrate dcp/Report for Synthesis"
puts "=================================================================="
write_checkpoint -force "${kOutputDir}/post_synth.dcp"
report_timing_summary -file "${kOutputDir}/post_synth_timing_summary.rpt"
report_power -file "${kOutputDir}/post_synth_power.rpt"
report_compile_order -file "${kOutputDir}/post_synth_compile_order.rpt"

# STEP#4: 
# run placement and logic optimzation, 
# report utilization and timing estimates, write checkpoint design
#
puts "=================================================================="
puts "INFO: Run Implementions"
puts "=================================================================="
opt_design
place_design
phys_opt_design

puts "=================================================================="
puts "INFO: Genetrate dcp/Report for Implementions"
puts "=================================================================="
#write_checkpoint -force "${kOutputDir}/post_place"
report_timing_summary -file "${kOutputDir}/post_place_timing_summary.rpt"

# STEP#5: 
# run router, report actual utilization and timing, 
# write checkpoint design, run drc, write verilog and xdc out
#
puts "=================================================================="
puts "INFO: Run Route"
puts "=================================================================="
route_design
write_checkpoint -force "${kOutputDir}/post_route"

puts "=================================================================="
puts "INFO: Genetrate dcp/Report for Route"
puts "=================================================================="
report_timing_summary -file "${kOutputDir}/post_route_timing_summary.rpt"
report_timing -sort_by group -max_paths 100 -path_type summary -file \
  "${kOutputDir}/post_route_timing.rpt"
report_clock_utilization -file "${kOutputDir}/clock_util.rpt"
report_utilization -file "${kOutputDir}/post_route_util.rpt"
report_power -file "${kOutputDir}/post_route_power.rpt"
report_drc -file "${kOutputDir}/post_imp_drc.rpt"

puts "=================================================================="
puts "INFO: Genetrate Summrized xdc/hdl file"
puts "=================================================================="
write_verilog -force "${kOutputDir}/${kBDName}_top_impl_netlist.v"
write_xdc -no_fixed_only -force "${kOutputDir}/${kBDName}_top_impl.xdc"

# STEP#6: generate a bitstream
# 
puts "=================================================================="
puts "INFO: Genetrate Bitstream and debug info"
puts "=================================================================="
write_bitstream -force "${kOutputDir}/${kBDName}_top.bit"
write_debug_probes -force "${kOutputDir}/${kBDName}_top.itx"

# STEP#7: Export the implemented hardware system to the Vitis environment
#
# Before write_hw_platform, 
# must run 
# open_checkpoint <post-route.dcp>
# furthermore, can't use read_bd ${bd_file_and_path}
# reason Refer to
# https://www.xilinx.com/support/answers/60945.html
#
puts "=================================================================="
puts "INFO: Genetrate xsa File"
puts "=================================================================="
open_checkpoint "${kOutputDir}/post_route.dcp"
set_property platform.design_intent.embedded true [current_project]
set_property platform.design_intent.server_managed false [current_project]
set_property platform.design_intent.external_host false [current_project]
set_property platform.design_intent.datacenter false [current_project]
set_property platform.default_output_type "sd_card" [current_project]
write_hw_platform -fixed -include_bit -force -verbose \
  "${kOutputDir}/${kBDName}_top.xsa"
validate_hw_platform -verbose "${kOutputDir}/${kBDName}_top.xsa"

#start_gui