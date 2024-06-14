`default_nettype none

module fetch (
    input  logic clk,
    input  logic rst_n,
    input  logic [31:0] instr_i,
    input  logic stall_i,
    output logic re_o,
    output logic [31:0] instr_o
);

  // Instruction pipeline
  always_ff @(posedge clk, negedge rst_n) begin
    if (!rst_n) instr_o <= '0;
    else if (!stall_i) begin
      instr_o <= instr_i;
    end
  end

  always_comb begin
    if (!stall_i) re_o = 1'b1;
    else          re_o = 1'b0;
  end

  // The instruction fetch (IF) stage should read an instruction from memory.
  // It should pass the instruction to the decode stage.
  // It should increment the PC counter by 4

  // It should have an FSM that implements a handshake with the decode stage.

endmodule : fetch