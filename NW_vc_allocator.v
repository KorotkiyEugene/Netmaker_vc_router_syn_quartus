/* -------------------------------------------------------------------------------
 * (C)2007 Robert Mullins
 * Computer Architecture Group, Computer Laboratory
 * University of Cambridge, UK.
 * -------------------------------------------------------------------------------
 * 
 * VC allocator 
 * 
 * Allocates new virtual-channels for newly arrived packets.
 * 
 * Supported VC allocation architectures:
 * 
 *    (A) "fifo_free_pool" - Free VC pool is organised as a FIFO, at most one VC
 *        may be allocated per output port per clock cycle
 * 
 *           In this case we just need P x PV:1 arbiters
 * 
 *    (B) "unrestricted"   - Peh/Dally style VC allocation. 
 *        Takes place in two stages:
 * 
 *           stage 1. Each waiting packet determines which VC it will request.
 *                    (v:1 arbitration). Can support VC alloc. mask here (from 
 *                    packet header or static or dynamic..)
 *                    
 * 
 *           stage 2. Access to each output VC is arbitrated (PV x PV:1 arbiters)
 * 
 */

module NW_vc_allocator (req, output_port,      // VC request, for which port?
			req_priority,          // prioritized requests?
			vc_new, vc_new_valid,  // newly allocated VC ids
			// ** restricted FIFO case **
			next_free_vc,          // next free VC at each output port
			no_free_vc,            // free VC fifo empty? 
			pop_free_vc,           // VC consumed at output port
			// ** unrestricted case **
			vc_mask,               // which VCs is input VC permitted to request
//			vc_sel_priority,       // Priorities for VC selection stage 
			vc_allocated,          // which VCs were allocated on this cycle?
			vc_requested,          // which VCs were requested by each input VC?
			vc_alloc_status,       // which VCs are free?
			flit,                  // head of each VC buffer
			vc_credits,            // Credits available at each VC at each output port
			clk, rst_n);

   `include "NW_functions.v"

   //parameter type flit_priority_t = flit_pri_t;
   
   parameter buf_len=4;
   
   parameter xs=4;
   parameter ys=4;
		
   parameter np=5;
   parameter nv=4;
   parameter dynamic_priority_vc_alloc = 0;
   parameter vcalloc_unrestricted = 0;

   // specifically for unrestricted VC pool case
//   parameter type vc_priority_t = bit unsigned [2:0];
//   parameter prioritize_vc_selection = 0;
//   parameter use_vc_allocation_mask = 1;

   parameter vcselect_bydestinationnode = 0;
   parameter vcselect_leastfullbuffer = 0;
   parameter vcselect_arbstateupdate = 0;  
   parameter vcselect_usepacketmask = 0;   
   
//-----
   input [np-1:0][nv-1:0] req;
   input flit_priority_t req_priority [np-1:0][nv-1:0];
   input output_port_t output_port [np-1:0][nv-1:0];
   input [np-1:0][nv-1:0] next_free_vc;
   input [np-1:0]  no_free_vc; // free VC fifo empty?
   output [np-1:0][nv-1:0][nv-1:0] vc_new;
   output [np-1:0][nv-1:0] vc_new_valid;
   output [np-1:0] pop_free_vc;

   input [np-1:0][nv-1:0][nv-1:0] vc_mask;
//   input vc_priority_t vc_sel_priority [np-1:0][nv-1:0][nv-1:0];
   output [np-1:0][nv-1:0] vc_allocated;  
   output [np-1:0][nv-1:0][nv-1:0] vc_requested;
   input [np-1:0][nv-1:0] vc_alloc_status;
   input flit_t flit [np-1:0][nv-1:0];
   input [np-1:0][nv-1:0][clogb2(buf_len+1)-1:0] vc_credits;
   
   input clk, rst_n;

   generate
      if (!vcalloc_unrestricted) begin
	 /*NW_vc_restricted_allocator
	   #(.np(np), .nv(nv),
	     .dynamic_priority_vc_alloc(dynamic_priority_vc_alloc))
	     restricted 
	       (
		.req, 
		.output_port,     
		.req_priority,         
		.vc_new, 
		.vc_new_valid, 
		.next_free_vc,         
		.no_free_vc,           
		.pop_free_vc,          
		.clk, .rst_n
		);*/
      end else begin // if (!vcalloc_unrestricted)
	 
	 NW_vc_unrestricted_allocator
	   #(.np(np), .nv(nv), .xs(xs), .ys(ys), .buf_len(buf_len), 
	     .dynamic_priority_vc_alloc(dynamic_priority_vc_alloc),
	     .vcselect_bydestinationnode(vcselect_bydestinationnode), 
	     .vcselect_leastfullbuffer(vcselect_leastfullbuffer), 
	     .vcselect_arbstateupdate(vcselect_arbstateupdate), 
	     .vcselect_usepacketmask(vcselect_usepacketmask))
	     unrestricted
	       (
		.req, 
		.output_port,     
		//.vc_mask,         
		.req_priority,    
//		.vc_sel_priority, 
		.vc_status(vc_alloc_status),        
		.vc_new,          
		.vc_new_valid,    
		.vc_allocated,    
		.vc_requested, 
		.flit, .vc_credits,
		.clk, .rst_n
		);

      end
   endgenerate

endmodule // NW_vc_allocator

