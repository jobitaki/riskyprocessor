`default_nettype none

module execute (
    input  logic clk,
    input  logic rst_n,
    input  logic [ 4:0] opcode_i,
    input  logic [31:0] rs1_i,
    input  logic [31:0] rs2_i,
    input  logic [31:0] rd_i,
    input  logic [19:0] imm_i,
    output logic [ 4:0] opcode_o,
    output logic [31:0] alu_result_o
);

  always_ff @(posedge clk, negedge rst_n) begin
    if (~rst_n) begin
      opcode_o <= '0;
    end
    else begin
      opcode_o <= opcode_i;
    end
  end

  logic [31:0] alu_oper1, alu_oper2;
  logic [ 4:0] alu_sel_op;
  logic [31:0] alu_result;

  always_comb begin
    case (opcode_i)
      5'b00000: begin
        alu_oper1 = rs1_i;
        alu_oper2 = imm_i;
        alu_sel_op = ALU_ADD;
      end

      default: begin
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
    if (~rst_n) alu_result_o <= '0;
    else alu_result_o <= alu_result;
  end

endmodule : execute
