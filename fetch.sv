`default_nettype none

import constants::*

module fetch (
    input  logic clk,
    input  logic rst_n,
    input  logic [31:0] instr_i,
    input  logic stall_i,
    input  logic branch_resolve_i,
    output logic re_o,
    output logic [31:0] instr_o
);

  // The instruction fetch (IF) stage should read an instruction from memory.
  // It should pass the instruction to the decode stage.
  // It should increment the PC counter by 4

  logic flush;

  // Instruction pipeline
  always_ff @(posedge clk, negedge rst_n) begin
    if (!rst_n) instr_o <= '0;
    else if (flush) begin
      instr_o <= '0;
    end
    else if (stall_i)
      instr_o <= instr_o;
    else begin
      instr_o <= instr_i;
    end
  end

  always_comb begin
    if (!stall_i && !flush) re_o = 1'b1;
    else                    re_o = 1'b0;
  end

  // TODO Implement a branch detection circuit to insert bubbles where necessary
  // When branch is seen, go into flush state until branch is resolved in execute stage.

  typedef enum logic {NORMAL, FLUSH} state_e;

  state_e state, next_state;

  always_comb begin
    case (state)
      NORMAL: begin
        if (instr_i[6:0] == 7'b110_0011 || 
            instr_i[6:0] == 7'b110_1111) begin
          next_state = FLUSH;
        end 
        else begin
          next_state = NORMAL;
        end

        flush = 1'b0;
      end

      FLUSH: begin
        if (branch_resolve_i) next_state = NORMAL;
        else next_state = FLUSH;

        flush = 1'b1;
      end

      default: begin
        next_state = NORMAL;
        flush = 1'b0;
      end
    endcase
  end

  always_ff @(posedge clk, negedge rst_n) begin
    if (!rst_n) state <= NORMAL;
    else        state <= next_state;
  end

endmodule : fetch