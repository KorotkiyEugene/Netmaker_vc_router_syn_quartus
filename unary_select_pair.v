
// USED ONLY TO SELECT VC BLOCKED STATUS
// OPTIMISE FOR XY ROUTING

/* autovdoc@
 *
 * component@ unary_select_pair
 * what@ A sort of mux!
 * authors@ Robert Mullins
 * date@ 5.3.04
 * revised@ 5.3.04
 * description@
 * 
 * Takes two unary (one-hot) encoded select signals and selects one bit of the input.
 * 
 * Implements the following:
 * 
 * {\tt selectedbit=datain[binary(sela)*WB+binary(selb)]}
 * 
 * pin@ sel_a, WA, in, select signal A (unary encoded)
 * pin@ sel_b, WB, in, select signal B (unary encoded)
 * pin@ data_in, WA*WB, in, input data 
 * pin@ selected_bit, 1, out, selected data bit (see above)
 * 
 * param@ WA, >1, width of select signal A
 * param@ WB, >1, width of select signal B
 * 
 * autovdoc@
 */

module unary_select_pair (sel_a, sel_b, data_in, selected_bit);

   parameter input_port = 0; // from 'input_port' to 'sel_a' output port
   parameter WA = 4;
   parameter WB = 4;

   input [WA-1:0] sel_a;
   input [WB-1:0] sel_b;
   input [WA*WB-1:0] data_in;
   output selected_bit;

   genvar i,j;

   wire [WA*WB-1:0]  selected;
   
   generate
   for (i=0; i<WA; i=i+1) begin:ol
      for (j=0; j<WB; j=j+1) begin:il

	 assign selected[i*WB+j] = (NW_route_valid_turn(input_port, i)) ?
				   data_in[i*WB+j] & sel_a[i] & sel_b[j] : 1'b0;
	 
	 /*
	 // i = output_port
	 // assume XY routing and that data never leaves on port it entered
	 if ((input_port==i) || (((input_port==`NORTH)||(input_port==`SOUTH)) &&
	     ((i==`EAST)||(i==`WEST)))) begin
	    assign selected[i*WB+j]=1'b0;
	 end else begin
	    assign selected[i*WB+j]=data_in[i*WB+j] & sel_a[i] & sel_b[j];
	 end
	  */
      end
   end
   endgenerate

   assign selected_bit=|selected;
   
endmodule // unary_select_pair
