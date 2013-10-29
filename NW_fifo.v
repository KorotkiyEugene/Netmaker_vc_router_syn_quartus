
/* -------------------------------------------------------------------------------
 * (C)2007 Robert Mullins
 * Computer Architecture Group, Computer Laboratory
 * University of Cambridge, UK.
 * -------------------------------------------------------------------------------
 *
 * FIFO
 * ====
 *
 * Implementation notes:
 *  
 * - Read and write pointers are simple ring counters
 * 
 * - Number of items held in FIFO is recorded in shift register
 *      (Full/empty flags are most and least-significant bits of register)
 * 
 * - Supports input and/or output registers on FIFO
 * 
 * Examples:
 * 
 *   fifo_v #(.fifo_elements_t(int), .size(8)) myfifo (.*);
 * 
 * Instantiates a FIFO that can hold up to 8 integers.
 * 
 *   fifo_v #(.fifo_elements_t(int), .size(8), .output_reg(1)) myfifo (.*);
 * 
 * Instantiates a FIFO that can hold up to 8 integers with output register
 * 
 * Output Register
 * ===============
 * 
 * Instantiate a FIFO of length (size-1) + an output register and bypass logic
 *  
 *   output_reg = 0 (default) - no output register
 *   output_reg = 1 - instantiate a single output register
 * 
 *                      _
 *      ______    |\   | |
 *  _|-[_FIFO_]-->| |__| |__ Out
 *   |----------->| |  |_|
 *      bypass    |/   Reg.
 *
 * 
 * Input Register
 * ==============
 * 
 *   input_reg = 0 (default) - no input register, FIFO receives data directly
 *   input_reg = 1 - assume **external** input register and bypass logic 
 *   input_reg = 2 - instantiate input register and bypass logic 
 * 
 * In case 1. the FIFO is still of length 'size' as it is assumed the external
 * input register is always enabled (used when building VC buffers).
 * 
 *   _      ______    |\
 *  | |  |-[_FIFO_]-->| |___ Out
 *  | |__|___________>| |
 *  |_|               |/
 *  Reg.
 * 
 * Input and Output Registers
 * ==========================
 * 
 * Can set input_reg=2, output_reg=1 to create FIFO with both input and output
 * registers. FIFO behaviour remains identical at the cycle-level with the 
 * addition of input/output registers.
 * 
 * InReg            OutReg
 *   _     ______     _ 
 *  | |---[_FIFO_]---| |
 *  | | |____________| |___|\
 *  |_| |            |_|   | |__ Out
 *      |__________________| |
 *                         |/
 * FIFO Initialisation
 * ===================
 * 
 *   init_fifo_contents = 0    - FIFO is empty on reset
 *   init_fifo_contents = 1    - FIFO is nearly_full on reset (mem[i]=1'b1<<i, mem[size]=0)
 *   init_fifo_contents = 2    - FIFO is nearly empty on reset (mem[0]=1)
 * 
 * 
 * ===============================================================================      
 */ 

// other FIFO types: double buffered, two slower FIFOs + output register
//                   FIFOs with second entry outputs (as required by router)
//                   pending write input register
//
// - second output with output registers [two output registers?]
//

//`ifdef VCS
//import fifo_package::*;
//`endif
 
/************************************************************************************
 *
 * FIFO 
 *
 ************************************************************************************/

typedef struct packed
{
 logic full, empty, nearly_full, nearly_empty;
 logic fast_empty;
} fifov_flags_t;


