/* -------------------------------------------------------------------------------
 * (C)2007 Robert Mullins
 * Computer Architecture Group, Computer Laboratory
 * University of Cambridge, UK.
 * -------------------------------------------------------------------------------
 *
 * vc_input_port
 * 
 * - Buffers incoming flits and updates VC ID field with VC allocated for 
 *   packet at current router.
 * 
 * - Determine which port is needed at next router (route packet)
 * 
 * pipelined_vc_switch_alloc = 0 | 1
 * =================================
 * 
 *   Do we need to consider VCs allocated on this cycle when returning
 *   currently allocated VC id.?
 *   If VC/switch allocation is pipelined, current VC will always be 
 *   read from the 'vc_reg' register.
 * 
 */

module NW_vc_input_port(push, pop, data_in, vc_id, select, data_out, output_port, data_in_reg, 
			flags, buf_finished_empty, 
			// currently allocated VCs and valid bits
			allocated_vc, allocated_vc_valid,
			// incoming newly granted/allocated VCs and valid bits
			vc_new, vc_new_valid,
			head_is_tail,
			flit_buffer_out, 
			clk, rst_n);

   // number of virtual channels
   parameter num_vcs = 4;
   
   // length of each virtual channel buffer
   parameter buffer_length = 8;

   // Are VC and switch allocation pipelined?
   parameter pipelined_vc_switch_alloc = 0;
   // use of explicit pipelining registers?
   parameter explicit_pipe_registers = 0;

   input  push, clk, rst_n;
   input  [num_vcs-1:0] pop;
   input  flit_t data_in;
   output flit_t data_out;
   output output_port_t output_port [num_vcs-1:0];
   output flit_t data_in_reg;
   output [num_vcs-1:0] head_is_tail;
   output flit_t flit_buffer_out [num_vcs-1:0];
   output [num_vcs-1:0] buf_finished_empty;
   
   `include "NW_functions.v"

   input [clogb2(num_vcs)-1:0] vc_id;
//   input [clogb2(num_vcs)-1:0] select;
   input [num_vcs-1:0] select;

   output fifov_flags_t flags [num_vcs-1:0];
   output [num_vcs-1:0] allocated_vc [num_vcs-1:0];
   output [num_vcs-1:0] allocated_vc_valid;
	 
   input [num_vcs-1:0][num_vcs-1:0] vc_new;
   input [num_vcs-1:0] 	vc_new_valid;

   logic [num_vcs-1:0] vc_reg [num_vcs-1:0];
   logic [num_vcs-1:0] allocated_vc_valid;

   flit_t buffer_data_out, routed;

   logic [clogb2(num_vcs)-1:0] select_bin;

   logic sel_allocated_vc_valid;
   logic [num_vcs-1:0] sel_vc_reg, sel_vc_new;
   
   integer i;
   genvar vc;

   assign select_bin = vc_index_t'(oh2bin(select));
   
   //
   // virtual-channel buffers
   //

/*
   NW_behav_vc_buffers #(.size(buffer_length),
		   .n(num_vcs),
		   .fifo_elements_t(flit_t),
		   .output_all_head_flits(1)) vc_bufsi
     (.push(push), .pop(pop), .data_in(data_in), .vc_id(vc_id), .select(select), 
      .data_out(buffer_data_out), .output_port(output_port), .data_in_reg(data_in_reg), 
      .flags(flags), 
      .head_is_tail(head_is_tail),
      .flit_buffer_out(flit_buffer_out), 
      .clk, .rst_n);
*/

   NW_vc_buffers #(.size(buffer_length),
		   .n(num_vcs),
		   //.fifo_elements_t(flit_t),
		   .output_all_head_flits(1)) vc_bufsi
     (.push(push), .pop(pop), .data_in(data_in), .vc_id(vc_id), .select(select), 
      .data_out(buffer_data_out), .output_port(output_port), .data_in_reg(data_in_reg), 
      .flags(flags), .buf_finished_empty(buf_finished_empty),
      .head_is_tail(head_is_tail),
      .flit_buffer_out(flit_buffer_out), 
      .clk, .rst_n);

   generate
   for (vc=0; vc<num_vcs; vc++) begin:eachvc

      if ((pipelined_vc_switch_alloc)&&(!explicit_pipe_registers)) begin
	 //
	 // if VC and switch allocation are pipelined, 
	 // current VC is always read from register.
	 //
	 assign allocated_vc[vc] = vc_reg[vc];
	 
      end else begin
	 
	 // is VC already held or will it be allocated on this cycle?
	 assign allocated_vc[vc] = vc_reg[vc]; //(allocated_vc_valid[vc]) ? vc_reg[vc] : vc_new[vc];
      end
   end
   endgenerate

   always@(posedge clk) begin
      if (!rst_n) begin
	 for (i=0; i<num_vcs; i++) begin
	    // No allocated VCs on reset
	    allocated_vc_valid[i]<=1'b0;
	 end
      end else begin
	 //
	 // if we have sent the last flit (tail) we don't hold a VC anymore
	 //
	 
//	 if (data_out.control.tail && pop[select]) begin
//	    allocated_vc_valid[select]<=1'b0;
//	 end
	 
	 for (i=0; i<num_vcs; i++) begin

	    if (flit_buffer_out[i].control.tail && pop[i]) begin
	       //
	       // tail has gone, no longer hold a valid VC
	       //
	       allocated_vc_valid[i]<=1'b0;
	       vc_reg[i]<='0;
	    end else begin

	       // [may obtain, use and release VC in one cycle (single flit packets), if so
	       // allocated_vc_valid[] is never set
	       
	       if (vc_new_valid[i]) begin
		  //
		  // receive new VC
		  //
//		  $display ("%m: new VC (%b) written to reg. at input VC buffer %1d", vc_new[i], i);
		  allocated_vc_valid[i]<=1'b1;
		  vc_reg[i]<=vc_new[i];

		  assert (vc_new[i]!='0) else begin
		     $display ("New VC id. is blank?"); $fatal;
		  end
	       end
	    end
	 end
      end // else: !if(!rst_n)
   end // always@ (posedge clk)

   // allocated_vc_valid[select_bin], vc_reg[select_bin], vc_new[select_bin]
   assign sel_allocated_vc_valid = |(allocated_vc_valid & select);

//   NW_mux_oh_select #(.dtype_t(logic[num_vcs-1:0]), .n(num_vcs)) selvcr (vc_reg, select, sel_vc_reg);
//   NW_mux_oh_select #(.dtype_t(logic[num_vcs-1:0]), .n(num_vcs)) selvcn (vc_new, select, sel_vc_new); 
   
   generate
      if (!explicit_pipe_registers) begin
	 NW_route rfn (.flit_in(buffer_data_out), .flit_out(routed), .clk, .rst_n);
	 
	 always_comb
	   begin
	      data_out = routed;

	      data_out.control.vc_id = (sel_allocated_vc_valid) ? vc_reg[select_bin] : vc_new[select_bin]; 
	      
//	      data_out.control.vc_id = (sel_allocated_vc_valid) ? sel_vc_reg : sel_vc_new;
	      //data_out.control.vc_id = (allocated_vc_valid[select_bin]) ? vc_reg[select_bin] : vc_new[select_bin]; 
	      //allocated_vc[select]; rdm34
	   end
      end
   endgenerate

endmodule // vc_input_port
