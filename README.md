####Small (Q)SPI flash memory programmer in Verilog.

Can read memory chip IDs, enable quad SPI mode, disable write protection, erase sectors, do bulk erase, program pages and poll the status register.

Tested in simulation with several Verilog SPI memory models listed below and in hardware - in-system reprogramming the N25Q128 boot memory of Artix 7 at 40 MHz.

Tested memory models:
- N25Q128: https://www.micron.com/~/media/documents/products/sim-model/nor-flash/serial/bfm/n25q/n25q128a13e_3v_micronxip_vg12,-d-,tar.gz

- GD25Q16B: https://transfer.sh/l7kcx/GD25Q16B_verilog.rar (no longer available on the manufacturer's website)

- S25FL128L: https://www.cypress.com/file/260091/download


Code structure:

1: spi_cmd.v: low-level SPI write-read sequence using 4x i/o and chip select

2: qspi_mem_controller.v: memory-specific commands (erase, write page etc) and simple sequences like "start a write then poll status register until it's finished"

3: hw_test.v: minimal complete example which can be used as a top module for implementation. Uses STARTUPE2 primitive to connect to the boot memory on Xilinx FPGAs.

4: testbench.v: simulation testbench for hw_test.v  
