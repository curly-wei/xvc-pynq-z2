set kAPPName "xvc_fsbl"
set kPlatformName "${kAPPName}_pf"
set kDomainName "${kAPPName}_dom"
set kBuildDir "[pwd]"
set kXSAFilePath "${kBuildDir}/xvc_server_hw/xvc_system_top.xsa"
set kOutputDir "${kBuildDir}/xvc_server_os/fsbl" 

setws ${kOutputDir}

puts "=================================================================="
puts "INFO: clear previous build objects"
puts "=================================================================="
file delete -force ${kOutputDir}

puts "=================================================================="
puts "INFO: check xsa file if exist"
puts "=================================================================="
if { [file exist ${kXSAFilePath}] == 1} {
  puts "INFO: Found xsa file, located at:"
  puts [file normalize ${kXSAFilePath}] 
} else {
  error "ERROR: xsa file does not exist"
}

puts "=================================================================="
puts "INFO: create pf"
puts "=================================================================="
platform create \
  -name ${kPlatformName} \
  -hw ${kXSAFilePath}

puts "=================================================================="
puts "INFO: create domain"
puts "=================================================================="
domain create \
  -name ${kDomainName} \
  -os standalone \
  -proc ps7_cortexa9_0

puts "=================================================================="
puts "INFO: set bsplib xilffs"
puts "=================================================================="
bsp setlib xilffs

puts "=================================================================="
puts "INFO: gen pf"
puts "=================================================================="
platform generate

puts "=================================================================="
puts "INFO: create app"
puts "=================================================================="
app create \
  -name ${kAPPName} \
  -platform ${kPlatformName} \
  -domain ${kDomainName} \
  -template {Zynq FSBL} 

puts "=================================================================="
puts "INFO: conf app"
puts "=================================================================="
app config \
  -name ${kAPPName} \
  define-compiler-symbols {FSBL_DEBUG_INFO}

puts "=================================================================="
puts "INFO: build app"
puts "=================================================================="
app build -name ${kAPPName} 

puts "=================================================================="
puts "INFO: Generate FSBL form app"
puts "=================================================================="
#exec bootgen -arch zynq -image output.bif -w -o "${kOutputDir}/BOOT.BIN"
