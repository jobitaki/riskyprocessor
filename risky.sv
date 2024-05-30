`default_nettype none

module risky(
  input logic clk,
  input logic rst_n
);

  // ALU + MUXES
  // REGFILE
  // MDR, MAR
  // DECODER
  // IR
  // PC

  logic fetch_re;
  logic [31:0] instr_q1;
  tri instr_memory_bus;

  fetch u_fetch (
    .clk,
    .rst_n,
    .instr_i(instr_memory_bus),
    .stall_i(),
    .re_o(fetch_re),
    .instr_o(instr_q1)
  );

  logic [31:0] pc;
  logic [31:0] pc_i;

  assign pc_i = pc + 4;

  program_counter u_program_counter (
    .clk,
    .rst_n,
    .pc_i,
    .en_i(fetch_re),
    .pc_o(pc)
  );

  instr_memory u_instr_memory (
    .clk,
    .addr_i(pc_o),
    .bus_io(instr_memory_bus),
    .re_i(fetch_re),
    .we_i(1'b0)
  );

  decode u_decode (
    .clk,
    .rst_n,
    .instr_i(),
    .sel_rs1_o(),
    .sel_rs2_o(),
    .imm_o(),
    .opcode_o()
  );

  logic [31:0] execute_alu_result;

  execute u_execute (
    .instr_i,
    .rs1_i,
    .rs2_i,
    .imm_i,
    .result_o(execute_alu_result)
  );

  mem_access u_mem_access (
    .clk,
    .rst_n,
    .opcode_i,
    .alu_result_i,
    .data_i,
    .re_o,
    .we_o,
    .opcode_o,
    .data_o
  );

  data_memory u_data_memory (
    .clk,
    .addr_i(execute_alu_result),
    .bus_io,
    .re_i,
    .we_i
  );

  // regfile u_regfile (
  //   .clock,
  //   .reset,
  //   .sel_rd,
  //   .in_rd,
  //   .we,
  //   .sel_rs1,
  //   .sel_rs2,
  //   .out_rs1,
  //   .out_rs2
  // );


endmodule : risky
