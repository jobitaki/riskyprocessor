`default_nettype none

import constants::*;

//  Module 'decode'
//
//  The ID (instruction decode) stage of the pipeline. Instructions are decoded
//  and registers are read from the regfile.
//
module decode (
    input  logic              clk,
    input  logic              rst_n,
    input  logic       [31:0] instr_i,     // Instruction in
    input  logic              stall_i,     // Stall pipeline up to execute
    output logic       [ 4:0] sel_rs1_o,   // Register 1 id
    output logic       [ 4:0] sel_rs2_o,   // Register 2 id
    output logic       [ 4:0] sel_rd_o,    // Destination register id
    output alu_op_e           alu_op_o,    // ALU opcode
    output alu_src_e          alu_src1_o,  // ALU mux sel
    output alu_src_e          alu_src2_o,  // ALU mux sel
    output logic              mem_re_o,    // Memory read enable
    output logic              mem_we_o,    // Memory write enable
    output data_size_e        mem_size_o,  // Size and signedness of memory instr
    output logic       [31:0] imm_o,       // Immediate value
    output logic              branch_o,    // True if instr in front is branch
    output logic              jump_o       // True if instr in front is jump
);

  // The instruction decode stage should take in a 32-bit instruction and read
  // the proper registers from the regfile.

  // It should also generate the necessary control signals
  // ALU_OP, mem_re, mem_we, DEST_REG, ALU_SRC1, ALU_SRC2, IMM
  logic    [4:0] sel_rd;
  alu_op_e       alu_op;
  alu_src_e alu_src1, alu_src2;
  logic mem_re, mem_we;
  data_size_e        mem_size;
  logic       [31:0] imm;
  logic              branch;
  logic              jump;

  always_ff @(posedge clk, negedge rst_n) begin
    if (!rst_n) begin
      sel_rd_o   <= '0;
      alu_op_o   <= '0;
      alu_src1_o <= '0;
      alu_src2_o <= '0;
      mem_re_o   <= '0;
      mem_we_o   <= '0;
      mem_size   <= '0;
      imm_o      <= '0;
      branch_o   <= '0;
      jump_o     <= '0;
    end else if (!stall_i) begin
      sel_rd_o   <= sel_rd;
      alu_op_o   <= alu_op;
      alu_src1_o <= alu_src1;
      alu_src2_o <= alu_src2;
      mem_re_o   <= mem_re;
      mem_we_o   <= mem_we;
      mem_size_o <= mem_size;
      imm_o      <= imm;
      branch_o   <= branch;
      jump_o     <= jump;
    end
  end

  /////////////
  // Decoder //
  /////////////

  always_comb begin
    unique casez (instr_i)
      // Oui instructions
      U_LUI: begin
        sel_rs1_o = '0;
        sel_rs2_o = '0;
        sel_rd    = instr_i[11:7];
        alu_op    = ALU_PASS;
        alu_src1  = ALU_SRC_IMM;
        alu_src2  = '0;
        mem_re    = 1'b0;
        mem_we    = 1'b0;
        mem_size  = UNDEF;
        imm       = {instr_i[31:12], 12'd0};
        branch    = 1'b0;
        jump      = 1'b0;
        $display("LUI x%0d, 0x%h", sel_rd, imm);
      end

      U_AUIPC: begin
        sel_rs1_o = '0;
        sel_rs2_o = '0;
        sel_rd    = instr_i[11:7];
        alu_op    = ALU_ADD;
        alu_src1  = ALU_SRC_IMM;
        alu_src2  = ALU_SRC_PC;
        mem_re    = 1'b0;
        mem_we    = 1'b0;
        mem_size  = UNDEF;
        imm       = {instr_i[31:12], 12'd0};
        branch    = 1'b0;
        jump      = 1'b0;
        $display("AUIPC x%0d, 0x%h", sel_rd, imm);
      end

      // Jump instructions

      J_JAL: begin
        sel_rs1_o = '0;
        sel_rs2_o = '0;
        sel_rd    = instr_i[11:7];
        alu_op    = ALU_PASS;
        alu_src1  = '0;
        alu_src2  = '0;
        mem_re    = 1'b0;
        mem_we    = 1'b0;
        mem_size  = UNDEF;
        imm       = {{12{instr_i[31]}}, instr_i[19:12], instr_i[20], instr_i[30:21], 1'b0};
        branch    = 1'b1;
        jump      = 1'b1;
        $display("JAL x%0d, %0d", sel_rd, $signed(imm));
      end

      I_JALR: begin
        sel_rs1_o = instr_i[19:15];
        sel_rs2_o = '0;
        sel_rd    = instr_i[11:7];
        alu_op    = ALU_PASS;
        alu_src1  = ALU_SRC_PC;
        alu_src2  = '0;
        mem_re    = 1'b0;
        mem_we    = 1'b0;
        mem_size  = UNDEF;
        imm       = instr_i[31:20];
        branch    = 1'b0;
        jump      = 1'b1;
        $display("JALR x%0d, %0d", sel_rd, $signed(imm));
      end

      // Branch instructions

      B_BEQ: begin
        sel_rs1_o = instr_i[19:15];
        sel_rs2_o = instr_i[24:20];
        sel_rd    = '0;
        alu_op    = ALU_EQ;
        alu_src1  = ALU_SRC_RS1;
        alu_src2  = ALU_SRC_RS2;
        mem_re    = 1'b0;
        mem_we    = 1'b0;
        mem_size  = UNDEF;
        imm       = {{20{instr_i[31]}}, instr_i[7], instr_i[30:25], instr_i[11:8], 1'b0};
        branch    = 1'b1;
        jump      = 1'b0;
        $display("BEQ x%0d, x%0d, %0d", sel_rs1_o, sel_rs2_o, $signed(imm));
      end

      B_BNE: begin
        sel_rs1_o = instr_i[19:15];
        sel_rs2_o = instr_i[24:20];
        sel_rd    = '0;
        alu_op    = ALU_NE;
        alu_src1  = ALU_SRC_RS1;
        alu_src2  = ALU_SRC_RS2;
        mem_re    = 1'b0;
        mem_we    = 1'b0;
        mem_size  = UNDEF;
        imm       = {{20{instr_i[31]}}, instr_i[7], instr_i[30:25], instr_i[11:8], 1'b0};
        branch    = 1'b1;
        jump      = 1'b0;
        $display("BNE x%0d, x%0d, %0d", sel_rs1_o, sel_rs2_o, $signed(imm));
      end

      B_BLT: begin
        sel_rs1_o = instr_i[19:15];
        sel_rs2_o = instr_i[24:20];
        sel_rd    = '0;
        alu_op    = ALU_SLT;
        alu_src1  = ALU_SRC_RS1;
        alu_src2  = ALU_SRC_RS2;
        mem_re    = 1'b0;
        mem_we    = 1'b0;
        mem_size  = UNDEF;
        imm       = {{20{instr_i[31]}}, instr_i[7], instr_i[30:25], instr_i[11:8], 1'b0};
        branch    = 1'b1;
        jump      = 1'b0;
        $display("BLT x%0d, x%0d, %0d", sel_rs1_o, sel_rs2_o, $signed(imm));
      end

      B_BLTU: begin
        sel_rs1_o = instr_i[19:15];
        sel_rs2_o = instr_i[24:20];
        sel_rd    = '0;
        alu_op    = ALU_SLTU;
        alu_src1  = ALU_SRC_RS1;
        alu_src2  = ALU_SRC_RS2;
        mem_re    = 1'b0;
        mem_we    = 1'b0;
        mem_size  = UNDEF;
        imm       = {{20{instr_i[31]}}, instr_i[7], instr_i[30:25], instr_i[11:8], 1'b0};
        branch    = 1'b1;
        jump      = 1'b0;
        $display("BLTU x%0d, x%0d, %0d", sel_rs1_o, sel_rs2_o, $signed(imm));
      end

      B_BGE: begin
        sel_rs1_o = instr_i[19:15];
        sel_rs2_o = instr_i[24:20];
        sel_rd    = '0;
        alu_op    = ALU_SGE;
        alu_src1  = ALU_SRC_RS1;
        alu_src2  = ALU_SRC_RS2;
        mem_re    = 1'b0;
        mem_we    = 1'b0;
        mem_size  = UNDEF;
        imm       = {{20{instr_i[31]}}, instr_i[7], instr_i[30:25], instr_i[11:8], 1'b0};
        branch    = 1'b1;
        jump      = 1'b0;
        $display("BGE x%0d, x%0d, %0d", sel_rs1_o, sel_rs2_o, $signed(imm));
      end

      B_BGEU: begin
        sel_rs1_o = instr_i[19:15];
        sel_rs2_o = instr_i[24:20];
        sel_rd    = '0;
        alu_op    = ALU_SGEU;
        alu_src1  = ALU_SRC_RS1;
        alu_src2  = ALU_SRC_RS2;
        mem_re    = 1'b0;
        mem_we    = 1'b0;
        mem_size  = UNDEF;
        imm       = {{20{instr_i[31]}}, instr_i[7], instr_i[30:25], instr_i[11:8], 1'b0};
        branch    = 1'b1;
        jump      = 1'b0;
        $display("BGEU x%0d, x%0d, %0d", sel_rs1_o, sel_rs2_o, $signed(imm));
      end

      // Load instructions

      I_LB: begin
        sel_rs1_o = instr_i[19:15];
        sel_rs2_o = '0;
        sel_rd    = instr_i[11:7];
        alu_op    = ALU_ADD;
        alu_src1  = ALU_SRC_RS1;
        alu_src2  = ALU_SRC_IMM;
        mem_re    = 1'b1;
        mem_we    = 1'b0;
        mem_size  = BYTE_S;
        imm       = instr_i[31:20];
        branch    = 1'b0;
        jump      = 1'b0;
        $display("LB x%0d, %0d(x%0d)", sel_rd, $signed(imm), sel_rs1_o);
      end

      I_LBU: begin
        sel_rs1_o = instr_i[19:15];
        sel_rs2_o = '0;
        sel_rd    = instr_i[11:7];
        alu_op    = ALU_ADD;
        alu_src1  = ALU_SRC_RS1;
        alu_src2  = ALU_SRC_IMM;
        mem_re    = 1'b1;
        mem_we    = 1'b0;
        mem_size  = BYTE_U;
        imm       = instr_i[31:20];
        branch    = 1'b0;
        jump      = 1'b0;
        $display("LBU x%0d, %0d(x%0d)", sel_rd, $signed(imm), sel_rs1_o);
      end

      I_LH: begin
        sel_rs1_o = instr_i[19:15];
        sel_rs2_o = '0;
        sel_rd    = instr_i[11:7];
        alu_op    = ALU_ADD;
        alu_src1  = ALU_SRC_RS1;
        alu_src2  = ALU_SRC_IMM;
        mem_re    = 1'b1;
        mem_we    = 1'b0;
        mem_size  = HALF_S;
        imm       = instr_i[31:20];
        branch    = 1'b0;
        jump      = 1'b0;
        $display("LH x%0d, %0d(x%0d)", sel_rd, $signed(imm), sel_rs1_o);
      end

      I_LHU: begin
        sel_rs1_o = instr_i[19:15];
        sel_rs2_o = '0;
        sel_rd    = instr_i[11:7];
        alu_op    = ALU_ADD;
        alu_src1  = ALU_SRC_RS1;
        alu_src2  = ALU_SRC_IMM;
        mem_re    = 1'b1;
        mem_we    = 1'b0;
        mem_size  = HALF_U;
        imm       = instr_i[31:20];
        branch    = 1'b0;
        jump      = 1'b0;
        $display("LHU x%0d, %0d(x%0d)", sel_rd, $signed(imm), sel_rs1_o);
      end

      I_LW: begin
        sel_rs1_o = instr_i[19:15];
        sel_rs2_o = '0;
        sel_rd    = instr_i[11:7];
        alu_op    = ALU_ADD;
        alu_src1  = ALU_SRC_RS1;
        alu_src2  = ALU_SRC_IMM;
        mem_re    = 1'b1;
        mem_we    = 1'b0;
        mem_size  = WORD;
        imm       = instr_i[31:20];
        branch    = 1'b0;
        jump      = 1'b0;
        $display("LW x%0d, %0d(x%0d)", sel_rd, $signed(imm), sel_rs1_o);
      end

      // Store instructions

      S_SB: begin
        sel_rs1_o = instr_i[19:15];
        sel_rs2_o = instr_i[24:20];
        sel_rd    = '0;
        alu_op    = ALU_ADD;
        alu_src1  = ALU_SRC_RS1;
        alu_src2  = ALU_SRC_IMM;
        mem_re    = 1'b0;
        mem_we    = 1'b1;
        mem_size  = BYTE_U;
        imm       = {{20{instr_i[31]}}, instr_i[31:25], instr_i[11:7]};
        branch    = 1'b0;
        jump      = 1'b0;
        $display("SB x%0d, %0d(x%0d)", sel_rs2_o, $signed(imm), sel_rs1_o);
      end

      S_SH: begin
        sel_rs1_o = instr_i[19:15];
        sel_rs2_o = instr_i[24:20];
        sel_rd    = '0;
        alu_op    = ALU_ADD;
        alu_src1  = ALU_SRC_RS1;
        alu_src2  = ALU_SRC_IMM;
        mem_re    = 1'b0;
        mem_we    = 1'b1;
        mem_size  = HALF_U;
        imm       = {{20{instr_i[31]}}, instr_i[31:25], instr_i[11:7]};
        branch    = 1'b0;
        jump      = 1'b0;
        $display("SH x%0d, %0d(x%0d)", sel_rs2_o, $signed(imm), sel_rs1_o);
      end

      S_SW: begin
        sel_rs1_o = instr_i[19:15];
        sel_rs2_o = instr_i[24:20];
        sel_rd    = '0;
        alu_op    = ALU_ADD;
        alu_src1  = ALU_SRC_RS1;
        alu_src2  = ALU_SRC_IMM;
        mem_re    = 1'b0;
        mem_we    = 1'b1;
        mem_size  = WORD;
        imm       = {{20{instr_i[31]}}, instr_i[31:25], instr_i[11:7]};
        branch    = 1'b0;
        jump      = 1'b0;
        $display("SW x%0d, %0d(x%0d)", sel_rs2_o, $signed(imm), sel_rs1_o);
      end

      // Arithmetic instructions

      R_ADD: begin
        sel_rs1_o = instr_i[19:15];
        sel_rs2_o = instr_i[24:20];
        sel_rd    = instr_i[11:7];
        alu_op    = ALU_ADD;
        alu_src1  = ALU_SRC_RS1;
        alu_src2  = ALU_SRC_RS2;
        mem_re    = 1'b0;
        mem_we    = 1'b0;
        mem_size  = UNDEF;
        imm       = '0;
        branch    = 1'b0;
        jump      = 1'b0;
        $display("ADD x%0d, x%0d, x%0d", sel_rd, sel_rs1_o, sel_rs2_o);
      end

      R_SUB: begin
        sel_rs1_o = instr_i[19:15];
        sel_rs2_o = instr_i[24:20];
        sel_rd    = instr_i[11:7];
        alu_op    = ALU_SUB;
        alu_src1  = ALU_SRC_RS1;
        alu_src2  = ALU_SRC_RS2;
        mem_re    = 1'b0;
        mem_we    = 1'b0;
        mem_size  = UNDEF;
        imm       = '0;
        branch    = 1'b0;
        jump      = 1'b0;
        $display("SUB x%0d, x%0d, x%0d", sel_rd, sel_rs1_o, sel_rs2_o);
      end

      R_SLL: begin
        sel_rs1_o = instr_i[19:15];
        sel_rs2_o = instr_i[24:20];
        sel_rd    = instr_i[11:7];
        alu_op    = ALU_SLL;
        alu_src1  = ALU_SRC_RS1;
        alu_src2  = ALU_SRC_RS2;
        mem_re    = 1'b0;
        mem_we    = 1'b0;
        mem_size  = UNDEF;
        imm       = '0;
        branch    = 1'b0;
        jump      = 1'b0;
        $display("SLL x%0d, x%0d, x%0d", sel_rd, sel_rs1_o, sel_rs2_o);
      end

      R_SLT: begin
        sel_rs1_o = instr_i[19:15];
        sel_rs2_o = instr_i[24:20];
        sel_rd    = instr_i[11:7];
        alu_op    = ALU_SLT;
        alu_src1  = ALU_SRC_RS1;
        alu_src2  = ALU_SRC_RS2;
        mem_re    = 1'b0;
        mem_we    = 1'b0;
        mem_size  = UNDEF;
        imm       = '0;
        branch    = 1'b0;
        jump      = 1'b0;
        $display("SLT x%0d, x%0d, x%0d", sel_rd, sel_rs1_o, sel_rs2_o);
      end

      R_SLTU: begin
        sel_rs1_o = instr_i[19:15];
        sel_rs2_o = instr_i[24:20];
        sel_rd    = instr_i[11:7];
        alu_op    = ALU_SLTU;
        alu_src1  = ALU_SRC_RS1;
        alu_src2  = ALU_SRC_RS2;
        mem_re    = 1'b0;
        mem_we    = 1'b0;
        mem_size  = UNDEF;
        imm       = '0;
        branch    = 1'b0;
        jump      = 1'b0;
        $display("SLTU x%0d, x%0d, x%0d", sel_rd, sel_rs1_o, sel_rs2_o);
      end

      R_XOR: begin
        sel_rs1_o = instr_i[19:15];
        sel_rs2_o = instr_i[24:20];
        sel_rd    = instr_i[11:7];
        alu_op    = ALU_XOR;
        alu_src1  = ALU_SRC_RS1;
        alu_src2  = ALU_SRC_RS2;
        mem_re    = 1'b0;
        mem_we    = 1'b0;
        mem_size  = UNDEF;
        imm       = '0;
        branch    = 1'b0;
        jump      = 1'b0;
        $display("XOR x%0d, x%0d, x%0d", sel_rd, sel_rs1_o, sel_rs2_o);
      end

      R_SRL: begin
        sel_rs1_o = instr_i[19:15];
        sel_rs2_o = instr_i[24:20];
        sel_rd    = instr_i[11:7];
        alu_op    = ALU_SRL;
        alu_src1  = ALU_SRC_RS1;
        alu_src2  = ALU_SRC_RS2;
        mem_re    = 1'b0;
        mem_we    = 1'b0;
        mem_size  = UNDEF;
        imm       = '0;
        branch    = 1'b0;
        jump      = 1'b0;
        $display("SRL x%0d, x%0d, x%0d", sel_rd, sel_rs1_o, sel_rs2_o);
      end

      R_SRA: begin
        sel_rs1_o = instr_i[19:15];
        sel_rs2_o = instr_i[24:20];
        sel_rd    = instr_i[11:7];
        alu_op    = ALU_SRA;
        alu_src1  = ALU_SRC_RS1;
        alu_src2  = ALU_SRC_RS2;
        mem_re    = 1'b0;
        mem_we    = 1'b0;
        mem_size  = UNDEF;
        imm       = '0;
        branch    = 1'b0;
        jump      = 1'b0;
        $display("SRA x%0d, x%0d, x%0d", sel_rd, sel_rs1_o, sel_rs2_o);
      end

      R_OR: begin
        sel_rs1_o = instr_i[19:15];
        sel_rs2_o = instr_i[24:20];
        sel_rd    = instr_i[11:7];
        alu_op    = ALU_OR;
        alu_src1  = ALU_SRC_RS1;
        alu_src2  = ALU_SRC_RS2;
        mem_re    = 1'b0;
        mem_we    = 1'b0;
        mem_size  = UNDEF;
        imm       = '0;
        branch    = 1'b0;
        jump      = 1'b0;
        $display("OR x%0d, x%0d, x%0d", sel_rd, sel_rs1_o, sel_rs2_o);
      end

      R_AND: begin
        sel_rs1_o = instr_i[19:15];
        sel_rs2_o = instr_i[24:20];
        sel_rd    = instr_i[11:7];
        alu_op    = ALU_AND;
        alu_src1  = ALU_SRC_RS1;
        alu_src2  = ALU_SRC_RS2;
        mem_re    = 1'b0;
        mem_we    = 1'b0;
        mem_size  = UNDEF;
        imm       = '0;
        branch    = 1'b0;
        jump      = 1'b0;
        $display("AND x%0d, x%0d, x%0d", sel_rd, sel_rs1_o, sel_rs2_o);
      end

      I_ADDI: begin
        sel_rs1_o = instr_i[19:15];
        sel_rs2_o = '0;
        sel_rd    = instr_i[11:7];
        alu_op    = ALU_ADD;
        alu_src1  = ALU_SRC_RS1;
        alu_src2  = ALU_SRC_IMM;
        mem_re    = 1'b0;
        mem_we    = 1'b0;
        mem_size  = UNDEF;
        imm       = instr_i[31:20];
        branch    = 1'b0;
        jump      = 1'b0;
        $display("ADDI x%0d, x%0d, %0d", sel_rd, sel_rs1_o, imm);
      end

      I_SLTI: begin
        sel_rs1_o = instr_i[19:15];
        sel_rs2_o = '0;
        sel_rd    = instr_i[11:7];
        alu_op    = ALU_SLT;
        alu_src1  = ALU_SRC_RS1;
        alu_src2  = ALU_SRC_IMM;
        mem_re    = 1'b0;
        mem_we    = 1'b0;
        mem_size  = UNDEF;
        imm       = instr_i[31:20];
        branch    = 1'b0;
        jump      = 1'b0;
        $display("SLTI x%0d, x%0d, %0d", sel_rd, sel_rs1_o, imm);
      end

      I_SLTIU: begin
        sel_rs1_o = instr_i[19:15];
        sel_rs2_o = '0;
        sel_rd    = instr_i[11:7];
        alu_op    = ALU_SLTU;
        alu_src1  = ALU_SRC_RS1;
        alu_src2  = ALU_SRC_IMM;
        mem_re    = 1'b0;
        mem_we    = 1'b0;
        mem_size  = UNDEF;
        imm       = instr_i[31:20];
        branch    = 1'b0;
        jump      = 1'b0;
        $display("SLTIU x%0d, x%0d, %0d", sel_rd, sel_rs1_o, imm);
      end

      I_XORI: begin
        sel_rs1_o = instr_i[19:15];
        sel_rs2_o = '0;
        sel_rd    = instr_i[11:7];
        alu_op    = ALU_XOR;
        alu_src1  = ALU_SRC_RS1;
        alu_src2  = ALU_SRC_IMM;
        mem_re    = 1'b0;
        mem_we    = 1'b0;
        mem_size  = UNDEF;
        imm       = instr_i[31:20];
        branch    = 1'b0;
        jump      = 1'b0;
        $display("XORI x%0d, x%0d, %0d", sel_rd, sel_rs1_o, imm);
      end

      I_ORI: begin
        sel_rs1_o = instr_i[19:15];
        sel_rs2_o = '0;
        sel_rd    = instr_i[11:7];
        alu_op    = ALU_OR;
        alu_src1  = ALU_SRC_RS1;
        alu_src2  = ALU_SRC_IMM;
        mem_re    = 1'b0;
        mem_we    = 1'b0;
        mem_size  = UNDEF;
        imm       = instr_i[31:20];
        branch    = 1'b0;
        jump      = 1'b0;
        $display("ORI x%0d, x%0d, %0d", sel_rd, sel_rs1_o, imm);
      end

      I_ANDI: begin
        sel_rs1_o = instr_i[19:15];
        sel_rs2_o = '0;
        sel_rd    = instr_i[11:7];
        alu_op    = ALU_AND;
        alu_src1  = ALU_SRC_RS1;
        alu_src2  = ALU_SRC_IMM;
        mem_re    = 1'b0;
        mem_we    = 1'b0;
        mem_size  = UNDEF;
        imm       = instr_i[31:20];
        branch    = 1'b0;
        jump      = 1'b0;
        $display("ANDI x%0d, x%0d, %0d", sel_rd, sel_rs1_o, imm);
      end

      I_SLLI: begin
        sel_rs1_o = instr_i[19:15];
        sel_rs2_o = '0;
        sel_rd    = instr_i[11:7];
        alu_op    = ALU_SLL;
        alu_src1  = ALU_SRC_RS1;
        alu_src2  = ALU_SRC_IMM;
        mem_re    = 1'b0;
        mem_we    = 1'b0;
        mem_size  = UNDEF;
        imm       = instr_i[24:20];
        branch    = 1'b0;
        jump      = 1'b0;
        $display("SLLI x%0d, x%0d, %0d", sel_rd, sel_rs1_o, imm);
      end

      I_SRLI: begin
        sel_rs1_o = instr_i[19:15];
        sel_rs2_o = '0;
        sel_rd    = instr_i[11:7];
        alu_op    = ALU_SRL;
        alu_src1  = ALU_SRC_RS1;
        alu_src2  = ALU_SRC_IMM;
        mem_re    = 1'b0;
        mem_we    = 1'b0;
        mem_size  = UNDEF;
        imm       = instr_i[24:20];
        branch    = 1'b0;
        jump      = 1'b0;
        $display("SRLI x%0d, x%0d, %0d", sel_rd, sel_rs1_o, imm);
      end

      I_SRAI: begin
        sel_rs1_o = instr_i[19:15];
        sel_rs2_o = '0;
        sel_rd    = instr_i[11:7];
        alu_op    = ALU_SRA;
        alu_src1  = ALU_SRC_RS1;
        alu_src2  = ALU_SRC_IMM;
        mem_re    = 1'b0;
        mem_we    = 1'b0;
        mem_size  = UNDEF;
        imm       = instr_i[24:20];
        branch    = 1'b0;
        jump      = 1'b0;
        $display("SRAI x%0d, x%0d, %0d", sel_rd, sel_rs1_o, imm);
      end

      default: begin
        sel_rs1_o = '0;
        sel_rs2_o = '0;
        sel_rd    = '0;
        alu_op    = '0;
        alu_src1  = '0;
        alu_src2  = '0;
        mem_re    = '0;
        mem_we    = '0;
        mem_size  = '0;
        imm       = '0;
        branch    = '0;
        jump      = '0;
        $display("BUBBLE");
      end
    endcase
  end

endmodule : decode
