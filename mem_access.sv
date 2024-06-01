`default_nettype none

module mem_access (
    input  logic        clk,
    input  logic        rst_n,
    input  logic [ 4:0] opcode_i,
    input  logic [31:0] alu_result_i,
    input  logic [31:0] data_i,
    output logic        re_o,
    output logic        we_o,
    output logic [ 4:0] opcode_o,
    output logic [31:0] data_o
);

  always_ff @(posedge clk, negedge rst_n) begin
    if (!rst_n) begin
      opcode_o <= '0;
      data_o   <= '0;
    end
    else begin
      opcode_o <= opcode_i;
      data_o   <= data_i;
    end
  end

  always_comb begin
    re_o = 1'b0;
    we_o = 1'b0;
    case (opcode_i)
      5'b00000: begin
        re_o = 1'b1;
      end

      default: begin
      end
    endcase
  end

  tri [31:0] data_memory_bus;

  data_memory u_data_memory (
    .clk,
    .addr_i(alu_result_i),
    .bus_io(data_memory_bus),
    .re_i  (mem_re),
    .we_i  (mem_we)
  );

endmodule
