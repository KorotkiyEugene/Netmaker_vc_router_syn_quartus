/* -------------------------------------------------------------------------------
 * (C)2007 Robert Mullins
 * Computer Architecture Group, Computer Laboratory
 * University of Cambridge, UK.
 * -------------------------------------------------------------------------------
 *
 * FIFO-based VC Free Pool
 * ============-==========
 * 
 * Serves next free VC id. Tail flits sent on output link replenish free VC pool
 * 
 * One free VC pool per output port
 * 
 */

module NW_vc_free_pool (flit, valid,
			// FIFO free pool
			oh_free_vc, no_free_vc, // head of free VC FIFO, free VC FIFO empty?
			vc_consumed,            // VC allocated at this output
			// Unrestricted free pool
			vc_alloc_status,        // VC allocation status
			vc_allocated,           // which VCs were allocated on this cycle?
			vc_empty,               // is downstream FIFO associated with VC empty?
			clk, rst_n);

   parameter num_vcs_global = 4; // in router
   parameter num_vcs_local  = 4; // at this output port
   
   parameter fifo_free_pool = 0; // organise free pool as FIFO (offer at most one VC per output port per cycle)

   // only applicable if fifo_free_pool = 0
   parameter only_allocate_vc_when_empty = 0; // only allow a VC to be allocated when it is empty
   
//-------
   input flit_t flit;
   input valid;
   output vc_t oh_free_vc;
   output no_free_vc;
   input  vc_consumed;
   input [num_vcs_global-1:0] vc_allocated;
   output [num_vcs_global-1:0] vc_alloc_status;
   input [num_vcs_global-1:0]  vc_empty;
   input  clk, rst_n;

   logic [num_vcs_global-1:0] vc_alloc_status_reg;
   vc_t fifo_out;
   fifov_flags_t fifo_flags;
   logic push;

   integer i;
   
   generate
      // =============================================================
      // Organise Free VC pool as FIFO 
      // permits at most one VC to be allocated per output per cycle.
      // =============================================================
      if (fifo_free_pool) begin
	 
	 // avoid adding output reg output port serving tile without VCs
	 // (could avoid instantiating a FIFO at all in that case)

	 NW_fifo_v #(.init_fifo_contents(1),
		     //.fifo_elements_t(vc_t),
		     .size(num_vcs_local+1),
		     .input_reg(0), 
		     .output_reg(num_vcs_local>2))
//	   	     .output_reg(0)) 
	   free_vc_fifo (.push(push),
			 .pop(vc_consumed), 
			 .data_in(flit.control.vc_id), 
			 .data_out(fifo_out),
			 .flags(fifo_flags),
			 .clk, .rst_n);
	    
	 if (num_vcs_local>2) begin
	    assign oh_free_vc = fifo_out;// & {(num_vcs_local){!fifo_flags.empty}}; //- assumes output reg is used
	 end else begin
	    assign oh_free_vc = fifo_out & {(num_vcs_local){!fifo_flags.empty}};
	 end
	 
	 assign push = valid && flit.control.tail;
	 
	 assign no_free_vc = fifo_flags.fast_empty; // or |oh_free_vc
	 
	 always@(posedge clk) begin

	    /*
	     if (vc_consumed) begin
	     $display ("%d: %m: pop free VC FIFO (vc=%b)", $time, fifo_out);
             end
	     if (push) begin
	     $display ("%d: %m: push free VC on FIFO (flit.vc_id=%b, flit.tail=%b)", 
		       $time, flit.control.vc_id, flit.control.tail);
             end
	     */
	    
	    // synopsys translate_off
	    if (push && fifo_flags.full && !vc_consumed) begin
	       $display ("%d: %m: Error free VC fifo full, push and !pop ....", $time);
	       $display ("flit.vc_id  = %b", flit.control.vc_id);
	       $display ("flit.tail   = %b", flit.control.tail);
	       $display ("vc_consumed = %b", vc_consumed);
	       $finish;
	    end
	    // synopsys translate_on
	 end // always@ (posedge clk)
      end else begin // if (fifo_free_pool)

	 // =============================================================
	 // Unrestricted VC allocation
	 // =============================================================
	 always@(posedge clk) begin
	    if (!rst_n) begin
	       for (i=0; i<num_vcs_global; i++) begin:forvcs2
		  vc_alloc_status_reg[i] <= (i<num_vcs_local);
	       end
	    end else begin
	       for (i=0; i<num_vcs_global; i++) begin:forvcs
		  //
		  // VC consumed, mark VC as allocated
		  //
		  if (vc_allocated[i]) vc_alloc_status_reg[i]<=1'b0;
	       end
	       if (valid && flit.control.tail) begin
		  //
		  // Tail flit departs, packets VC is ready to be used again
		  //

		  // what about single flit packets - test
		  assert (!vc_alloc_status_reg[oh2bin(flit.control.vc_id)]);
		  
		  vc_alloc_status_reg[oh2bin(flit.control.vc_id)]<=1'b1;
	       end
	    end
	 end // always@ (posedge clk)

	 if (only_allocate_vc_when_empty) begin
	    assign vc_alloc_status = vc_alloc_status_reg & vc_empty;
	 end else begin
	    assign vc_alloc_status = vc_alloc_status_reg;
	 end
      end
   endgenerate
   
endmodule // NW_vc_free_pool

