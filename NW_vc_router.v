/* -------------------------------------------------------------------------------
 * (C)2007 Robert Mullins
 * Computer Architecture Group, Computer Laboratory
 * University of Cambridge, UK.
 * -------------------------------------------------------------------------------
 * 
 * VC router
 * 
 */

`include "types.v"
//`include "parameters.v"

typedef flit_pri_t flit_priority_t;

module NW_vc_router (i_flit_in, i_flit_out,
		     i_cntrl_in, i_cntrl_out,
		     i_input_full_flag, 
		     clk, rst_n);

   `include "NW_functions.v"

   //parameter type flit_priority_t = flit_pri_t;
   
   parameter network_x = 4;
   parameter network_y = 4;
   
   parameter buf_len = 4;
   parameter NP=5;
   parameter NV=2;

   // numbers of virtual-channels on entry/exit to network?
   parameter router_num_vcs_on_entry = 1;
   parameter router_num_vcs_on_exit = 2; //4
   
   //
   // Pipeline VC and switch allocation?
   //
   parameter uarch_pipeline=0;
   // with or without an explicit pipelining register?
   // can just read from head of FIFO twice
   parameter uarch_explicit_pipeline_register=0;

   //
   // Check VC buffer is full (at dest.) before making a switch request?
   //
   parameter uarch_full_vc_check_before_switch_request=0;

   //
   // Switch Allocation
   //
   // perform VC and switch allocation in parallel
   parameter swalloc_speculative=0;

   //
   // VC Allocation
   //
   parameter vcalloc_unrestricted=1;

   //
   // VC Selection
   //
   parameter vcselect_bydestinationnode = 0;
   parameter vcselect_leastfullbuffer = 0;
   parameter vcselect_arbstateupdate = 0;   
   parameter vcselect_usepacketmask = 0;    
   parameter vcselect_onlywhenempty = 0;
   
   //
   // Prioritised Communications
   //

   // prioritise switch allocation by position of flit in packet (head=0, tail=N)
   parameter priority_switch_alloc_byflitid=0;
   
   // prioritise switch allocation based on flit.control.flit_priority
   parameter priority_flit_dynamic_switch_alloc=0;
   // prioritise vc allocation based on flit.control.flit_priority
   parameter priority_flit_dynamic_vc_alloc=0;
   // size of flit.control.flit_priority field (in bits)
   parameter priority_flit_bits=4;
   //
   // prioritise_network_traffic = 0 - no modifications to flit_priority are made by the router
   // prioritise_network_traffic = 1 - router sets flit_priority to 1 on exit, traffic in network has
   //                                  priority over newly injected traffic
   // prioritise_network_traffic = 2 - flit_priority is increased at each router as the flit exists
   //                                  flit_priority is determined by its current hop count
   //                                  (be careful to ensure enough priority bits are available)
   //                                  Upto a limit of 'priority_flit_limit'   
   parameter priority_network_traffic=0;
   parameter priority_flit_limit=4;

//==================================================================

   // FIFO rec. data from tile/core is full?
   output  [router_num_vcs_on_entry-1:0] i_input_full_flag;
   // link data and control
   input   flit_t i_flit_in [NP-1:0];
   output  flit_t i_flit_out [NP-1:0];
   input   chan_cntrl_t i_cntrl_in [NP-1:0];
   output  chan_cntrl_t i_cntrl_out [NP-1:0];
   input   clk, rst_n;


   
   // Credit count for each VC at each output port
   logic [NP-1:0][NV-1:0][clogb2(buf_len+1)-1:0] vc_credits;
   
   flit_priority_t req_priority [NP-1:0][NV-1:0];
   logic [NP-1:0] output_valid_flit_check;
   logic [NP-1:0][NV-1:0] pop_vc_valid_check;
   logic [NP-1:0] free_vc_blocked;
   logic [NP-1:0] no_free_vc;
   logic [NP-1:0][NV-1:0] switch_req, spec_switch_req;
//   vc_t x_vc_status [NP-1:0];
   logic [NP-1:0][NV-1:0] x_vc_status;
   logic [NP-1:0] 	  x_push;
   logic [NP-1:0][NV-1:0] x_pop;
   flit_t x_flit_xbarin[NP-1:0];
   flit_t x_flit_xbarin_pipe[NP-1:0];
   flit_t x_flit_xbarout[NP-1:0];
   
//   logic [clogb2(NV)-1:0] x_vc_id [NP-1:0];
//   logic [clogb2(NV)-1:0] x_select [NP-1:0];

   vc_index_t x_vc_id [NP-1:0];
   vc_index_t x_select [NP-1:0];
   
   flit_t x_flit_bufout [NP-1:0];
   flit_t x_data_in_reg [NP-1:0];
   fifov_flags_t x_flags [NP-1:0][NV-1:0];
   logic [NV-1:0] 	  x_allocated_vc [NP-1:0][NV-1:0];
   logic [NV-1:0] 	  vc_for_blocked_check [NP-1:0][NV-1:0];
   logic [NP-1:0][NV-1:0] x_allocated_vc_valid;   
   logic [NP-1:0][NV-1:0][NV-1:0] x_vc_new;
   logic [NP-1:0][NV-1:0] 	  x_vc_new_valid;
   output_port_t x_output_port [NP-1:0][NV-1:0];
   output_port_t x_output_port_for_vc [NP-1:0][NV-1:0];
   output_port_t x_output_port_for_sw [NP-1:0][NV-1:0];
   vc_t [NP-1:0] x_free_vc;
   logic [NP-1:0][NP-1:0] xbar_select; 
   logic [NP-1:0][NV-1:0] vc_request;             // VC request from each input VC
   logic [NP-1:0] 	 vc_allocated_at_output;            // for each output port, has a VC been allocated?
   logic [NP-1:0][NV-1:0] allocated_vc_blocked, check_full_vc;
   logic [NP-1:0][NV-1:0] switch_grant;
//   logic [`PV-1:0] 	 input_vc_mux_sel;
   logic [NP-1:0][NV-1:0] input_vc_mux_sel;
   logic [NP-1:0] 	  output_used; // output channel used on this cycle?
   logic [NP-1:0] 	 outgoing_blocked, output_requested;
