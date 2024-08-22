`default_nettype none

//
//  Module 'ls_forward_unit'
//
//  Detects data hazards between store and load operations and controls
//  the mux sel into the mem_access stage in load operations. The point is
//  to catch loads to the same address as stores that have not finished storing
//  yet. Then, the data that is scheduled to be stored can be routed into the
//  load instruction without any bubbles in the pipeline.
//
module ls_forward_unit (
    input logic [31:0] store_address,
    input logic [31:0] load_address,
    input logic        sel_data_src
);

  always_comb begin
    if (store_address == load_address) begin
    end
  end
  
endmodule : ls_forward_unit