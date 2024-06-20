`default_nettype none

import constants::*;

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

  task print_registers;
    for (int i = 0; i < 4; i++) begin
      for (int j = 0; j < 8; j++) begin
        int idx = ((8 * i) + j);
        int real_idx = ((8 * i) + j) * 32;
        int real_idx_32 = real_idx + 31;
        $write("[%2d] = %h ", idx, {dut.u_regfile.register_file[real_idx + 31],
                                    dut.u_regfile.register_file[real_idx + 30],
                                    dut.u_regfile.register_file[real_idx + 29],
                                    dut.u_regfile.register_file[real_idx + 28],
                                    dut.u_regfile.register_file[real_idx + 27],
                                    dut.u_regfile.register_file[real_idx + 26],
                                    dut.u_regfile.register_file[real_idx + 25],
                                    dut.u_regfile.register_file[real_idx + 24],
                                    dut.u_regfile.register_file[real_idx + 23],
                                    dut.u_regfile.register_file[real_idx + 22],
                                    dut.u_regfile.register_file[real_idx + 21],
                                    dut.u_regfile.register_file[real_idx + 20],
                                    dut.u_regfile.register_file[real_idx + 19],
                                    dut.u_regfile.register_file[real_idx + 18],
                                    dut.u_regfile.register_file[real_idx + 17],
                                    dut.u_regfile.register_file[real_idx + 16],
                                    dut.u_regfile.register_file[real_idx + 15],
                                    dut.u_regfile.register_file[real_idx + 14],
                                    dut.u_regfile.register_file[real_idx + 13],
                                    dut.u_regfile.register_file[real_idx + 12],
                                    dut.u_regfile.register_file[real_idx + 11],
                                    dut.u_regfile.register_file[real_idx + 10],
                                    dut.u_regfile.register_file[real_idx + 9],
                                    dut.u_regfile.register_file[real_idx + 8],
                                    dut.u_regfile.register_file[real_idx + 7],
                                    dut.u_regfile.register_file[real_idx + 6],
                                    dut.u_regfile.register_file[real_idx + 5],
                                    dut.u_regfile.register_file[real_idx + 4],
                                    dut.u_regfile.register_file[real_idx + 3],
                                    dut.u_regfile.register_file[real_idx + 2],
                                    dut.u_regfile.register_file[real_idx + 1],
                                    dut.u_regfile.register_file[real_idx + 0]});
      end
      $display();
    end
  endtask

  initial begin
    rst_n = 0;

    @(posedge clk);

    rst_n = 1;

    @(posedge clk);

    for (int i = 0; i < 120; i++) begin
      $display("Cycle %0d", i + 2);
      print_registers();
      @(posedge clk);
    end

    $finish;
  end

endmodule : risky_tb
