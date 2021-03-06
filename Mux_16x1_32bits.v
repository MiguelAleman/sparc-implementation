// MULTIPLEXER 16x1 32 Bits

module mux_16x1_32bits(output [31:0] Y, input[3:0] S, 
input[31:0] I15, I14, I13, I12, I11, I10, I9, I8, I7, I6, I5, I4, I3, I2, I1, I0);
	wire [2:0] S_2;
	assign S_2[2] = S[2];
	assign S_2[1] = S[1];
	assign S_2[0] = S[0];
	wire [31:0] A1;
	wire [31:0] A2;
	mux_8x1_32bits mux1 (A1, S_2, I7, I6, I5, I4, I3, I2, I1, I0);
	mux_8x1_32bits mux2 (A2, S_2, I15, I14, I13, I12, I11, I10, I9, I8);
	mux_2x1_32bits mux3 (Y, S[3], A2, A1);		
endmodule