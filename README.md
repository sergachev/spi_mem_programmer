## Small (Q)SPI flash memory programmer in Verilog

Targets N25Q128 memory, adaptable to other ones.
Can read memory chip ID, enable quad SPI mode, disable write protection, erase sectors, do bulk erase, program pages and poll the status register.


#### Implementation
`top.v` can be used to implement a minimal test design for a Xilinx FPGA (tested on Artix); STARTUPE2 primitive is used to talk to the boot memory of the FPGA. `top.xdc` are the constraints to use together. Configured to run from 100 MHz external clock converting it to 40 MHz for SPI; indicates the test progress using 2 LEDs.


#### Simulation
`testbench.v` wraps `top.v` for a simulation with a Verilog model of the memory. `sim.sh` runs the simulation with Icarus Verilog (https://github.com/steveicarus/iverilog); Xilinx Vivado simulator can be used as well. 
###### Requirements:
- Memory model files (`N25Qxxx.v`, `*.vmf`, `include/*`) from https://www.micron.com/~/media/documents/products/sim-model/nor-flash/serial/bfm/n25q/n25q128a13e_3v_micronxip_vg12,-d-,tar.gz
- line 2024 in `N25Qxxx.v` has to be patched at least for Icarus Verilog (see https://github.com/steveicarus/iverilog/issues/131)
- Xilinx primitives Verilog models from Vivado (see `sim.sh`)

#### Notes
The 256-byte wide data interface is definitely inoptimal for implementation (though it works) and should be replaced with something more reasonable.
