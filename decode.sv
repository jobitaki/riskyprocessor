`default_nettype none

//
//  Module 'decode'
//
//  The ID (instruction decode) stage of the pipeline. Instructions are decoded
//  and registers are read from the regfile.
//
module decode (
    input  logic        clk,
    input  logic        rst_n,
    input  logic [31:0] instr_i,
    input  logic        stall_i,
    output logic [ 4:0] sel_rs1_o,
    output logic [ 4:0] sel_rs2_o,
    output logic [31:0] instr_o
);

  // The instruction decode stage should take in a 32-bit instruction and read
  // the proper registers from the regfile. Is that it?

  always_ff @(posedge clk, negedge rst_n) begin
    if (~rst_n)        instr_o <= '0;
    else if (!stall_i) instr_o <= instr_i;
  end

  always_comb begin
    casez (instr_i)
      I_ALL_LOADS: begin
        sel_rs1_o = instr_i[19:15];
      end

      S_ALL: begin
        sel_rs1_o = instr_i[19:15];
        sel_rs2_o = instr_i[24:20];
      end

      R_ALL: begin
        sel_rs1_o = instr_i[19:15];
        sel_rs2_o = instr_i[24:20];
      end

      default: begin
        sel_rs1_o = '0;
        sel_rs2_o = '0;
      end
    endcase
  end

endmodule : decode
