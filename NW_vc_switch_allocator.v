/* -------------------------------------------------------------------------------
 * (C)2007 Robert Mullins
 * Computer Architecture Group, Computer Laboratory
 * University of Cambridge, UK.
 * -------------------------------------------------------------------------------
 *
 * VC Switch Allocator
 * ===================
 * 
 * Technically this is an input first seperable allocator (see Dally/Towles p.367)
 * 
 * Arbitration Stage 1:
 *    * Arbitrate between requests from VCs at each input port (np x nv:1 arbiters)
 *    * Select the output port request of the winning flit
 * 
 * Arbitration Stage 2:
 *    * Arbitrate between requests for each output port (np x np:1 arbiters)
 *    * Determine which input port requests were successful.
 * 
 * 
 *    ----> req                                                               --> grant
 *    ----> required_output_port                                                 
 *                .                                                            .
 *                .                    [STAGE 1]            [STAGE 2]          .
 *                .                Arbitrate between    Arbitrate between      .       
 *    ----> req                    requests from same   winners of stage 1    --> grant
 *    ----> required_output_port       input port       that require the    
 *                                                      same output port 
 * 
 * Parameters
 * ==========
 * 
 *     # np - number of ports (assumes no. input = no. output)
 *     # nv - number of virtual-channels
 *
 * (NOT SUPPORTED IN CONFIGURATION FILE)
 * Lonely Outputs Optimization [experimentation only, very poor synthesis results]
 * ===========================
 *  
 * ** Ignores flit priority if present **
 * 
 *     # priority_lonely_outputs = 0 | 1
 *     
 *     Prioritises a request if it represents the only request for a 
 *     particular output. See Dally/Towles p.373 for rationale. Note
 *     this scheme doesn't perform a full count of requests for each
 *     output. It simply looks for cases where an output is requested
 *     by a single input.
 * 
 */

