#!/bin/bash

BIN=.sim.bin
VV=/opt/Xilinx/Vivado/2019.1/data/verilog/src
rm $BIN
iverilog -Wall \
  -o $BIN \
  $VV/glbl.v \
  $VV/unisims/IBUF.v \
  $VV/unisims/BUFG.v \
  $VV/unisims/MMCME2_ADV.v \
  $VV/unisims/STARTUPE2.v \
  clk_for_spi.v \
  spi_cmd.v \
  qspi_mem_controller.v \
  top.v \
  N25Qxxx.v \
  testbench.v \

./$BIN
