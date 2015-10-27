module control_unit (output reg S, MDRE, X, PSRE, MARE, WIME, MFA, R_W, P, IRE, T, RFE, PCE, nPCE, clrnPC, TEMPE, TBRE, Z, E, G, output reg [1:0] N, D, Q, W, R, K, output reg [2:0] M, PSR_flags, tt, output reg [4:0] CWP, output reg [31:0] WIM_out, input [31:0] PSR, IR, WIM, Y, input MFC, Clk, Clr, External_Trap);	
	reg [5:0] State, NextState;
	// Trap #1, Trap #2, Trap # 3, Trap #4, Trap # 5(FLAGS)
	reg overflow, underflow, software_reg_trap, software_imm_trap, illegal_instruction;
	always @ (posedge Clk, negedge Clr, posedge External_Trap) begin
			if (!Clr) 
				begin 
					State <= 6'b000000;
				end
			else if (External_Trap == 1'b1) State <= 6'b000110;
			else if (overflow == 1'b1) State <= 6'b100010;	
			else if (underflow == 1'b1) State <= 6'b100011;	
			else if (software_reg_trap == 1'b1) State <= 6'b011110;	
			else if (software_imm_trap == 1'b1) State <= 6'b011101;	
			else if (illegal_instruction == 1'b1) State <= 6'b100100;
			else State <= NextState;
		
			// Deactivate flags
			overflow = 1'b0;
			underflow = 1'b0;
			software_reg_trap = 1'b0;
			software_imm_trap = 1'b0;
			illegal_instruction = 1'b0;
		end

		
	always @ (State, MFC)
		case (State)
		// Del estado 0 brinco al 7 para tener PC = 0, nPC = 4
		6'b000000 : NextState = 6'b000111;
		6'b000001 : NextState = 6'b000010;
		6'b000010 : if (!MFC) NextState = 6'b000010; else NextState = 6'b000011;
		6'b000011 : 
		begin
			// LOAD STORE FORMAT con RS2
			if(IR[31:30] == 2'b11 && IR[13] == 1'b0) NextState = 6'b001001;
			
			// LOAD STORE FORMAT con SIMM13
			else if(IR[31:30] == 2'b11 && IR[13] == 1'b1) NextState = 6'b001010;
			
			// Call
			else if(IR[31:30] == 2'b01) NextState = 6'b010000;
				
			// Sethi
			else if(IR[31:30] == 2'b00 && IR[24:22] == 3'b100) NextState = 6'b010101;
			
			// Branch A value 0
			else if(IR[31:30] == 2'b00 && IR[24:22] == 3'b010 && IR[29] == 1'b0)begin
				if(IR[28:25] == 4'b1000)begin
					NextState = 6'b010110;
				end
				// NOP
				else if(IR[28:25] == 4'b0000)begin
					NextState = 6'b000111;
				end
				else begin
					// Branch on not Equal
					if(IR[28:25] == 4'b1001)begin
						if(!PSR[22]) NextState = 6'b010110;
						else NextState = 6'b000111;
					end
					// Branch on Equal
					else if(IR[28:25] == 4'b0001)begin
						if(PSR[22]) NextState = 6'b010110;
						else NextState = 6'b000111;
					end
					// Branch on Greater
					else if(IR[28:25] == 4'b1010)begin
						if(!(PSR[22] || (PSR[23] ^ PSR[21]))) NextState = 6'b010110;
						else NextState = 6'b000111;
					end
					// Branch on Less or Equal
					else if(IR[28:25] == 4'b0010)begin
						if(PSR[22] || (PSR[23] ^ PSR[21])) NextState = 6'b010110;
						else NextState = 6'b000111;
					end
					// Branch on Greater or Equal
					else if(IR[28:25] == 4'b1011)begin
						if(!(PSR[23] ^ PSR[21])) NextState = 6'b010110;
						else NextState = 6'b000111;
					end
					// Branch on Less
					else if(IR[28:25] == 4'b0011)begin
						if(PSR[23] ^ PSR[21]) NextState = 6'b010110;
						else NextState = 6'b000111;
					end
					// Branch on Greater Unsigned
					else if(IR[28:25] == 4'b1100)begin
						if(!(PSR[20] || PSR[22])) NextState = 6'b010110;
						else NextState = 6'b000111;
					end
					// Branch on Less or Equal Unsigned
					else if(IR[28:25] == 4'b0100)begin
						if(PSR[20] || PSR[22]) NextState = 6'b010110;
						else NextState = 6'b000111;
					end
					// Branch on Carry Clear
					else if(IR[28:25] == 4'b1101)begin
						if(!PSR[20]) NextState = 6'b010110;
						else NextState = 6'b000111;
					end
					// Branch on Carry Set
					else if(IR[28:25] == 4'b0101)begin
						if(PSR[20]) NextState = 6'b010110;
						else NextState = 6'b000111;
					end
					// Branch on Positive
					else if(IR[28:25] == 4'b1110)begin
						if(!PSR[23]) NextState = 6'b010110;
						else NextState = 6'b000111;
					end
					// Branch on Negative
					else if(IR[28:25] == 4'b0110)begin
						if(PSR[23]) NextState = 6'b010110;
						else NextState = 6'b000111;
					end
					// Branch on Overflow Clear
					else if(IR[28:25] == 4'b1111)begin
						if(!PSR[21]) NextState = 6'b010110;
						else NextState = 6'b000111;
					end
					// Branch on Overflow Set
					else if(IR[28:25] == 4'b0111)begin
						if(PSR[21]) NextState = 6'b010110;
						else NextState = 6'b000111;
					end
					else illegal_instruction = 1'b1;
				end
			end
			
			// n,z,v,c
								
			// Branch A value 1
			else if(IR[31:30] == 2'b00 && IR[24:22] == 3'b010 && IR[29] == 1'b1)begin
				// Not conditional
				if(IR[28:25] == 4'b1000)begin
					NextState = 6'b011000;
				end
				else if(IR[28:25] == 4'b0000) begin
					NextState = 6'b010111;
				end
				else begin
					// Branch on not Equal
					if(IR[28:25] == 4'b1001)begin
						if(!PSR[22]) NextState = 6'b010110;
						else NextState = 6'b010111;
					end
					// Branch on Equal
					else if(IR[28:25] == 4'b0001)begin
						if(PSR[22]) NextState = 6'b010110;
						else NextState = 6'b010111;
					end
					// Branch on Greater
					else if(IR[28:25] == 4'b1010)begin
						if(!(PSR[22] || (PSR[23] ^ PSR[21]))) NextState = 6'b010110;
						else NextState = 6'b010111;
					end
					// Branch on Less or Equal
					else if(IR[28:25] == 4'b0010)begin
						if(PSR[22] || (PSR[23] ^ PSR[21])) NextState = 6'b010110;
						else NextState = 6'b010111;
					end
					// Branch on Greater or Equal
					else if(IR[28:25] == 4'b1011)begin
						if(!(PSR[23] ^ PSR[21])) NextState = 6'b010110;
						else NextState = 6'b010111;
					end
					// Branch on Less
					else if(IR[28:25] == 4'b0011)begin
						if(PSR[23] ^ PSR[21]) NextState = 6'b010110;
						else NextState = 6'b010111;
					end
					// Branch on Greater Unsigned
					else if(IR[28:25] == 4'b1100)begin
						if(!(PSR[20] || PSR[22])) NextState = 6'b010110;
						else NextState = 6'b010111;
					end
					// Branch on Less or Equal Unsigned
					else if(IR[28:25] == 4'b0100)begin
						if(PSR[20] || PSR[22]) NextState = 6'b010110;
						else NextState = 6'b010111;
					end
					// Branch on Carry Clear
					else if(IR[28:25] == 4'b1101)begin
						if(!PSR[20]) NextState = 6'b010110;
						else NextState = 6'b010111;
					end
					// Branch on Carry Set
					else if(IR[28:25] == 4'b0101)begin
						if(PSR[20]) NextState = 6'b010110;
						else NextState = 6'b010111;
					end
					// Branch on Positive
					else if(IR[28:25] == 4'b1110)begin
						if(!PSR[23]) NextState = 6'b010110;
						else NextState = 6'b010111;
					end
					// Branch on Negative
					else if(IR[28:25] == 4'b0110)begin
						if(PSR[23]) NextState = 6'b010110;
						else NextState = 6'b010111;
					end
					// Branch on Overflow Clear
					else if(IR[28:25] == 4'b1111)begin
						if(!PSR[21]) NextState = 6'b010110;
						else NextState = 6'b010111;
					end
					// Branch on Overflow Set
					else if(IR[28:25] == 4'b0111)begin
						if(PSR[21]) NextState = 6'b010110;
						else NextState = 6'b010111;
					end
					
					else illegal_instruction = 1'b1;
				end
			end
			
			else if(IR[31:30] == 2'b00) illegal_instruction = 1'b1;
			
			else if(IR[31:30] == 2'b10) 
			begin
				// SAVE/RESTORE
				if (IR[24:19] == 6'b111100 || IR[24:19] == 6'b111101 )begin
					// Verify if overflow or underflow occurs
					if((IR[24:19] == 6'b111100) && (WIM[(PSR[1:0] - 2'b01)] == 1'b1)) overflow = 1'b1;
					
					else if((IR[24:19] == 6'b111101) && (WIM[(PSR[1:0] + 2'b01)] == 1'b1)) underflow = 1'b1;
					
					else begin
						// No overflow or underflow occurs
						if(IR[13] == 1'b0)  NextState = 6'b011001;
						else NextState = 6'b011010;
					end
				end
			
				// TRAP
				else if(IR[24:19] == 6'b111010) begin
		
					// TRAP Always
					if(IR[28:25] == 4'b1000) begin
						if(IR[13] ==  1'b1) software_imm_trap = 1'b1;
						else software_reg_trap = 1'b1;
					end
					
					// TRAP Never
					else if(IR[28:25] == 4'b0000) begin
						NextState = 6'b000111;
					end
					
					// TRAP on Not Equal
					else if(IR[28:25] == 4'b1001) begin
						if(!PSR[22]) begin
							if(IR[13] ==  1'b1) software_imm_trap = 1'b1;
							else software_reg_trap = 1'b1;
						end
						else NextState = 6'b000111;
					end
					
					// TRAP on Equal
					else if(IR[28:25] == 4'b0001) begin
						if(PSR[22]) begin
							if(IR[13] ==  1'b1) software_imm_trap = 1'b1;
							else software_reg_trap = 1'b1;
						end
						else NextState = 6'b000111;
					end
					
					// TRAP on Greater
					else if(IR[28:25] == 4'b1010) begin
						if(!(PSR[22] || (PSR[23] ^ PSR[21]))) begin
							if(IR[13] ==  1'b1) software_imm_trap = 1'b1;
							else software_reg_trap = 1'b1;
						end
						else NextState = 6'b000111;
					end
					
					// TRAP Less or Equal
					else if(IR[28:25] == 4'b0010) begin
						if(PSR[22] || (PSR[23] ^ PSR[21])) begin
							if(IR[13] ==  1'b1) software_imm_trap = 1'b1;
							else software_reg_trap = 1'b1;
						end
						else NextState = 6'b000111;
					end
					
					// TRAP Greater or Equal
					else if(IR[28:25] == 4'b1011) begin
						if(!(PSR[23] ^ PSR[21])) begin
							if(IR[13] ==  1'b1) software_imm_trap = 1'b1;
							else software_reg_trap = 1'b1;
						end
						else NextState = 6'b000111;
					end
					
					// TRAP on Less
					else if(IR[28:25] == 4'b0011) begin
						if(PSR[23] ^ PSR[21]) begin
							if(IR[13] ==  1'b1) software_imm_trap = 1'b1;
							else software_reg_trap = 1'b1;
						end
						else NextState = 6'b000111;
					end
					
					// TRAP on Greater Unsigned
					else if(IR[28:25] == 4'b1100) begin
						if(!(PSR[20] || PSR[22])) begin
							if(IR[13] ==  1'b1) software_imm_trap = 1'b1;
							else software_reg_trap = 1'b1;
						end
						else NextState = 6'b000111;
					end
					
					// TRAP on Less or Equal Unsigned
					else if(IR[28:25] == 4'b0100) begin
						if(PSR[20] || PSR[22]) begin
							if(IR[13] ==  1'b1) software_imm_trap = 1'b1;
							else software_reg_trap = 1'b1;
						end
						else NextState = 6'b000111;
					end
					
					// TRAP on Carry Clear
					else if(IR[28:25] == 4'b1101) begin
						if(!PSR[20]) begin
							if(IR[13] ==  1'b1) software_imm_trap = 1'b1;
							else software_reg_trap = 1'b1;
						end
						else NextState = 6'b000111;
					end
					
					// TRAP on Carry Set
					else if(IR[28:25] == 4'b0101) begin
						if(PSR[20]) begin
							if(IR[13] ==  1'b1) software_imm_trap = 1'b1;
							else software_reg_trap = 1'b1;
						end
						else NextState = 6'b000111;
					end
					
					// TRAP on Positive
					else if(IR[28:25] == 4'b1110) begin
						if(!PSR[23]) begin
							if(IR[13] ==  1'b1) software_imm_trap = 1'b1;
							else software_reg_trap = 1'b1;
						end
						else NextState = 6'b000111;
					end
					
					// TRAP on Negative
					else if(IR[28:25] == 4'b0110) begin
						if(PSR[23]) begin
							if(IR[13] ==  1'b1) software_imm_trap = 1'b1;
							else software_reg_trap = 1'b1;
						end
						else NextState = 6'b000111;
					end
					
					// TRAP on Overflow Clear
					else if(IR[28:25] == 4'b1111) begin
						if(!PSR[21]) begin
							if(IR[13] ==  1'b1) software_imm_trap = 1'b1;
							else software_reg_trap = 1'b1;
						end
						else NextState = 6'b000111;
					end
					
					// TRAP on Overflow Set
					else if(IR[28:25] == 4'b0111) begin
						if(PSR[21]) begin
							if(IR[13] ==  1'b1) software_imm_trap = 1'b1;
							else software_reg_trap = 1'b1;
						end
						else NextState = 6'b000111;
					end
				end
				
					
				// RETT
				else if((IR[24:19] == 6'b111001) && (PSR[7] == 1'b1)) begin
					if((WIM & (2^(CWP + 1'b1))) ==  1'b1) underflow = 1'b1; 
					else if(IR[13] == 1'b0) NextState = 6'b101110;
					else  NextState = 6'b101111;
				end
				
				// JUMP
				else if(IR[24:19] == 6'b111000) NextState = 6'b010010;
				
				else if((IR[24:19] == 6'b000000) || (IR[24:19] == 6'b010000) || (IR[24:19] == 6'b001000)
				|| (IR[24:19] == 6'b011000) || (IR[24:19] == 6'b000100) || (IR[24:19] == 6'b010100)
				|| (IR[24:19] == 6'b001100) || (IR[24:19] == 6'b011100) || (IR[24:19] == 6'b000001)
				|| (IR[24:19] == 6'b010001) || (IR[24:19] == 6'b000101) || (IR[24:19] == 6'b010101)
				|| (IR[24:19] == 6'b000010) || (IR[24:19] == 6'b010010) || (IR[24:19] == 6'b000110)
				|| (IR[24:19] == 6'b010110) || (IR[24:19] == 6'b000011) || (IR[24:19] == 6'b010011)
				|| (IR[24:19] == 6'b000111) || (IR[24:19] == 6'b010111) || (IR[24:19] == 6'b100101)
				|| (IR[24:19] == 6'b100110) || (IR[24:19] == 6'b100111)) begin
				 
					// Aritmetico y logico con registro
					if(IR[13]== 1'b0) NextState = 6'b000100;
				
					// Aritmetico y logico con valor inmediato
					else if(IR[13]== 1'b1) NextState = 6'b000101;
				end
	
				// RDPSR
				else if((IR[24:19] == 6'b101001) && (PSR[7] == 1'b1)) begin
					NextState = 6'b100101;
				end
				
				// RDWIM
				else if((IR[24:19] == 6'b101010) && (PSR[7] == 1'b1))begin
					NextState = 6'b100110;
				end
				
				// RDTBR
				else if((IR[24:19] == 6'b101011) && (PSR[7] == 1'b1))begin
					NextState = 6'b100111;
				end
				
				// WRPSR
				else if((IR[24:19] == 6'b110001) && (PSR[7] == 1'b1))begin
					if(IR[13] == 1'b0) NextState = 6'b101000; 
					else NextState = 6'b101011;
				end
				
				// WRWIM
				else if((IR[24:19] == 6'b110010) && (PSR[7] == 1'b1))begin
					if(IR[13] == 1'b0) NextState = 6'b101001; 
					else NextState = 6'b101100; 
				end
				
				// WRTBR
				else if((IR[24:19] == 6'b110011) && (PSR[7] == 1'b1))begin
					if(IR[13] == 1'b0) NextState = 6'b101010; 
					else NextState = 6'b101101; 
				end

				else illegal_instruction = 1'b1;
				
			end
		end
		6'b000100 : NextState = 6'b000111;
		6'b000101 : NextState = 6'b000111;
		6'b000110 : NextState = 6'b011111; 
		6'b000111 : NextState = 6'b001000;
		6'b001000 : NextState = 6'b000001;
		6'b001001 : 
		begin
			// Store
			if(IR[21] == 1'b1) NextState = 6'b001011;
			// Load
			else NextState = 6'b001100;
		end
		6'b001010 :
		begin
			// Store
			if(IR[21] == 1'b1) NextState = 6'b001011;
			// Load
			else NextState = 6'b001100;
		end
		6'b001011 : NextState = 6'b001111;
		6'b001100 : 
		begin
			if(!MFC) NextState = 6'b001100;
			else NextState = 6'b001101;
		end
		6'b001101 : NextState = 6'b000111;
		//6'b001110 : NextState = 6'b000111; Not Used
		6'b001111 : 
		begin
			if(!MFC) NextState = 6'b001111;
			else NextState = 6'b000111;
		end
		6'b010000 : NextState = 6'b010001;
		6'b010001 : NextState = 6'b000001;
		6'b010010 :
		begin
			if(IR[13]) NextState = 6'b010100;
			else NextState = 6'b010011;
		end
		6'b010011 : NextState = 6'b000001;
		6'b010100 : NextState = 6'b000001;
		6'b010101 : NextState = 6'b000111;
		6'b010110 : NextState = 6'b000001;
		6'b010111 : NextState = 6'b000111;
		6'b011000 : NextState = 6'b000111;
		6'b011001 : NextState = 6'b011011;
		6'b011010 : NextState = 6'b011011;
		6'b011011 : NextState = 6'b011100;
		6'b011100 : NextState = 6'b000111;
		6'b011101 : NextState = 6'b011111;
		6'b011110 : NextState = 6'b011111;
		6'b011111 : NextState = 6'b100000;
		6'b100000 : NextState = 6'b100001;
		6'b100001 : NextState = 6'b000001;
		6'b100010 : NextState = 6'b011111;
		6'b100011 : NextState = 6'b011111;
		6'b100100 : NextState = 6'b011111;
		6'b100101 : NextState = 6'b000111;
		6'b100110 : NextState = 6'b000111;
		6'b100111 : NextState = 6'b000111;
		6'b101000 : NextState = 6'b110000;
		6'b101001 : NextState = 6'b000111;
		6'b101010 : NextState = 6'b000111;
		6'b101011 : NextState = 6'b110000;
		6'b101100 : NextState = 6'b000111;
		6'b101101 : NextState = 6'b000111;
		6'b101110 : NextState = 6'b000001;
		6'b101111 : NextState = 6'b000001;
		6'b110000 : NextState = 6'b000111;
		default : NextState = 6'b000000;
		endcase
	always @ (State, MFC)
		case (State)
		// 0
		6'b000000 : begin  clrnPC <= 1'b0; PSR_flags <= 3'b001; CWP <= 5'b00011; E <= 1'b0; G <= 1'b0; PSRE <= 1'b0;  WIME <= 1'b0; WIM_out <= 32'b0000000000000000000000000000000; dat.TBR.Q[31:7] = 25'b0000000000000000000000011; end 
		// 1
		6'b000001 : begin  PSRE <= 1'b1; PCE <= 1'b1;  nPCE <= 1'b1; M <= 3'b011; Q <= 2'b01; N <= 2'b01; MARE <= 1'b0; end
		// 2
		6'b000010 : begin  MARE<= 1'b1; P = 1'b1; R_W <= 1'b1;  MFA <= 1'b0; IRE <= 1'b0; end
		// 3
		6'b000011 : begin  MFA <= 1'b1; IRE <= 1'b1; end
		// 4
		6'b000100 : begin  T <= 1'b0; Q <= 2'b00; M <= 3'b000; N <= 2'b00;  W <= 2'b00;  K <= 2'b00; CWP <=  PSR[4:0]; PSR_flags <= PSR[7:5]; E <= 1'b0; PSRE <= 1'b0; RFE <= 1'b0; end
		// 5
		6'b000101 : begin  Q <= 2'b00; M <= 3'b001; N <= 2'b00; W <= 2'b00; K <= 2'b00;  CWP <=  PSR[4:0]; PSR_flags <= PSR[7:5]; E <= 1'b0; PSRE <= 1'b0; RFE <= 1'b0; end
		// 6
		6'b000110 : begin  D <= 2'b00; tt <= 3'b000; CWP <=  PSR[4:0] - 5'b00001; PSR_flags <= {1'b1,PSR[7],1'b0}; E <= 1'b0; PSRE <= 1'b0; TBRE <= 1'b0; end 
		// 7
		6'b000111 : begin  WIME <= 1'b1; PSRE <= 1'b1; TBRE <= 1'b1; clrnPC <= 1'b1; nPCE <= 1'b1; RFE <= 1'b1; MFA <= 1'b1; Z <= 1'b0; PCE <= 1'b0; end
		// 8
		6'b001000 : begin  PCE <= 1'b1; R <= 2'b00; nPCE <= 1'b0; end
		// 9
		6'b001001 : begin  M <= 3'b000; Q <= 2'b00; T <= 1'b0; N <= 2'b01; MARE <= 1'b0;  end
		// 10
		6'b001010 : begin  M <= 3'b001; Q <= 2'b00; N <= 2'b01; MARE <= 1'b0; end
		// 11
		6'b001011 : begin  MARE <= 1'b1; N <= 2'b01; S <= 1'b0; T <= 1'b1; Q <= 2'b01; M <= 3'b000; MDRE <= 1'b0; end
		// 12
		6'b001100 : begin  MARE <= 1'b1; P = 1'b0; MFA <= 1'b0; R_W <= 1'b1; S <= 1'b1; MDRE <= 1'b0; end
		// 13
		6'b001101 : begin  MDRE <= 1'b1; W <= 2'b00; N <= 2'b01; K <= 2'b00; RFE<= 1'b0; M <= 3'b010; Q <= 2'b01; end
		// 14
		6'b001110 : begin   end // Not Used
		// 15
		6'b001111 : begin  MDRE <= 1'b1; P = 1'b0; MFA <= 1'b0; R_W <= 1'b0; end
		// 16
		6'b010000 : begin  M <= 3'b011; Q <= 2'b01; N <= 2'b01; W <= 2'b01; K <= 2'b00; RFE <= 1'b0; end
		// 17
		6'b010001 : begin  RFE <= 1'b1; X <= 1'b0; Q <= 2'b10; R <= 2'b01; M <= 3'b011; N <= 2'b01; Z <= 1'b0; nPCE <= 1'b0; PCE <= 1'b0; end
		// 18
		6'b010010 : begin  M <= 3'b011; Q <= 2'b01; N <= 2'b01; W <= 2'b00; K <= 2'b00; RFE <= 1'b0; end
		// 19
		6'b010011 : begin  RFE <= 1'b1; T <= 1'b0; M <= 3'b000; Q <= 2'b00; N <= 2'b01; R <= 2'b01; Z <= 1'b0; nPCE <= 1'b0; PCE <= 1'b0; end
		// 20
		6'b010100 : begin  RFE <= 1'b1; M <= 3'b001; Q <= 2'b00; N <= 2'b01; R <= 2'b01; Z <= 1'b0; nPCE <= 1'b0; PCE <= 1'b0; end
		// 21
		6'b010101 : begin  M <= 3'b100; Q <= 2'b01; N <= 2'b01; W <= 2'b00; K <= 2'b00; RFE <= 1'b0; end
		// 22
		6'b010110 : begin  M <= 3'b011; Q <= 2'b10; N <= 2'b01; X <= 1'b1; R <= 2'b01;  Z <= 1'b0; nPCE <= 1'b0; PCE <= 1'b0; end
		// 23
		6'b010111 : begin  nPCE <= 1'b0; R <= 2'b00; end
		// 24
		6'b011000 : begin  M <= 3'b011; Q <= 2'b10; N <= 2'b01; X <= 1'b1; R <= 2'b01;  Z <= 1'b0; nPCE <= 1'b0; PCE <= 1'b0; end
		// 25
		6'b011001 : begin  T <= 1'b0; Q <= 2'b00; M <= 3'b000; N <= 2'b01; TEMPE <= 1'b0; end
		// 26
		6'b011010 : begin  T <= 1'b0; Q <= 2'b00; M <= 3'b001; N <= 2'b01; TEMPE <= 1'b0; end
		// 27
		6'b011011 : begin  
						TEMPE <= 1'b1; 
						E <= 1'b0;
						PSRE <= 1'b0; 
						if(IR[24:19] == 6'b111100) CWP <=  PSR[4:0] - 5'b00001;
						else if(IR[24:19] == 6'b111101) CWP <=  PSR[4:0] + 5'b00001;
					end 
		// 28
		6'b011100 : begin  PSRE <= 1'b1; W <= 2'b00; Q <= 2'b01; M <= 3'b111; N <= 2'b01; K <= 2'b00; RFE <= 1'b0; end
		// 29
		6'b011101 : begin  Q <= 2'b00; M <= 3'b101; N <= 2'b01; CWP <=  PSR[4:0] - 5'b00001; PSR_flags <= {1'b1, PSR[7], 1'b0}; D <= 2'b01; E <= 1'b0; PSRE <= 1'b0; TBRE <= 1'b0; end
		// 30
		6'b011110 : begin  T <= 1'b0; Q <= 2'b00;  M <= 3'b000; N <= 2'b01;  CWP <=  PSR[4:0] - 5'b00001; PSR_flags <= {1'b1,PSR[7],1'b0}; D <= 2'b01; E <= 1'b0; PSRE <= 1'b0; TBRE <= 1'b0; end
		// 31
		6'b011111 : begin  PSRE <= 1'b1; TBRE <= 1'b1;  W <= 2'b10;  M <= 3'b011; Q <= 2'b01; N <= 2'b01; K <= 2'b00; RFE <= 1'b0; end
		// 32
		6'b100000 : begin  W <= 2'b11; M <= 3'b110;  Q <= 2'b01; N <= 2'b01; K <= 2'b00; RFE <= 1'b0; end
		// 33
		6'b100001 : begin  RFE <= 1'b1; Z <= 1'b1;  R <= 2'b10;  PCE <= 1'b0; nPCE <= 1'b0; end
		// 34
		6'b100010 : begin  D <= 2'b00; tt <= 3'b001; CWP <=  PSR[4:0] - 5'b00001; PSR_flags <= {1'b1,PSR[7],1'b0}; E <= 1'b0; PSRE <= 1'b0; TBRE <= 1'b0; end
		// 35
		6'b100011 : begin  D <= 2'b00; tt <= 3'b010; CWP <=  PSR[4:0] - 5'b00001; PSR_flags <= {1'b1,PSR[7],1'b0}; E <= 1'b0; PSRE <= 1'b0; TBRE <= 1'b0; end
		// 36
		6'b100100 : begin  D <= 2'b00; tt <= 3'b101; CWP <=  PSR[4:0] - 5'b00001; PSR_flags <= {1'b1,PSR[7],1'b0}; E <= 1'b0; PSRE <= 1'b0; TBRE <= 1'b0; end
		// 37
		6'b100101 : begin  W <= 1'b0; K <= 2'b01; RFE <= 1'b0; end
		// 38
		6'b100110 : begin  W <= 1'b0; K <= 2'b10; RFE <= 1'b0; end
		// 39
		6'b100111 : begin  W <= 1'b0; K <= 2'b11; RFE <= 1'b0; end
		// 40
		6'b101000 : begin T = 1'b0; Q = 2'b00; M = 3'b000; N = 2'b10; E = 1'b1; end
		// 41
		6'b101001 : begin T <= 1'b0; Q <= 2'b00; M <= 3'b000; N <= 2'b10; G <= 1'b1; WIME <= 1'b0; end
		// 42
		6'b101010 : begin T <= 1'b0; Q <= 2'b00; M <= 3'b000; N <= 2'b10; D <= 2'b10; TBRE <= 1'b0;  end
		// 43
		6'b101011 : begin T = 1'b0; Q = 2'b00; M = 3'b001; N = 2'b10; E = 1'b1; end
		// 44
		6'b101100 : begin T <= 1'b0; Q <= 2'b00; M <= 3'b001; N <= 2'b10; G <= 1'b1; WIME <= 1'b0;  end
		// 45
		6'b101101 : begin T <= 1'b0; Q <= 2'b00; M <= 3'b001; N <= 2'b10; D <= 2'b10; TBRE <= 1'b0;  end
		// 46
		6'b101110 : begin T <= 1'b0; Q <= 2'b00; M <= 3'b000; N <= 2'b01; R <= 2'b01; Z <= 1'b0; E <= 1'b0; CWP <=  PSR[4:0] + 5'b00001; PSR_flags <= {PSR[6],PSR[6],1'b1}; PSRE <= 1'b0;  PCE <= 1'b0;  nPCE <= 1'b0; end
		// 47
		6'b101111 : begin T <= 1'b0; Q <= 2'b00; M <= 3'b101; N <= 2'b01; R <= 2'b01; Z <= 1'b0; E <= 1'b0; CWP <=  PSR[4:0] + 5'b00001; PSR_flags <= {PSR[6],PSR[6],1'b1}; PSRE <= 1'b0;  PCE <= 1'b0;  nPCE <= 1'b0;  end
		// 48
		6'b110000 : begin
						 if (Y[1:0] > 2'b11) illegal_instruction = 1'b1;
			   			 else PSRE = 1'b0;
		  			end
		default : begin  end
	endcase
endmodule