typedef flit_t fifo_elements_t;
  
  
module NW_fifo_v (push, pop, data_in, data_out, second_data_out, flags, clk, rst_n);
   
   // initialise FIFO contents? (usually no initialisation, set to 0)
   parameter init_fifo_contents = 0;
   // Type of FIFO elements
   //parameter type fifo_elements_t = integer ;
  
   //parameter fifo_elements_t = integer ;
   // max no. of entries
   parameter size = 8;
   // opt. delay between clk+ and data becoming valid on output of FIFO?
   parameter output_reg = 1;
   // external input register and bypass logic? or (2) internal input register
   parameter input_reg = 0;
   // trade performance for power savings? (may degrade performance in some cases!) - rename late_pop?
   parameter low_power = 0;
   // need second data out?
   parameter generate_second_data_out = 1;
   
   input     push, pop;
   output    fifov_flags_t flags;
   input     fifo_elements_t data_in;
   output    fifo_elements_t data_out, second_data_out;
   input     clk, rst_n;

   fifo_elements_t second;
   
   logic is_push, select_bypass, fifo_push, fifo_pop;
   fifo_elements_t in_reg, fifo_data_out;

   generate
   if (input_reg==0) begin
   
      fifo_r #(.init_fifo_contents(init_fifo_contents),
	       //.fifo_elements_t(fifo_elements_t),
	       .size(size),
	       .output_reg(output_reg),
	       .low_power(low_power)) fifo_r
	(push, pop, data_in, data_out, second, clk, rst_n);

   end else if (input_reg==1) begin

      //
      // instantiate FIFO which can be used with *external* input register and bypass
      //			
      fifo_r #(.init_fifo_contents(init_fifo_contents),
	       //.fifo_elements_t(fifo_elements_t),
	       .size(size),
	       .output_reg(output_reg),
	       .low_power(low_power)) fifo_r
	(fifo_push, fifo_pop, data_in, data_out, second, clk, rst_n);
      
   end else if (input_reg==2) begin 

      //
      // instantiate FIFO and input register and bypass
      //			
      fifo_r #(.init_fifo_contents(init_fifo_contents),
	      // .fifo_elements_t(fifo_elements_t),
	       .size(size),
	       .output_reg(output_reg),
	       .low_power(low_power)) fifo_r
	(fifo_push, fifo_pop, in_reg, fifo_data_out, second, clk, rst_n);
      
      //
      // instantiate input register and bypass (input_reg==2)
      //
      always@(posedge clk) 
	begin
           if (!rst_n) begin
              in_reg<='0;
           end else begin
	      if (push) begin
		in_reg<=data_in;
	      end else
		in_reg<='0; // rdm34
	   end
	end
      
      assign data_out = (select_bypass) ? in_reg : fifo_data_out;
   end 
   
   endgenerate

   generate
      //
      // if input_reg==0, push and pop are used directly
      //
      if (!low_power && !(output_reg && input_reg!=0)) begin
         /* Always write even if data bypassed FIFO altogether. May reduce router
	  cycle time in cases where 'fifo_push' is generated late in the clock
	  cycle. Downside - this wastes energy */
	 assign fifo_push = is_push;
	 assign fifo_pop = pop;
      end else begin
	 // only copy input register contents to FIFO if there was a push operation
	 // and contents didn't bypass FIFO altogether
	 assign fifo_push = is_push && !(select_bypass && pop);
	 // similarly for pop, only pop if we aren't bypasses the FIFO
	 assign fifo_pop = pop && !select_bypass;
      end
   endgenerate
   
   always@(posedge clk) begin

      if (!rst_n) begin
	 is_push <= 1'b0;
	 select_bypass <= 1'b1;
      end else begin
	 is_push <= push;

	 select_bypass <= flags.empty || (flags.nearly_empty && pop);
      end
   end
   
   /************************************************************************************
    * Generate Flags for FIFO (flags are always generated for a FIFO of length 'size')
    ************************************************************************************/
   fifo_flags #(.size(size), 
		.init_fifo_contents(init_fifo_contents)) genflags 
     (push, pop, flags, clk, rst_n);

   /************************************************************************************
    * Need second data out?
    ************************************************************************************/
   generate
      if (generate_second_data_out) begin
	 assign second_data_out = second;
      end else begin
	 assign second_data_out = 'x;
      end
   endgenerate
endmodule // fifo_v


/************************************************************************************
 *
 * FIFO + Output Register (if requested)
 *  
 ************************************************************************************/

module fifo_r (push, pop, data_in, data_out, second_data_out, clk, rst_n);

   // initialise FIFO
   parameter init_fifo_contents = 0;
   // what does FIFO hold?
   //parameter type fifo_elements_t = int ;
   // max no. of entries
   parameter size = 8;
   // opt. delay between clk+ and data becoming valid on output of FIFO?
   parameter output_reg = 1;
   // trade power for performance
   parameter low_power = 0;

   // 'always_write'
   // regardless of 'push' always write input data to FIFO slot pointed to by write
   // pointer (one extra entry is added to FIFO to ensure FIFO data is not overwritten).
   parameter always_write = 1'b0; //!low_power;

