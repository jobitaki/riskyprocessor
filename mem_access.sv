`default_nettype none

module mem_access (
    input  logic        clk,
    input  logic        rst_n,
    input  logic [31:0] instr_i,
    input  logic [31:0] alu_result_i,
    input  logic [31:0] data_i,
    output logic [31:0] instr_o,
    output logic [31:0] alu_result_o,
    output logic [31:0] data_o,
    output logic [31:0] data_bypass_o,
    output logic [ 4:0] sel_rd_o
);

  logic re, we;
  logic [31:0] wr_data;

  always_ff @(posedge clk, negedge rst_n) begin
    if (!rst_n) begin
      instr_o      <= '0;
      alu_result_o <= '0;
    end
    else begin
      instr_o      <= instr_i;
      alu_result_o <= alu_result_i;
    end
  end
  
  // We output sel_rd_o for the forwarding unit to know if forwarding is needed
  always_comb begin
    casez (instr_o)
      I_ALL_LOADS: sel_rd_o = instr_o[11:7];
      R_ALL:       sel_rd_o = instr_o[11:7];
      default:     sel_rd_o = '0;
    endcase
  end

  always_comb begin
    casez (instr_i)
      I_ALL_LOADS: begin
        re = 1'b1;
      end

      S_ALL: begin
        we = 1'b1;
      end

      default: begin
        re = 1'b0;
        we = 1'b0;
      end
    endcase
  end

  // Data slicing for store operations
  always_comb begin
    casez (instr_i)
      S_SB:    wr_data = data_i[7:0];
      S_SH:    wr_data = data_i[15:0];
      S_SW:    wr_data = data_i;
      default: wr_data = '0;
    endcase
  end

  tri   [          31:0] data_memory_bus;
  logic [ADDR_WIDTH-1:0] data_memory_addr;

  assign data_memory_bus  = (we) ? wr_data : 'z;
  assign data_memory_addr = {alu_result_i[ADDR_WIDTH:2], 2'b00};
  assign data_bypass_o    = (re) ? data_memory_bus : '0;

  data_memory u_data_memory (
    .clk,
    .addr_i(data_memory_addr),
    .bus_io(data_memory_bus),
    .re_i  (re),
    .we_i  (we)
  );

  always_ff @(posedge clk, negedge rst_n) begin
    if (!rst_n)  data_o <= '0;
    else if (re) data_o <= data_memory_bus;
  end

endmodule
