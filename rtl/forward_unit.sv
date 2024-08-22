`default_nettype none

import constants::*;

//
//  Module 'forward_unit'
//
//  Detects data hazards and controls the mux sel into the execute stage.
//
module forward_unit (
    input  logic [4:0] sel_rs1_i,
    input  logic [4:0] sel_rs2_i, 
    input  logic [4:0] mem_stage_sel_rd_i, // rd pointer of current instr in MEM stage
    input  logic [4:0] wb_stage_sel_rd_i,  // rd pointer of current instr in WB stage
    output logic [1:0] sel_rs1_src_o,      // Bypass to execute
    output logic [1:0] sel_rs2_src_o       // Bypass to execute
);
  
  // Logic to select rs1 source into execute
  always_comb begin
    if (sel_rs1_i) begin 
      if (sel_rs1_i == mem_stage_sel_rd_i) begin
        sel_rs1_src_o = FU_SRC_MEM;
      end
      else if (sel_rs1_i == wb_stage_sel_rd_i) begin
        sel_rs1_src_o = FU_SRC_WB;
      end
      else begin
        sel_rs1_src_o = FU_SRC_REG;
      end
    end
    else begin
      sel_rs1_src_o = FU_SRC_REG;
    end
  end

  // Logic to select rs2 source into execute
  always_comb begin
    if (sel_rs2_i) begin
      if (sel_rs2_i == mem_stage_sel_rd_i) begin
        sel_rs2_src_o = FU_SRC_MEM;
      end
      else if (sel_rs2_i == wb_stage_sel_rd_i) begin
        sel_rs2_src_o = FU_SRC_WB;
      end
      else begin
        sel_rs2_src_o = FU_SRC_REG;
      end
    end
    else begin
      sel_rs2_src_o = FU_SRC_REG;
    end
  end

endmodule : forward_unit