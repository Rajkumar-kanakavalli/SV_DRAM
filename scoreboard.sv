class ram_sb;


    event DONE;
	
	
	int data_verified = 0;
	int rm_data_count =0;
	int mon_data_count =0;
	
	ram_trans rm_data;
	ram_trans rcvd_data;
	ram_trans cov_data;
	
	mailbox #(ram_trans) rm2sb;
	mailbox #(ram_trans) rdm2sb;
	
	function new (mailbox #(ram_trans) rm2sb,
	              mailbox #(ram_trans) rdm2sb);
				  
 this.rm2sb = rm2sb;
 this.rdm2sb = rdm2sb;
 
 endfunction
 
 virtual task start;
	
		fork
		
			while (1)
			
				begin
				
					rm2sb.get (rm_data);
					
					rm_data_count++;
					
					rdm2sb.get (rcvd_data);
					
					mon_data_count++;
					
					check (rcvd_data);
					
				end
				
		join_none
		
	endtask
	
	
	covergroup mem_coverage_rd;
		
		RD_ADDR: coverpoint cov_data.rd_address {
		
													bins ZERO      =  	 {0};
													bins LOW1      =  	 {[1:585]};
													bins LOW2  	   =  	 {[586:1170]};
													bins MID_LOW   =  	 {[1171:1755]};
													bins MID       =  	 {[1756:2340]};
													bins MID_HIGH  =  	 {[2341:2925]};
													bins HIGH1     =  	 {[2926:3510]};
													bins HGIH2     = 	 {[3511:4094]};
													bins MAX       =	 {4095};
													
												}
												
			  DATA: coverpoint cov_data.data_out {
		
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
													
				  RD: coverpoint cov_data.read {
				  
													bins read     =     {1};

												}
												
		READxADDxDATA: cross RD,RD_ADDR,DATA;	//implicit bin for crossing 

	endgroup: mem_coverage_rd

	virtual task check (ram_trans rc_data);
	   string diff;
	     if(rc_data.read==1)
		 begin
		     if (rc_data.data_out==0)
			    $display("SB: Recevied data not written ");
				
				
                if(rc_data.data_out ==0)
				  begin
				       if(!rm_data.compare(rc_data,diff))
                           begin:failed_compare
                              
                                rc_data.display ("SB: Received Data");
								
								rm_data.display ("SB: Data sent to DUT");
								
								$display ("%s\n%m\n\n",diff);
								
								$finish;
								
							end
							
							
						else
						
							$display ("SB: %s\n%m\n\n",diff);
							
					end
					
				data_verified++;
				
				cov_data = rm_data;
				
				mem_coverage_rd.sample;
				
				if (data_verified >= (number_of_transactions.rc_data.no_of_write_trans))
				
					begin
					
						->DONE;
						
					end
					
			end
							
								
	endtask: check	
	
	virtual function void report;
	
		$display ("-------SCOREBOARD REPORT--------");
		
		$display ("%0d Read Data Generated, %0d Received Data Received, %0d Read Data Verified\n",rm_data_count,mon_data_count,data_verified);
		
		$display ("---------------------------------");
		
	endfunction
	
endclass							  
 
 
	