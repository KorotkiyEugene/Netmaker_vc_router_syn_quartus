/********** defines.v **********/
// `defines are only used to create type definitions (and in some local optimisations)
// module parameters should always be used locally in
// modules

`ifndef DEFINES_V
`define DEFINES_V

`define OPT_MESHXYTURNS
`define CHANNEL_DATA_WIDTH 32
`define FLIT_DYNAMIC_PRIORITY_BITS 4
`define X_ADDR_BITS 2
`define Y_ADDR_BITS 2
`define ROUTER_NUM_VCS 2
`define VC_INDEX_BITS 2
`define ROUTER_RADIX 5
`define NETWORK_X 4
`define NETWORK_Y 4

`endif