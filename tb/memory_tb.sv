`default_nettype none

module memory_tb ();
  logic                  clk;
  logic [ADDR_WIDTH-1:0] addr_i;
  tri   [          31:0] bus_io;
  logic [          31:0] temp_data;
  logic                  re_i;
  logic                  we_i;

  assign bus_io = (we_i) ? temp_data : 32'bz;

  data_memory dut (.*);

  initial begin
    clk = 0;
    forever #1 clk = ~clk;
  end

  initial begin
    $display(ADDR_WIDTH);
    $monitor($time,, "addr_i = %b", addr_i,, "data = %h", data);
  end

  initial begin
    $dumpvars(0, memory_tb);
  end

  initial begin
    addr_i = 0;
    re_i = 0;
    we_i = 0;
    temp_data = 0;

    @(posedge clk);
    @(posedge clk);

    re_i <= 1;

    @(posedge clk);

    addr_i <= addr_i + 4;

    @(posedge clk);

    addr_i <= addr_i + 4;

    @(posedge clk);

    addr_i <= addr_i + 4;

    @(posedge clk);

    re_i <= 0;
    we_i <= 1;
    addr_i <= 0;
    temp_data <= 32'hDEEDFEED;

    @(posedge clk);

    $finish();
  end

endmodule