#!/bin/bash

set -e
source /opt/Xilinx/Vivado/2019.1/settings64.sh
xelab --include N25Q128A13E_VG12 -prj sim_vivado.prj -s sim xil_defaultlib.testbench xil_defaultlib.glbl
xsim -R sim