//==========
   
   input     push, pop;
   input     fifo_elements_t data_in;
   output    fifo_elements_t data_out, second_data_out;
   input     clk, rst_n;

   fifov_flags_t local_flags;

   fifo_elements_t fifo_data_out, second_data;
   fifo_elements_t fifo_out_reg;

   fifo_elements_t to_reg;
   
   logic bypass, fifo_push, fifo_pop;

   generate
   if (!output_reg) begin

      fifo_buffer #(.init_fifo_contents(init_fifo_contents), 
		    //.fifo_elements_t(fifo_elements_t), 
		    .size(always_write+size), .output_reg(0), 
		    .low_power(low_power), .always_write(always_write))
         fifo_buf (push, pop, data_in, data_out, second_data, clk, rst_n);

      assign second_data_out = second_data;
      
   end else begin
      //
      // FIFO + output register 
      //
      fifo_buffer #(.init_fifo_contents(init_fifo_contents),
		    //.fifo_elements_t(fifo_elements_t), 
		    .size(always_write+size), .output_reg(0), .low_power(low_power),
		    .always_write(always_write))
         fifo_buf (push, pop, data_in, fifo_data_out, second_data, clk, rst_n);

      //
      // local flags to determine when to bypass, read and write FIFO
      //
      // *rdm34, better if we could use global flags, are these flags ever on critical path?
      //
      fifo_flags #(.size(always_write+size), 
		   .init_fifo_contents(init_fifo_contents)) gen_localflags
	(push, pop, local_flags, clk, rst_n);   

      always@(posedge clk) begin
	 if (!rst_n) begin
            // initialise FIFO contents?
            if (init_fifo_contents!=0) begin
               fifo_out_reg<=1;
            end
	 end else begin
	    fifo_out_reg<=to_reg;

	    /*
            if (local_flags.empty || (local_flags.nearly_empty && pop)) begin
               if (push) begin
		  fifo_out_reg<=data_in;
               end else begin
		  // fifo_out_reg<='0; // FIFO is empty
               end
            end else if (pop) begin
               fifo_out_reg<=second_data;
            end else begin
               fifo_out_reg<=fifo_data_out;
            end
	     */
	    
	 end // else: !if(!rst_n)
      end // always@ (posedge clk)

      // select data to write to fifo_out_reg
      always_comb
	begin
           if (local_flags.empty || (local_flags.nearly_empty && pop)) begin
              if (push) begin
		 to_reg = data_in;
              end else begin
		 // FIFO is empty
		 //if (init_fifo_contents!=0) to_reg='0; else to_reg='x;
		 to_reg = '0;
              end
           end else if (pop) begin
	      to_reg = second_data;
           end else begin
              to_reg = fifo_data_out;
           end
	end
      
      assign data_out = fifo_out_reg;
      assign second_data_out = second_data;

   end
   endgenerate
   
endmodule // fifo_r

/************************************************************************************
 *
 * Maintain FIFO flags (full, nearly_full, nearly_empty and empty)
 * 
 * This design uses a shift register to ensure flags are available quickly.
 * 
 ************************************************************************************/

