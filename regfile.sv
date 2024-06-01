`default_nettype none

module regfile (
    input  logic        clk,
    input  logic        rst_n,
    input  logic [ 4:0] sel_rd_i,
    input  logic [31:0] rd_i,
    input  logic        we_i,
    input  logic [ 4:0] sel_rs1_i,
    input  logic [ 4:0] sel_rs2_i,
    output logic [31:0] rs1_o,
    output logic [31:0] rs2_o
);

  logic [31:0][32] register_file;

  assign register_file[0] = 32'd0;

  always_ff @(posedge clk, negedge rst_n) begin
    if (!rst_n) begin
      register_file[31:1] <= '0;
      rs1_o               <= '0;
      rs2_o               <= '0;
    end else begin
      if (we_i && (sel_rd_i != 5'b0)) register_file[sel_rd_i] <= rd_i;
      rs1_o <= register_file[sel_rs1_i];
      rs2_o <= register_file[sel_rs2_i];
    end
  end

endmodule : regfile
