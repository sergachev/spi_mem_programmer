set_property BITSTREAM.GENERAL.COMPRESS TRUE [current_design]
set_property BITSTREAM.GENERAL.JTAG_XADC DISABLE [current_design]
set_property BITSTREAM.GENERAL.XADCPOWERDOWN ENABLE [current_design]
set_property BITSTREAM.CONFIG.CONFIGRATE 50 [current_design]
set_property BITSTREAM.CONFIG.SPI_BUSWIDTH 4 [current_design]

set_property CONFIG_VOLTAGE 3.3 [current_design]
set_property CFGBVS VCCO [current_design]

set_operating_conditions -airflow 0
set_operating_conditions -heatsink low

set_property IOSTANDARD LVCMOS33 [get_ports {S {DQio[*]} CLK_100M {status_led[*]}}]

set_property PACKAGE_PIN T19 [get_ports S]
set_property PACKAGE_PIN P22 [get_ports {DQio[0]}]
set_property PACKAGE_PIN R22 [get_ports {DQio[1]}]
set_property PACKAGE_PIN P21 [get_ports {DQio[2]}]
set_property PACKAGE_PIN R21 [get_ports {DQio[3]}]

set_property PACKAGE_PIN H4 [get_ports CLK_100M]

set_property PACKAGE_PIN B1 [get_ports {status_led[1]}]
set_property PACKAGE_PIN D1 [get_ports {status_led[0]}]


create_generated_clock -name cclk -source [get_pins STARTUPE2_inst/USRCCLKO] -combinational [get_pins STARTUPE2_inst/USRCCLKO]
set_input_delay -clock [get_clocks cclk] -clock_fall -min -add_delay 1.000 [get_ports {DQio[*]}]
set_input_delay -clock [get_clocks cclk] -clock_fall -max -add_delay 6.000 [get_ports {DQio[*]}]
set_output_delay -clock [get_clocks cclk] -min -add_delay -3.000 [get_ports {DQio[*]}]
set_output_delay -clock [get_clocks cclk] -max -add_delay 2.000 [get_ports {DQio[*]}]
set_output_delay -clock [get_clocks cclk] -min -add_delay -4.000 [get_ports S]
set_output_delay -clock [get_clocks cclk] -max -add_delay 4.000 [get_ports S]


set_false_path -to [get_ports {status_led[*]}]
set_false_path -from [get_ports rst]
