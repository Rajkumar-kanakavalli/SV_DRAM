`include "interface.sv"
	
	`include "test.sv"
   //`include "testcase.sv"
  module top;

	parameter cycle = 10;
	
	reg clock;
	
	ram_if DUV_IF (clock);  //interface instantiation
	
	test test_h;      //test bench instantiation
	
	ram_4096 RAM (.clk(clock),.data_in(DUV_IF.data_in),.data_out(DUV_IF.data_out),.wr_address(DUV_IF.wr_address),.rd_address(DUV_IF.rd_address),.read(DUV_IF.read),.write(DUV_IF.write));
	
	initial 
	
		begin
		
			test_h = new (DUV_IF,DUV_IF,DUV_IF,DUV_IF);
			
			test_h.build_and_run;
			
		end
		
	initial 
	
		begin
		
			clock = 1'b0;
			
			forever  # (cycle/2) clock = ~clock;
			
		end
		
endmodule: top
	//
	