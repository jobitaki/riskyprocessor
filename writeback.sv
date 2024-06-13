`default_nettype none

module writeback (
    input  logic        clk,
    input  logic        rst_n,
    input  logic [31:0] instr_i,
    input  logic [31:0] alu_result_i,
    input  logic [31:0] data_i,
    output logic [31:0] data_bypass_o,
    output logic [ 4:0] sel_rd_o,
    output logic        we_o,
    output logic [31:0] data_o
);

  // The writeback stage should write what is in data or alu_result into the rd
  // register.
  
  assign data_bypass_o = data_i;

  always_ff @(posedge clk, negedge rst_n) begin
    if (!rst_n) begin
      sel_rd_o <= '0;
      we_o <= '0;
      data_o <= '0;
    end else begin
      casez (instr_i)
        I_LB: begin
          sel_rd_o <= instr_i[11:7];
          we_o     <= 1'b1;
          case (alu_result_i[1:0])
            2'b00:   data_o <= {{24{data_i[7]}}, data_i[7:0]};
            2'b01:   data_o <= {{24{data_i[15]}}, data_i[15:8]};
            2'b10:   data_o <= {{24{data_i[23]}}, data_i[23:16]};
            2'b11:   data_o <= {{24{data_i[31]}}, data_i[31:24]};
            default: data_o <= '0;
          endcase
        end

        I_LBU: begin
          sel_rd_o <= instr_i[11:7];
          we_o     <= 1'b1;
          case (alu_result_i[1:0])
            2'b00:   data_o <= {24'd0, data_i[7:0]};
            2'b01:   data_o <= {24'd0, data_i[15:8]};
            2'b10:   data_o <= {24'd0, data_i[23:16]};
            2'b11:   data_o <= {24'd0, data_i[31:24]};
            default: data_o <= '0;
          endcase
        end

        I_LH: begin
          sel_rd_o <= instr_i[11:7];
          we_o     <= 1'b1;
          case (alu_result_i[1:0])
            2'b00:   data_o <= {{16{data_i[15]}}, data_i[15:0]};
            2'b10:   data_o <= {{16{data_i[15]}}, data_i[31:16]};
            default: data_o <= '0;
          endcase
        end

        I_LHU: begin
          sel_rd_o <= instr_i[11:7];
          we_o     <= 1'b1;
          case (alu_result_i[1:0])
            2'b00:   data_o <= {16'd0, data_i[15:0]};
            2'b10:   data_o <= {16'd0, data_i[31:16]};
            default: data_o <= '0;
          endcase
        end

        I_LW: begin
          sel_rd_o <= instr_i[11:7];
          we_o     <= 1'b1;
          data_o   <= data_i;
        end

        R_ALL: begin
          sel_rd_o <= instr_i[11:7];
          we_o     <= 1'b1;
          data_o   <= alu_result_i;
        end

        default: begin
          sel_rd_o <= '0;
          we_o     <= 1'b0;
          data_o   <= '0;
        end
      endcase
    end
  end

endmodule : writeback
