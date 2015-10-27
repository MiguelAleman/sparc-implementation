module test_data_path();
	reg Clr, Clk, External_Trap;
	integer fd, code, i, j = 0, n = 0; 
	reg [7:0] data;
	parameter sim_time = 5000000;
	data_path dat(Clr, Clk, External_Trap);		
	initial #sim_time $finish;
	
	// Pre charge Memory				
	initial begin
		fd = $fopen("testcode_sparc3.txt","r");
		i = 0;
		while (!($feof(fd))) begin
			code = $fscanf(fd, "%b", data);
			dat.memoria.Mem[i] = data;
			i = i + 1;
		end
		$fclose(fd);
	end
	
	// Data in Memory
	initial begin
		i = 9'b000000000;
		$display("Before");
		while(i <= 512) begin 
			$display("Mem[%d] = %b %b %b %b", i, dat.memoria.Mem[i],dat.memoria.Mem[i+1],dat.memoria.Mem[i+2],dat.memoria.Mem[i+3]);
			i = i + 9'b000000100;
		end
	end
	
	initial begin
		Clr = 1'b0;
		#10;
		Clr = 1'b1;
		Clk = 1'b0;
		// Test 2
		// repeat (600) 
		// Test 3
		repeat (2050) 
		#200 Clk = ~Clk;
	end


	// TEST 2
	// 	always @ (dat.con_unit.State)begin
	// 		if(dat.PC_out == 32'b00000000000000000000000011010000 && (n == 0))begin
	// 			$display("After");
	// 			i = 224;
	// 			while(i <= 260) begin 
	// 				$display("Mem[%d] = %b %b %b %b", i, dat.memoria.Mem[i],dat.memoria.Mem[i+1],dat.memoria.Mem[i+2],dat.memoria.Mem[i+3]);
	// 				i = i + 4;
	// 			end
	// 			n = n + 1;
	// 		end
	// 	end
	
	// DEBUG
	initial $display("         PSR                             R1         R5         R6         R7        TBR         R4         R17        R62       R40   State        PC");
	always @ (dat.con_unit.State)begin
		if(dat.con_unit.State == 6'b000001)begin
			$display("%b %d %d %d %d %d %d %d %d %d    %d %d %d", dat.PSR_out, dat.reg_win.Q_r1, dat.reg_win.Q_r5, dat.reg_win.Q_r6, dat.reg_win.Q_r7, dat.TBR_out, dat.reg_win.Q_r4, dat.reg_win.Q_r17, dat.reg_win.Q_r62, dat.reg_win.Q_r40, dat.con_unit.State, dat.PC_out, j);
			j = j + 1;
		end
	end

	// TEST 3
	always @ (j)
		if (j == 164) begin
			i = 352;
			while(i <= 456) begin 
				$display("Mem[%d] = %b %b %b %b", i, dat.memoria.Mem[i],dat.memoria.Mem[i+1],dat.memoria.Mem[i+2],dat.memoria.Mem[i+3]);
				i = i + 4;
			end
		end
endmodule