## clock 100 MHz
set_property -dict { PACKAGE_PIN E3  IOSTANDARD LVCMOS33 } [get_ports clk]
create_clock -add -name sys_clk -period 10.000 -waveform {0 5} [get_ports clk]

## resetn (active-low) 
set_property -dict { PACKAGE_PIN C12 IOSTANDARD LVCMOS33 PULLUP true } [get_ports resetn]

## step/execute button
set_property -dict { PACKAGE_PIN M18 IOSTANDARD LVCMOS33 PULLDOWN true } [get_ports w] ;# BTNU

## Instruction switches IR_in[5:0] -> SW15..SW10
set_property -dict { PACKAGE_PIN V10 IOSTANDARD LVCMOS33 } [get_ports {IR_in[5]}] ;# SW15
set_property -dict { PACKAGE_PIN U11 IOSTANDARD LVCMOS33 } [get_ports {IR_in[4]}] ;# SW14
set_property -dict { PACKAGE_PIN U12 IOSTANDARD LVCMOS33 } [get_ports {IR_in[3]}] ;# SW13
set_property -dict { PACKAGE_PIN H6  IOSTANDARD LVCMOS33 } [get_ports {IR_in[2]}] ;# SW12
set_property -dict { PACKAGE_PIN T13 IOSTANDARD LVCMOS33 } [get_ports {IR_in[1]}] ;# SW11
set_property -dict { PACKAGE_PIN R16 IOSTANDARD LVCMOS33 } [get_ports {IR_in[0]}] ;# SW10

## Data switches IN_sw[7:0] -> SW7..SW0 
set_property -dict { PACKAGE_PIN R13 IOSTANDARD LVCMOS33 } [get_ports {IN_sw[7]}] ;# SW7
set_property -dict { PACKAGE_PIN U18 IOSTANDARD LVCMOS33 } [get_ports {IN_sw[6]}] ;# SW6
set_property -dict { PACKAGE_PIN T18 IOSTANDARD LVCMOS33 } [get_ports {IN_sw[5]}] ;# SW5
set_property -dict { PACKAGE_PIN R17 IOSTANDARD LVCMOS33 } [get_ports {IN_sw[4]}] ;# SW4
set_property -dict { PACKAGE_PIN R15 IOSTANDARD LVCMOS33 } [get_ports {IN_sw[3]}] ;# SW3
set_property -dict { PACKAGE_PIN M13 IOSTANDARD LVCMOS33 } [get_ports {IN_sw[2]}] ;# SW2
set_property -dict { PACKAGE_PIN L16 IOSTANDARD LVCMOS33 } [get_ports {IN_sw[1]}] ;# SW1
set_property -dict { PACKAGE_PIN J15 IOSTANDARD LVCMOS33 } [get_ports {IN_sw[0]}] ;# SW0

## 7-segment segments CA..CG
set_property -dict { PACKAGE_PIN T10 IOSTANDARD LVCMOS33 } [get_ports {seg[0]}] ;# CA
set_property -dict { PACKAGE_PIN R10 IOSTANDARD LVCMOS33 } [get_ports {seg[1]}] ;# CB
set_property -dict { PACKAGE_PIN K16 IOSTANDARD LVCMOS33 } [get_ports {seg[2]}] ;# CC
set_property -dict { PACKAGE_PIN K13 IOSTANDARD LVCMOS33 } [get_ports {seg[3]}] ;# CD
set_property -dict { PACKAGE_PIN P15 IOSTANDARD LVCMOS33 } [get_ports {seg[4]}] ;# CE
set_property -dict { PACKAGE_PIN T11 IOSTANDARD LVCMOS33 } [get_ports {seg[5]}] ;# CF
set_property -dict { PACKAGE_PIN L18 IOSTANDARD LVCMOS33 } [get_ports {seg[6]}] ;# CG
# (DP is unused)

## 7-segment digit enables AN7..AN0
set_property -dict { PACKAGE_PIN U13 IOSTANDARD LVCMOS33 } [get_ports {an[7]}]
set_property -dict { PACKAGE_PIN K2  IOSTANDARD LVCMOS33 } [get_ports {an[6]}]
set_property -dict { PACKAGE_PIN T14 IOSTANDARD LVCMOS33 } [get_ports {an[5]}]
set_property -dict { PACKAGE_PIN P14 IOSTANDARD LVCMOS33 } [get_ports {an[4]}]
set_property -dict { PACKAGE_PIN J14 IOSTANDARD LVCMOS33 } [get_ports {an[3]}]
set_property -dict { PACKAGE_PIN T9  IOSTANDARD LVCMOS33 } [get_ports {an[2]}]
set_property -dict { PACKAGE_PIN J18 IOSTANDARD LVCMOS33 } [get_ports {an[1]}]
set_property -dict { PACKAGE_PIN J17 IOSTANDARD LVCMOS33 } [get_ports {an[0]}]
