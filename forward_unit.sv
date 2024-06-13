`default_nettype none

module forward_unit (
    input  logic [ 4:0] sel_rs1_i,
    input  logic [ 4:0] sel_rs2_i, 
    input  logic [ 4:0] execute_sel_rd_i,
    input  logic [ 4:0] mem_sel_rd_i,
    output logic [ 1:0] sel_rs1_src_o,
    output logic [ 1:0] sel_rs2_src_o
);
  
  always_comb begin
    if (sel_rs1_i && sel_rs2_i) begin 
      if (sel_rs1_i == execute_sel_rd_i) begin
        sel_rs1_src_o = FU_SRC_MEM;
      end
      else if (sel_rs1_i == mem_sel_rd_i) begin
        sel_rs1_src_o = FU_SRC_WB;
      end
      else begin
        sel_rs1_src_o = FU_SRC_REG;
      end
      
      if (sel_rs2_i == execute_sel_rd_i) begin
        sel_rs2_src_o = FU_SRC_MEM;
      end
      else if (sel_rs2_i == mem_sel_rd_i) begin
        sel_rs2_src_o = FU_SRC_WB;
      end
      else begin
        sel_rs2_src_o = FU_SRC_REG;
      end
    end
    else begin
      sel_rs1_src_o = FU_SRC_REG;
      sel_rs2_src_o = FU_SRC_REG;
    end
  end

endmodule : forward_unit