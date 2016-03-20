This is a small (Q)SPI flash programmer in verilog.  
It's written as a module to be integrated into larger projects.  
For example, I use it for in-system reprogramming the boot memory of Artix7 via PCI express.  
Works in simulation (with verilog SPI memory model), and tested on hardware with N25Q128 at 40MHz.  
The verilog interface is really simple: i.e. give address + data to be written on the input, trigger, wait for completion.
hw_test.v provides an example command sequence using the module.  
At the moment it supports these features: read ID, enable quad protocol, write enable, sector erase, bulk erase, page program, poll status register.
