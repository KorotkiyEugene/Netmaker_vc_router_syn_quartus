/* -------------------------------------------------------------------------------
 * (C)2007 Robert Mullins
 * Computer Architecture Group, Computer Laboratory
 * University of Cambridge, UK.
 * -------------------------------------------------------------------------------
 *
 * Virtual-Channel Buffers
 * =======================
 * 
 * Instantiates 'N' FIFOs in parallel, if 'push' is asserted
 * data_in is sent to FIFO[vc_id].
 *
 * The output is determined by an external 'select' input.
 * 
 * if 'pop' is asserted by the end of the clock cycle, the 
 * FIFO that was read (indicated by 'select') recieves a 
 * pop command.
 *
 * - flags[] provides access to all FIFO status flags.
 * - output_port[] provides access to 'output_port' field of flits at head of FIFOs
 * 
 * Assumptions:
 * - 'vc_id' is binary encoded (select is one-hot) //and 'select' are binary encoded.
 * 
 */

module NW_vc_buffers (push, pop, data_in, vc_id, select, 
		      data_out, output_port, data_in_reg, 
		      flags, buf_finished_empty,
		      head_is_tail, flit_buffer_out,
		      clk, rst_n);

   `include "NW_functions.v"
      
   // length of VC FIFOs
   parameter size = 3;
   // number of virtual channels
   parameter n = 4;
   // what does each FIFO hold?
   //parameter type fifo_elements_t = flit_t;
   // optimize FIFO parameters for different fields of flit
   parameter optimize_fifo_fields = 0;                         
   // export output of each VC buffer
   parameter output_all_head_flits = 0;

   input     push;
   input     [n-1:0] pop;
   input     fifo_elements_t data_in;
   input     [clogb2(n)-1:0] vc_id;
//   input     [clogb2(n)-1:0] select;
   input [n-1:0] 	     select;

   output    fifo_elements_t data_out;
   output    fifov_flags_t flags [n-1:0];
   output    output_port_t output_port [n-1:0];
   output    flit_t data_in_reg;
   output    fifo_elements_t flit_buffer_out [n-1:0];

   output [n-1:0] head_is_tail;
   
   // at the end of the last clock cycle was vc_buffer[i] empty?
   // - i.e. is the next flit entering an empty FIFO
   // used for various things, e.g. abort detection 
   output    [n-1:0] buf_finished_empty;
   
   input     clk, rst_n;

//   logic [clogb2(n)-1:0] select_bin;
   fifo_elements_t sel_fifo_out;
   
   // single input register
   fifo_elements_t in_reg;
   // fifo outputs
   fifo_elements_t fifo_out [n-1:0];
   // fifo push/pop control
   logic [n-1:0] push_fifo, pop_fifo;
   // need to bypass FIFO and output contents of input register?
   logic [n-1:0] fifo_bypass;

   logic [n-1:0] fifo_bypass2;

   output_port_t op_fifo_out [n-1:0];
   control_flit_t control_fifo_out [n-1:0];
   
   genvar i;
   integer j;

   assign  data_in_reg = in_reg;
   assign  buf_finished_empty = fifo_bypass;

//   assign select_bin = vc_index_t'(oh2bin(select));
   
   generate
   for (i=0; i<n; i++) begin:vcbufs

      if (optimize_fifo_fields) begin
	 //
	 // use multiple FIFOs for different fields of flit so there
	 // parameters can be optimized individually.  Allows us to
	 // move logic from start to end of clock cycle and vice-versa - 
	 // depending on what is on critical path.
	 //

	 //
	 // break down into control and data fields
	 //
	 // *** CONTROL FIFO ***
	 NW_fifo_v #(.init_fifo_contents(0), 
		     //.fifo_elements_t(control_flit_t),
		     .size(size),
		     .output_reg(0),
		     .input_reg(1) // must be 1 - assume external input reg.
		     ) vc_fifo_c
	   (.push(push_fifo[i]), 
	    .pop(pop_fifo[i]), 
	    .data_in(in_reg.control), 
	    .data_out(control_fifo_out[i]), 
	    .flags(flags[i]),
	    .clk, .rst_n);

	 // *** OUTPUT PORT REQUEST ONLY ***
	 NW_fifo_v #(.init_fifo_contents(0), 
		     //.fifo_elements_t(output_port_t),
		     .size(size),
		     .output_reg(1),
		     .input_reg(1) // must be 1 - assume external input reg.
		     ) vc_fifo_op
	   (.push(push_fifo[i]), 
	    .pop(pop_fifo[i]), 
	    .data_in(in_reg.control.output_port), 
	    .data_out(op_fifo_out[i]), 
//	    .flags(flags[i]),
	    .clk, .rst_n);

	 always_comb
	   begin
	      fifo_out[i].control = control_fifo_out[i];
	      fifo_out[i].control.output_port = op_fifo_out[i];
	   end
	 
	 // *** DATA FIFO ***
	 NW_fifo_v #(.init_fifo_contents(0), 
		     //.fifo_elements_t(data_t),
		     .size(size),
		     .output_reg(0),  // remove FIFO output register ****
		     .input_reg(1) // must be 1 - assume external input reg.
		     ) vc_fifo_d
	   (.push(push_fifo[i]), 
	    .pop(pop_fifo[i]), 
	    .data_in(in_reg.data), 
	    .data_out(fifo_out[i].data),
//	    .flags(flags[i]), only need one set of flags (obviously identical to control FIFO's)
	    .clk, .rst_n);

   `ifdef DEBUG
	 // need FIFO for debug too
	 NW_fifo_v #(.init_fifo_contents(0), 
		     //.fifo_elements_t(debug_flit_t),
		     .size(size),
		     .output_reg(1),
		     .input_reg(1)
		     ) vc_fifo
	   (.push(push_fifo[i]), 
	    .pop(pop_fifo[i]), 
	    //.data_in(in_reg.debug), 
	    //.data_out(fifo_out[i].debug),
//	    .flags(flags[i]),
	    .clk, .rst_n);
   `endif
	 
      end else begin

	 // **********************************
	 // SINGLE FIFO holds complete flit
	 // **********************************
	 NW_fifo_v #(.init_fifo_contents(0), 
		     //.fifo_elements_t(fifo_elements_t),
		     .size(size),
		     .output_reg(0),
		     .input_reg(1)
		     ) vc_fifo
	   (.push(push_fifo[i]), 
	    .pop(pop_fifo[i]), 
	    .data_in(in_reg), 
	    .data_out(fifo_out[i]),
	    .flags(flags[i]),
	    .clk, .rst_n);
      end
	 
      always@(posedge clk) begin
	 if (!rst_n) begin
	    fifo_bypass[i] <= 1'b1;
	    
	    fifo_bypass2[i] <= 1'b1; // duplicate
	 end else begin
	    fifo_bypass[i] <= flags[i].empty || (flags[i].nearly_empty && pop_fifo[i]);

	    fifo_bypass2[i] <= flags[i].empty || (flags[i].nearly_empty && pop_fifo[i]); // duplicate
	 end
      end

      assign push_fifo[i] = push & (vc_id==i);
      assign pop_fifo[i] = pop[i]; //pop & (select==i);

      assign head_is_tail[i] = fifo_out[i].control.tail; // && !flags[i].empty; 

   // we need to know which output port is required by all packets, in order to make
   // virtual-channel and switch allocation requests.
   assign output_port[i] = 
	  fifo_bypass2[i] ? in_reg.control.output_port : fifo_out[i].control.output_port;
   
   end
   endgenerate

   //
   // assign data_out = (fifo_bypass[select]) ? in_reg : fifo_out[select];
   //
   NW_mux_oh_select #( .n(n)) 
     fifosel (.data_in(fifo_out), .select(select), .data_out(sel_fifo_out));
   assign sel_fifo_bypass = |(fifo_bypass & select);
   assign data_out = sel_fifo_bypass ? in_reg : sel_fifo_out; //fifo_out[select_bin];

   //
   // some architectures require access to head of all VC buffers
   //
   generate
      if (output_all_head_flits) begin
	 for (i=0; i<n; i++) begin:allvcs
	    assign flit_buffer_out[i] = (fifo_bypass[i]) ? in_reg : fifo_out[i];
	 end
      end
   endgenerate

   //
   // in_reg
   //
   always@(posedge clk) begin

      if (!rst_n) begin
	 in_reg.control.valid <= 1'b0;
	 in_reg.control.tail <= 1'b1;
	 in_reg.control.output_port <='0;
      end else begin
	 if (push) begin
	    in_reg <= data_in;
	 end else begin
	    in_reg.control.valid<=1'b0;
	    in_reg.control.output_port<='0;
	 end
      end
   end

endmodule 
