`default_nettype none

//
//  Module 'decode'
//
//  The ID (instruction decode) stage of the pipeline. Instructions are decoded
//  and registers are read from the regfile.
//
module decode (
    input  logic        clk,
    input  logic        rst_n,       
    input  logic [31:0] instr_i,      // Instruction in
    input  logic        stall_i,      // Stall pipeline up to execute
    output logic [ 4:0] sel_rs1_o,    // Register 1 id 
    output logic [ 4:0] sel_rs2_o,    // Register 2 id
    output logic [ 4:0] sel_rd_o,     // Destination register id
    output alu_op_e     alu_op_o,     // ALU opcode
    output alu_src_e    alu_src1_o,   // ALU mux sel
    output alu_src_e    alu_src2_o,   // ALU mux sel
    output logic        mem_re_o,     // Memory read enable
    output logic        mem_we_o,     // Memory write enable
    output data_size_e  mem_size_o,   // Size and signedness of memory instr
    output logic [31:0] imm_o,        // Immediate value
    output logic        branch_o      // True if instr in front is branch
);

  // The instruction decode stage should take in a 32-bit instruction and read
  // the proper registers from the regfile.

  // It should also generate the necessary control signals
  // ALU_OP, mem_re, mem_we, DEST_REG, ALU_SRC1, ALU_SRC2, IMM
  logic [ 4:0] sel_rd;
  alu_op_e     alu_op;
  alu_src_e    alu_src1, alu_src2;
  logic        mem_re, mem_we;
  data_size_e  mem_size;
  logic [31:0] imm;
  logic        branch;

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
    end
    else if (!stall_i) begin
      sel_rd_o   <= sel_rd;
      alu_op_o   <= alu_op;
      alu_src1_o <= alu_src1;
      alu_src2_o <= alu_src2;
      mem_re_o   <= mem_re;
      mem_we_o   <= mem_we;
      mem_size_o <= mem_size;
      imm_o      <= imm;
      branch_o   <= branch;
    end
  end

  /////////////
  // Decoder //
  /////////////

  always_comb begin
    unique casez (instr_i)
      // Branch operations

      B_BEQ: begin
        sel_rs1_o = instr_i[19:15];
        sel_rs2_o = instr_i[24:20];
        sel_rd    = '0;
        alu_op    = ALU_XOR;
        alu_src1  = ALU_SRC_RS1;
        alu_src2  = ALU_SRC_RS2;
        mem_re    = 1'b0;
        mem_we    = 1'b0;
        mem_size  = UNDEF;
        imm       = {{20{instr_i[31]}}, instr_i[7], instr_i[30:25], instr_i[11:8], 1'b0};
        branch    = 1'b1;
      end
      
      B_BNE: begin
        sel_rs1_o = instr_i[19:15];
        sel_rs2_o = instr_i[24:20];
        sel_rd    = '0;
        alu_op    = ALU_XOR;
        alu_src1  = ALU_SRC_RS1;
        alu_src2  = ALU_SRC_RS2;
        mem_re    = 1'b0;
        mem_we    = 1'b0;
        mem_size  = UNDEF;
        imm       = {{20{instr_i[31]}}, instr_i[7], instr_i[30:25], instr_i[11:8], 1'b0};
        branch    = 1'b1;
      end

      // Load operations

      I_LB: begin
        $display("LB decode");
        sel_rs1_o = instr_i[19:15];
        sel_rs2_o = '0;
        sel_rd    = instr_i[11: 7];
        alu_op    = ALU_ADD;
        alu_src1  = ALU_SRC_RS1;
        alu_src2  = ALU_SRC_IMM;
        mem_re    = 1'b1;
        mem_we    = 1'b0;
        mem_size  = BYTE_S;
        imm       = instr_i[31:20];
        branch    = 1'b0;
      end

      I_LBU: begin
        $display("LBU decode");
        sel_rs1_o = instr_i[19:15];
        sel_rs2_o = '0;
        sel_rd    = instr_i[11: 7];
        alu_op    = ALU_ADD;
        alu_src1  = ALU_SRC_RS1;
        alu_src2  = ALU_SRC_IMM;
        mem_re    = 1'b1;
        mem_we    = 1'b0;
        mem_size  = BYTE_U;
        imm       = instr_i[31:20];
        branch    = 1'b0;
      end

      I_LH: begin
        $display("LH decode");
        sel_rs1_o = instr_i[19:15];
        sel_rs2_o = '0;
        sel_rd    = instr_i[11: 7];
        alu_op    = ALU_ADD;
        alu_src1  = ALU_SRC_RS1;
        alu_src2  = ALU_SRC_IMM;
        mem_re    = 1'b1;
        mem_we    = 1'b0;
        mem_size  = HALF_S;
        imm       = instr_i[31:20];
        branch    = 1'b0;
      end

      I_LHU: begin
        $display("LHU decode");
        sel_rs1_o = instr_i[19:15];
        sel_rs2_o = '0;
        sel_rd    = instr_i[11: 7];
        alu_op    = ALU_ADD;
        alu_src1  = ALU_SRC_RS1;
        alu_src2  = ALU_SRC_IMM;
        mem_re    = 1'b1;
        mem_we    = 1'b0;
        mem_size  = HALF_U;
        imm       = instr_i[31:20];
        branch    = 1'b0;
      end

      I_LW: begin
        sel_rs1_o = instr_i[19:15];
        sel_rs2_o = '0;
        sel_rd    = instr_i[11: 7];
        alu_op    = ALU_ADD;
        alu_src1  = ALU_SRC_RS1;
        alu_src2  = ALU_SRC_IMM;
        mem_re    = 1'b1;
        mem_we    = 1'b0;
        mem_size  = WORD;
        imm       = instr_i[31:20];
        branch    = 1'b0;
      end

      // Store operations

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
      end

      // Arithmetic operations

      R_ADD: begin
        sel_rs1_o = instr_i[19:15];
        sel_rs2_o = instr_i[24:20];
        sel_rd    = instr_i[11: 7];
        alu_op    = ALU_ADD;
        alu_src1  = ALU_SRC_RS1;
        alu_src2  = ALU_SRC_RS2;
        mem_re    = 1'b0;
        mem_we    = 1'b0;
        mem_size  = UNDEF;
        imm       = '0;
        branch    = 1'b0;
      end

      R_SUB: begin
        sel_rs1_o = instr_i[19:15];
        sel_rs2_o = instr_i[24:20];
        sel_rd    = instr_i[11: 7];
        alu_op    = ALU_SUB;
        alu_src1  = ALU_SRC_RS1;
        alu_src2  = ALU_SRC_RS2;
        mem_re    = 1'b0;
        mem_we    = 1'b0;
        mem_size  = UNDEF;
        imm       = '0;
        branch    = 1'b0;
      end

      R_SLL: begin
        sel_rs1_o = instr_i[19:15];
        sel_rs2_o = instr_i[24:20];
        sel_rd    = instr_i[11: 7];
        alu_op    = ALU_SLL;
        alu_src1  = ALU_SRC_RS1;
        alu_src2  = ALU_SRC_RS2;
        mem_re    = 1'b0;
        mem_we    = 1'b0;
        mem_size  = UNDEF;
        imm       = '0;
        branch    = 1'b0;
      end

      R_SLT: begin
        sel_rs1_o = instr_i[19:15];
        sel_rs2_o = instr_i[24:20];
        sel_rd    = instr_i[11: 7];
        alu_op    = ALU_SLT;
        alu_src1  = ALU_SRC_RS1;
        alu_src2  = ALU_SRC_RS2;
        mem_re    = 1'b0;
        mem_we    = 1'b0;
        mem_size  = UNDEF;
        imm       = '0;
        branch    = 1'b0;
      end
      
      R_SLTU: begin
        sel_rs1_o = instr_i[19:15];
        sel_rs2_o = instr_i[24:20];
        sel_rd    = instr_i[11: 7];
        alu_op    = ALU_SLTU;
        alu_src1  = ALU_SRC_RS1;
        alu_src2  = ALU_SRC_RS2;
        mem_re    = 1'b0;
        mem_we    = 1'b0;
        mem_size  = UNDEF;
        imm       = '0;
        branch    = 1'b0;
      end

      R_XOR: begin
        sel_rs1_o = instr_i[19:15];
        sel_rs2_o = instr_i[24:20];
        sel_rd    = instr_i[11: 7];
        alu_op    = ALU_XOR;
        alu_src1  = ALU_SRC_RS1;
        alu_src2  = ALU_SRC_RS2;
        mem_re    = 1'b0;
        mem_we    = 1'b0;
        mem_size  = UNDEF;
        imm       = '0;
        branch    = 1'b0;
      end

      R_SRL: begin
        sel_rs1_o = instr_i[19:15];
        sel_rs2_o = instr_i[24:20];
        sel_rd    = instr_i[11: 7];
        alu_op    = ALU_SRL;
        alu_src1  = ALU_SRC_RS1;
        alu_src2  = ALU_SRC_RS2;
        mem_re    = 1'b0;
        mem_we    = 1'b0;
        mem_size  = UNDEF;
        imm       = '0;
        branch    = 1'b0;
      end

      R_SRA: begin
        sel_rs1_o = instr_i[19:15];
        sel_rs2_o = instr_i[24:20];
        sel_rd    = instr_i[11: 7];
        alu_op    = ALU_SRA;
        alu_src1  = ALU_SRC_RS1;
        alu_src2  = ALU_SRC_RS2;
        mem_re    = 1'b0;
        mem_we    = 1'b0;
        mem_size  = UNDEF;
        imm       = '0;
        branch    = 1'b0;
      end

      R_OR: begin
        sel_rs1_o = instr_i[19:15];
        sel_rs2_o = instr_i[24:20];
        sel_rd    = instr_i[11: 7];
        alu_op    = ALU_OR;
        alu_src1  = ALU_SRC_RS1;
        alu_src2  = ALU_SRC_RS2;
        mem_re    = 1'b0;
        mem_we    = 1'b0;
        mem_size  = UNDEF;
        imm       = '0;
        branch    = 1'b0;
      end

      R_AND: begin
        sel_rs1_o = instr_i[19:15];
        sel_rs2_o = instr_i[24:20];
        sel_rd    = instr_i[11: 7];
        alu_op    = ALU_AND;
        alu_src1  = ALU_SRC_RS1;
        alu_src2  = ALU_SRC_RS2;
        mem_re    = 1'b0;
        mem_we    = 1'b0;
        mem_size  = UNDEF;
        imm       = '0;
        branch    = 1'b0;
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
      end
    endcase
  end

endmodule : decode
