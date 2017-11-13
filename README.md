This is a small (Q)SPI flash memory programmer in Verilog.  
It was designed as a module to be integrated into larger projects.  
For example, I use it for in-system reprogramming of the boot memory of Artix7 board via PCI express. 
It works in simulation (with verilog SPI memory models), and was tested in hardware with N25Q128 at 40 MHz clock speed.  

The Verilog interface is really simple: give address + data to be written on the input, trigger, wait for completion.
hw_test.v provides an example command sequence using the module and can be used as a top module for a small test on hardware.
As an additional feature, hw_test.v wraps around STARTUPE2 primitive - so it connects to the boot memory.

At the moment the module can: 
read ID, enable quad protocol, write enable, sector erase, bulk erase, page program, poll status register.

An N25Q128 Verilog model can be obtained from the Micron website:
https://www.micron.com/~/media/documents/products/sim-model/nor-flash/serial/bfm/n25q/n25q128a13e_3v_micronxip_vg12,-d-,tar.gz


The structure of the project is:

1: spi_cmd.v: the internal core, implements SPI write-read sequence with 4xIO and Chip Select lines  
2: qspi_mem_controller.v: uses memory-specific commands (erase, write page etc) and implements simple sequences like "start a write then poll status register until it's done"
3: hw_test.v: implements a sample sequence of real use (read ID, enable quad IO, disable write lock, (should add erase first) page program ), can be used as a top module for a hardware test
4: testbench.v: used as a simulation wrapper for hw_test.v  
5: dword_interface.v is an alternative wrapper around qspi_mem_controller.v instead of hw_test.v -- which adds a DWORD-wide interface (I use it to connect to PCIe PIO)
6: testbench_dword.v can be used to dword_interface.v instead of testbench.v


License: MIT.
