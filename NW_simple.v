/* -------------------------------------------------------------------------------
 * (C)2007 Robert Mullins
 * Computer Architecture Group, Computer Laboratory
 * University of Cambridge, UK.
 * -------------------------------------------------------------------------------
 *
 * Simple/useful components
 * 
 */

//
// Register
//
/*module NW_reg (data_in, data_out, clk, rst_n);

   parameter type reg_t = byte;

   input     reg_t data_in;
   output    reg_t data_out;
   input     clk, rst_n;

   always@(posedge clk) begin
      if (!rst_n) begin
	 data_out<='0;
      end else begin
	 data_out<=data_in;
      end
   end
   
endmodule */ // NW_reg

//
// Multiplexer with one-hot encoded select input
//
// - output is '0 if no select input is asserted
//

 module NW_mux_oh_select (data_in, select, data_out);

   //parameter type dtype_t = byte;
   parameter n = 4;

   input fifo_elements_t data_in [n-1:0];
   input [n-1:0] select;
   output fifo_elements_t data_out;

   int i;
   
   always_comb
     begin
	data_out='0;
	for (i=0; i<n; i++) begin
	   if (select[i]) data_out = data_in[i];
	end
     end

endmodule // NW_mux_oh_select

//
// Crossbar built from multiplexers, one-hot encoded select input
//

module NW_crossbar_oh_select (data_in, select, data_out);

   //parameter type dtype_t = byte;
   parameter n = 4;

   input flit_t data_in [n-1:0];
   // select[output][select-input];
   input [n-1:0][n-1:0] select;   // n one-hot encoded select signals per output
   output flit_t data_out [n-1:0];

   genvar i;
   
   generate
      for (i=0; i<n; i++) begin:outmuxes
	 NW_mux_oh_select #( .n(n)) xbarmux (data_in, select[i], data_out[i]);
      end
   endgenerate
   
endmodule  // NW_crossbar_oh_select

