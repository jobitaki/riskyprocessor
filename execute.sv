`default_nettype none

module execute (
    input  logic clk,
    input  logic rst_n,
    input  logic [31:0] instr_i,
    input  logic [31:0] rs1_i,
    input  logic [31:0] rs2_i,
    output logic [31:0] instr_o,
    output logic [31:0] alu_result_o,
    output logic [ 4:0] sel_rd_o
);

  always_ff @(posedge clk, negedge rst_n) begin
    if (!rst_n) begin
      instr_o  <= '0;
      sel_rd_o <= '0;
    end
    else begin
      instr_o  <= instr_i;
    end
  end

  always_comb begin
    casez (instr_o)
      I_ALL_LOADS: sel_rd_o = instr_o[11:7];
      R_ALL:       sel_rd_o = instr_o[11:7];
      default:     sel_rd_o = '0;
    endcase
  end

  logic [31:0] alu_oper1, alu_oper2;
  logic [ 4:0] alu_sel_op;
  logic [31:0] alu_result;

  always_comb begin
    casez (instr_i)
      I_ALL_LOADS: begin
        alu_oper1  = rs1_i;
        alu_oper2  = instr_i[31:20];
        alu_sel_op = ALU_ADD;
      end

      R_ADD_SUB: begin
        alu_oper1  = rs1_i;
        alu_oper2  = (instr_i[30]) ? ~rs2_i + 1'b1 : rs2_i;
        alu_sel_op = ALU_ADD;
      end

      R_SLL: begin
        alu_oper1  = rs1_i;
        alu_oper2  = rs2_i;
        alu_sel_op = ALU_SLL;
      end

      R_SLT: begin
      end

      R_SLTU: begin
      end

      R_XOR: begin
      end

      default: begin
        alu_oper1  = '0;
        alu_oper2  = '0;
        alu_sel_op = ALU_UNDEF;
      end
    endcase
  end

  alu u_alu (
    .oper1_i (alu_oper1),
    .oper2_i (alu_oper2),
    .sel_op_i(alu_sel_op),
    .result_o(alu_result)
  );

  always_ff @(posedge clk, negedge rst_n) begin
    if (!rst_n) alu_result_o <= '0;
    else alu_result_o <= alu_result;
  end

endmodule : execute
