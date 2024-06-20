`default_nettype none

import constants::*;

module writeback (
    input  logic        clk,
    input  logic        rst_n,
    input  logic [ 4:0] sel_rd_i,
    input  logic        mem_re_i,
    input  logic        mem_we_i,
    input  logic [31:0] alu_result_i,
    input  logic [31:0] data_i,
    output logic [31:0] data_bypass_o,
    output logic [ 4:0] sel_rd_o,
    output logic        we_o,
    output logic [31:0] data_o
);

  // The writeback stage should write what is in data or alu_result into the rd
  // register.
  
  assign data_bypass_o = data_i;

  always_ff @(posedge clk, negedge rst_n) begin
    if (!rst_n) begin
      sel_rd_o <= '0;
      we_o <= '0;
      data_o <= '0;
    end else begin
      sel_rd_o <= sel_rd_i;
      we_o     <= 1'b1; // Is it okay to always be writing? Since no writes are to x0?

      if (mem_re_i) begin
        data_o <= data_i;
      end else begin
        data_o <= alu_result_i;
      end
    end
  end

endmodule : writeback
