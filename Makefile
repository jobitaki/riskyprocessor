all: rtl/constants.sv rtl/fetch.sv rtl/decode.sv rtl/program_counter.sv rtl/alu.sv rtl/instr_memory.sv rtl/regfile.sv rtl/execute.sv rtl/mem_access.sv rtl/data_memory.sv rtl/writeback.sv rtl/forward_unit.sv rtl/risky.sv tb/risky_tb.sv
	sv2v -w risky.v rtl/constants.sv rtl/fetch.sv rtl/decode.sv rtl/program_counter.sv rtl/alu.sv rtl/instr_memory.sv rtl/regfile.sv rtl/execute.sv rtl/mem_access.sv rtl/data_memory.sv rtl/writeback.sv rtl/forward_unit.sv rtl/risky.sv tb/risky_tb.sv
	iverilog risky.v
	vvp a.out

clean:
	rm a.out risky.v dump.vcd
