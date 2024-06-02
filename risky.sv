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

  logic [ 4:0] decode_sel_rs1, decode_sel_rs2, decode_sel_rd;
  logic [19:0] decode_imm;
  logic [31:0] instr_q2;


  decode u_decode (
      .clk,
      .rst_n,
      .instr_i  (instr_q1),
      .sel_rs1_o(decode_sel_rs1),
      .sel_rs2_o(decode_sel_rs2),
      .sel_rd_o (decode_sel_rd),
      .imm_o    (decode_imm),
      .instr_o  (instr_q2)
  );

  logic [31:0] regfile_rs1;
  logic [31:0] regfile_rs2;
  logic        writeback_we;
  logic [ 4:0] writeback_sel_rd;
  logic [31:0] writeback_data;

  regfile u_regfile (
      .clk,
      .rst_n,
      .sel_rd_i (writeback_sel_rd),
      .rd_i     (writeback_data),
      .we_i     (writeback_we),
      .sel_rs1_i(decode_sel_rs1),
      .sel_rs2_i(decode_sel_rs2),
      .rs1_o    (regfile_rs1),
      .rs2_o    (regfile_rs2)
  );

  logic [31:0] instr_q3;
  logic [31:0] execute_alu_result;
  logic [ 4:0] execute_sel_rd;

  execute u_execute (
    .clk,
    .rst_n,
    .instr_i     (instr_q2),
    .rs1_i       (regfile_rs1),
    .rs2_i       (regfile_rs2),
    .sel_rd_i    (decode_sel_rd),
    .imm_i       (decode_imm),
    .instr_o     (instr_q3),
    .sel_rd_o    (execute_sel_rd),
    .alu_result_o(execute_alu_result)
  );

  tri   [31:0] data_memory_bus;
  logic [31:0] instr_q4;
  logic [31:0] mem_data;
  logic [31:0] mem_access_alu_result;

  mem_access u_mem_access (
    .clk,
    .rst_n,
    .instr_i     (instr_q3),
    .alu_result_i(execute_alu_result),
    .instr_o     (instr_q4),
    .alu_result_o(mem_access_alu_result),
    .data_o      (mem_data)
  );

  writeback u_writeback (
    .clk,
    .rst_n,
    .instr_i     (instr_q4),
    .alu_result_i(mem_access_alu_result),
    .data_i      (mem_data),
    .sel_rd_o    (writeback_sel_rd),
    .we_o        (writeback_we),
    .data_o      (writeback_data)
  );

endmodule : risky
