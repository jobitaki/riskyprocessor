`default_nettype none

import constants::*

//
//  Module 'risky'
//
//  The top module of the Risky RISCV32I processor.
//
module risky (
    input logic clk,
    input logic rst_n
);

  logic        fetch_re;
  logic        execute_stall;
  logic [31:0] instr_q1;
  tri   [31:0] instr_memory_bus;
  logic        decode_branch;
  logic        execute_branch_taken;

  fetch u_fetch (
      .clk,
      .rst_n,
      .instr_i         (instr_memory_bus),
      .stall_i         (execute_stall),
      .branch_resolve_i(decode_branch),
      .re_o            (fetch_re),
      .instr_o         (instr_q1)
  );

  logic [31:0] pc;
  logic [31:0] pc_i;

  always_comb begin
    if (execute_branch_taken) begin
      pc_i = pc + decode_imm;
    end else begin
      pc_i = pc + 4;
    end
  end

  logic pc_en;
  assign pc_en = fetch_re | decode_branch;

  program_counter u_program_counter (
      .clk,
      .rst_n,
      .pc_i,
      .en_i(pc_en),
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
  alu_op_e     decode_alu_op;
  alu_src_e    decode_alu_src1, decode_alu_src2;
  logic        decode_mem_re, decode_mem_we;
  data_size_e  decode_mem_size;
  logic [31:0] decode_imm;

  decode u_decode (
      .clk,
      .rst_n,
      .instr_i   (instr_q1),
      .stall_i   (execute_stall),
      .sel_rs1_o (decode_sel_rs1),
      .sel_rs2_o (decode_sel_rs2),
      .sel_rd_o  (decode_sel_rd),
      .alu_op_o  (decode_alu_op),
      .alu_src1_o(decode_alu_src1),
      .alu_src2_o(decode_alu_src2),
      .mem_re_o  (decode_mem_re),
      .mem_we_o  (decode_mem_we),
      .mem_size_o(decode_mem_size),
      .imm_o     (decode_imm),
      .branch_o  (decode_branch)
  );

  logic [31:0] regfile_rs1, regfile_rs2;
  logic [ 4:0] regfile_sel_rs1, regfile_sel_rs2;
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

  logic [31:0] execute_alu_result;

  logic [ 4:0] memacc_sel_rd;
  logic [ 4:0] execute_sel_rd;
  logic [ 1:0] fu_sel_rs1_src, fu_sel_rs2_src;

  forward_unit u_forward_unit (
      .sel_rs1_i         (regfile_sel_rs1),
      .sel_rs2_i         (regfile_sel_rs2),
      .mem_stage_sel_rd_i(execute_sel_rd),
      .wb_stage_sel_rd_i (memacc_sel_rd),
      .sel_rs1_src_o     (fu_sel_rs1_src),
      .sel_rs2_src_o     (fu_sel_rs2_src)
  );

  // Forwarding unit mux

  logic [31:0] fu_mux_rs1, fu_mux_rs2;

  logic [31:0] memacc_data_bypass;
  logic [31:0] writeback_data_bypass;

  always_comb begin
    case (fu_sel_rs1_src)
      FU_SRC_REG: fu_mux_rs1 = regfile_rs1;
      FU_SRC_MEM: fu_mux_rs1 = memacc_data_bypass;
      FU_SRC_WB:  fu_mux_rs1 = writeback_data_bypass;
      default:    fu_mux_rs1 = '0;
    endcase
    
    case (fu_sel_rs2_src)
      FU_SRC_REG: fu_mux_rs2 = regfile_rs2;
      FU_SRC_MEM: fu_mux_rs2 = memacc_data_bypass;
      FU_SRC_WB:  fu_mux_rs2 = writeback_data_bypass;
      default:    fu_mux_rs2 = '0;
    endcase
  end

  logic [31:0] execute_rs2;
  logic        execute_mem_re, execute_mem_we;
  data_size_e  execute_mem_size;

  execute u_execute (
      .clk,
      .rst_n,
      .sel_rd_i      (decode_sel_rd),
      .alu_op_i      (decode_alu_op),
      .alu_src1_i    (decode_alu_src1),
      .alu_src2_i    (decode_alu_src2),
      .mem_re_i      (decode_mem_re),
      .mem_we_i      (decode_mem_we),
      .mem_size_i    (decode_mem_size),
      .imm_i         (decode_imm),
      .branch_i      (decode_branch),
      .rs1_i         (fu_mux_rs1),
      .rs2_i         (fu_mux_rs2),
      .pc_i          (pc),
      .sel_rd_o      (execute_sel_rd),
      .mem_re_o      (execute_mem_re),
      .mem_we_o      (execute_mem_we),
      .mem_size_o    (execute_mem_size),
      .alu_result_o  (execute_alu_result),
      .rs2_o         (execute_rs2),
      .stall_o       (execute_stall),
      .branch_taken_o(execute_branch_taken)
  );

  logic [31:0] memacc_alu_result;
  logic [31:0] memacc_data;
  logic        memacc_mem_re, memacc_mem_we;

  // TODO implement hazard detection for mem_access stage store operations

  mem_access u_mem_access (
    .clk,
    .rst_n,
    .sel_rd_i     (execute_sel_rd),
    .mem_re_i     (execute_mem_re),
    .mem_we_i     (execute_mem_we),
    .mem_size_i   (execute_mem_size),
    .alu_result_i (execute_alu_result),
    .data_i       (execute_rs2),
    .stall_i      (execute_stall),
    .mem_re_o     (memacc_mem_re),
    .mem_we_o     (memacc_mem_we),
    .alu_result_o (memacc_alu_result),
    .data_o       (memacc_data),
    .data_bypass_o(memacc_data_bypass),
    .sel_rd_o     (memacc_sel_rd)
  );

  writeback u_writeback (
    .clk,
    .rst_n,
    .sel_rd_i     (memacc_sel_rd),
    .mem_re_i     (memacc_mem_re),
    .mem_we_i     (memacc_mem_we),
    .alu_result_i (memacc_alu_result),
    .data_i       (memacc_data),
    .data_bypass_o(writeback_data_bypass),
    .sel_rd_o     (writeback_sel_rd),
    .we_o         (writeback_we),
    .data_o       (writeback_data)
  );

endmodule : risky
