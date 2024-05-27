`default_nettype none

module regfile (
    input  logic        clock,
    input  logic        reset,
    input  logic [ 4:0] rd,
    input  logic [31:0] rd_in,
    input  logic        we,
    input  logic [ 4:0] rs1,
    input  logic [ 4:0] rs2,
    output logic [31:0] rs1_out,
    output logic [31:0] rs2_out
);

  logic [31:0][32] register;

  always_ff @(posedge clock, posedge reset) begin
    if (reset) begin
      register <= '0;
      rs1_out  <= '0;
      rs2_out  <= '0;
    end else begin
      if (we) register[rd] <= rd_in;
      rs1_out <= register[rs1];
      rs2_out <= register[rs2];
    end
  end

endmodule : regfile
