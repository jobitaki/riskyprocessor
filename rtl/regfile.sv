`default_nettype none

module regfile (
    input  logic        clk,
    input  logic        rst_n,
    input  logic [ 4:0] sel_rd_i,
    input  logic [31:0] rd_i,
    input  logic        we_i,      // We are always reading, so only we
    input  logic [ 4:0] sel_rs1_i,
    input  logic [ 4:0] sel_rs2_i,
    output logic [31:0] rs1_o,
    output logic [31:0] rs2_o,
    output logic [ 4:0] sel_rs1_o, // Register index of the current rs1 value
    output logic [ 4:0] sel_rs2_o  // Register index of the current rs2 value
);

  // logic [31:0] register_file[32];

  // assign register_file[0] = 32'd0;

  // always_ff @(posedge clk, negedge rst_n) begin
  //   if (!rst_n) begin
  //     register_file[31:1] <= '0;
  //     rs1_o               <= '0;
  //     rs2_o               <= '0;
  //     sel_rs1_o           <= '0;
  //     sel_rs2_o           <= '0;
  //   end else begin
  //     if (we_i && (sel_rd_i != 5'b0)) register_file[sel_rd_i] <= rd_i;
  //     rs1_o     <= register_file[sel_rs1_i];
  //     rs2_o     <= register_file[sel_rs2_i];
  //     sel_rs1_o <= sel_rs1_i;
  //     sel_rs2_o <= sel_rs2_i;
  //   end
  // end

  // How not to write SystemVerilog example 1:

  logic [31:0] x0, x1, x2, x3, x4, x5, x6, x7, x8, x9, x10, x11, x12, x13, x14,
               x15, x16, x17, x18, x19, x20, x21, x22, x23, x24, x25, x26, x27,
               x28, x29, x30, x31;
  
  assign x0 = 32'd0;

  always_ff @(posedge clk, negedge rst_n) begin
    if (!rst_n) begin
      {x1, x2, x3, x4, x5, x6, x7, x8, x9, x10, x11, x12, x13, x14,
      x15, x16, x17, x18, x19, x20, x21, x22, x23, x24, x25, x26, x27,
      x28, x29, x30, x31} <= '0;

      rs1_o               <= '0;
      rs2_o               <= '0;
      sel_rs1_o           <= '0;
      sel_rs2_o           <= '0;
    end else begin
      if (we_i && (sel_rd_i != 5'b0)) begin
        unique case (sel_rd_i)
          5'd1: x1 <= rd_i;
          5'd2: x2 <= rd_i;
          5'd3: x3 <= rd_i;
          5'd4: x4 <= rd_i;
          5'd5: x5 <= rd_i;
          5'd6: x6 <= rd_i;
          5'd7: x7 <= rd_i;
          5'd8: x8 <= rd_i;
          5'd9: x9 <= rd_i;
          5'd10: x10 <= rd_i;
          5'd11: x11 <= rd_i;
          5'd12: x12 <= rd_i;
          5'd13: x13 <= rd_i;
          5'd14: x14 <= rd_i;
          5'd15: x15 <= rd_i;
          5'd16: x16 <= rd_i;
          5'd17: x17 <= rd_i;
          5'd18: x18 <= rd_i;
          5'd19: x19 <= rd_i;
          5'd20: x20 <= rd_i;
          5'd21: x21 <= rd_i;
          5'd22: x22 <= rd_i;
          5'd23: x23 <= rd_i;
          5'd24: x24 <= rd_i;
          5'd25: x25 <= rd_i;
          5'd26: x26 <= rd_i;
          5'd27: x27 <= rd_i;
          5'd28: x28 <= rd_i;
          5'd29: x29 <= rd_i;
          5'd30: x30 <= rd_i;
          5'd31: x31 <= rd_i;
        endcase
      end
      sel_rs1_o <= sel_rs1_i;
      sel_rs2_o <= sel_rs2_i;

      case (sel_rs1_i)
        5'd0: rs1_o <= x0;
        5'd1: rs1_o <= x1;
        5'd2: rs1_o <= x2;
        5'd3: rs1_o <= x3;
        5'd4: rs1_o <= x4;
        5'd5: rs1_o <= x5;
        5'd6: rs1_o <= x6;
        5'd7: rs1_o <= x7;
        5'd8: rs1_o <= x8;
        5'd9: rs1_o <= x9;
        5'd10: rs1_o <= x10;
        5'd11: rs1_o <= x11;
        5'd12: rs1_o <= x12;
        5'd13: rs1_o <= x13;
        5'd14: rs1_o <= x14;
        5'd15: rs1_o <= x15;
        5'd16: rs1_o <= x16;
        5'd17: rs1_o <= x17;
        5'd18: rs1_o <= x18;
        5'd19: rs1_o <= x19;
        5'd20: rs1_o <= x20;
        5'd21: rs1_o <= x21;
        5'd22: rs1_o <= x22;
        5'd23: rs1_o <= x23;
        5'd24: rs1_o <= x24;
        5'd25: rs1_o <= x25;
        5'd26: rs1_o <= x26;
        5'd27: rs1_o <= x27;
        5'd28: rs1_o <= x28;
        5'd29: rs1_o <= x29;
        5'd30: rs1_o <= x30;
        5'd31: rs1_o <= x31;
        default: rs1_o <= '0;
      endcase

      case (sel_rs2_i)
        5'd0: rs2_o <= x0;
        5'd1: rs2_o <= x1;
        5'd2: rs2_o <= x2;
        5'd3: rs2_o <= x3;
        5'd4: rs2_o <= x4;
        5'd5: rs2_o <= x5;
        5'd6: rs2_o <= x6;
        5'd7: rs2_o <= x7;
        5'd8: rs2_o <= x8;
        5'd9: rs2_o <= x9;
        5'd10: rs2_o <= x10;
        5'd11: rs2_o <= x11;
        5'd12: rs2_o <= x12;
        5'd13: rs2_o <= x13;
        5'd14: rs2_o <= x14;
        5'd15: rs2_o <= x15;
        5'd16: rs2_o <= x16;
        5'd17: rs2_o <= x17;
        5'd18: rs2_o <= x18;
        5'd19: rs2_o <= x19;
        5'd20: rs2_o <= x20;
        5'd21: rs2_o <= x21;
        5'd22: rs2_o <= x22;
        5'd23: rs2_o <= x23;
        5'd24: rs2_o <= x24;
        5'd25: rs2_o <= x25;
        5'd26: rs2_o <= x26;
        5'd27: rs2_o <= x27;
        5'd28: rs2_o <= x28;
        5'd29: rs2_o <= x29;
        5'd30: rs2_o <= x30;
        5'd31: rs2_o <= x31;
        default: rs2_o <= '0;
      endcase
    end
  end

endmodule : regfile
