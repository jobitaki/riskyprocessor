`default_nettype none

module risky_tb ();
  logic clk, rst_n;

  risky dut (
    .clk,
    .rst_n
  );

  initial begin
    clk = 0;
    forever #1 clk = ~clk;
  end

  initial begin
    $dumpvars(0, risky_tb);
  end

  initial begin
    rst_n = 0;

    @(posedge clk);

    rst_n = 1;

    @(posedge clk);

    for (int i = 0; i < 50; i++) @(posedge clk);
    $finish;
  end

endmodule : risky_tb
