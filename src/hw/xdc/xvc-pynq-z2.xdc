## Original XDC file for pynq-z2, refer to
## https://d2m32eurp10079.cloudfront.net/Download/pynq-z2_v1.0.xdc.zip

## Clock signal 125 MHz

set_property -dict { PACKAGE_PIN H16   IOSTANDARD LVCMOS33 } [get_ports { sysclk }]; #IO_L13P_T2_MRCC_35 Sch=sysclk
create_clock -add -name sys_clk_pin -period 8.00 -waveform {0 4} [get_ports { sysclk }];

# Put Jtag port to PMOD-A port
# pin 1~4 of PMOD-A 

set_property PACKAGE_PIN T10 [get_ports TCK] 
set_property PACKAGE_PIN T11 [get_ports TDO]
set_property PACKAGE_PIN Y14 [get_ports TDI]
set_property PACKAGE_PIN W14 [get_ports TMS]
set_property IOSTANDARD LVCMOS33 [get_ports TCK]
set_property IOSTANDARD LVCMOS33 [get_ports TDO]
set_property IOSTANDARD LVCMOS33 [get_ports TDI]
set_property IOSTANDARD LVCMOS33 [get_ports TMS]
set_property PULLUP true [get_ports TCK]
set_property PULLUP true [get_ports TDO]
set_property PULLUP true [get_ports TDI]
set_property PULLUP true [get_ports TMS]