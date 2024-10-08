`default_nettype none

import constants::*;

module alu (
    input  logic    [31:0] oper1_i,
    input  logic    [31:0] oper2_i,
    input  alu_op_e        sel_op_i,
    output logic    [31:0] result_o
);

  always_comb begin
    case (sel_op_i)
      ALU_PASS: begin
        result_o = oper1_i;
      end

      ALU_ADD: begin
        result_o = oper1_i + oper2_i;
      end

      ALU_SUB: begin
        result_o = oper1_i - oper2_i;
      end

      ALU_SLL: begin
        result_o = oper1_i << oper2_i[4:0];
      end

      ALU_SLT: begin
        result_o = $signed(oper1_i) < $signed(oper2_i);
      end

      ALU_SLTU: begin
        result_o = oper1_i < oper2_i;
      end

      ALU_SGE: begin
        result_o = oper1_i >= oper2_i;
      end
      
      ALU_SGEU: begin
        result_o = $signed(oper1_i) >= $signed(oper2_i);
      end

      ALU_XOR: begin
        result_o = oper1_i ^ oper2_i; 
      end

      ALU_SRL: begin
        result_o = oper1_i >> oper2_i;
      end

      ALU_SRA: begin
        result_o = oper1_i >>> oper2_i;
      end

      ALU_OR: begin
        result_o = oper1_i | oper2_i;
      end

      ALU_AND: begin
        result_o = oper1_i & oper2_i;
      end

      ALU_NE: begin
        result_o = oper1_i != oper2_i;
      end

      ALU_EQ: begin
        result_o = oper1_i == oper2_i;
      end

      default: begin
        result_o = 32'd0;
      end
    endcase
  end

endmodule : alu