module NW_vc_switch_allocator (req,
			       req_priority,            // for flit prioritisation support
			       output_port, 
			       grant,
			       vc_mux_sel,              // not used by Lochside
			       xbar_select,             // not used by Lochside
			       any_request_for_output,  // not used by Lochside
			       taken_by_nonspec,        // not used by Lochside
			       clk, rst_n);

   parameter np=5;
   parameter nv=4;
   parameter priority_lonely_outputs = 0;
   parameter speculative_alloc = 0;
   
   parameter dynamic_priority_switch_alloc = 0;
   //parameter type flit_priority_t = logic unsigned [3:0];

   parameter turn_opt = 1 ; // 0 useful when testing, default 1
   
   input [np-1:0][nv-1:0] req;
   input flit_priority_t req_priority [np-1:0][nv-1:0];
   input output_port_t output_port [np-1:0][nv-1:0];
   output [np-1:0][nv-1:0] grant;
   output [np-1:0][nv-1:0] vc_mux_sel;
   output [np-1:0][np-1:0] xbar_select;
   output [np-1:0] any_request_for_output;
   input [np-1:0]  taken_by_nonspec; // has a non-spec request been granted at this input port?
   input clk, rst_n;

   logic [np-1:0] input_port_success;
   logic [np-1:0][nv-1:0] stage1_grant;
   output_port_t winning_port_req [np-1:0];

   logic [np-1:0][np-1:0] output_port_req, all_grants_for_input, output_port_grant, 
		 permitted_output_port_req, permitted_output_port_grant;

   logic [np-1:0] uncontested, contested;
   logic priority_bit [np-1:0][nv-1:0];

   flit_priority_t max_priority[np-1:0];
   flit_priority_t req_priority_stage2 [np-1:0][np-1:0];

   genvar i,j;

   // buffers at each input port arbitrate for access to single port on crossbar
   // (winners of stage1 go on to arbitrate for access to actually output port)
   assign vc_mux_sel = stage1_grant; 
   
   function logic [np-1:0] find_uncontested(input [np-1:0][nv-1:0] req,
                                            input output_port_t output_port [np-1:0][nv-1:0]);

      logic [np-1:0] contested, uncontested;
      integer o,p,v;
      begin
	 for (o=0; o<np; o++) begin
	    
	    uncontested[o]=1'b0;
	    contested[o]=1'b0;
	    
	    for (p=0; p<np; p++) begin
	       for (v=0; v<nv; v++) begin
		  if ((req[p][v])&&(output_port[p][v][o])) begin
		     // request at input port 'p' at VC 'v' is requesting port 'o'
		     if (!uncontested[o]&&!contested[o]) begin
			uncontested[o]=1'b1;
		     end else begin
			if (uncontested[o]&&!contested[o]) begin
			   contested[o]=1'b1;
			   uncontested[o]=1'b0;
			end
		     end
		  end
	       end
	    end 
	 end // for (o=0; o<np; o++)

	 find_uncontested=uncontested;

      end
   endfunction

   // arbitrate between virtual-channels at each input port	
   generate
      // ************************************************
      // look for uncontested requests for an output port
      // ************************************************
      if (priority_lonely_outputs) begin

	 assign uncontested=find_uncontested(req, output_port);
	 
	 // foreach output port
	 for (i=0; i<np; i++) begin:ips
	    // set priority bit if request needs uncontested port
	    for (j=0;j<nv;j++) begin:vcs
	       assign priority_bit[i][j]=|(output_port[i][j] & uncontested);
	    end
	 end
      end // if (priority_lonely_outputs)
      
      for (i=0; i<np; i++) begin:inport

	 // **********************************
	 // nv:1 arbiter at each input port
	 // **********************************
	 if (priority_lonely_outputs) begin
	    matrix_arb #(.size(nv),
			 .multistage(1),
			 //.priority_type(bit),
			 .priority_support(1)) vc_arb
	      (.request(req[i]),
	       .req_priority(priority_bit[i]),
	       .grant(stage1_grant[i]),
	       .success(input_port_success[i]),
	       .clk, .rst_n);	    
	 end else begin
	    matrix_arb #(.size(nv),
			 .multistage(1),
			 //.priority_type(flit_priority_t),
			 .priority_support(dynamic_priority_switch_alloc)) vc_arb
	      (.request(req[i]),
	       .req_priority(req_priority[i]),
	       .max_priority(max_priority[i]),
	       .grant(stage1_grant[i]),
	       .success(input_port_success[i]),
	       .clk, .rst_n);
	 end

	 // select output port request of (first-stage) winner
	 NW_mux_oh_select #( .n(nv)) reqmux
           (output_port[i], stage1_grant[i], winning_port_req[i]);

	 // setup requests for output ports
	 for (j=0; j<np; j++) begin:outport

	    //
	    // request priorities for second stage of arbitration
	    // - requests from input i will have priority 'max_priority[i]'
	    //
	    assign req_priority_stage2[j][i] = max_priority[i];
	    
	    // if turn is invalid output port request will never be made
	    if (turn_opt) begin
	       assign output_port_req[j][i]=(NW_route_valid_turn(i,j)) ? winning_port_req[i][j] : 1'b0;
	    end else begin
	       assign output_port_req[j][i] = winning_port_req[i][j];
	    end

	    // for cases when both speculative and non-speculative versions of a switch
	    // allocator are employed together.
	    if (speculative_alloc) begin
	       assign permitted_output_port_req[j][i] = output_port_req[j][i] & !taken_by_nonspec[i];
	    end else begin
	       assign permitted_output_port_req[j][i] = output_port_req[j][i];
	    end
	 end
	 
	 for (j=0; j<nv; j++) begin:suc   
	    // was request successful at both input and output arbitration?
	    assign grant[i][j]=stage1_grant[i][j] && input_port_success[i];
	 end
      end // block: inport

      for (i=0; i<np; i++) begin:outport

	 // **********************************
	 // np:1 arbiter at each output port
	 // **********************************
	 if (priority_lonely_outputs) begin
	    matrix_arb #(.size(np),
			 .multistage(0)) outport_arb
	      (.request(output_port_req[i]),
	       .grant(output_port_grant[i]),
	       .clk, .rst_n);
	 end else begin
	    matrix_arb #(.size(np),
			 .multistage(0),
			 //.priority_type(flit_priority_t), 
			 .priority_support(dynamic_priority_switch_alloc)) outport_arb
	      (.request(output_port_req[i]),
	       .req_priority(req_priority_stage2[i]),
	       .grant(output_port_grant[i]),
	       .clk, .rst_n);
	 end

	 for (j=0; j<np; j++) begin:g
	    // was input port successful?
	    assign all_grants_for_input[j][i]=output_port_grant[i][j];

	    if (speculative_alloc) begin
	       assign permitted_output_port_grant[j][i] = output_port_grant[j][i] && !taken_by_nonspec[i];
	    end else begin
	       assign permitted_output_port_grant[j][i] = output_port_grant[j][i];
	    end
						      
	 end
	 assign input_port_success[i]=|all_grants_for_input[i];

	 assign any_request_for_output[i]=|permitted_output_port_req[i];

      end
   endgenerate

   assign xbar_select = permitted_output_port_grant;
    
endmodule // NW_vc_switch_allocator


