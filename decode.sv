`default_nettype none

module decode (
    input  logic        clk,
    input  logic        rst_n,
    input  logic [31:0] instr_i,
    output logic [ 4:0] sel_rs1_o,
    output logic [ 4:0] sel_rs2_o,
    output logic [19:0] imm_o,
    output logic [ 4:0] opcode_o
);

  // The instruction decode stage should take in a 32-bit instruction and read
  // the proper registers from the regfile. Is that it?

  always_ff @(posedge clk, negedge rst_n) begin
    if (~rst_n) opcode_o <= '0;
    else opcode_o <= instr_i[6:2];
  end

  logic [19:0] temp_imm;

  always_ff @(posedge clk, negedge rst_n) begin
    if (~rst_n) imm_o <= '0;
    else imm_o <= temp_imm;
  end

  always_comb begin
    casez (instr_i)
      LB: begin
        sel_rs1_o  = instr_i[19:15];
        temp_imm = instr_i[31:20];
      end
      ADD: begin
        sel_rs1_o = instr_i[19:15];
        sel_rs2_o = instr_i[24:20];
      end
      default: begin
      end
    endcase
  end

endmodule : decode
