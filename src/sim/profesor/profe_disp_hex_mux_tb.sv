// Code your testbench here
// or browse Examples
`include "invsseg.sv"

module  testbench;

//  signal   declaration  
  logic  [3:0]  a, b; 
  logic  [7:0]  sum;
  logic  [7:0]  sseg;
  logic  [3:0]  an;
  logic  reset, clk;
  logic valid;
  logic [3:0] bin_out;
  
//  instantiate   7-seg  LED  display   module 
  disp_hex_mux disp_unit (.clk(clk), .reset(reset), 
                          .hex3(sum[7:4]), .hex2(sum[3:0]),  
                          .hex1(b), .hex0(a), .dp_in(4'b1011),
                          .an(an), .sseg(sseg));
  
 //This module is just for checking that the 7-seg decoder is workin
  invsseg iss(sseg, bin_out, valid) ;
  
// Initialize Inputs
// You can add your stimulus here
    initial begin
      
          //This is needed to have everything plotted
    	$dumpfile("dump.vcd");
    	$dumpvars;
    
		$display ($time, " << Starting the Simulation >> ");
        clk   = 1'b0;
        reset = 1'b0;
      
      for (int i = 0; i < 4; i++) @(negedge clk); // we set the reset on the negedge of clock
      reset = 1'b1;
      for (int i = 0; i < 4; i++) @(negedge clk);// This is just for waiting 4 clocks
      // and keep the reset high for those clocks
      reset = 1'b0;
      
      @(negedge clk);
      a =  4'h1 ; 
      b =  4'h2 ; 
      sum =  {4'b0,a}  +  {4'b0,b};
      //$display("%h->%h", sseg, bin_out)
      repeat (64) @(negedge clk) ;// This another way of waiting for 24 clocks
      //To allow for checking the right multiplexing
      a =  4'h2 ; 
      b =  4'h3 ; 
      sum =  {4'b0,a}  +  {4'b0,b};

    end


	always 
			#10 clk = ~clk;    // every ten nanoseconds invert the clock

       // This parallel process determines the length of the simulation
     initial //Simulation is run for 800ns
     #3200  $finish; 
endmodule