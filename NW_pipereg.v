/* -------------------------------------------------------------------------------
 * (C)2007 Robert Mullins
 * Computer Architecture Group, Computer Laboratory
 * University of Cambridge, UK.
 * -------------------------------------------------------------------------------
 *
 * Pipelining Register (Interlocked pipeline register or single-element FIFO)
 * 
 * 
 *          ----------------
 *    ----> push         pop <-----
 *    <---- ready      valid ----->
 * 
 *    ----> data_in data_out ----->
 * 
 *    ----> clk
 *    ----> rst_n
 *          ----------------
 * 
 *    
 *   if (ready) register can accept data on next clock edge
 *                 i.e. (1) register is empty (!valid)
 *                   or (2) register is (valid) and (pop) is asserted
 * 
 *   if (valid) register contents are valid
 */

`include "types.v"    

 typedef flit_t reg_t;
 
module NW_pipereg (push, pop, data_in, data_out, ready, valid, clk, rst_n);

   //parameter type reg_t = flit_t;

   input push, pop, clk, rst_n;
   input reg_t data_in;
   output reg_t data_out;
   output valid, ready;

   logic  valid;
   reg_t r;
   
   always@(posedge clk) begin
      if (!rst_n) begin
	 valid<=1'b0;
      end else begin
	 // attempt to push when register isn't ready

	 assert (!(push & !ready)) else $fatal;

	 if (pop) begin
//	    $display ("%d: %m: pop", $time);
	 end
	 
	 if (push) begin
	    r <= data_in;
	    valid<=1'b1;

//	    $display ("%d: %m: push, new data=%1d, output_port=%b", $time, data_in.data, data_in.control.output_port);
	    
	 end else begin
	    if (pop) begin
	       valid<=1'b0;
	    end
	 end
	 
      end
   end // always@ (posedge clk)

   assign ready = !valid || pop ;

   assign data_out = r;
   
endmodule // NW_pipereg

