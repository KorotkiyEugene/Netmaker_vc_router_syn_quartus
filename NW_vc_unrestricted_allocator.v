/* -------------------------------------------------------------------------------
 * (C)2007 Robert Mullins
 * Computer Architecture Group, Computer Laboratory
 * University of Cambridge, UK.
 * -------------------------------------------------------------------------------
 * 
 * VC allocator 
 * Allocates new virtual-channels for newly arrived packets.
 * 
 * "unrestricted" VC allocation (Peh/Dally style)
 * 
 * Takes place in two stages:
 * 
 *           stage 1. ** VC Selection **
 *                    Each waiting packet determines which VC it will request.
 *                    (v:1 arbitration). Can support VC alloc. mask here (from 
 *                    packet header or static or dynamic..)
 *                    
 * 
 *           stage 2. ** VC Allocation **
 *                    Access to each output VC is arbitrated (PV x PV:1 arbiters)
 * 
 */

//
// ** THIS IS NOT USED ** only for hacking at present.... (*:
//

`include "types.v"

function automatic logic[15:0] NW_vc_sel_mask (input flit_t f);
   begin

      case (f.control.output_port)
	`port5id_tile:
	  begin
	     NW_vc_sel_mask='1;
	  end
	`port5id_north:
	  begin
	     // north next too
	     if (f.control.y_disp+1<0) begin
		NW_vc_sel_mask=4'b0011;
	     end else begin
		NW_vc_sel_mask=4'b1100;
	     end
	  end
	`port5id_east:
	  begin
	     // east next too
	     if (f.control.x_disp-1>0) begin
		NW_vc_sel_mask=4'b0011;
	     end else begin
		NW_vc_sel_mask=4'b1100;
	     end
	  end
	`port5id_south:
	  begin
	     // south next too
	     if (f.control.y_disp-1>0) begin
		NW_vc_sel_mask=4'b0011;
	     end else begin
		NW_vc_sel_mask=4'b1100;
	     end
	  end
	`port5id_west:
	  begin
	     // west next too
	     if (f.control.x_disp+1<0) begin
		NW_vc_sel_mask=4'b0011;
	     end else begin
		NW_vc_sel_mask=4'b1100;
	     end
	  end
      endcase 

   end
endfunction // NW_vc_sel_mask


module NW_vc_unrestricted_allocator (req,              // VC request
				     output_port,      // for which port?
				     //vc_mask,          // which VC's are we permitted to request
				     req_priority,     // prioritized requests? (between VC requests)
				     vc_status,        // which VCs are free
				     vc_new,           // newly allocated VC id.
				     vc_new_valid,     // has new VC been allocated?
				     vc_allocated,     // change VC status from free to allocated?
				     vc_requested,     // which VCs were requested at each input VC?
				     flit,             // head of each input VC buffer
				     vc_credits,       // credits for each VC at each output port
				     clk, rst_n);

//   `include "NW_functions.v";

   //parameter type flit_priority_t = flit_pri_t;
   
   parameter buf_len = 4;
		
   parameter xs=4;
   parameter ys=4;
	
   parameter np=5;
   parameter nv=4;

   // some packets can make higher priority requests for VCs
   // ** NOT YET IMPLEMENTED **
   parameter dynamic_priority_vc_alloc = 0;

   //
   // selection policies
   //
   parameter vcselect_bydestinationnode = 0;
   parameter vcselect_leastfullbuffer = 0;
   parameter vcselect_arbstateupdate = 0;    // always/never update state of VC select matrix arbiter
   parameter vcselect_usepacketmask = 0;     // packet determines which VCs may be requested (not with bydestinationnode!)
   
   typedef logic unsigned [clogb2(buf_len+1)-1:0] pri_t;
   
