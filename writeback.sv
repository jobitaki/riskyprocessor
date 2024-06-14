`default_nettype none

module writeback (
    input  logic        clk,
    input  logic        rst_n,
    input  logic [31:0] instr_i,
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
      casez (instr_i)
        I_ALL_LOADS: begin
          sel_rd_o <= instr_i[11:7];
          we_o     <= 1'b1;
          data_o   <= data_i;
        end

        R_ALL: begin
          sel_rd_o <= instr_i[11:7];
          we_o     <= 1'b1;
          data_o   <= alu_result_i;
        end

        default: begin
          sel_rd_o <= '0;
          we_o     <= 1'b0;
          data_o   <= '0;
        end
      endcase
    end
  end

endmodule : writeback
