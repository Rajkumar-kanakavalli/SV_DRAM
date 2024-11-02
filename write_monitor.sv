class ram_write_mon;

    virtual ram_if.WR_MON wr_mon_if;
	
	ram_trans wrdata;
	ram_trans data2rm;
	ram_trans cov_data;
	
	// int mem_coverage_wr;
	mailbox #(ram_trans) mon2rm;
	
	function new(virtual ram_if.WR_MON wr_mon_if,mailbox #(ram_trans) mon2rm);
	
	this.wr_mon_if = wr_mon_if;
	this.mon2rm = mon2rm;
	this.wrdata = new;
	// mem_coverage_wr = new;
	
	endfunction
	
	covergroup mem_coverage_wr;
	
	    WR_ADDR: coverpoint cov_data.wr_address{
		                                        bins ZERO      = {0};
												bins LOW1      ={[1:585]};
												bins LOW2      ={[586:1170]};
												bins MID_LOW   ={[1171:1755]};
												bins MID       = {[1756:2340]};
									            bins MID_HIGH  = {[2341:2925]};
										        bins HIGH1     = {[2926:3510]};
												bins HIGH2     = {[3511:4094]};
												bins MAX       = {4095};
												}
	  DATA: coverpoint cov_data.data_in {
		
													bins ZERO      =     {0};
													bins LOW1      =     {[1:500]};
													bins LOW2  	   =  	 {[501:1000]};
													bins MID_LOW   =  	 {[1001:1500]};
													bins MID       =  	 {[1501:2000]};
													bins MID_HIGH  =  	 {[2001:2500]};
													bins HIGH1     =  	 {[2501:3000]};
													bins HGIH2     = 	 {[3000:4293]};
													bins MAX       =	 {4294};
													
												}
													
				  WR: coverpoint cov_data.write {
				  
													bins write     =     {1};

												}
												
		WRxADDxDATA: cross WR,WR_ADDR,DATA;	//implicit bin for crossing 

endgroup

     virtual task monitor();
	    @(wr_mon_if.wr_mon_cb);
		
		wait(wr_mon_if.wr_mon_cb.write==1)
		@(wr_mon_if.wr_mon_cb)
		
		begin
		wrdata.write = wr_mon_if.wr_mon_cb.write;
		wrdata.wr_address = wr_mon_if.wr_mon_cb.wr_address;
		wrdata.data_in = wr_mon_if.wr_mon_cb.data_in;
		
		//call the display of ram_trans to display the monitor
		wrdata.display("DATA FROM  WRITE MONITOR");
		
		end
		endtask:monitor
		
		virtual task start();
		   fork
		       forever
			      begin
				   monitor();
				   cov_data = new wrdata;
				   data2rm = new wrdata;
				   
				   mem_coverage_wr.sample;
				   mon2rm.put(data2rm);
				   
				   end
				join_none
				   
	endtask
				 
endclass
		
		
		