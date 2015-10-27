module memoria_ram_512x8(output reg[31:0] DataOut, output reg Done, input Enable, ReadWrite, input [5:0] S, input [8:0] Address, input [31:0] DataIn);
reg [7:0] Mem [0:511]; //512 localizaciones de 8 bits
always @ (Enable, ReadWrite, S)
begin
	if(!Enable)
	begin
		Done = 1'b0;
	
		// Transaccion de read
		if(ReadWrite)
		begin
			case(S)
			
				// LOAD SIGNED BYTE
				6'b001001:
				begin
					DataOut[31:8] = {Mem[Address][7], 
					Mem[Address][7], Mem[Address][7], Mem[Address][7], Mem[Address][7], Mem[Address][7], 
					Mem[Address][7], Mem[Address][7], Mem[Address][7], Mem[Address][7], Mem[Address][7], Mem[Address][7], 
					Mem[Address][7], Mem[Address][7], Mem[Address][7], Mem[Address][7], Mem[Address][7], Mem[Address][7],
					Mem[Address][7], Mem[Address][7], Mem[Address][7], Mem[Address][7], Mem[Address][7], Mem[Address][7]};
					DataOut[7:0] = Mem[Address][7:0];
					#20;
				end
				
				// LOAD UNSIGNED BYTE				
				6'b000001:
				begin
					DataOut[31:8] = 24'b000000000000000000000000;
					DataOut[7:0] = Mem[Address][7:0];
					#20;
				end
				
				// LOAD SIGNED HALF-WORD
				6'b001010:
				begin
					DataOut[31:16] = {Mem[Address][7], 
					Mem[Address][7], Mem[Address][7], Mem[Address][7], Mem[Address][7], Mem[Address][7], Mem[Address][7], 
					Mem[Address][7], Mem[Address][7], Mem[Address][7], Mem[Address][7], Mem[Address][7], Mem[Address][7], 
					Mem[Address][7], Mem[Address][7], Mem[Address][7]};
					DataOut[15:8] = Mem[Address][7:0];
					DataOut[7:0] = Mem[Address + 8'b00000001][7:0];
					#40;
				end
				
				// LOAD UNSIGNED HALF-WORD
				6'b000010:
				begin
					DataOut[31:16] = 16'b0000000000000000;
					DataOut[15:8] = Mem[Address][7:0];
					DataOut[7:0] = Mem[Address + 8'b00000001][7:0];
					#40;
				end
				
				// LOAD WORD
				6'b000000:
				begin
					DataOut[31:24] = Mem[Address + 8'b00000000][7:0];
					DataOut[23:16] = Mem[Address + 8'b00000001][7:0];
					DataOut[15:8] = Mem[Address + 8'b00000010][7:0];
					DataOut[7:0] = Mem[Address + 8'b00000011][7:0];
					#80;
				end
			endcase
			Done = 1'b1;
		end
		
		// Write (BIG ENDIAN)
		else 
		begin
			case(S)
				// STORE BYTE
				6'b000101:
				begin
					Mem[Address]= DataIn[7:0];
					#20;
				end
				
				// STORE HALF-WORD
				6'b000110:
				begin
					Mem[Address]= DataIn[15:8];
					Mem[Address + 8'b00000001]= DataIn[7:0];
					#40;
				end
				
				// STORE WORD
				6'b000100:
				begin
					Mem[Address]= DataIn[31:24];
					Mem[Address + 8'b00000001]= DataIn[23:16];
					Mem[Address + 8'b00000010]= DataIn[15:8];
					Mem[Address + 8'b00000011]= DataIn[7:0];
					#80;
				end
			endcase
			Done = 1'b1;
		end
	end
		else DataOut = 32'bz; //alta impedancia en la salida
end
endmodule
