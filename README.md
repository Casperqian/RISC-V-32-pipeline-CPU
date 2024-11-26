# CPU Design
This codebase is the official implementation of our **32-bit three-level pipeline CPU**. We verified the validity through synthesis and simulation using EDA software, and the validation instruction text document is shown above.
## Quick Start
### Installation
- Vivado
- ModelSim 10.5
### Note
1. Different module code is included in `RISC-V-32-pipeline-CPU-main/rtl`.
2. Code of common modules is included in `RISC-V-32-pipeline-CPU-main/utils`
3. `RISC-V-32-pipeline-CPU-main/tb` contains testbench and top level of the CPU. 
4.  The testing instruction lines are included in `RISC-V-32-pipeline-CPU-main/tb/inst_txt`
## Testing on FPGA board
An FPGA board of type ZYNQ-7000 was utilized for board-level validation. All CPU instructions were tested on the FPGA through onboard LEDs. An ILA IP core was integrated to probe internal signals for verification purposes.

Set of Pins is defined below:
```verilog 
set_property -dict {PACKAGE_PIN M19 IOSTANDARD LVCMOS33} [get_ports clk]  
set_property -dict {PACKAGE_PIN AB6 IOSTANDARD LVCMOS33} [get_ports rst]  
set_property -dict {PACKAGE_PIN U7 IOSTANDARD LVCMOS33} [get_ports {led[7]}]  
set_property -dict {PACKAGE_PIN W5 IOSTANDARD LVCMOS33} [get_ports {led[6]}]  
set_property -dict {PACKAGE_PIN W6 IOSTANDARD LVCMOS33} [get_ports {led[5]}]  
set_property -dict {PACKAGE_PIN W7 IOSTANDARD LVCMOS33} [get_ports {led[4]}]  
set_property -dict {PACKAGE_PIN V7 IOSTANDARD LVCMOS33} [get_ports {led[3]}]  
set_property -dict {PACKAGE_PIN U5 IOSTANDARD LVCMOS33} [get_ports {led[2]}]  
set_property -dict {PACKAGE_PIN U6 IOSTANDARD LVCMOS33} [get_ports {led[1]}]  
set_property -dict {PACKAGE_PIN V4 IOSTANDARD LVCMOS33} [get_ports {led[0]}] 
```
