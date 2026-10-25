# UART Transmitter and Receiver on FPGA

VHDL 8N1 UART with fractional 16x baud tick, synchronized receive input, midpoint sampling, framing-error detection and a self-checking all-byte loopback bench.

## Run

Requires GHDL. Run `make test`. Defaults to 50 MHz and 115200 baud; clock must exceed 16 times baud.
