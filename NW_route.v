/* -------------------------------------------------------------------------------
 * (C)2007 Robert Mullins
 * Computer Architecture Group, Computer Laboratory
 * University of Cambridge, UK.
 * -------------------------------------------------------------------------------
 * 
 * XY routing
 * 
 * Routing Function
 * ================
 * 
 * Simple XY routing
 *  - Function updates flit with the output port required at next router 
 *    and modifies displacement fields as head flit gets closer to 
 *    destination.
 * 
 * More complex routing algorithms may be implemented by making edits here 
 * and to the flit's control field defn.
 * 
 * Valid Turn?
 * ===========
 * 
 * NW_route_valid_turn(from, to) 
 * 
 * This function is associated with the routing algorithm and is used to 
 * optimize the synthesis of the implementation by indicating impossible 
 * turns - hence superfluous logic.
 * 
 * Valid Input VC
 * ==============
 * 
 * Does a particular input VC exist. e.g. Tile input port may only contain
 * one VC buffer.
 * 
 */

function automatic bit NW_route_valid_input_vc;

   input integer port;
   input integer vc;
   
   `include "parameters.v"

   bit valid;
   begin
      valid=1'b1;

//      if ((port==`TILE)&&(vc!=0)) valid=1'b0; 

      if (port==`TILE) begin
	 if (vc>=router_num_vcs_on_entry) valid=1'b0;
      end

      NW_route_valid_input_vc=valid;
   end
endfunction // automatic

function automatic bit NW_route_valid_turn;
   
   input output_port_t from;
   input output_port_t to;
   
   bit valid;
   begin
      valid=1'b1;

      // flits don't leave on the same port as they entered
      if (from==to) valid=1'b0;

`ifdef OPT_MESHXYTURNS
      // Optimise turns for XY routing in a mesh
      if (((from==`NORTH)||(from==`SOUTH))&&((to==`EAST)||(to==`WEST))) valid=1'b0;
`endif      

      NW_route_valid_turn=valid;
   end
endfunction // bit


module NW_route (flit_in, flit_out, clk, rst_n);

   input flit_t flit_in;
   output flit_t flit_out;

   input  clk, rst_n;

   function flit_t next_route;

	  input flit_t flit_in;
	  
      logic [4:0] route;
      flit_t new_flit;

      begin

	 new_flit=flit_in;

	 // Simple XY Routing

	 if (flit_in.control.x_disp!=0) begin
	    if (flit_in.control.x_disp>0) begin
	       route = `port5id_east;
	       new_flit.control.x_disp--;
	    end else begin
	       route = `port5id_west;
	       new_flit.control.x_disp++;
	    end
	 end else begin
	    if (flit_in.control.y_disp==0) begin
	       route=`port5id_tile;
	    end else if (flit_in.control.y_disp>0) begin
	       route=`port5id_south;
	       new_flit.control.y_disp--;
	    end else begin
	       route=`port5id_north;
	       new_flit.control.y_disp++;
	    end
	 end

	 new_flit.control.output_port = route;
	 
	 next_route = new_flit;

      end
   endfunction // flit_t
   
   assign  flit_out=next_route(flit_in);
  
endmodule // route