//   logic [`PV-1:0] 	 blocked;
//   logic [NP-1:0][NV-1:0] blocked;
	 
   logic [NP-1:0][NV-1:0] pipereg_ready, pipereg_valid, pipereg_push, pipereg_pop;
   flit_t pipereg_data_in [NP-1:0][NV-1:0];
   flit_t pipereg_data_out [NP-1:0][NV-1:0];
   flit_t routed_flit_buffer_out [NP-1:0][NV-1:0];
   flit_t flit_buffer_out [NP-1:0][NV-1:0];

   //
   // unrestricted VC free pool/allocation
   //
   logic [NP-1:0][NV-1:0] vc_alloc_status;         // which output VCs are free to be allocated
   logic [NP-1:0][NV-1:0] vc_allocated;            // indicates which VCs were allocated on this clock cycle
   logic [NP-1:0][NV-1:0][NV-1:0] vc_requested;    // which VCs were selected to be requested at each input VC?
   //
   logic [NP-1:0][NV-1:0] 	  vc_empty;        // is downstream FIFO associated with VC empty?
   
   genvar 		  i,j,k;

   integer db_out_used, db_in_popped, p,v;
   
   // quick parameter sanity check
   // synopsys translate_off
   always@(negedge rst_n) begin
      if (swalloc_speculative) begin
	 assert (!uarch_pipeline) else begin
	    $error("*** Speculative switch allocation cannot be applied to pipelined designs ***");
	    $finish;
	 end
	 assert (!uarch_explicit_pipeline_register) else begin
	    $error("*** Speculative switch allocation cannot be applied to pipelined designs ***");
	    $finish;
	 end
      end
      if (uarch_explicit_pipeline_register) begin
	 assert (uarch_pipeline) else begin
	    $error("*** Pipelining registers can only be added if the '(uarch_)pipeline' parameter is set ***");
	    $finish;
	 end
      end
   end
   // synopsys translate_on

   
   // **************************************
   // map new interface to old interface
   // **************************************
   generate
      for (i=0; i<NP; i++) begin:map
