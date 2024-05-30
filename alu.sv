`default_nettype none

module alu (
    input  logic    [31:0] oper1_i,
    input  logic    [31:0] oper2_i,
    input  logic    [ 4:0] sel_op_i,
    output logic    [31:0] result_o
);

  always_comb begin
    case (sel_op_i)
      ALU_ADD: begin
        result_o = oper1_i + oper2_i;
      end

      default: begin
      end
    endcase
  end

endmodule : alu
