create_project -force -name top -part xc7a200tfbg484-1
add_files {top.v qspi_mem_controller.v clk_for_spi.v spi_cmd.v}
read_xdc top.xdc
synth_design -top top -part xc7a200tfbg484-1 -verilog_define "__SYNTHESIS__"
opt_design
place_design
phys_opt_design
report_utilization -hierarchical -file top_utilization_hierarchical_place.rpt
report_utilization -file top_utilization_place.rpt
route_design
phys_opt_design
report_timing_summary -no_header -no_detailed_paths
report_drc -file top_drc.rpt
report_timing_summary -datasheet -max_paths 10 -file top_timing.rpt
write_bitstream -force top.bit
write_cfgmem -checksum -force -format mcs -interface SPIx1 -size 64 -loadbit "up 0x0 top.bit" -file top.mcs
quit