//	 assign nearly_full_in [(i+1)*NV-1:i*NV] = i_cntrl_in[i].nearly_full;
`ifdef NEARLY_FULL_FLOW_CONTROL
	 for (j=0; j<NV; j++) begin:nv
	    assign i_cntrl_out[i].nearly_full[j] = x_flags[i][j].nearly_full;
	 end
`endif	 
      end
   endgenerate


   // *******************************************************************************
   // output ports
   // *******************************************************************************
   generate
   for (i=0; i<NP; i++) begin:output_ports

      //      
      // Free VC pools 
      //
      if (i==`TILE) begin
	 //
	 // may have less than a full complement of VCs on exit from network
	 //
	 NW_vc_free_pool #(.num_vcs_local(router_num_vcs_on_exit), 
			   .num_vcs_global(NV),
			   .fifo_free_pool(!vcalloc_unrestricted),
			   .only_allocate_vc_when_empty(vcselect_onlywhenempty)) vcfreepool
	   (.flit(x_flit_xbarout[i]), 
	    .valid(output_used[i]),
	    // FIFO free pool
	    .oh_free_vc(x_free_vc[i]),
	    .no_free_vc(no_free_vc[i]),
	    .vc_consumed(vc_allocated_at_output[i]),
	    // Unrestricted free pool
	    .vc_alloc_status(vc_alloc_status[i]),
	    .vc_allocated(vc_allocated[i]),
	    .vc_empty(vc_empty[i]),
	    //
	    .clk, .rst_n);
      end else begin
	 NW_vc_free_pool #(.num_vcs_local(NV),
			   .num_vcs_global(NV),
			   .fifo_free_pool(!vcalloc_unrestricted),
			   .only_allocate_vc_when_empty(vcselect_onlywhenempty)) vcfreepool
	   (.flit(x_flit_xbarout[i]), 
	    .valid(output_used[i]),
	    // FIFO free pool
	    .oh_free_vc(x_free_vc[i]),
	    .no_free_vc(no_free_vc[i]),
	    .vc_consumed(vc_allocated_at_output[i]),
	    // Unrestricted free pool
	    .vc_alloc_status(vc_alloc_status[i]),
	    .vc_allocated(vc_allocated[i]),
	    .vc_empty(vc_empty[i]),
	    //
	    .clk, .rst_n);
      end // else: !if(i==`TILE)
      
      //
      // Flow Control 
      //
      NW_vc_fc_out #(.num_vcs(NV),
		     .init_credits(buf_len))
	fcout (.flit(x_flit_xbarout[i]), 
	       .flit_valid(output_used[i]),
	       .channel_cntrl_in(i_cntrl_in[i]),
	       .vc_status(x_vc_status[i]),
	       .vc_empty(vc_empty[i]),
	       .vc_credits(vc_credits[i]), 
	       .clk, .rst_n);

      // indicate to upstream router that new buffer is free when
      // we remove flit from an input FIFO (credit-based flow-control)
`ifdef CREDIT_FLOW_CONTROL
      always@(posedge clk) begin
	 if (!rst_n) begin
	    i_cntrl_out[i].credit_valid<=1'b0;
	 end else begin
	    //
	    // ensure 'credit' is registered before it is sent to the upstream router
	    //
	    if (uarch_explicit_pipeline_register) begin
	       //
	       // can only send one credit per cycle, so have to look at output of
	       // pipeline register and not FIFO->pipe-reg. transfers
	       //
	       i_cntrl_out[i].credit<=oh2bin(pipereg_pop[i]);
	       i_cntrl_out[i].credit_valid<=|pipereg_pop[i];
	       
	    end else begin
	       // send credit corresponding to flit sent from this input port
	       i_cntrl_out[i].credit<=x_select[i];
	       i_cntrl_out[i].credit_valid<=|x_pop[i];
	    end
	 end
      end
`endif
      
