/* -------------------------------------------------------------------------------
 * (C)2007 Robert Mullins
 * Computer Architecture Group, Computer Laboratory
 * University of Cambridge, UK.
 * -------------------------------------------------------------------------------
 * 
 * Logic to determine if the virtual-channel held by a particular packet 
 * (buffered in an input VC FIFO) is blocked or ready?
 * 
 * Looks at currently allocated VC or the next free VC that would be allocated
 * at this port (as VC allocation may be taking place concurrently).
 * 
 */

module NW_vc_status (output_port, 
		     free_vc_blocked,
		     vc_requested, 
		     allocated_vc,
		     allocated_vc_valid,
		     vc_status,
		     vc_blocked);

   parameter np=5;
   parameter nv=4;

   parameter unrestricted_vc_alloc = 0;
   
   input output_port_t output_port [np-1:0][nv-1:0]; 
   input [np-1:0] free_vc_blocked; // at each output port
   input [nv-1:0] allocated_vc [np-1:0][nv-1:0]; // allocated VC ID
   input [np-1:0][nv-1:0] allocated_vc_valid; // holding allocated VC?
   input [np-1:0][nv-1:0] vc_status; // blocked/ready status for each output VC
   output [np-1:0][nv-1:0] vc_blocked;
   input [np-1:0][nv-1:0][nv-1:0] vc_requested;
   
   logic [np-1:0][nv-1:0][np-1:0] next_blocked;
   logic [np-1:0][nv-1:0] b, current_vc_blocked, new_vc_blocked;

   logic [np-1:0][nv-1:0][nv-1:0] current_vc;
   
   genvar ip,vc,op;
   
   generate
      for (ip=0; ip<np; ip++) begin:il
	 for (vc=0; vc<nv; vc++) begin:vl

	    if (unrestricted_vc_alloc) begin

	       assign current_vc[ip][vc] = (allocated_vc_valid[ip][vc]) ? allocated_vc[ip][vc] : vc_requested[ip][vc];
	       
	    end else begin
	    
               for (op=0; op<np; op=op+1) begin:ol
		  
		  assign next_blocked[ip][vc][op] = (NW_route_valid_turn(ip, op)) ?
						    output_port[ip][vc][op] & free_vc_blocked[op] : 1'b0;
		  
	       end
	       assign new_vc_blocked[ip][vc]=|next_blocked[ip][vc];

	       assign current_vc[ip][vc] = allocated_vc[ip][vc];
	    end
	    
	    unary_select_pair #(ip, np, nv) blocked_mux
	      (output_port[ip][vc],
//	       allocated_vc[ip][vc],
	       current_vc[ip][vc],
	       vc_status,
	       current_vc_blocked[ip][vc]);
	    
	    /* (excludes impossible turn optimisations)
	     assign current_vc_blocked[ip][vc] = 
             vc_status[oh2bin(output_port[ip][vc])][oh2bin(allocated_vc[ip][vc])];
	     
	     */
	    if (unrestricted_vc_alloc) begin
	       assign b[ip][vc] = current_vc_blocked[ip][vc];
	    end else begin
	       assign b[ip][vc] = (allocated_vc_valid[ip][vc]) ? current_vc_blocked[ip][vc] : new_vc_blocked[ip][vc];
	    end

	    assign vc_blocked[ip][vc] = (NW_route_valid_input_vc (ip,vc)) ? b[ip][vc] : 1'b0;
	 end
      end 
      
   endgenerate
   
   
endmodule // NW_vc_status
