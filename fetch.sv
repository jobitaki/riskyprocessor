`default_nettype none

module fetch (
    input logic clk,
    input logic rst_n,
    input logic [31:0] instr_i,
    input logic stall_i,
    output logic re_o,
    output logic [31:0] instr_o
);

  // Instruction pipeline
  always_ff @(posedge clk, negedge rst_n) begin
    if (~rst_n) instr_o <= '0;
    else instr_o <= instr_i;
  end

  // The instruction fetch (IF) stage should read an instruction from memory.
  // It should pass the instruction to the decode stage.
  // It should increment the PC counter by 4

  // It should have an FSM that implements a handshake with the decode stage.
  fetch_fsm u_fetch_fsm (
    .clk,
    .rst_n,
    .stall_i,
    .re_o,
  );

endmodule : fetch

module fetch_fsm (
    input logic clk,
    input logic rst_n,
    input logic stall_i,
    output logic re_o
);

  typedef enum logic [1:0] {
    FETCH,
    STALL
  } state_e;

  state_e state, next_state;

  always_comb begin
    re_o = 1'b0;

    case (state)
      FETCH: begin
        if (stall_i) next_state = STALL;
        else next_state = FETCH;

        re_o = 1'b1;
      end

      STALL: begin
        if (stall_i) next_state = STALL;
        else next_state = FETCH;
      end

      default: begin
        next_state = FETCH;
      end
    endcase
  end

  always_ff @(posedge clk, negedge rst_n) begin
    if (~rst_n) state <= FETCH;
    else state <= next_state;
  end

endmodule : fetch_fsm