//-----   
   input [np-1:0][nv-1:0] req;
   input output_port_t output_port [np-1:0][nv-1:0];
   //input [np-1:0][nv-1:0][nv-1:0] vc_mask;
   input flit_priority_t req_priority [np-1:0][nv-1:0];
   input [np-1:0][nv-1:0] vc_status;
   output [np-1:0][nv-1:0][nv-1:0] vc_new;
   output [np-1:0][nv-1:0] vc_new_valid;   
   output [np-1:0][nv-1:0] vc_allocated;  
   output [np-1:0][nv-1:0][nv-1:0] vc_requested;
   input flit_t flit [np-1:0][nv-1:0];
   input [np-1:0][nv-1:0][clogb2(buf_len+1)-1:0] vc_credits;
   input clk, rst_n;

   genvar i,j,k,l;

   logic [np-1:0][nv-1:0][nv-1:0] stage1_request, stage1_grant;
   logic [np-1:0][nv-1:0][nv-1:0] selected_status;
   logic [np-1:0][nv-1:0][np-1:0][nv-1:0] stage2_requests, stage2_grants;
   logic [np-1:0][nv-1:0][nv-1:0][np-1:0] vc_new_;
   
   logic [np-1:0][nv-1:0][nv-1:0] vc_mask;


   pri_t pri [np-1:0][nv-1:0][nv-1:0];
   
   assign vc_requested=stage1_grant;
   
   generate
      for (i=0; i<np; i++) begin:foriports
	 for (j=0; j<nv; j++) begin:forvcs

	    //
	    // Determine value of 'vc_mask'
	    //
	    // What VCs may be requested?
	    //
	    //    (a) all
	    //    (b) use mask set in packet's control field
	    //    (c) or select VC solely by destination node 
	    //
	    if (vcselect_bydestinationnode || vcselect_usepacketmask) begin

	       if (vcselect_bydestinationnode) begin
		  //
		  // unless exiting network! - should be set as vcalloc_mask at source!!!!! TO-DO 
		  // OR just set second stage request directly?
		  /*assign vc_mask[i][j] = (output_port[i][j]==`port5id_tile) ? '1 : 
					 1'b1<<(flit[i][j].debug.xdest+xs*flit[i][j].debug.ydest);
//					 1'b1<<(flit[i][j].debug.xsrc+xs*flit[i][j].debug.ysrc);
*/

	       end else begin
		  
	       end
	    end else begin
	       // packet may request any free VC
	       assign vc_mask[i][j] = '1;
	    end
	    
	    //	    
	    // Select VC status bits at output port of interest (determine which VCs are free to be allocated)
	    //
	    assign selected_status[i][j] = vc_status[oh2bin(output_port[i][j])];

	    //
	    // Requests for VC selection arbiter
	    //
	    // Narrows requests from all possible VCs that could be requested to 1
	    //
	    for (k=0; k<nv; k++) begin:forvcs2
	       // Request is made if 
	       // (1) Packet requires VC
	       // (2) VC Mask bit is set
	       // (3) VC is currently free, so it can be allocated
	       //
	       assign stage1_request[i][j][k] = req[i][j] && vc_mask[i][j][k] && selected_status[i][j][k];

	       // VC selection priority = number of credits
	       if (vcselect_leastfullbuffer) begin
		  assign pri[i][j][k] = vc_credits[oh2bin(output_port[i][j])][k];
	       end
	    end

	    //
	    // first-stage of arbitration
	    //
	    // Arbiter state doesn't mean much here as requests on different clock cycles may be associated
	    // with different output ports. vcselect_arbstateupdate determines if state is always or never
	    // updated.
	    //
	    matrix_arb #(.size(nv), .multistage(1), 
			 .priority_support(vcselect_leastfullbuffer)
			 //, 
			 //.priority_type(pri_t)
			 )
			 stage1arb
			 (.request(stage1_request[i][j]),
			  .req_priority(pri[i][j]), 
			  .grant(stage1_grant[i][j]),
//			  .success(vc_new_valid[i][j]),
			  .success((vcselect_arbstateupdate==1)), 
			  .clk, .rst_n);

	    //
	    // second-stage of arbitration, determines who gets VC
	    //
	    for (k=0; k<np; k++) begin:fo
	       for (l=0; l<nv; l++) begin:fv
		  assign stage2_requests[k][l][i][j] = stage1_grant[i][j][l] && output_port[i][j][k];
	       end
	    end

	    //
	    // np*nv np*nv:1 tree arbiters
	    //
	    NW_tree_arbiter #(.multistage(0),
                              .size(np*nv),
                              .groupsize(nv),
                              .priority_support(dynamic_priority_vc_alloc)
                              //,
                              //.priority_type(flit_priority_t)
                              ) vcarb
              (.request(stage2_requests[i][j]),
               .req_priority(req_priority),
               .grant(stage2_grants[i][j]),
               .clk, .rst_n);

	    assign vc_allocated[i][j]=|(stage2_requests[i][j]);

	    //
	    // new VC IDs 
	    //
	    for (k=0; k<np; k++) begin:fo2
	       for (l=0; l<nv; l++) begin:fv2
		  // could get vc x from any one of the output ports
		  assign vc_new_[i][j][l][k]=stage2_grants[k][l][i][j];
	       end
	    end
	    for (l=0; l<nv; l++) begin:fv3
	       assign vc_new[i][j][l]=|vc_new_[i][j][l];
	    end
	    assign vc_new_valid[i][j]=|vc_new[i][j];
	 end
      end
   endgenerate
   
endmodule // NW_vc_unrestricted_allocator
