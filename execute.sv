`default_nettype none

module execute (
    input  logic clk,
    input  logic rst_n,
    input  logic [31:0] instr_i,
    input  logic [31:0] rs1_i,
    input  logic [31:0] rs2_i,
    output logic [31:0] instr_o,
    output logic [31:0] alu_result_o,
    output logic [31:0] rs2_o,        // Necessary for store operations
    output logic [ 4:0] sel_rd_o,
    output logic        stall_o
);

  logic set_was_store;     // Sets the was_store value
  logic was_store;         // Marks if previous operation was a store op
  logic [31:0] was_store_address; // The address of the previous store
  logic [31:0] alu_result;

  always_ff @(posedge clk, negedge rst_n) begin
    if (!rst_n) begin
      instr_o           <= '0;
      rs2_o             <= '0;
      was_store         <= 1'b0;
      was_store_address <= '0;
    end
    else begin
      if (!stall_o) begin
        instr_o <= instr_i;
        rs2_o   <= rs2_i;
      end else begin
        instr_o <= '0;
      end

      if (set_was_store) begin
        was_store         <= 1'b1;
        was_store_address <= alu_result;
      end
      else begin
        was_store         <= 1'b0;
        was_store_address <= '0;
      end
    end
  end

  always_comb begin
    stall_o = 1'b0;
    casez (instr_i) 
      I_ALL_LOADS: begin
        if (was_store && was_store_address == alu_result) begin
          stall_o = 1'b1; 
        end else begin
          stall_o = 1'b0;
        end
      end

      default: stall_o = 1'b0;
    endcase
  end

  always_comb begin
    casez (instr_o)
      I_ALL_LOADS: sel_rd_o = instr_o[11:7];
      R_ALL:       sel_rd_o = instr_o[11:7];
      default:     sel_rd_o = '0;
    endcase
  end

  logic [31:0] alu_oper1, alu_oper2;
  logic [ 4:0] alu_sel_op;

  always_comb begin
    set_was_store = 1'b0;
    casez (instr_i)
      I_ALL_LOADS: begin
        alu_oper1  = rs1_i;
        alu_oper2  = instr_i[31:20];
        alu_sel_op = ALU_ADD;
      end

      S_ALL: begin
        alu_oper1     = rs1_i;
        alu_oper2     = {{20{instr_i[31]}}, instr_i[31:25], instr_i[11:7]};
        alu_sel_op    = ALU_ADD;
        set_was_store = 1'b1;
      end

      R_ADD_SUB: begin
        alu_oper1  = rs1_i;
        alu_oper2  = (instr_i[30]) ? ~rs2_i + 1'b1 : rs2_i;
        alu_sel_op = ALU_ADD;
      end

      R_SLL: begin
        alu_oper1  = rs1_i;
        alu_oper2  = rs2_i;
        alu_sel_op = ALU_SLL;
      end

      R_SLT: begin
        alu_oper1  = rs1_i;
        alu_oper2  = rs2_i;
        alu_sel_op = ALU_SLT;
      end

      R_SLTU: begin
        alu_oper1  = rs1_i;
        alu_oper2  = rs2_i;
        alu_sel_op = ALU_SLTU;
      end

      R_XOR: begin
        alu_oper1  = rs1_i;
        alu_oper2  = rs2_i;
        alu_sel_op = ALU_XOR;
      end
      
      R_SRL_SRA: begin
        alu_oper1  = rs1_i;
        alu_oper2  = rs2_i;
        alu_sel_op = (instr_i[30]) ? ALU_SRA : ALU_SRL;
      end
      
      R_OR: begin
        alu_oper1  = rs1_i;
        alu_oper2  = rs2_i;
        alu_sel_op = ALU_OR;
      end
      
      R_AND: begin
        alu_oper1  = rs1_i;
        alu_oper2  = rs2_i;
        alu_sel_op = ALU_AND;
      end
      
      default: begin
        alu_oper1     = '0;
        alu_oper2     = '0;
        alu_sel_op    = ALU_UNDEF;
        set_was_store = 1'b0;
      end
    endcase
  end

  alu u_alu (
    .oper1_i (alu_oper1),
    .oper2_i (alu_oper2),
    .sel_op_i(alu_sel_op),
    .result_o(alu_result)
  );

  always_ff @(posedge clk, negedge rst_n) begin
    if (!rst_n) alu_result_o <= '0;
    else alu_result_o <= alu_result;
  end

endmodule : execute
