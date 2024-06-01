`default_nettype none

module risky (
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
  tri [31:0] instr_memory_bus;

  fetch u_fetch (
      .clk,
      .rst_n,
      .instr_i(instr_memory_bus),
      .stall_i(1'b0),
      .re_o   (fetch_re),
      .instr_o(instr_q1)
  );

  logic [31:0] pc;
  logic [31:0] pc_i;

  // TODO change into a mux
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
      .addr_i(pc),
      .bus_io(instr_memory_bus),
      .re_i  (fetch_re),
      .we_i  (1'b0)
  );

  logic decode_sel_rs1;
  logic decode_sel_rs2;
  logic decode_sel_rd;
  logic [19:0] decode_imm;
  logic [4:0] opcode_q2; // q2 because already 1 cycle latency with instr


  decode u_decode (
      .clk,
      .rst_n,
      .instr_i  (instr_q1),
      .sel_rs1_o(decode_sel_rs1),
      .sel_rs2_o(decode_sel_rs2),
      .sel_rd_o (decode_sel_rd),
      .imm_o    (decode_imm),
      .opcode_o (opcode_q2)
  );
  
  logic [31:0] regfile_rs1;
  logic [31:0] regfile_rs2;
  
  regfile u_regfile (
      .clk,
      .rst_n,
      .sel_rd_i (5'b0),
      .rd_i     (32'b0),
      .we_i     (1'b0),
      .sel_rs1_i(decode_sel_rs1),
      .sel_rs2_i(decode_sel_rs2),
      .rs1_o    (regfile_rs1),
      .rs2_o    (regfile_rs2)
  );

  logic [ 4:0] opcode_q3;
  logic [31:0] execute_alu_result;

  execute u_execute (
    .clk,
    .rst_n,
    .opcode_i(opcode_q2),
    .rs1_i   (regfile_rs1),
    .rs2_i   (regfile_rs2),
    .rd_i    (decode_sel_rd),
    .imm_i   (decode_imm),
    .opcode_o(opcode_q3),
    .result_o(execute_alu_result)
  );

  tri   [31:0] data_memory_bus;
  logic [ 4:0] opcode_q4;
  logic mem_re;
  logic mem_we;
  logic [31:0] mem_data;

  mem_access u_mem_access (
    .clk,
    .rst_n,
    .opcode_i    (opcode_q3),
    .alu_result_i(execute_alu_result),
    .data_i      (data_memory_bus),
    .re_o        (mem_re),
    .we_o        (mem_we),
    .opcode_o    (opcode_q4),
    .data_o      (mem_data)
  );

  data_memory u_data_memory (
    .clk,
    .addr_i(execute_alu_result),
    .bus_io(data_memory_bus),
    .re_i  (mem_re),
    .we_i  (mem_we)
  );



endmodule : risky
