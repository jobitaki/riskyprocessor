`default_nettype none

import constants::*;

// 
//  Module 'data_memory'
//
//  Basic memory with combinational read, sequential write.
//  Will be replaced with cache system later on.
//
module data_memory (
    input  logic                        clk,
    input  logic       [ADDR_WIDTH-1:0] addr_i,
    inout  tri         [          31:0] bus_io,
    input  logic                        re_i,
    input  logic                        we_i,
    input  data_size_e                  access_unit_i, // For store ops
    output logic       [         127:0] mem_o          // FOR TESTING
);

  logic [7:0] mem[SIM_MEM_SIZE];

  logic [31:0] rd_data;

  always_comb begin
    if (re_i) begin
      unique case (access_unit_i)
        BYTE_S: rd_data = {{24{mem[addr_i][7]}}, mem[addr_i]};
        BYTE_U: rd_data = {24'd0, mem[addr_i]};
        HALF_S: rd_data = {{16{mem[addr_i+1][7]}}, mem[addr_i+1], mem[addr_i]};
        HALF_U: rd_data = {16'd0, mem[addr_i], mem[addr_i]};
        WORD:   rd_data = {mem[addr_i+3], mem[addr_i+2], mem[addr_i+1], mem[addr_i]};
      endcase
    end
  end

  assign mem_o  = {mem[7], mem[6], mem[5], mem[4], mem[3], mem[2], mem[1], mem[0]};

  assign bus_io = (re_i) ? rd_data : 'z;

  always_ff @(posedge clk) begin
    if (we_i) begin
      unique case (access_unit_i)
        BYTE_U: mem[addr_i] <= bus_io[7:0];
        HALF_U: {mem[addr_i+1], mem[addr_i]} <= bus_io[15:0];
        WORD:   {mem[addr_i+3], mem[addr_i+2], mem[addr_i+1], mem[addr_i]} <= bus_io;
      endcase
    end
  end

  initial begin
    int fd = $fopen("data.hex", "r");
    int status;
    logic [$clog2(SIM_MEM_SIZE+1):0] addr;
    logic [31:0] mem_line;
    if (fd) begin
      addr = '0;
      while (!$feof(
          fd
      )) begin
        status = $fscanf(fd, "%h", mem_line);
        if (status == 1) begin
          for (int i = 0; i < 4; i++) begin
            mem[addr+i] = mem_line[i*8+:8];
          end
          addr += 4;
        end
      end
    end else begin
      $display("File not found");
      $fflush();
      $finish(2);
    end

    $fclose(fd);
  end

endmodule : data_memory
