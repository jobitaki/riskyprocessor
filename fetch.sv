`default_nettype none

module fetch(
  input  logic [31:0] instr_in,
  output logic re,
  output logic [31:0] instr_out
);

  // The instruction fetch (IF) stage should read an instruction from memory.
  // It should pass the instruction to the decode stage.
  // It should increment the PC counter by 4

  // It should have an FSM that implements a handshake with the decode stage.

endmodule : fetch

module fetch_fsm (
  input logic clock,
  input logic reset
);

  typedef enum logic [1:0] {
    FETCH,
    STALL
  } state_e;

  state_e state, next_state;

  always_comb begin
    case (state)
      FETCH: begin
      end

      STALL: begin
      end

      default: begin
      end
    endcase
  end

  always_ff @(posedge clock, posedge reset) begin
    if (reset) state <= FETCH;
    else state <= next_state;
  end
  
endmodule : fetch_fsm
