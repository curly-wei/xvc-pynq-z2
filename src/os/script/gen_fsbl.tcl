set kAPPName "xvc_fsbl"
set kPlatformName "${kAPPName}_pf"
set kDomainName "${kAPPName}_dom"
set kBuildDir "[pwd]"
set kXSAFilePath "${kBuildDir}/xvc_server_hw/xvc_system_top.xsa"
set kOutputDir "${kBuildDir}/xvc_server_os/fsbl" 

setws ${kOutputDir}


puts "UserINFO: clear previous build objects"
file delete -force ${kOutputDir}


puts "UserINFO: check xsa file if exist"
if { [file exist ${kXSAFilePath}] == 1} {
  puts "UserINFO: Found xsa file, located at:"
  puts [file normalize ${kXSAFilePath}] 
} else {
  error "ERROR: xsa file does not exist"
}


puts "UserINFO: create pf"
platform create \
  -name ${kPlatformName} \
  -hw ${kXSAFilePath}


puts "UserINFO: create domain"
domain create \
  -name ${kDomainName} \
  -os standalone \
  -proc ps7_cortexa9_0


puts "UserINFO: set bsplib xilffs"
bsp setlib xilffs


puts "UserINFO: gen pf"
platform generate


puts "UserINFO: create app"
app create \
  -name ${kAPPName} \
  -platform ${kPlatformName} \
  -domain ${kDomainName} \
  -template {Zynq FSBL} 


puts "UserINFO: conf app"
app config \
  -name ${kAPPName} \
  define-compiler-symbols {FSBL_DEBUG_INFO}


puts "UserINFO: build app"
app build -name ${kAPPName} 


puts "UserINFO: Generate FSBL form app"
#exec bootgen -arch zynq -image output.bif -w -o "${kOutputDir}/BOOT.BIN"
