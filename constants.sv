parameter int ADDR_WIDTH = 9;
parameter int SIM_MEM_SIZE = 16'hFFFF;

typedef enum logic [31:0] {
  // I-type instructions
  I_LB        = 32'b????_????_????_????_?000_????_?000_0011,
  I_LH        = 32'b????_????_????_????_?001_????_?000_0011,
  I_LW        = 32'b????_????_????_????_?010_????_?000_0011,
  I_LBU       = 32'b????_????_????_????_?100_????_?000_0011,
  I_LHU       = 32'b????_????_????_????_?101_????_?000_0011,
  I_ALL_LOADS = 32'b????_????_????_????_????_????_?000_0011,

  // R-type instructions
  R_ADD_SUB = 32'b0?00_000?_????_????_?000_????_?011_0011,
  R_SLL     = 32'b0000_000?_????_????_?001_????_?011_0011,
  R_SLT     = 32'b0000_000?_????_????_?010_????_?011_0011,
  R_SLTU    = 32'b0000_000?_????_????_?011_????_?011_0011,
  R_XOR     = 32'b0000_000?_????_????_?100_????_?011_0011,
  R_SRL_SRA = 32'b0?00_000?_????_????_?101_????_?011_0011,
  R_OR      = 32'b0000_000?_????_????_?110_????_?011_0011,
  R_AND     = 32'b0000_000?_????_????_?111_????_?011_0011,
  R_ALL     = 32'b????_????_????_????_????_????_?011_0011,

  // S-type instructions
  S_SB  = 32'b????_????_????_????_?000_????_?010_0011, 
  S_SH  = 32'b????_????_????_????_?001_????_?010_0011, 
  S_SW  = 32'b????_????_????_????_?010_????_?010_0011,
  S_ALL = 32'b????_????_????_????_????_????_?010_0011
} opcode_e;

typedef enum logic [4:0] {
  ALU_ADD   = 5'b00000,
  ALU_SLL   = 5'b00001,
  ALU_SLT   = 5'b00010,
  ALU_SLTU  = 5'b00011,
  ALU_XOR   = 5'b00100,
  ALU_SRL   = 5'b00101,
  ALU_SRA   = 5'b00110,
  ALU_OR    = 5'b00111,
  ALU_AND   = 5'b01000,
  ALU_UNDEF = 5'b11111
} alu_op_e;

typedef enum logic [1:0] {
  FU_SRC_REG,
  FU_SRC_MEM,
  FU_SRC_WB
} fu_sel_e;