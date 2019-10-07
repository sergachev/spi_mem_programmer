.DEFAULT_GOAL := impl

clean:
	rm -rf *.jou *.log *.rpt *.vvp *.pb *.bit *.mcs *.prm \
        *webtalk.* xsim.dir/ top.cache/ top.hw/ top.ip_user_files/

impl:
	./impl.sh

prepare:
	./get_mem_model.sh

sim:	prepare
	./sim_iverilog.sh

simv:	prepare
	./sim_vivado.sh
