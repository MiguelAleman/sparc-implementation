// REGISTER 32 Bits

module register_32bits(output reg [31:0] Q, output [31:0] Q_n, input [31:0] D, input Clr, Clk, Enable);
	assign Q_n = ~Q;
	initial begin
		Q <= 32'b00000000000000000000000000000000;
	end
	always @ (posedge Clk, negedge Clr)
		 if(!Clr) Q <= 32'b00000000000000000000000000000000;
		 else if(!Enable) Q <= D;
endmodule
