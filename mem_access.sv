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
    input  logic [31:0] instr_i,
    input  logic [31:0] alu_result_i,
    input  logic [31:0] data_i,
    input  logic        stall_i,
    output logic [31:0] instr_o,
    output logic [31:0] alu_result_o,
    output logic [31:0] data_o,
    output logic [31:0] data_bypass_o,
    output logic [ 4:0] sel_rd_o
);

  logic re, we;
  logic [31:0] wr_data, rd_data;

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
  
  // We output sel_rd_o for the forwarding unit to know if forwarding is needed.
  always_comb begin
    casez (instr_o)
      I_ALL_LOADS: sel_rd_o = instr_o[11:7];
      R_ALL:       sel_rd_o = instr_o[11:7];
      default:     sel_rd_o = '0;
    endcase
  end

  // Data to bypass depends on instruction. If load instruction, send memory read.
  // Otherwise, just send alu result. 
  always_comb begin
    casez (instr_i)
      I_ALL_LOADS: begin
        data_bypass_o = rd_data;
      end

      default: data_bypass_o = alu_result_i;
    endcase
  end

  // Based on the instruction, we either read or write from/to memory.
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

  // Data slicing for load operations
  always_comb begin
    casez (instr_i)
      I_LB: begin
        case (alu_result_i[1:0])
          2'b00:   rd_data <= {{24{data_memory_bus[7]}}, data_memory_bus[7:0]};
          2'b01:   rd_data <= {{24{data_memory_bus[15]}}, data_memory_bus[15:8]};
          2'b10:   rd_data <= {{24{data_memory_bus[23]}}, data_memory_bus[23:16]};
          2'b11:   rd_data <= {{24{data_memory_bus[31]}}, data_memory_bus[31:24]};
          default: rd_data <= '0;
        endcase
      end

      I_LBU: begin
        case (alu_result_i[1:0])
          2'b00:   rd_data <= {24'd0, data_memory_bus[7:0]};
          2'b01:   rd_data <= {24'd0, data_memory_bus[15:8]};
          2'b10:   rd_data <= {24'd0, data_memory_bus[23:16]};
          2'b11:   rd_data <= {24'd0, data_memory_bus[31:24]};
          default: rd_data <= '0;
        endcase
      end

      I_LH: begin
        case (alu_result_i[1:0])
          2'b00:   rd_data <= {{16{data_memory_bus[15]}}, data_memory_bus[15:0]};
          2'b10:   rd_data <= {{16{data_memory_bus[15]}}, data_memory_bus[31:16]};
          default: rd_data <= '0;
        endcase
      end

      I_LHU: begin
        case (alu_result_i[1:0])
          2'b00:   rd_data <= {16'd0, data_memory_bus[15:0]};
          2'b10:   rd_data <= {16'd0, data_memory_bus[31:16]};
          default: rd_data <= '0;
        endcase
      end

      I_LW: begin
        rd_data  <= data_memory_bus;
      end
      
      default: rd_data <= '0;
    endcase
  end

  data_memory u_data_memory (
    .clk,
    .addr_i(data_memory_addr),
    .bus_io(data_memory_bus),
    .re_i  (re),
    .we_i  (we)
  );

  always_ff @(posedge clk, negedge rst_n) begin
    if (!rst_n) data_o <= '0;
    else                   data_o <= rd_data;
  end

endmodule
