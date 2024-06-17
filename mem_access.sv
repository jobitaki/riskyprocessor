`default_nettype none

//
//  Module 'mem_access'
//
//  The MEM stage of the pipeline. Instructions requiring reads and writes
//  from/to memory make use of this stage.
//
module mem_access (
    input  logic        clk,
    input  logic        rst_n,
    input  logic [ 4:0] sel_rd_i,
    input  logic        mem_re_i,
    input  logic        mem_we_i,
    input  data_size_e  mem_size_i,
    input  logic [31:0] alu_result_i,
    input  logic [31:0] data_i,        // rs2 data for store operations
    input  logic        stall_i,
    output logic        mem_re_o,
    output logic        mem_we_o,
    output logic [31:0] alu_result_o,
    output logic [31:0] data_o,
    output logic [31:0] data_bypass_o, // For data forwarding
    output logic [ 4:0] sel_rd_o       // For forwarding unit
);

  logic [31:0] wr_data, rd_data;

  always_ff @(posedge clk, negedge rst_n) begin
    if (!rst_n) begin
      sel_rd_o     <= '0;
      mem_re_o     <= '0;
      mem_we_o     <= '0;
      alu_result_o <= '0;
    end
    else begin
      sel_rd_o     <= sel_rd_i;
      mem_re_o     <= mem_re_i;
      mem_we_o     <= mem_we_i;
      alu_result_o <= alu_result_i;
    end
  end

  // Data to bypass depends on instruction. If load instruction, send memory read.
  // Otherwise, just send alu result. 
  always_comb begin
    if (mem_re_i) data_bypass_o = rd_data;
    else          data_bypass_o = alu_result_i;
  end

  // Data slicing for store operations
  always_comb begin
    if (mem_we_i) begin
      casez (mem_size_i)
        BYTE_U:  wr_data = data_i[7:0];
        HALF_U:  wr_data = data_i[15:0];
        WORD:    wr_data = data_i;
        default: wr_data = '0;
      endcase
    end else wr_data = '0;
  end

  tri   [          31:0] data_memory_bus;
  logic [ADDR_WIDTH-1:0] data_memory_addr;

  assign data_memory_bus  = (mem_we_i) ? wr_data : 'z;
  assign data_memory_addr = {alu_result_i[ADDR_WIDTH:2], 2'b00};

  // Data slicing for load operations
  always_comb begin
    if (mem_re_i) begin
      case (mem_size_i)
        BYTE_S: begin
          case (alu_result_i[1:0])
            2'b00:   rd_data = {{24{data_memory_bus[7]}}, data_memory_bus[7:0]};
            2'b01:   rd_data = {{24{data_memory_bus[15]}}, data_memory_bus[15:8]};
            2'b10:   rd_data = {{24{data_memory_bus[23]}}, data_memory_bus[23:16]};
            2'b11:   rd_data = {{24{data_memory_bus[31]}}, data_memory_bus[31:24]};
            default: rd_data = '0;
          endcase
        end

        BYTE_U: begin
          case (alu_result_i[1:0])
            2'b00:   rd_data = {24'd0, data_memory_bus[7:0]};
            2'b01:   rd_data = {24'd0, data_memory_bus[15:8]};
            2'b10:   rd_data = {24'd0, data_memory_bus[23:16]};
            2'b11:   rd_data = {24'd0, data_memory_bus[31:24]};
            default: rd_data = '0;
          endcase
        end

        HALF_S: begin
          case (alu_result_i[1:0])
            2'b00:   rd_data = {{16{data_memory_bus[15]}}, data_memory_bus[15:0]};
            2'b10:   rd_data = {{16{data_memory_bus[15]}}, data_memory_bus[31:16]};
            default: rd_data = '0;
          endcase
        end

        HALF_U: begin
          case (alu_result_i[1:0])
            2'b00:   rd_data = {16'd0, data_memory_bus[15:0]};
            2'b10:   rd_data = {16'd0, data_memory_bus[31:16]};
            default: rd_data = '0;
          endcase
        end

        WORD: begin
          rd_data = data_memory_bus;
        end
        
        default: rd_data = '0;
      endcase
    end else rd_data = '0;
  end

  data_memory u_data_memory (
    .clk,
    .addr_i(data_memory_addr),
    .bus_io(data_memory_bus),
    .re_i  (mem_re_i),
    .we_i  (mem_we_i)
  );

  always_ff @(posedge clk, negedge rst_n) begin
    if (!rst_n) data_o <= '0;
    else        data_o <= rd_data;
  end

endmodule
