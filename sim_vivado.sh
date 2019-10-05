#!/bin/bash

source /opt/Xilinx/Vivado/2019.1/settings64.sh
xelab -prj sim_vivado.prj -s sim xil_defaultlib.testbench xil_defaultlib.glbl
xsim -R sim
