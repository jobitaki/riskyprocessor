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
  logic [31:0] instr_q2;

  decode u_decode (
      .clk,
      .rst_n,
      .instr_i  (instr_q1),
      .sel_rs1_o(decode_sel_rs1),
      .sel_rs2_o(decode_sel_rs2),
      .instr_o  (instr_q2)
  );

  logic [31:0] regfile_rs1;
  logic [31:0] regfile_rs2;
  logic [ 4:0] regfile_sel_rs1;
  logic [ 4:0] regfile_sel_rs2;
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
      .rs2_o    (regfile_rs2),
      .sel_rs1_o(regfile_sel_rs1),
      .sel_rs2_o(regfile_sel_rs2)
  );

  logic [31:0] instr_q3;
  logic [31:0] execute_alu_result;

  logic [ 4:0] mem_sel_rd;
  logic [31:0] mem_data;
  logic [ 4:0] execute_sel_rd;
  logic [ 1:0] fu_sel_rs1_src;
  logic [ 1:0] fu_sel_rs2_src;

  forward_unit u_forward_unit (
    .sel_rs1_i         (regfile_sel_rs1),
    .sel_rs2_i         (regfile_sel_rs2),
    .execute_sel_rd_i  (execute_sel_rd),
    .mem_sel_rd_i      (mem_sel_rd),
    .sel_rs1_src_o     (fu_sel_rs1_src),
    .sel_rs2_src_o     (fu_sel_rs2_src)
  );

  // Forwarding unit mux

  logic [31:0] fu_mux_rs1;
  logic [31:0] fu_mux_rs2;

  logic [31:0] mem_data_bypass;
  logic [31:0] writeback_data_bypass;

  always_comb begin
    case (fu_sel_rs1_src)
      FU_SRC_REG: fu_mux_rs1 = regfile_rs1;
      FU_SRC_MEM: fu_mux_rs1 = mem_data_bypass;
      FU_SRC_WB:  fu_mux_rs1 = writeback_data_bypass;
      default:    fu_mux_rs1 = '0;
    endcase
    
    case (fu_sel_rs2_src)
      FU_SRC_REG: fu_mux_rs2 = regfile_rs2;
      FU_SRC_MEM: fu_mux_rs2 = mem_data_bypass;
      FU_SRC_WB:  fu_mux_rs2 = writeback_data_bypass;
      default:    fu_mux_rs2 = '0;
    endcase
  end

  logic [31:0] execute_rs2;

  execute u_execute (
    .clk,
    .rst_n,
    .instr_i     (instr_q2),
    .rs1_i       (fu_mux_rs1),
    .rs2_i       (fu_mux_rs2),
    .instr_o     (instr_q3),
    .alu_result_o(execute_alu_result),
    .rs2_o       (execute_rs2),
    .sel_rd_o    (execute_sel_rd)
  );

  logic [31:0] instr_q4;
  logic [31:0] mem_alu_result;

  mem_access u_mem_access (
    .clk,
    .rst_n,
    .instr_i      (instr_q3),
    .alu_result_i (execute_alu_result),
    .data_i       (execute_rs2),
    .instr_o      (instr_q4),
    .alu_result_o (mem_alu_result),
    .data_o       (mem_data),
    .data_bypass_o(mem_data_bypass),
    .sel_rd_o     (mem_sel_rd)
  );

  writeback u_writeback (
    .clk,
    .rst_n,
    .instr_i      (instr_q4),
    .alu_result_i (mem_alu_result),
    .data_i       (mem_data),
    .data_bypass_o(writeback_data_bypass),
    .sel_rd_o     (writeback_sel_rd),
    .we_o         (writeback_we),
    .data_o       (writeback_data)
  );

endmodule : risky
