#!/bin/bash

wget -nc https://www.micron.com/~/media/documents/products/sim-model/nor-flash/serial/bfm/n25q/n25q128a13e_3v_micronxip_vg12,-d-,tar.gz
md5sum -c checksums.txt
tar xf n25q128a13e_3v_micronxip_vg12,-d-,tar.gz
patch N25Q128A13E_VG12/code/N25Qxxx.v n25q_force.patch
