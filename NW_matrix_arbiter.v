
/* -------------------------------------------------------------------------------
 * (C)2007 Robert Mullins
 * Computer Architecture Group, Computer Laboratory
 * University of Cambridge, UK.
 * -------------------------------------------------------------------------------
 *
 * Matrix Arbiter
 * 
 * See Dally/Towles (p.359) for implementation details and full description
 * 
 * Multistage Options
 * ==================
 * 
 * [multistage=0] Arbiter state is updated whenever a request is granted.
 * 
 * [multistage=1] This arbiter is meant for situations where the initial 
 * request must progress through multiple stages of arbitration. An 
 * additional input to the arbiter (success) ensures that the state of 
 * the arbiter is only updated if the request is finally granted (at the 
 * last stage of arbitration).
 * 
 * || This assumes 'success' is produced before the end of the current clock 
 * || cycle.
 * 
 * [multistage=2] Used in situations where multistage=1 would be, but when
 * 'success' is not available until the next clock cycle.
 * 
 * Prioritised inputs
 * ==================
 * 
 * [priority_support = 0 | 1]
 * 
 * Input requested are prioritized by associated 'req_priority' input, 
 * may be anything from a single bit to N-bits wide.
 * 
 * e.g. for 16 priority levels:
 * 
 *     parameter priority_support = 1;
 *     parameter type priority_type = bit unsigned [3:0]; 
 * 
 * Note: The priority input is ignored if the associated request is 
 * not asserted.
 * 
 */

//#################################
// NOT IMPLEMENTED YET:
//
//   - parameter GRANT_HOLD 
//               don't update matrix state until request
//               assoc. with current grant is released
//               - winning request will hold grant for as long as it is asserted
//
//   - parameter PRIORITIZE first F inputs - 
//               inputs 0..F are priority inputs
//               input 0 will be granted if requested
//               input 1 will be granted (if input 0 is not asserted)
//               ..etc to input F
//
// weighted arbiter,....


module comb_matrix_arb_next_state (state, grant, new_state);
   parameter size=4;
   
   input [size*size-1:0] state;
   input [size-1:0] grant;
   output [size*size-1:0] new_state;

   genvar i,j;
   
   generate
   for (i=0; i<size; i=i+1) begin:ol2
      for (j=0; j<size; j=j+1) begin:il2
         assign new_state[j*size+i]= (state[j*size+i]&&!grant[j])||(grant[i]);
      end
   end
   endgenerate

endmodule // comb_matrix_arb_next_state

module matrix_arb (request, req_priority, max_priority, grant, success, clk, rst_n);
   
   parameter size= 4;
   parameter multistage = 0;
   parameter grant_hold = 0;
   parameter priority_support = 0;

   //parameter type priority_type = bit unsigned [3:0]; // e.g. 16-levels of priority

   input [size-1:0] request;
   input priority_type req_priority [size-1:0]; // optional
   
   output priority_type max_priority;
   output [size-1:0] grant;
   input success;
   input clk, rst_n; 

   genvar i,j;

   logic [size-1:0] req;
   logic [size-1:0] newgrant;
   logic [size*size-1:0] next_state, current_state;
   logic [size-1:0] pri [size-1:0];
   logic [size*size-1:0] new_state;
   logic [size*size-1:0] state;

   logic  update;

   genvar r;

   integer k;
   priority_type highest_pri;
   
   // #########################################
   // Support for Prioritized Requests
   // #########################################

   assign max_priority = highest_pri;

//   always@(posedge clk) begin
//      $display ("%m: req=%b, grant=%b", req, grant);
//   end
   
   always_comb
     begin
//	if (priority_support && $bits(priority_type)>1) begin
	if (priority_support) begin
	   highest_pri='0;
	   for (k=0; k<size; k++) begin
	      if (request[k] && (req_priority[k]>highest_pri)) highest_pri=req_priority[k];
	   end
	end
     end
   
   generate
      if (priority_support) begin
	 //
	 // determine what is highest priority request
	 // filter out any request with lower priority
	 //
	 for (r=0; r<size; r++) begin:ll
	    assign req[r]=request[r] && (req_priority[r]>=highest_pri);
	 end
      end else begin // if (priority_support)
	 assign req=request;
      end
   endgenerate
   
   // ##########################################
   // Generate grants
   // ##########################################
   generate
   for (i=0; i<size; i=i+1) begin:ol1
      // generate grant i
      for (j=0; j<size; j=j+1) begin:il1
         if (j==i) 
           // request i wins if requesting and....
           assign pri[i][j]=req[i];
         else 
           // ....no other request with higher priority
           if (j>i)
             // j beats i
             assign pri[i][j]=!(req[j]&&state[j*size+i]);
           else
             // !(i beats j)
             assign pri[i][j]=!(req[j]&&!state[i*size+j]);
      end

      assign grant[i]=&pri[i];
      
   end
   endgenerate

   generate
   if (multistage==2) begin
      assign state = success ? next_state : current_state;
   end else begin
      assign state = current_state;
   end
   endgenerate
   
   //
   // calculate next matrix state based on current requests and grants
   //
   comb_matrix_arb_next_state #(size) calc_next (.*);
   
   always@(posedge clk) begin
     if (!rst_n) begin
        current_state<='1; //-1;
	next_state<='1; //-1; 
     end else begin

	// **************************************************
	// Multistage Arbiter with Late Success Notification  (multistage==2)
	// **************************************************
	if (multistage==2) begin
	   update<=|req;
	   if (|req) begin
	      // This 'next_state' will only be used on next clock cycle if
	      // 'success' is asserted
	      next_state <= new_state;
	   end
	   if (update) begin
	      current_state <= state;
	   end
	end else begin

	   // ************************************
	   // Multistage Arbiter (multistage==1)
	   // ************************************
	   // check request was ultimately successful before updating arbiter state
	   // we know about success before the next clock cycle.
	   if ((multistage==1)&!success) begin
	      // request was not ultimately successful, don't update priorities
	   end else begin

	      // **********************************
	      // Basic Arbiter (multistage==0)
	      // **********************************
	      // Update state whenever at least one request has been made
              if (|req) begin
		 current_state<=new_state;
              end
	   end
	end 
     end
   end
                                                  
endmodule
