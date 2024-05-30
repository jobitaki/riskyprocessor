`default_nettype none

module regfile (
    input  logic        clk,
    input  logic        rst_n,
    input  logic [ 4:0] sel_rd,
    input  logic [31:0] in_rd,
    input  logic        we,
    input  logic [ 4:0] sel_rs1,
    input  logic [ 4:0] sel_rs2,
    output logic [31:0] out_rs1,
    output logic [31:0] out_rs2
);

  logic [31:0][32] register_file;

  always_ff @(posedge clk, negedge rst_n) begin
    if (~rst_n) begin
      register_file <= '0;
      out_rs1  <= '0;
      out_rs2  <= '0;
    end else begin
      if (we) register_file[sel_rd] <= in_rd;
      out_rs1 <= register_file[sel_rs1];
      out_rs2 <= register_file[sel_rs2];
    end
  end

endmodule : regfile
