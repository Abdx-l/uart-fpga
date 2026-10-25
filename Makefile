test:
	ghdl -a --std=08 uart.vhd tb.vhd
	ghdl -e --std=08 tb
	ghdl -r --std=08 tb --assert-level=error
