// MULTIPLEXER 2x1 32 Bits

module mux_2x1_32bits(output reg [31:0] Y, input S, input [31:0] I1, I0);
	always @ (S, I1, I0)
		if(S) Y = I1;
		else Y = I0;
endmodule