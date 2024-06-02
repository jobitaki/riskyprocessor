all: constants.sv fetch.sv decode.sv program_counter.sv alu.sv instr_memory.sv regfile.sv execute.sv mem_access.sv data_memory.sv writeback.sv risky.sv risky_tb.sv
	sv2v -w risky.v constants.sv fetch.sv decode.sv program_counter.sv alu.sv instr_memory.sv regfile.sv execute.sv mem_access.sv data_memory.sv writeback.sv risky.sv risky_tb.sv
	iverilog risky.v
	vvp a.out

clean:
	rm a.out risky.v dump.vcd
