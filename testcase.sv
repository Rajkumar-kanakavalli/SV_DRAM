
//`include "package.sv"
import ram_pkg::*;
  //class ram_trans_crt with constraints  for wr_address &rd_address
 class ram_trans_crt extends ram_trans;
     constraint VALID_RD_ADDR {rd_address inside {1756:4095};}}
	 constraint VALID_WR_ADDR {wr_address inside {2926:4095};}}
	 
	 endclass:ram_trans_crt
	 //class ram_trans_crt with constraints  for wr_address &rd_address data
class ram_trans_cwt extends ram_trans; 
     constraint VALID_RD_ADDR {rd_address inside {3511:4094};}}
	 constraint VALID_WR_ADDR {wr_address inside 4095;}
	 constraint VALID_DATA {data_in inside {[1:10000]};}
	 
endclass:ram_trans_cwt
	 
	 class test;
	    virtual ram_if.WR_DRV wr_drv_if;
		virtual ram_if.RD_DRV rd_drv_if;
		virtual ram_if.WR_MON wr_mon_if;
		virtual ram_if.RD_MON rd_mon_if;
		
		//declare an handle for ram_env as env
		   ram_env env_h;
		//declare an handle for ram_trans_crt as crt_data_h
		    ram_trans_crt crt_data_h;
		//declare an handle for ram_trans_cwt as crt_data_h
		   ram_trans_cwt  cwt_data_h;
		   
		   function new( virtual ram_if.WR_DRV wr_drv_if,
		                 virtual ram_if.RD_DRV rd_drv_if,
		                 virtual ram_if.WR_MON wr_mon_if,
		                 virtual ram_if.RD_MON rd_mon_if);
						 
	this.wr_drv_if = wr_drv_if;
	this.rd_drv_if = rd_drv_if;
	this.wr_mon_if = wr_mon_if;
	this.rd_mon_if = rd_mon_if;
	
	env_h = new(wr_drv_if,rd_drv_if,wr_mon_if,rd_mon_if);
	endfunction:new
	
	//which builds the TB environment and runs the simulation for different tests
	task build_and_run();
	   begin 
	       if ($test$plusargs("TEST 1"))
		      begin 
			     number_of_transactions =100;
				 env_h.build();
				 env_h.run();
				 $finish;
				 
			 end
			 if($test$plusargs("TEST 2"))
			     begin
				     crt_data_h=new;
					 number_of_transactions = 200;
					 env_h.build();
					 env_h.gen_h.gen_trans = crt_data_h;
					 env_h.run();
					 $finish;
				end
			 if($test$plusargs("TEST 3"))
			     begin
				     crt_data_h=new;
					 number_of_transactions = 500;
					 env_h.build();
					 env_h.gen_h.gen_trans = cwt_data_h;
					 env_h.run();
					 $finish;
					 end
					
					end
				endtask:build_and_run
					
	endclass:test
				
	   
	
	     
	 
	 