//      assign blocked[(i+1)*NV-1:i*NV]=x_vc_status[i];
//      assign blocked[i]=x_vc_status[i];

      if (!vcalloc_unrestricted) begin
	 assign free_vc_blocked[i]=|(x_vc_status[i] & x_free_vc[i]);
      end
      
   end
   endgenerate


   // *******************************************************************************
   // input ports (vc buffers and VC registers)
   // *******************************************************************************

   generate
      for (i=0; i<router_num_vcs_on_entry; i++) begin:vcsx
	 assign i_input_full_flag[i] = x_flags[`TILE][i].full; // TILE input FIFO[i] is full?
      end

      for (i=0; i<NP; i++) begin:input_ports


	 // should support .nv and .num_vcs (e.g. for tile input that may only
	 // support a single input VC)
	 
	 // input port 'i'
	 NW_vc_input_port #(.num_vcs(NV), 
			    .buffer_length(buf_len), 
			    .pipelined_vc_switch_alloc(uarch_pipeline),
			    .explicit_pipe_registers(uarch_explicit_pipeline_register)) inport
	   (.push(x_push[i]), 
	    .pop(x_pop[i]), 
	    .data_in(i_flit_in[i]), 
	    .vc_id(x_vc_id[i]),
	    .select(input_vc_mux_sel[i]), // use one-hot
//	    .select(x_select[i]), 
	    .data_out(x_flit_xbarin[i]),
	    //	 .output_port(x_output_port[i]),
	    .data_in_reg(x_data_in_reg[i]), 
	    .flags(x_flags[i]),
	    //	 .buf_finished_empty(x_buf_finished_empty[i]), 
	    .allocated_vc(x_allocated_vc[i]), 
	    .allocated_vc_valid(x_allocated_vc_valid[i]), 
	    .vc_new(x_vc_new[i]), 
	    .vc_new_valid(x_vc_new_valid[i]),
	    //	 .head_is_tail(head_is_tail[i]),
	    .flit_buffer_out(flit_buffer_out[i]),
	    .clk, .rst_n);

      //
      // output port fields and flit priorities
      // flit priorities come from flit.control.flit_priority (if required)
      //
      for (j=0; j<NV; j++) begin:allvcs2

	 assign x_output_port_for_vc[i][j] = flit_buffer_out[i][j].control.output_port;

	 //
	 // Explicit Pipelining Register
	 //
	 if (uarch_explicit_pipeline_register) begin
	    assign x_output_port_for_sw[i][j] = pipereg_data_out[i][j].control.output_port;


	 end else begin
	    assign x_output_port_for_sw[i][j] = flit_buffer_out[i][j].control.output_port;
	 end
      end

      
      // *** DATA IN *** //
      assign x_push[i]=i_flit_in[i].control.valid;
      
      // cast result of oh2bin to type of x_vc_id[i]
      assign x_vc_id[i]= vc_index_t'(oh2bin(i_flit_in[i].control.vc_id));

      // *** DATA OUT *** //
      // was selected VC at input port 'i' granted access to crossbar?

      // If we have performed speculative switch allocation we need
      // to check flit received VC before removing it from the input FIFO.
      for (j=0; j<NV; j++) begin:allvcs3
	 if (swalloc_speculative) begin
	    assign pop_vc_valid_check[i][j] = (x_allocated_vc_valid[i][j] || x_vc_new_valid[i][j]);
	 end else begin
	    assign pop_vc_valid_check[i][j] = 1'b1;
	 end
      end
      
      if (uarch_explicit_pipeline_register) begin
	 // remove from FIFO when copied to pipelining register
	 assign x_pop[i]= pipereg_push[i];
      end else begin
	 if (uarch_full_vc_check_before_switch_request) begin
	    // VC blocked check already made before request
	    assign x_pop[i] = switch_grant[i] & pop_vc_valid_check[i];
	 end else begin
	    // need to check VC isn't blocked
	    assign x_pop[i]= switch_grant[i] & ~allocated_vc_blocked[i] & pop_vc_valid_check[i];
	 end
      end

      // convert one-hot select at input port 'i' to binary for vc_input_port
//      assign x_select[i]= vc_index_t'(oh2bin(input_vc_mux_sel[(i+1)*NV-1:i*NV]));
      assign 	   x_select[i]= vc_index_t'(oh2bin(input_vc_mux_sel[i]));

      /**************************************************************************/
      //
      // add explicit pipelining register if requested.
      //
      // pipelining register after VC allocation stage. Switch requests
      // are in this case received from this register.
      // 
      if (uarch_explicit_pipeline_register) begin
	 
	 for (j=0; j<NV; j++) begin:allvcs

	    //
	    // push - * pipe register ready to receive
	    //        * VC FIFO has a flit
	    //        * flit has been allocated a VC (previously or on this cycle)
	    //
	    assign pipereg_push[i][j] = pipereg_ready[i][j] && !x_flags[i][j].empty && 
					(x_allocated_vc_valid[i][j] || x_vc_new_valid[i][j]);

	    //
	    // pop
	    //
	    if (uarch_full_vc_check_before_switch_request) 
		 assign pipereg_pop[i][j] = switch_grant[i][j];
	    else
		 assign pipereg_pop[i][j] = switch_grant[i][j] && ~allocated_vc_blocked[i][j];

	    //
	    // data_in
	    //
	    always_comb
	      begin
		 //
		 // flit that is stored in pipelining register always has a valid VC
		 //
		 pipereg_data_in[i][j] = flit_buffer_out[i][j]; 
		 pipereg_data_in[i][j].control.vc_id = x_allocated_vc[i][j];
	      end
	    
	    NW_pipereg pipe_reg1
	      (.push(pipereg_push[i][j]),
	       .pop(pipereg_pop[i][j]),
	       .data_in(pipereg_data_in[i][j]),
	       .data_out(pipereg_data_out[i][j]),
	       .ready(pipereg_ready[i][j]),
	       .valid(pipereg_valid[i][j]),
	       .clk, .rst_n);
	 end
	 
      end
      
      /**************************************************************************/

      //
      // Switch and Virtual-Channel allocation requests
      // 
      for (j=0; j<NV; j++) begin:reqs
	 //
	 // VIRTUAL-CHANNEL ALLOCATION REQUESTS
	 //
	 assign vc_request[i][j]= (NW_route_valid_input_vc(i,j)) ? 
				  !x_flags[i][j].empty & !x_allocated_vc_valid[i][j] : 1'b0;
	 
	 //
	 // SWITCH ALLOCATION REQUESTS
	 //

	 // Full VC buffer check. Perform check prior to making a switch request or
	 // later at output port. Schedule-quality/clock-cycle trade-off
	 if (uarch_full_vc_check_before_switch_request) begin
	    assign check_full_vc[i][j]=!allocated_vc_blocked[i][j];
	 end else begin
	    assign check_full_vc[i][j]=1'b1; // check at end of cycle.
	 end

	 // Pipelined VC / Switch Alloc.
	 if (uarch_pipeline==1) begin
	    
	    if (uarch_explicit_pipeline_register) begin
	       
	       //
	       // switch req come from pipeline registers
	       // (as does output port info.)
	       //
	       assign switch_req[i][j] = (NW_route_valid_input_vc(i,j)) ?
					 pipereg_valid[i][j] &&
					 check_full_vc[i][j] : 1'b0;
	       
	       assign vc_for_blocked_check[i][j] = pipereg_data_out[i][j].control.vc_id;
	       
	    end else begin
	       assign switch_req[i][j] = (NW_route_valid_input_vc(i,j)) ? 
					 !x_flags[i][j].empty && 
					 x_allocated_vc_valid[i][j] &&
					 check_full_vc[i][j] : 1'b0;
	       
	       assign vc_for_blocked_check[i][j] = x_allocated_vc[i][j];
	    end
	    
	    // is current VC blocked?
	    // - VC allocation happened in previous clock cycle so don't have to
	    //   worry about new VCs. Just look at status of allocated VC.
	    unary_select_pair #(i, NP, NV) blocked_mux 
	      (x_output_port_for_sw[i][j],
	       //	       x_allocated_vc[i][j],
	       vc_for_blocked_check[i][j],
//	       blocked,
	       x_vc_status, 
	       allocated_vc_blocked[i][j]);
	    
	 end else begin
	    //
	    // ** Single Cycle ** 
	    //
	    if (!swalloc_speculative) begin
	       //
	       // Without speculative switch alloc.
	       //
	       // VC allocation takes place first. Need to check outcome
	       // of this VC allocation before making request (x_vc_new_valid)
	       //
	       assign switch_req[i][j] = (NW_route_valid_input_vc(i,j)) ? 
					 !x_flags[i][j].empty && 
					 (x_allocated_vc_valid[i][j] || x_vc_new_valid[i][j]) &&
					 check_full_vc[i][j] : 1'b0;
	    end else begin // if (!swalloc_speculative)
	       //
	       // With speculative switch allocation
	       // Only make non-speculative requests when VC has been allocated
	       // in previous clock cycle.
	       //
	       assign switch_req[i][j] = (NW_route_valid_input_vc(i,j)) ? 
					 !x_flags[i][j].empty && 
					 x_allocated_vc_valid[i][j] &&
					 check_full_vc[i][j] : 1'b0;

	       // If we are performing speculative switch allocation
	       // need to make speculative switch requests.
	       // (requests from flits without allocated output VCs)
	       assign spec_switch_req[i][j] = (NW_route_valid_input_vc(i,j)) ?
                                              !x_flags[i][j].empty &&
					      !x_allocated_vc_valid[i][j] &&
                                              check_full_vc[i][j] : 1'b0;
	    end
	 end
      end // block: reqs
   end // block: input_ports
      
   if (uarch_pipeline==0) begin
      //
      // if single-cycle we need to consider newly allocated
      // virtual-channels too when determining if VCs are blocked
      //
      NW_vc_status #(.np(NP), .nv(NV)) vstat
	(.output_port(x_output_port_for_sw), 
         .free_vc_blocked(free_vc_blocked),
	 .vc_requested(vc_requested), 
         .allocated_vc(x_allocated_vc),
         .allocated_vc_valid(x_allocated_vc_valid),
//         .vc_status(blocked),
	 .vc_status(x_vc_status), 
         .vc_blocked(allocated_vc_blocked));
   end
      
   endgenerate

   // ----------------------------------------------------------------------
   // virtual-channel allocation logic
   // ----------------------------------------------------------------------
   NW_vc_allocator #(.buf_len(buf_len), .np(NP), .nv(NV), .xs(network_x), .ys(network_y), 
		     .dynamic_priority_vc_alloc( priority_flit_dynamic_vc_alloc),
		     .vcalloc_unrestricted(vcalloc_unrestricted),
		     .vcselect_bydestinationnode(vcselect_bydestinationnode), 
		     .vcselect_leastfullbuffer(vcselect_leastfullbuffer), 
		     .vcselect_arbstateupdate(vcselect_arbstateupdate), 
		     .vcselect_usepacketmask(vcselect_usepacketmask))
     vcalloc
       (.req(vc_request),
	.req_priority(req_priority), 
	.output_port(x_output_port_for_vc),
	.vc_new(x_vc_new),
	.vc_new_valid(x_vc_new_valid),
	.next_free_vc(x_free_vc),
	.no_free_vc(no_free_vc),
	.pop_free_vc(vc_allocated_at_output),
	// unrestricted VC pool
	.vc_allocated(vc_allocated),
	.vc_requested(vc_requested),
	.vc_alloc_status(vc_alloc_status),
	.flit(flit_buffer_out),
	.vc_credits(vc_credits), 
	.clk, .rst_n);

   // ----------------------------------------------------------------------
   // switch-allocation logic (or speculative switch allocation)
   // ----------------------------------------------------------------------
   generate
      if (!swalloc_speculative) begin
	 //
	 // for pipelined VC/switch allocation or switch allocation following
	 // VC allocation in single-cycle.
	 //
	 NW_vc_switch_allocator 
	   #(.np(NP), .nv(NV), 
	     .dynamic_priority_switch_alloc(priority_flit_dynamic_switch_alloc || priority_switch_alloc_byflitid)
	     //,
             //.flit_priority_t(flit_priority_t)
             )
	   swalloc
	     (.req(switch_req),
	      .req_priority(req_priority), 
	      .output_port(x_output_port_for_sw),
	      .grant(switch_grant), 
	      .vc_mux_sel(input_vc_mux_sel),
	      .xbar_select(xbar_select),
	      .any_request_for_output(output_requested), 
	      .clk, .rst_n);
	 
      end else begin // if (!swalloc_speculative)
	 
	/* NW_speculative_switch_allocator 
	   #(.np(NP), .nv(NV),
	     .dynamic_priority_switch_alloc(priority_flit_dynamic_switch_alloc)
	     //,
	     //.flit_priority_t(flit_priority_t)
	     )
	   specswitch
	     (.nonspec_req(switch_req),
	      .spec_req(spec_switch_req),
	      .req_priority(req_priority), 
	      .output_port(x_output_port_for_sw),
	      .grant(switch_grant),
	      .vc_mux_sel(input_vc_mux_sel),
	      .xbar_select(xbar_select),
	      .any_request_for_output(output_requested), 
	      .clk, .rst_n);*/
      end // else: !if(!swalloc_speculative)
   endgenerate
      
   // ----------------------------------------------------------------------
   // crossbar
   // ----------------------------------------------------------------------
   generate
      if (uarch_explicit_pipeline_register) begin
	 //
	 // crossbar inputs come from mux fed by pipelining registers
	 //
	 for (i=0; i<NP; i++) begin:allinps

	    NW_route rfn (.flit_in(pipereg_data_out[i][x_select[i]]), 
			  .flit_out(x_flit_xbarin_pipe[i]), .clk, .rst_n);
	    
	 end
	 
	 NW_crossbar_oh_select #( .n(NP)) myxbar 
	   (x_flit_xbarin_pipe, xbar_select, x_flit_xbarout); 
	 
      end else begin

	 //
	 // crossbar inputs from VC input ports
	 //
	 NW_crossbar_oh_select #( .n(NP)) myxbar 
	   (x_flit_xbarin, xbar_select, x_flit_xbarout); 
      end
   endgenerate
      
   // ----------------------------------------------------------------------
   // output port logic
   // ----------------------------------------------------------------------
   generate
   for (i=0; i<NP; i++) begin:outports

      if (swalloc_speculative) begin
	 // need to check flit at output has valid output VC
	 assign output_valid_flit_check[i] = |(x_flit_xbarout[i].control.vc_id);
      end else begin
	 assign output_valid_flit_check[i] = 1'b1;
      end
      
      if (uarch_full_vc_check_before_switch_request) begin
	 //
	 // output is valid if any request for this output was made
	 // (request can only be made if 1. VC is already allocated
	 //  and 2. vc is not blocked (full).
	 //

	 // What about two requests at same input port (different VCs)
	 // to different output ports?
	 // - 'output_requested' is request to second stage of arbiters
	 //   in switch allocator so this is OK.
	 
	 assign output_used[i] = output_requested[i] && output_valid_flit_check[i];
	 
      end else begin
	 //
	 // need to check VC id. of flit leaving on this port is
	 // not blocked.
	 //
	 assign outgoing_blocked[i] = |(x_flit_xbarout[i].control.vc_id & x_vc_status[i]) ;
	 assign output_used[i] = output_requested[i] && !outgoing_blocked[i] && output_valid_flit_check[i];
      end 

      always_comb 
        begin
           i_flit_out[i]=x_flit_xbarout[i];
           i_flit_out[i].control.valid=output_used[i];

	   // injected flits from tile have the lowest priority, once in network priority is increased.
`ifdef FLIT_DYNAMIC_PRIORITY 
	   if (priority_network_traffic==1) begin
	      i_flit_out[i].control.flit_priority=1; // 4
	   end else begin
	      // flit priority is determined by the number of hops the flit has taken
	      if (priority_network_traffic==2) begin
		 if (i_flit_out[i].control.flit_priority<priority_flit_limit) begin
		    i_flit_out[i].control.flit_priority=i_flit_out[i].control.flit_priority+1;
		 end
	      end
	   end
`endif
	end

   end // block: outports
   endgenerate

   // synopsys translate_off
   /*  -----------------------------------------------------------------------------------
    *  assert (only unallocated VCs are allocated to waiting packets)
    *  -----------------------------------------------------------------------------------
    */
   always@(posedge clk) begin
      if (!rst_n) begin
      end else begin
	 for (p=0; p<NP; p++) begin
	    for (v=0; v<NV; v++) begin
	       if (x_vc_new_valid[p][v]) begin
		  // check x_vc_new is free to be allocated
		  if (vcalloc_unrestricted) begin
		     if (!vc_alloc_status[oh2bin(x_output_port_for_vc[p][v])][oh2bin(x_vc_new[p][v])]) begin
			$display ("%m: Error: Newly allocated VC is already allocated to another packet");
                        $display ("Input port=%1d, VC=%1d", p,v);
			$display ("Requesting Output Port %b (%1d)", x_output_port_for_vc[p][v],
				  oh2bin(x_output_port_for_vc[p][v]));
			$display ("VC requested  %b ", vc_requested[p][v]);
			$display ("x_vc_new      %b ", x_vc_new[p][v]);
			$finish;
		     end
		  end
	       end
	    end
	 end
      end
   end
   // synopsys translate_on

   
   // synopsys translate_off
   /*  -----------------------------------------------------------------------------------
    *  assert (no. of flits leaving router == no. of flits dequeued from input FIFOs)
    *  -----------------------------------------------------------------------------------
    */
   always@(posedge clk) begin
      if (!rst_n) begin
      end else begin
	 db_out_used = 0;
	 db_in_popped = 0;
	 // count number of outputs used.
	 for (p=0; p<NP; p++) begin
	    if (output_used[p]) db_out_used++;
	 end
	 // count number of flits removed from input fifos
	 for (p=0; p<NP; p++) begin
	    for (v=0; v<NV; v++) begin
	       if (x_pop[p][v]) db_in_popped++;
	    end
	 end
	 if (db_out_used!=db_in_popped) begin
	    $display ("%m: Error: more flits sent on output than dequeued from input FIFOs!");
	    for (p=0; p<NP; p++) begin
	       $display ("-------------------------------------------------");
	       $display ("Input Port=%1d", p);
	       $display ("-------------------------------------------------");
	       for (v=0; v<NV; v++) begin
		  $write ("VC=%1d: ", v);
		  if ((switch_req[p][v])||(spec_switch_req[p][v])||(switch_grant[p][v])) 
		    $write ("[OUTP=%1d]", oh2bin(x_output_port_for_sw[p][v]));
		  if (switch_req[p][v]) $write ("(Switch_Req)");
		  if (spec_switch_req[p][v]) $write ("(Spec_Switch_Req)");
		  if (switch_grant[p][v]) $write ("(Switch_Grant)");
		  if (x_vc_new_valid[p][v]) $write ("(New VC Alloc'd)");
		  
		  $display ("");
	       end
	    end // for (p=0; p<NP; p++)
	    $display ("-------------------------------------------------");
	    $display ("Output Used=%b", output_used);
	    $display ("-------------------------------------------------");
//	    $finish;
	 end // if (db_out_used!=db_in_popped)
      end
   end // always@ (posedge clk)
   // synopsys translate_on
   
endmodule // simple_router
