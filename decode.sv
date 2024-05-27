`default_nettype none

module decode (
    input  logic [31:0] instr,
    output logic [ 4:0] rs1,
    output logic [ 4:0] rs2,
    output logic [19:0] imm
);

  // The instruction decode stage should take in a 32-bit instruction and read
  // the proper registers from the regfile. Is that it? 

  always_comb begin
    casez (instruction)
      LB: begin
      end
      ADD: begin
        rs1 = instr[19:15];
        rs2 = instr[24:20];
      end
      default: begin
      end
    endcase
  end

endmodule : decode
