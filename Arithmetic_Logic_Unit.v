module arithmetic_logic_unit (output reg [31:0] Y, output reg n, z, v, c, 
input [31:0] A, B, input [5:0] S, input c_in);

always @ (S, A, B, c_in)
	begin
		//LOGIC
		case({S[3], S[2], S[1], S[0]})
			//AND, ANDcc
			4'b0001: Y = A & B;

			//ANDN, ANDNcc
			4'b0101:
			begin
				// Shift Logical Left
				if(S[5] && !S[4])
					begin
						Y = A << B[4:0];
					end
				else if((!S[5] && S[4]) || (!S[5] && !S[4])) Y = ~(A & B);
			end
		
			//OR, ORcc
			4'b0010: Y = A | B;
		
			//ORN, ORNcc
			4'b0110:
			begin
				//SHIFT RIGHT LOGICAL
				if(S[5] && !S[4])
					begin
						Y = A >> B[4:0];
					end
				else if((!S[5] && S[4]) || (!S[5] && !S[4])) Y = ~(A | B);
			end

			//XOR, XORcc
			4'b0011: Y = A ^ B;
		
			//XORN, XORNcc
			4'b0111: 
			begin
				//SHIFT RIGHT ARITHMETICAL
				if(S[5] && !S[4])
					begin
						Y = $signed(A) >>> B[4:0];
					end
				else if((!S[5] && S[4]) || (!S[5] && !S[4])) Y = ~(A ^ B);
			end
		endcase
	
		if(!S[5] && S[4])
			begin
				n <= Y[31];
				if(Y == 32'b00000000000000000000000000000000) z <= 1'b1;
				else z <= 1'b0;
				v <= 1'b0;
				c <= 1'b0;
			end
		
		// ARITHMETIC
		case({S[3],S[2],S[1],S[0]})
	
			// ADD, ADDcc
			4'b0000: 
			begin
				Y = A + B;
				if(!S[5] && S[4])
					begin
						if((A[31] && B[31] && !Y[31])||(!A[31] && !B[31] && Y[31])) v <= 1'b1;
						else v <= 1'b0;
					
						if(Y == 32'b00000000000000000000000000000000) z <= 1'b1;
						else z <= 1'b0;
					
						n <= Y[31];
					
						if((A[31] && B[31]) || (!Y[31] && (A[31] || B[31]))) c <= 1'b1;
						else c <= 1'b0;
					end
			end
		
			// ADDX, ADDXcc
			4'b1000: 
			begin
				Y = A + B + c_in;
				if(!S[5] && S[4])
					begin
						if((A[31] && B[31] && !Y[31])||(!A[31] && !B[31] && Y[31])) v <= 1'b1;
						else v <= 1'b0;
					
						if( Y == 32'b00000000000000000000000000000000) z <= 1'b1;
						else z <= 1'b0;
					
						n <= Y[31];
					
						if((A[31] && B[31]) || (!Y[31] && (A[31] || B[31]))) c <= 1'b1;
						else c <= 1'b0;
					end
			end
		
			// SUB, SUBcc
			4'b0100: 
			begin
				Y = A - B;
				if(!S[5] && S[4])
					begin
						// B[31] changes in comparison to the sum
						if((A[31] && !B[31] && !Y[31]) || (!A[31] && B[31] && Y[31])) v <= 1'b1;
						else v <= 1'b0;
					
						if( Y == 32'b00000000000000000000000000000000) z <= 1'b1;
						else z <= 1'b0;
					
						n <= Y[31];
					
						// A[31] and Y[31] changes in comparison to the sum
						if((!A[31] && B[31]) || (Y[31] && (!A[31] || B[31]))) c <= 1'b1;
						else c <= 1'b0;
					end
			end
		
			// SUBX, SUBXcc
			4'b1100: 
			begin
				Y = A - B - c_in;
				if(!S[5] && S[4])
					begin
						// B[31] changes in comparison to the sum
						if((A[31] && !B[31] && !Y[31]) || (!A[31] && B[31] && Y[31])) v <= 1'b1;
						else v <= 1'b0;
					
						if( Y == 32'b00000000000000000000000000000000) z <= 1'b1;
						else z <= 1'b0;
					
						n <= Y[31];
					
						// A[31] and Y[31] changes in comparison to the sum
						if((!A[31] && B[31]) || (Y[31] && (!A[31] || B[31]))) c <= 1'b1;
						else c <= 1'b0;
					end
			end		
		endcase
	end
endmodule