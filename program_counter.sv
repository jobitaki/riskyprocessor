`default_nettype none

module program_counter (
  input logic clk,
  input logic rst_n,
  input logic [31:0] pc_i,
  input logic en_i,
  output logic [31:0] pc_o
);

  always_ff @(posedge clk, negedge rst_n) begin
    if (~rst_n) pc_o <= '0;
    else if (en_i) pc_o <= pc_i;
  end

endmodule : program_counter
