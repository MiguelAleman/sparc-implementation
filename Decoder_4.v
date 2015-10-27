module decoder_4(output reg [3:0] Y, input [1:0] S, input enable);
	always @ (S, enable)
		begin		
			if(!enable)
				case(S)
					2'b00: Y = 4'b1110;
					2'b01: Y = 4'b1101;
					2'b10: Y = 4'b1011;
					2'b11: Y = 4'b0111;
				endcase
			else
				Y = 4'b1111;
		end
endmodule