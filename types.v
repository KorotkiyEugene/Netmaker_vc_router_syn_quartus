
/* -------------------------------------------------------------------------------
 * (C)2007 Robert Mullins
 * Computer Architecture Group, Computer Laboratory
 * University of Cambridge, UK.
 * -------------------------------------------------------------------------------
 * 
 * Type definitions
 * 
 * 'flit_t' gets defined here
 * 
 */

//
// `defines are read from defines.v (generated from configuration file)
//

`ifndef __TYPES_V__
`define __TYPES_V__

typedef enum integer { VC, LOCHSIDE, ISLAY } router_t;

typedef bit unsigned [3:0] priority_type;

//`define NEARLY_FULL_FLOW_CONTROL
`define CREDIT_FLOW_CONTROL
`include "defines.v"
	     
typedef logic [`VC_INDEX_BITS-1:0] vc_index_t;
   
typedef logic [`ROUTER_RADIX-1:0] output_port_t;
typedef logic [`ROUTER_NUM_VCS-1:0] vc_t;
typedef logic [`CHANNEL_DATA_WIDTH-1:0] data_t;

// could save one bit here
typedef logic signed [`X_ADDR_BITS:0] x_displ_t;
typedef logic signed [`Y_ADDR_BITS:0] y_displ_t;

//`ifdef FLIT_DYNAMIC_PRIORITY
typedef logic unsigned [`FLIT_DYNAMIC_PRIORITY_BITS-1:0] flit_pri_t;
//`else
//typedef bit flit_pri_t;
//`endif

typedef struct packed 
	{
//`ifdef NEARLY_FULL_FLOW_CONTROL
	 //vc_t nearly_full;
//`endif
//`ifdef CREDIT_FLOW_CONTROL
	 vc_index_t credit;
//`endif
	 logic credit_valid;
	 } chan_cntrl_t;

typedef struct packed
	{
	 logic measure;        // 1 - include in statistics? (else 0 - warmup or drain phase)
	 integer flit_id;      // sequential flit id.
	 integer packet_id;    // sequential (for a particular source node) packet id.
	 integer inject_time;  // time flit entered source FIFO
	 
	 integer hops;         // no. of routers flit traverses on journey
	 
	 integer xdest, ydest; // final destination
	 integer xsrc, ysrc;   // where was packet sent from
	 
	 } debug_flit_t;

typedef struct packed
	{
	 logic valid;	   
	 logic tail;
	 // output port required at next router
	 output_port_t output_port;
	 
	 // destination as displacement from source
	 x_displ_t x_disp;
	 y_displ_t y_disp;
	 
	 vc_t vc_id;
	 } control_flit_t;
   
typedef struct packed
	{
	 data_t data;
	 control_flit_t control;
	 } flit_t;


/*typedef struct packed
	{
	 data_t data;
	 control_flit_t control;
`ifdef DEBUG
	 debug_flit_t debug;
`endif
	 } fifo_elements_t;*/
	 	 
// port ids for 5 port router (input or output)
`define port5id_north 5'b00001
`define port5id_east  5'b00010
`define port5id_south 5'b00100
`define port5id_west  5'b01000
`define port5id_tile  5'b10000

`define NORTH 0
`define EAST  1
`define SOUTH 2
`define WEST  3
`define TILE  4

`define PV  NP*NV

// arrays of struct with real numbers are not supported by SystemVerilog?
   
typedef struct 
  {
    integer total_latency;
    integer total_hops;
    integer min_latency, max_latency;
    integer min_hops, max_hops;

   // start and end of measurement period
    integer measure_start, measure_end, flit_count; 
   
   // record statistics for packets with common journey lengths (hop count)
    integer total_lat_for_hop_count [(`NETWORK_X+`NETWORK_Y):0];
    integer total_packets_with_hop_count [(`NETWORK_X+`NETWORK_Y):0];
   
   // record frequency of different packet latencies
    integer lat_freq[100:0];
   
   } sim_stats_t;

parameter MAXINT = 2^32-1;

`endif