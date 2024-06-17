`default_nettype none

module execute (
    input  logic clk,
    input  logic rst_n,
    input  logic [ 4:0] sel_rd_i,
    input  alu_op_e     alu_op_i,
    input  alu_src_e    alu_src1_i,
    input  alu_src_e    alu_src2_i,
    input  logic        mem_re_i,
    input  logic        mem_we_i,
    input  data_size_e  mem_size_i,
    input  logic [31:0] imm_i,
    input  logic [31:0] rs1_i,
    input  logic [31:0] rs2_i,
    output logic [ 4:0] sel_rd_o,
    output logic        mem_re_o,
    output logic        mem_we_o,
    output data_size_e  mem_size_o,
    output logic [31:0] alu_result_o,
    output logic [31:0] rs2_o,        // Necessary for store operations
    output logic        stall_o
);

  logic        set_was_store;     // Sets the was_store value
  logic        was_store;         // Marks if previous operation was a store op
  logic [31:0] was_store_address; // The address of the previous store
  logic [31:0] alu_result;

  always_ff @(posedge clk, negedge rst_n) begin
    if (!rst_n) begin
      sel_rd_o          <= '0;
      mem_re_o          <= '0;
      mem_we_o          <= '0;
      mem_size_o        <= '0;
      rs2_o             <= '0;
      was_store         <= 1'b0;
      was_store_address <= '0;
    end
    else begin
      if (!stall_o) begin
        sel_rd_o   <= sel_rd_i;
        mem_re_o   <= mem_re_i;
        mem_we_o   <= mem_we_i;
        mem_size_o <= mem_size_i;
        rs2_o      <= rs2_i;
      end else begin
        // In case of stall, we generate a bubble
        sel_rd_o   <= '0;
        mem_re_o   <= '0;
        mem_we_o   <= '0;
        mem_size_o <= '0;
        // We hold rs2_o to be the same since we want to save it
        // The other control signals are saved in the previous stage outputs
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

  // If store detected, set the was_store flag
  always_comb begin
    if (mem_we_i) set_was_store = 1'b1;
    else          set_was_store = 1'b0;
  end

  // Stall generator
  always_comb begin
    if (mem_re_i) begin
      // If the previous op was store, and the addresses are the same, stall
      if (was_store && was_store_address == alu_result) begin
        stall_o = 1'b1; 
      end else begin
        stall_o = 1'b0;
      end
    end 
    else begin
      stall_o = 1'b0;
    end
  end

  logic [31:0] alu_oper1, alu_oper2;

  always_comb begin
    case (alu_src1_i)
      ALU_SRC_IMM: alu_oper1 = imm_i;
      ALU_SRC_RS1: alu_oper1 = rs1_i;
      ALU_SRC_RS2: alu_oper1 = rs2_i;
      default:     alu_oper1 = '0;
    endcase
  end
  
  always_comb begin
    case (alu_src2_i)
      ALU_SRC_IMM: alu_oper2 = imm_i;
      ALU_SRC_RS1: alu_oper2 = rs1_i;
      ALU_SRC_RS2: alu_oper2 = rs2_i;
      default:     alu_oper2 = '0;
    endcase
  end

  alu u_alu (
    .oper1_i (alu_oper1),
    .oper2_i (alu_oper2),
    .sel_op_i(alu_op_i),
    .result_o(alu_result)
  );

  // Flop the alu result
  always_ff @(posedge clk, negedge rst_n) begin
    if (!rst_n) alu_result_o <= '0;
    else alu_result_o <= alu_result;
  end

endmodule : execute
