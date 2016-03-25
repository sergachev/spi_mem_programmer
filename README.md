This is a small (Q)SPI flash programmer in verilog.  
It's written as a module to be integrated into larger projects.  
For example, I use it for in-system reprogramming of the boot memory of Artix7 board via PCI express. 

Works in simulation (with verilog SPI memory models), and tested on hardware with N25Q128 at 40MHz.  

The verilog interface is really simple: i.e. give address + data to be written on the input, trigger, wait for completion.
hw_test.v provides an example command sequence using the module.  

At the moment the module supports these features: read ID, enable quad protocol, write enable, sector erase, bulk erase, page program, poll status register.

N25Q128 verilog model can be obtained from Micron website:
https://www.micron.com/~/media/documents/products/sim-model/nor-flash/serial/bfm/n25q/n25q128a13e_3v_micronxip_vg12,-d-,tar.gz

The structure is:


1: spi_cmd.v: the very core, implements SPI write-read sequence with 4xIO and Chip Select lines  
2: qspi_mem_controller.v:  uses mem-specific commands (erase, write page etc) and implements simple sequences like "start write - poll status reg for completion"  
3: hw_test.v: shows an example sequence of real use (read ID, enable quad IO, disable write lock, (should add erase first) page program ), can be used as top module for implementation  
4: testbench.v: used as simulation wrapper for hw_test.v  

dword_interface.v is an alternative wrapper around qspi_mem_controller.v (instead of hw_test.v) which adds a DWORD-wide interface to connect to PCIe PIO.  
testbench_dword.v can be used to test it.  
