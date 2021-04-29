set kOutputDir "xvc_server_os" 
setws ${kOutputDir}

set kXSAFilePath "xvc_server_hw/xvc_system_top.xsa"
createhw -name hw0 -hwspec ${kXSAFilePath}

createapp -name fsbl -app {Zynq FSBL} -proc ps7_cortexa9_0 \
  -hwproject hw0 -os standalone

project -build

exec bootgen -arch zynq -image output.bif -w -o BOOT.bin
