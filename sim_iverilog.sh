#!/bin/bash

BIN=sim.vvp
VV=/opt/Xilinx/Vivado/2019.1/data/verilog/src
set -e
rm -f $BIN
iverilog -Wall \
  -o $BIN \
  -I N25Q128A13E_VG12 \
  $VV/glbl.v \
  $VV/unisims/IBUF.v \
  $VV/unisims/BUFG.v \
  $VV/unisims/MMCME2_ADV.v \
  $VV/unisims/STARTUPE2.v \
  clk_for_spi.v \
  spi_cmd.v \
  qspi_mem_controller.v \
  top.v \
  N25Q128A13E_VG12/code/N25Qxxx.v \
  testbench.v

vvp $BIN
