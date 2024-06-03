`default_nettype none

module mem_access (
    input  logic        clk,
    input  logic        rst_n,
    input  logic [31:0] instr_i,
    input  logic [31:0] alu_result_i,
    output logic [31:0] instr_o,
    output logic [31:0] alu_result_o,
    output logic [31:0] data_o
);

  logic re, we;

  always_ff @(posedge clk, negedge rst_n) begin
    if (!rst_n) begin
      instr_o <= '0;
      alu_result_o <= '0;
    end
    else begin
      instr_o <= instr_i;
      alu_result_o <= alu_result_i;
    end
  end

  always_comb begin
    casez (instr_i)
      I_ALL_LOADS: begin
        re = 1'b1;
      end

      default: begin
        re = 1'b0;
        we = 1'b0;
      end
    endcase
  end

  tri   [          31:0] data_memory_bus;
  logic [ADDR_WIDTH-1:0] data_memory_addr;

  assign data_memory_addr = {alu_result_i[ADDR_WIDTH:2], 2'b00};

  data_memory u_data_memory (
    .clk,
    .addr_i(data_memory_addr),
    .bus_io(data_memory_bus),
    .re_i  (re),
    .we_i  (we)
  );

  always_ff @(posedge clk, negedge rst_n) begin
    data_o <= data_memory_bus;
  end

endmodule
