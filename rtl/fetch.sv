`default_nettype none

import constants::*;

//
//  Module 'fetch'
//
//  The instruction fetch (IF) stage should read an instruction from memory.
//  It should pass the instruction to the decode stage.
//  It should increment the PC counter by 4
//
module fetch (
    input  logic clk,
    input  logic rst_n,
    input  logic [31:0] instr_i,   // Instruction read from instruction memory
    input  logic stall_i,          // Stall the pipeline, wait for store to
                                   // occur before a load of the same address
    input  logic branch_resolve_i, // Signals if a branch is decided

    output logic re_o,             // Read enable for instruction memory
    output logic incr_pc_o,        // Signals to increment PC
    output logic [31:0] instr_o    // Instruction for decode stage
);


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

  assign re_o = ~stall_i;

  // Branch detection circuit to insert bubbles where necessary
  // When branch is seen, go into flush state until branch is resolved in execute stage.

  typedef enum logic {NORMAL, FLUSH} state_e;

  state_e state, next_state;

  always_comb begin
    case (state)
      NORMAL: begin
        if (instr_i[6:0] == 7'b110_0011 || 
            instr_i[6:0] == 7'b110_1111) begin
          next_state = FLUSH;
          incr_pc_o  = 1'b0;
        end 
        else begin
          next_state = NORMAL;
          incr_pc_o  = 1'b1;
        end

        flush      = 1'b0;
      end

      FLUSH: begin
        if (branch_resolve_i) begin
          next_state = NORMAL;
          incr_pc_o  = 1'b1;
        end
        else begin
          next_state = FLUSH;
          incr_pc_o  = 1'b0;
        end

        flush = 1'b1;
      end

      default: begin
        next_state = NORMAL;
        flush = 1'b0;
        incr_pc_o  = 1'b0;
      end
    endcase
  end

  always_ff @(posedge clk, negedge rst_n) begin
    if (!rst_n) state <= NORMAL;
    else        state <= next_state;
  end

endmodule : fetch