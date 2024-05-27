`default_nettype none

module memory (
    input logic                  clock,
    input logic [ADDR_WIDTH-1:0] addr,
    inout tri   [          31:0] data,
    input logic                  re,
    input logic                  we
);

  memory_simulation mem (.*);

endmodule

module memory_synthesis (
    input  logic                  clock,
    input  logic [ADDR_WIDTH-1:0] data_in_addr,
    input  logic [          31:0] data_in,
    input  logic                  re,
    input  logic                  we,
    input  logic [ADDR_WIDTH-1:0] data_out_addr,
    output logic [          31:0] data_out
);

  logic [31:0] mem[(1 << ADDR_WIDTH) + 1];

  always_ff @(posedge clock) begin
    if (we) begin
      mem[data_in_addr] <= data_in;
    end else if (re) begin
      data_out <= mem[data_out_addr];
    end
  end

endmodule : memory_synthesis

module memory_simulation (
    input logic                  clock,
    input logic [ADDR_WIDTH-1:0] addr,
    inout tri   [          31:0] data,
    input logic                  re,
    input logic                  we
);

  logic [31:0] mem[SIM_MEM_SIZE];

  assign data = (re) ? mem[addr] : 32'bz;

  always_ff @(posedge clock) begin
    if (we) mem[addr] <= data;
  end

  initial begin
    int fd = $fopen("memory.hex", "r");
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
          mem[{addr, 2'b00}] = mem_line;
          addr += 1;
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

module memory_tb ();
  logic                  clock;
  logic [ADDR_WIDTH-1:0] addr;
  tri   [          31:0] data;
  logic                  re;
  logic                  we;

  memory dut (.*);

  initial begin
    clock = 0;
    forever #1 clock = ~clock;
  end

  initial begin
    $monitor($time,, "addr = %b", addr, "data = %b", data);
  end

  initial begin
    addr = 0;
    re   = 0;
    we   = 0;

    @(posedge clock);
    @(posedge clock);

    re = 1;

    @(posedge clock);

    addr += 1;

    @(posedge clock);

    addr += 1;

    @(posedge clock);

    addr += 1;

    @(posedge clock);
    @(posedge clock);

    $finish();
  end

endmodule
