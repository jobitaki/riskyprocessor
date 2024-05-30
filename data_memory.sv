`default_nettype none

module data_memory (
    input logic                  clk,
    input logic [ADDR_WIDTH-1:0] addr_i,
    inout tri   [          31:0] bus_io,
    input logic                  re_i,
    input logic                  we_i
);

  logic [31:0] mem[SIM_MEM_SIZE];

  assign bus_io = (re_i) ? mem[addr_i] : 'z;

  always_ff @(posedge clk) begin
    if (we_i) mem[addr_i] <= data;
  end

  initial begin
    int fd = $fopen("data.hex", "r");
    int status;
    logic [$clog2(SIM_MEM_SIZE+1):0] addr_i;
    logic [31:0] mem_line;
    if (fd) begin
      addr_i = '0;
      while (!$feof(
          fd
      )) begin
        status = $fscanf(fd, "%h", mem_line);
        if (status == 1) begin
          mem[{addr_i, 2'b00}] = mem_line;
          addr_i += 1;
        end
      end
    end else begin
      $display("File not found");
      $fflush();
      $finish(2);
    end

    $fclose(fd);
  end

endmodule : memory_simulation
