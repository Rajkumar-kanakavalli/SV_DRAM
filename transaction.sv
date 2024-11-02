class ram_trans;

	rand bit [63:0] data_in;
	
	rand bit [11:0] rd_address;
	
	rand bit [11:0] wr_address;
	
	rand bit read;
	
	rand bit write;
	
	logic [63:0] data_out; //data_out is collected at output terminal and hence it has to be logic
	
	static int trans_id; //this is static because its value should not reset in between operation; also that this is static, only one memory location has been allocated to this variable
	
	//tracking number of transactions
	
	static int no_of_read_trans;
	
	static int no_of_write_trans; //these are declared static becasue they should not reset upon entering a new operation; also that this is static, only one memory location has been allocated to this variable
	
	static int no_of_RW_trans; //even though thousands of packets are genreated through the simulation time, the memory allocated to these static variables is going to be the same 
	
	//adding necessary constraints
	
	constraint VALID_ADDR {wr_address != rd_address;} //address locations of reading and writing at the same instance of time should never be the same because Dual Port RAM enables the users to read and write data at the same time and when both are high at the same instance, the data cannot be read from a location without  being written
		
	constraint VALID_CTRL {{read,write} != 2'b00;} //read and write should not be 00 at any instance of time
	
	constraint VALID_DATA {data_in inside {[1:4294]};} //limiting the data to be inside the specified limit
	
	//display statements
	
	virtual function void display (input string message);
		
		$display("======================================");
		
		$display("%s",message);
		
		$display("\tTransaction No.: %d",trans_id);
	
		$display("\tRead Transaction No.: %d",no_of_read_trans);
		
		$display("\tWrite Transaction No.: %d",no_of_write_trans);

		$display("\tRead-Write Transaction No.: %d",no_of_RW_trans);
		
		$display("\tRead = %d , Write = %d",read,write);
		
		$display("\tRead_Address = %d , Write_Address = %d",rd_address,wr_address);
		
		$display("\tData_in = %d",data_in);
		
		$display("\tData_out = %d",data_out);
		
		$display("=======================================");
		
	endfunction: display
	
	//incrementing counters - tracking transactions
	
	function void post_randomize;
	
		if(this.read == 1 && this.write == 0)
		
			no_of_read_trans++;
			
		if(this.read == 0 && this.write ==1)
		
			no_of_write_trans++;
			
		if(this.read == 1 && this.write == 1)
		
			no_of_RW_trans++;
			
		this.display("\tRANDOMIZED DATA");
		
	endfunction: post_randomize
	
	//SB compare
	
	virtual function bit compare (input ram_trans rcv, output string message);
	
		compare = '0;
		
		begin
		
			if (this.rd_address != rcv.rd_address)
			
				begin
				
					$display("$time");
					
					message = "-------ADDRESS MISMATCH--------";
					
					return(0);
					
				end
				
			if (this.wr_address != rcv.wr_address)
			
				begin
				
					$display("$time");
					
					message = "-------DATA MISMATCH--------";
					
					return(0);
					
				end
				
			if (this.wr_address ==  rcv.wr_address && this.rd_address == rcv.rd_address)
			
				begin
				
					$display("$time");
					
					message = "-------SUCCESSFUL COMPARISION--------";
					
					return(1);
					
				end
				
		end
		
	endfunction: compare
	
endclass: ram_trans