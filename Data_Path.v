// MULTIPLEXER 4x1 32 Bits

module data_path(input Clr, Clk, External_Trap);
	
	// Register Windows inputs
	reg [4:0] A_reg, B_reg, C_reg, CWP;
	reg [31:0] data;
	reg RFE;
	
	// Register Windows outputs
	wire [31:0] r_b, r_c;
	
	// Register Windows
	register_windows reg_win (r_b, r_c, A_reg, B_reg, C_reg, CWP, data, Clk, RFE);
	
	// ALU Inputs
	reg [31:0] A_alu, B_alu;
	reg [5:0] S_alu;
	reg c_in;
	
	// ALU Outputs
	wire [31:0] Y;
	wire n, z, v, c;

	// ALU
	arithmetic_logic_unit alu (Y, n, z, v, c, A_alu, B_alu, S_alu, c_in);
	
	initial begin
		alu.n = 1'b0;
		alu.z = 1'b0;
		alu.v = 1'b0;
		alu.c = 1'b0;
	end
	
	// Memory Inputs
	reg [31:0] DataIn;
	reg [8:0] Address;
	reg [5:0] S_memory;
	reg MFA, ReadWrite;
	
	// Memory Outputs
	wire [31:0] DataOut;
	wire MFC; // DONE
	
	// Memory
	memoria_ram_512x8 memoria (DataOut, MFC, MFA, ReadWrite, S_memory, Address, DataIn);	
	
	// Register PC inputs
	reg PCE;
	reg [31:0] PC_in;
	supply1 Vcc;
	
	// Register PC outputs
	wire [31:0] PC_out, PC_out_neg;
	
	// Register PC
	register_32bits PC (PC_out, PC_out_neg, PC_in, Vcc, Clk, PCE);
	
	// Register nPC inputs
	reg nPCE, clrnPC; 
	reg [31:0] nPC_in;
	
	// Register nPC outputs
	wire [31:0] nPC_out, nPC_out_neg;
	
	// Register nPC 
	register_32bits nPC(nPC_out, nPC_out_neg, nPC_in, clrnPC, Clk, nPCE);
	
	// Register MDR inputs
	reg MDRE;
	reg [31:0] MDR_in;
	
	// Register MDR outputs
	wire [31:0] MDR_out, MDR_out_neg;

	// Register MDR
	register_32bits MDR(MDR_out, MDR_out_neg, MDR_in, Vcc, Clk, MDRE);
	
	// Assign output of ALU to input of Register Windows, MAR,...
	always @ (MDR_out) begin
   		DataIn = MDR_out;
	end 

	// Register MAR inputs
	reg MARE;
	reg [31:0] MAR_in;
	
	// Register MAR outputs
	wire [31:0] MAR_out, MAR_out_neg;
	
	// Register MAR
	register_32bits MAR(MAR_out, MAR_out_neg, MAR_in, Vcc, Clk, MARE);
	
	// Assign Y to MAR_in, Assign MAR_out to Address
	always @ (*) begin
   		 MAR_in = Y;
   		 Address = MAR_out[8:0];
	end 
	
	// Register IR inputs
	reg IRE;
	reg [31:0] IR_in;
	
	// Register IR outputs
	wire [31:0] IR_out, IR_out_neg;
	
	// Register IR 
	register_32bits IR(IR_out, IR_out_neg, IR_in, Vcc, Clk, IRE);
	
	// Assign DataOut to IR_in, Assign MAR_out to Address
	always @ (*) begin
   		IR_in = DataOut;
		B_reg = IR_out[18:14];
	end 

	// Register PSR inputs
	reg PSRE;
	reg [31:0] PSR_in;
	
	// Register PSR outputs
	wire [31:0] PSR_out, PSR_out_neg;
	
	// PSR_implementation (impl) [31:28]
	// PSR_version (ver) [27:24]
	// PSR_integer_cond_codes (icc) [23:20]
	// 		PSR_negative (n) [23]
	// 		PSR_zero (z) [22]
	// 		PSR_overflow (v) [21]
	// 		PSR_carry (c) [20]
	// PSR_reserved [19:14]
	// PSR_enable_coprocesor (EC) [13]
	// PSR_enable_floating-point (EF) [12]
	// PSR_proc_interrupt_level (PIL) [11:8]
	// PSR_supervisor (S) [7]
	// PSR_previous_supervisor (PS) [6]
	// PSR_enable_traps (ET) [5]
	// PSR_current_window_pointer (CWP) [4:0]
	
	// Register PSR
	register_32bits PSR(PSR_out, PSR_out_neg, PSR_in, Vcc, Clk, PSRE);
	
	always @ (*) begin
		CWP = PSR_out[4:0];
	end 
	
	// Shifter Left inputs
	reg [31:0] shift_in_a, shift_in_b;
	reg [5:0] S_shift;
	reg c_in_shift;
	
	initial begin
		S_shift = 6'b100101;
	    shift_in_b = 32'b00000000000000000000000000000010;
	end 
	
	// Shifter Left outputs
	wire [31:0] shift_out;
	// Dummy cables
	wire n_shift, z_shift, v_shift, c_shift;
	
	// Shifter Left
	arithmetic_logic_unit shifter (shift_out, n_shift, z_shift, v_shift, c_shift, shift_in_a, shift_in_b, S_shift, c_in_shift);
	
	// Four Adder inputs
	reg [31:0] four_adder_in_a, four_adder_in_b;
	reg [5:0] S_four_adder;
	reg c_in_four_adder;
	initial begin
		S_four_adder = 6'b000000;
		four_adder_in_b = 32'b00000000000000000000000000000100;
	end 
	
	// Four Adder outputs
	wire [31:0] four_adder_out;
	// Dummy cables
	wire n_four_adder, z_four_adder, v_four_adder, c_four_adder;
	
	// Four Adder
	arithmetic_logic_unit four_adder (four_adder_out, n_four_adder, z_four_adder, v_four_adder, c_four_adder, four_adder_in_a, four_adder_in_b, S_four_adder, c_in_four_adder);
	
	// Assign
	always @ (*) begin
		four_adder_in_a = nPC_out;
	end 
	
	// Sign Extension inputs
	reg S_sign_ext;
	reg [31:0] I1_sign_ext, I0_sign_ext;
	initial begin
		S_sign_ext = 1'b0;
		// Dummy
		I1_sign_ext = 32'b00000000000000000000000000000000;
	end 
	
	// Sign Extension outputs
	wire [31:0] sign_ext_out;
	
	// Sign Extension
	mux_2x1_32bits sign_ext (sign_ext_out, S_sign_ext, I1_sign_ext, I0_sign_ext);
	
	// Assign
	always @* begin
		// simm13
		I0_sign_ext[12:0] = IR_out[12:0];
		I0_sign_ext[31:13] = {IR_out[12], IR_out[12], IR_out[12], IR_out[12], IR_out[12], IR_out[12], IR_out[12], IR_out[12], IR_out[12], IR_out[12], IR_out[12], IR_out[12], IR_out[12], IR_out[12], IR_out[12], IR_out[12], IR_out[12], IR_out[12], IR_out[12]};
	end 

	// mux4x1_1 inputs
	reg [1:0] S_mux4x1_1;
	reg [31:0] I3_mux4x1_1, I2_mux4x1_1, I1_mux4x1_1, I0_mux4x1_1;
	initial begin
		I1_mux4x1_1 = 32'b00000000000000000000000000001111;
		I2_mux4x1_1 = 32'b00000000000000000000000000010001;
		I3_mux4x1_1 = 32'b00000000000000000000000000010010;
	end 

	// mux2x1_1 outputs
	wire [31:0] mux4x1_1_out;
	
	// mux2x1_1 
	mux_4x1_32bits mux4x1_1 (mux4x1_1_out, S_mux4x1_1, I3_mux4x1_1, I2_mux4x1_1, I1_mux4x1_1, I0_mux4x1_1);
	
	// Assign
	always @ (*) begin
		I0_mux4x1_1[4:0] = IR_out[29:25];
		A_reg = mux4x1_1_out[4:0];
	end 
	initial begin
		I0_mux4x1_1[31:5] = 27'b000000000000000000000000000;
	end
	
	// mux2x1_2 inputs
	reg S_mux2x1_2;
	reg [31:0] I1_mux2x1_2, I0_mux2x1_2;
	
	// mux2x1_2 outputs
	wire [31:0] mux2x1_2_out;
	
	// mux2x1_2 
	mux_2x1_32bits mux2x1_2 (mux2x1_2_out, S_mux2x1_2, I1_mux2x1_2, I0_mux2x1_2);
	
	// Assign
	always @ (*) begin
		I0_mux2x1_2[4:0] = IR_out[4:0];
		I1_mux2x1_2[4:0] = IR_out[29:25];
		C_reg = mux2x1_2_out[4:0];
	end
	
	initial begin
		I0_mux2x1_2[31:5] = 27'b000000000000000000000000000;
		I1_mux2x1_2[31:5] = 27'b000000000000000000000000000;
	end 

	// mux4x1_3 inputs
	reg [1:0] S_mux4x1_3;
	reg [31:0] I3_mux4x1_3, I2_mux4x1_3, I1_mux4x1_3, I0_mux4x1_3;
	initial begin
		I1_mux4x1_3 = 32'b00000000000000000000000000000000;
		I2_mux4x1_3 = 32'b00000000000000000000000000000011;
		I3_mux4x1_3 = 32'b00000000000000000000000000000000;
	end 
	
	// mux4x1_3 outputs
	wire [31:0] mux4x1_3_out;
	
	// mux2x1_3 
	mux_4x1_32bits mux4x1_3 (mux4x1_3_out, S_mux4x1_3, I3_mux4x1_3, I2_mux4x1_3, I1_mux4x1_3, I0_mux4x1_3);
	
	// Assign
	always @ (*) begin
		I0_mux4x1_3[5:0] = IR_out[24:19];
		S_alu = mux4x1_3_out[5:0];
	end 
	
	initial begin
		I0_mux4x1_3[31:6] = 26'b00000000000000000000000000;
	end

	// mux2x1_4 inputs
	reg S_mux2x1_4;
	reg [31:0] I1_mux2x1_4, I0_mux2x1_4;
	
	// mux2x1_4 outputs
	wire [31:0] mux2x1_4_out;
	
	// mux2x1_4 
	mux_2x1_32bits mux2x1_4 (mux2x1_4_out, S_mux2x1_4, I1_mux2x1_4, I0_mux2x1_4);
	
	// Assign
	always @ (*) begin
		I0_mux2x1_4 = Y;
		I1_mux2x1_4 = DataOut;
		MDR_in = mux2x1_4_out;
	end 
	
	// mux4x1_5 inputs
	reg [1:0] S_mux4x1_5;
	reg [31:0]  I3_mux4x1_5,  I2_mux4x1_5, I1_mux4x1_5, I0_mux4x1_5;
	
	// mux4x1_5 outputs
	wire [31:0] mux4x1_5_out;
	
	// mux4x1_5 
	mux_4x1_32bits mux4x1_5 (mux4x1_5_out, S_mux4x1_5, I3_mux4x1_5, I2_mux4x1_5, I1_mux4x1_5, I0_mux4x1_5);
	
	// Assign
	always @ (*) begin
		I0_mux4x1_5 = four_adder_out;
		I1_mux4x1_5 = Y;
		nPC_in = mux4x1_5_out;
	end
	
	initial begin
		I3_mux4x1_5 = 32'b00000000000000000000000000000000;
	end 
	
	// mux2x1_6 inputs
	reg S_mux2x1_6;
	reg [31:0] I1_mux2x1_6, I0_mux2x1_6;
	
	// mux2x1_6 outputs
	wire [31:0] mux2x1_6_out;
	
	// mux2x1_6 
	mux_2x1_32bits mux2x1_6 (mux2x1_6_out, S_mux2x1_6, I1_mux2x1_6, I0_mux2x1_6);
	
	// Assign 
	always @ (*) begin
		I0_mux2x1_6[5:0] = IR_out[24:19];
		S_memory = mux2x1_6_out[5:0];
	end
	
	initial begin 
		I0_mux2x1_6[31:6] = 26'b00000000000000000000000000;
		I1_mux2x1_6 = 32'b00000000000000000000000000000000;
	end
	
	// mux2x1_7 inputs
	reg S_mux2x1_7;
	reg [31:0] I1_mux2x1_7, I0_mux2x1_7;
	
	// mux2x1_7 outputs
	wire [31:0] mux2x1_7_out;
		
	// mux2x1_7 
	mux_2x1_32bits mux2x1_7 (mux2x1_7_out, S_mux2x1_7, I1_mux2x1_7, I0_mux2x1_7);
	
	// Assign
	always @ (*) begin
		I0_mux2x1_7[29:0] = IR_out[29:0];
		I0_mux2x1_7[31:30] = {IR_out[29], IR_out[29]};
		I1_mux2x1_7[21:0] = IR_out[21:0];
		I1_mux2x1_7[31:22] = {IR_out[21], IR_out[21], IR_out[21], IR_out[21], IR_out[21], IR_out[21], IR_out[21], IR_out[21], IR_out[21], IR_out[21]};
		shift_in_a = mux2x1_7_out;
	end
	
	// Multiplexer 4x1_8 inputs
	reg [1:0] S_mux4x1_8;
	reg [31:0] I3_mux4x1_8, I2_mux4x1_8, I1_mux4x1_8, I0_mux4x1_8;
	
	initial begin
		I3_mux4x1_8 = 32'b00000000000000000000000000000000;
	end
	
	// Multiplexer 4x1_8 outputs
	wire [31:0] mux4x1_8_out;
	
	// Multiplexer 4x1_8
	mux_4x1_32bits mux4x1_8 (mux4x1_8_out, S_mux4x1_8, I3_mux4x1_8, I2_mux4x1_8, I1_mux4x1_8, I0_mux4x1_8);
	
	// Assign
	always @ (*) begin
		I0_mux4x1_8 =  r_b;
		I2_mux4x1_8 = shift_out;
		A_alu = mux4x1_8_out;
	end
	
	initial begin
		I1_mux4x1_8 = 32'b00000000000000000000000000000000;
	end

	// Multiplexer 8x1_9 inputs
	reg [2:0] S_mux8x1_9;
	reg [31:0] I7_mux8x1_9, I6_mux8x1_9, I5_mux8x1_9, I4_mux8x1_9, I3_mux8x1_9, I2_mux8x1_9, I1_mux8x1_9, I0_mux8x1_9;
	
	// Multiplexer 8x1_9 outputs
	wire [31:0] mux8x1_9_out;
	
	// Multiplexer 8x1_9
	mux_8x1_32bits mux8x1_9 (mux8x1_9_out, S_mux8x1_9, I7_mux8x1_9, I6_mux8x1_9, I5_mux8x1_9, I4_mux8x1_9, I3_mux8x1_9, I2_mux8x1_9, I1_mux8x1_9, I0_mux8x1_9);
	
	// Assign
	always @ (*) begin
		I0_mux8x1_9 = r_c;
		I1_mux8x1_9 = sign_ext_out;
		I2_mux8x1_9 = MDR_out;
		I3_mux8x1_9 = PC_out;
		I4_mux8x1_9[31:10] =  IR_out[21:0];
		I6_mux8x1_9 = nPC_out;
		B_alu = mux8x1_9_out;
	end
	
	initial begin
		I4_mux8x1_9[9:0] = 10'b0000000000;
	end


	///////////////////////NEW CODE //////////////////////////
	// Register TBR inputs
	reg TBRE;
	reg [31:0] TBR_in;
	
	// Register TBR outputs
	wire [31:0] TBR_out, TBR_out_neg;

	// Register TBR
	register_32bits TBR(TBR_out, TBR_out_neg, TBR_in, Vcc, Clk, TBRE);
	
	// Register WIM inputs
	reg WIME;
	reg [31:0] WIM_in;
	
	// Register WIM outputs
	wire [31:0] WIM_out, WIM_out_neg;

	// Register WIM
	register_32bits WIM(WIM_out, WIM_out_neg, WIM_in, Vcc, Clk, WIME);
	
	// Register TEMP inputs
	reg TEMPE;
	reg [31:0] TEMP_in;
	
	// Register TEMP outputs
	wire [31:0] TEMP_out, TEMP_out_neg;

	// Register TEMP
	register_32bits TEMP(TEMP_out, TEMP_out_neg, TEMP_in, Vcc, Clk, TEMPE);

	always @ (*) begin
		TEMP_in = Y;
		I7_mux8x1_9 = TEMP_out;
	end
	
	// TBR 4 Adder inputs
	reg [31:0] TBR_4_adder_in_a, TBR_4_adder_in_b;
	reg [5:0] S_TBR_4_adder;
	reg c_in_TBR_4_adder;
	initial begin
		S_TBR_4_adder = 6'b000000;
		TBR_4_adder_in_b = 32'b00000000000000000000000000000100;
	end 
	
	// TBR 4 Adder outputs
	wire [31:0] TBR_4_adder_out;
	// Dummy cables
	wire n_TBR_4_adder, z_TBR_4_adder, v_TBR_4_adder, c_TBR_4_adder;
	
	// TBR 4 Adder
	arithmetic_logic_unit TBR_4_adder (TBR_4_adder_out, n_TBR_4_adder, z_TBR_4_adder, v_TBR_4_adder, c_TBR_4_adder, TBR_4_adder_in_a, TBR_4_adder_in_b, S_TBR_4_adder, c_in_TBR_4_adder);

	always @ (*) begin
		TBR_4_adder_in_a = TBR_out;
		I2_mux4x1_5 = TBR_4_adder_out;
	end
	
	// mux2x1_10 inputs
	reg S_mux2x1_10;
	reg [31:0] I1_mux2x1_10, I0_mux2x1_10;
	
	// mux2x1_10 outputs
	wire [31:0] mux2x1_10_out;
	
	// mux2x1_10 
	mux_2x1_32bits mux2x1_10 (mux2x1_10_out, S_mux2x1_10, I1_mux2x1_10, I0_mux2x1_10);
	
	// Assign 
	always @ (*) begin
		I0_mux2x1_10 = nPC_out;
		I1_mux2x1_10 = TBR_out;
		PC_in = mux2x1_10_out;
	end
	
	// Sign Extension 7 bits inputs
	reg S_sign_ext_seven;
	reg [31:0] I1_sign_ext_seven, I0_sign_ext_seven;
	initial begin
		S_sign_ext_seven = 1'b0;
		// Dummy
		I1_sign_ext_seven = 32'b00000000000000000000000000000000;
	end 
	
	// Sign Extension 7 bits outputs
	wire [31:0] sign_ext_seven_out;
	
	// Sign Extension 7 bits
	mux_2x1_32bits sign_ext_seven (sign_ext_seven_out, S_sign_ext_seven, I1_sign_ext_seven, I0_sign_ext_seven);
	
	// Assign
	always @* begin
		I0_sign_ext_seven[6:0] = IR_out[6:0];
		I0_sign_ext_seven[31:7] = {IR_out[12], IR_out[12], IR_out[12], IR_out[12], IR_out[12], IR_out[12], IR_out[12], IR_out[12], IR_out[12], IR_out[12], IR_out[12], IR_out[12], IR_out[12], IR_out[12], IR_out[12], IR_out[12], IR_out[12], IR_out[12], IR_out[12], IR_out[12], IR_out[12], IR_out[12], IR_out[12], IR_out[12], IR_out[12]};
		I5_mux8x1_9 = sign_ext_seven_out;
	end 
	
	
	// mux4x1_11 inputs
	reg [1:0] S_mux4x1_11;
	reg [31:0] I3_mux4x1_11, I2_mux4x1_11, I1_mux4x1_11, I0_mux4x1_11;
	
	// mux4x1_11 outputs
	wire [31:0] mux4x1_11_out;
	
	// mux2x1_11 
	mux_4x1_32bits mux4x1_11 (mux4x1_11_out, S_mux4x1_11, I3_mux4x1_11, I2_mux4x1_11, I1_mux4x1_11, I0_mux4x1_11);
	
	// Assign 
	always @ (*) begin
		I1_mux4x1_11[6:4] = Y[2:0];
		I0_mux4x1_11[31:7] = TBR_out[31:7];
		I1_mux4x1_11[31:7] = TBR_out[31:7];
		I2_mux4x1_11[31:7] = Y[31:7];
		I2_mux4x1_11[6:4] = TBR_out[6:4];
		TBR_in = mux4x1_11_out;
	end
	
	initial begin 
		I0_mux4x1_11[3:0] = 4'b0000;
		I1_mux4x1_11[3:0] = 4'b0000;
		I2_mux4x1_11[3:0] = 4'b0000;
		I3_mux4x1_11[3:0] = 32'b00000000000000000000000000000000;
	end
	
	// mux4x1_12 inputs
	reg [1:0] S_mux4x1_12;
	reg [31:0] I3_mux4x1_12, I2_mux4x1_12, I1_mux4x1_12, I0_mux4x1_12;
	
	// mux4x1_12 outputs
	wire [31:0] mux4x1_12_out;
	
	// mux4x1_12 
	mux_4x1_32bits mux4x1_12 (mux4x1_12_out, S_mux4x1_12, I3_mux4x1_12, I2_mux4x1_12, I1_mux4x1_12, I0_mux4x1_12);
	
	// Assign 
	always @ (*) begin
		I0_mux4x1_12 = Y;
		I1_mux4x1_12 = PSR_out;
		I2_mux4x1_12 = WIM_out;
		I3_mux4x1_12 = TBR_out;
		data = mux4x1_12_out;
	end
	
	// mux2x1_13 inputs
	reg S_mux2x1_13;
	reg [31:0] I1_mux2x1_13, I0_mux2x1_13;
	
	// mux2x1_13 outputs
	wire [31:0] mux2x1_13_out;
	
	// mux2x1_13 
	mux_2x1_32bits mux2x1_13 (mux2x1_13_out, S_mux2x1_13, I1_mux2x1_13, I0_mux2x1_13);
	
	// Assign 
	always @ (*) begin
		// n,z,v,c
		I0_mux2x1_13[23:20] = {n,z,v,c};
		I1_mux2x1_13 = Y;
		PSR_in = mux2x1_13_out;
	end
	
	initial begin
		I0_mux2x1_13[19:8] = 12'b000000000000;
		I0_mux2x1_13[31:24] = 8'b00000000;
	end
	
	// mux2x1_14 inputs
	reg S_mux2x1_14;
	reg [31:0] I1_mux2x1_14, I0_mux2x1_14;
	
	// mux2x1_14 outputs
	wire [31:0] mux2x1_14_out;
	
	// mux2x1_14 
	mux_2x1_32bits mux2x1_14 (mux2x1_14_out, S_mux2x1_14, I1_mux2x1_14, I0_mux2x1_14);
	
	// Assign 
	always @ (*) begin
		I1_mux2x1_14 = Y;
		WIM_in = mux2x1_14_out;
	end
	
	/////////////////////////////////////////////////////////
	
	// Control Unit inputs
	reg [31:0] PSR_cu, IR_cu, WIM_cu, Y_cu;
	reg MFC_cu;
	
	// Control Unit outputs
	wire  S_cu, MDRE_cu, X_cu, PSRE_cu, MARE_cu, WIME_cu, MFA_cu, R_W_cu, P_cu, IRE_cu, T_cu, RFE_cu, PCE_cu, nPCE_cu, clrnPC_cu, TEMPE_cu, TBRE_cu, Z_cu, E_cu, G_cu; 
	wire [1:0] N_cu, Q_cu, W_cu, R_cu, K_cu, D_cu;
	wire [2:0] M_cu, PSR_flags_cu, tt_cu;  
	wire [4:0] CWP_cu;
	wire [31:0] WIM_out_cu; 
	
	// Control Unit
	control_unit con_unit (S_cu, MDRE_cu, X_cu, PSRE_cu, MARE_cu, WIME_cu, MFA_cu, R_W_cu, P_cu, IRE_cu, T_cu, RFE_cu, PCE_cu, nPCE_cu, clrnPC_cu, TEMPE_cu, TBRE_cu, Z_cu, E_cu, G_cu, N_cu, D_cu, Q_cu, W_cu, R_cu, K_cu, M_cu, PSR_flags_cu, tt_cu, CWP_cu, WIM_out_cu, PSR_cu, IR_cu, WIM_cu, Y_cu, MFC_cu, Clk, Clr, External_Trap);
	
	// Assign
	always @ (*) begin
		S_mux4x1_3 = N_cu;
		S_mux2x1_4 = S_cu;
		MDRE = MDRE_cu;
		S_mux2x1_7 = X_cu;
		PSRE = PSRE_cu;
		MARE = MARE_cu;
		MFA = MFA_cu;
		ReadWrite = R_W_cu;
		S_mux2x1_6 = P_cu;
		IRE = IRE_cu;
		S_mux2x1_2 = T_cu;
		RFE = RFE_cu;
		S_mux4x1_1 = W_cu;
		PCE = PCE_cu;
		S_mux4x1_5 = R_cu;
		nPCE = nPCE_cu;
		clrnPC = clrnPC_cu;
		S_mux4x1_8 = Q_cu;
		S_mux8x1_9 = M_cu;
		TEMPE = TEMPE_cu;
		TBRE = TBRE_cu;
		S_mux2x1_10 = Z_cu;
		I0_mux2x1_13[4:0] = CWP_cu;
		I0_mux2x1_13[7:5] = PSR_flags_cu;
		I0_mux4x1_11[6:4] = tt_cu;
		S_mux4x1_11 = D_cu;
		S_mux2x1_13 = E_cu;
		WIME = WIME_cu;
		I0_mux2x1_14 = WIM_out_cu;
		S_mux2x1_14 = G_cu;
		S_mux4x1_12 = K_cu;
		
		// Control Unit inputs
		PSR_cu = PSR_out;
		IR_cu = IR_out;
		WIM_cu = WIM_out;
		MFC_cu = MFC;
		Y_cu = Y;
	end
endmodule