module fifo_flags (push, pop, flags, clk, rst_n);
   input push, pop;
   output fifov_flags_t flags;
   input clk, rst_n;
   
   parameter size = 8;
   parameter init_fifo_contents = 0;

   reg [size:0]   counter;      // counter must hold 1..size + empty state

   logic 	  was_push, was_pop;

   fifov_flags_t flags_reg;
   logic 	  add, sub, same;

   logic 	  fast_empty;
   
   /*
    * maintain flags
    *
    *
    * maintain shift register as counter to determine if FIFO is full or empty
    * full=counter[size-1], empty=counter[0], etc..
    * init: counter=1'b1;
    *   (push & !pop): shift left
    *   (pop & !push): shift right
    */

   always@(posedge clk) begin
      if (!rst_n) begin
	 
	 //
	 // initialise flags counter on reset
	 //
	 if (init_fifo_contents==2) begin
	    // nearly_empty
	    counter<={{(size-1){1'b0}},2'b10};
	 end else if (init_fifo_contents==1) begin
	    // nearly_full
	    counter<={2'b01,{(size-1){1'b0}}}; 
	 end else begin
	    // empty
	    counter<={{size{1'b0}},1'b1};
	 end

	 was_push<=1'b0;
	 was_pop<=1'b0;

	 fast_empty <=1'b1;
	 
      end else begin
 	 if (add) begin
	    assert (counter!={1'b1,{size{1'b0}}}) else $fatal;
	    counter <= {counter[size-1:0], 1'b0};
	 end else if (sub) begin
	    assert (counter!={{size{1'b0}},1'b1}) else $fatal;
	    counter <= {1'b0, counter[size:1]};
	 end
	 
	 assert (counter!=0) else $fatal;

	 was_push<=push;
	 was_pop<=pop;

	 assert (push!==1'bx) else $fatal;
	 assert (pop!==1'bx) else $fatal;

	 fast_empty <= (flags.empty && !push && !pop) || (flags.nearly_empty && pop && !push);
	 
      end // else: !if(!rst_n)
      
   end

   assign add = was_push && !was_pop;
   assign sub = was_pop && !was_push;
   assign same = !(add || sub);
   
   assign flags.full = (counter[size] && !sub) || (counter[size-1] && add);
   assign flags.empty = (counter[0] && !add) || (counter[1] && sub);

   assign flags.nearly_full = (counter[size-1:0] && same) || (counter[size] && sub) || (counter[size-2] && add);
   assign flags.nearly_empty = (counter[1] && same) || (counter[0] && add) || (counter[2] && sub);
    
   assign flags.fast_empty = fast_empty;

   /*
   always@(posedge clk) begin
      if (size>3) begin
	 if (rst_n) begin

	    if ((flags.full && flags.empty)||
		(flags.full && flags.nearly_empty)||
		(flags.full && flags.nearly_full)||
		(flags.nearly_full && flags.nearly_empty) ||
		(flags.nearly_full && flags.empty) ||
		(flags.nearly_empty && flags.empty)) begin

	       $display ("%d: %m", $time);
	       
	       $display ("flags.full =%b", flags.full);
	       $display ("flags.nfull=%b (counter[size, -1, -2]=%b, %b, %b)", 
			 flags.nearly_full, counter[size], counter[size-1], counter[size-2]);
	       $display ("flags.nempt=%b", flags.nearly_empty);
	       $display ("flags.empt =%b", flags.empty);
	       $display ("Counter=%b", counter);
	    end
	 end
      end
   end
*/

endmodule // fifo_flags

/************************************************************************************
 *
 * Simple core FIFO module
 * 
 ************************************************************************************/

module fifo_buffer (push, pop, data_in, data_out, second_data_out, clk, rst_n);

   // initialise FIFO
   parameter init_fifo_contents = 0;
   // what does FIFO hold?
   //parameter type fifo_elements_t = logic ;
   // max no. of entries
   parameter int unsigned size = 4;
   // part of fast read FIFO?
   parameter output_reg = 0;
   // trade power for performance
   parameter low_power = 0;
   // write input data to FIFO[wt_ptr] every clock cycle regardless of 'push'
   parameter always_write = 0;

   input     push, pop;
   input     fifo_elements_t data_in;
   output    fifo_elements_t data_out;
   output    fifo_elements_t second_data_out;
   input     clk, rst_n;

//   reg [size-1:0] rd_ptr, wt_ptr;
   logic unsigned [size-1:0] rd_ptr, wt_ptr;
   
   fifo_elements_t fifo_mem[0:size-1];

   logic select_bypass;
   
   integer i,j;

   always@(posedge clk) begin

      assert (size>=2) else $fatal();

      if (!rst_n) begin
	 //
	 // reset read and write pointers
	 //
	 if ((init_fifo_contents==2)&&(output_reg==0)) begin
	    // initialise with single entry set to 1
	    fifo_mem[0]<=1;
	    rd_ptr<={{size-1{1'b0}},1'b1};
            wt_ptr <= {{size-2{1'b0}},2'b10};
	 end else if (init_fifo_contents==1) begin
	    // initialise FIFO full (contents 1'b1<<(i+output_reg))
	    for (i=0; i<size-1; i=i+1) begin
	       fifo_mem[i]<=1'b1<<(i+output_reg);
	    end
	    rd_ptr<={{size-1{1'b0}},1'b1};
            wt_ptr<={1'b1,{size-1{1'b0}}}; 
	 end else begin
	    //
	    // initialise empty FIFO
	    //
	    rd_ptr<={{size-1{1'b0}},1'b1};
            wt_ptr<={{size-1{1'b0}},1'b1};
	 end
	 
      end else begin

	 if (push || always_write) begin
	    // enqueue new data
	    for (i=0; i<size; i++) begin
	       if (wt_ptr[i]==1'b1) begin
		  fifo_mem[i] <= data_in;
	       end
	    end
	 end

	 if (push) begin
	    // rotate write pointer
	    wt_ptr <= {wt_ptr[size-2:0], wt_ptr[size-1]};
	 end
	 
	 if (pop) begin
	    // rotate read pointer
            rd_ptr <= {rd_ptr[size-2:0], rd_ptr[size-1]};	    
	 end
	 
      end // else: !if(!rst_n)
   end // always@ (posedge clk)

   /*
    *
    * FIFO output is item pointed to by read pointer 
    * 
    */
   always_comb begin
      //
      // one bit of read pointer is always set, ensure synthesis tool 
      // doesn't add logic to force a default
      //
      data_out = 'x;  
      second_data_out ='x;
      
      for (j=0; j<size; j++) begin
	 if (rd_ptr[j]==1'b1) begin

	    // output entry pointed to by read pointer
	    data_out = fifo_mem[j];
	    
	    // output next entry after head
	    if ((j+1)==size) begin
	       second_data_out = fifo_mem[0];
	    end else begin
	       second_data_out = fifo_mem[j+1];
	    end

	 end
      end 

   end

endmodule // fifo_buffer
