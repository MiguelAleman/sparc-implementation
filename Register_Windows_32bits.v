module register_windows(output [31:0] r_b, r_c, input [4:0] A, B, C, CWP, input [31:0] data, input Clk, RFE);
		// Cables to connect to the multiplexers [31:8]
		wire [31:0] r_mux_out [31:8];

		wire [3:0] dec3_enable;
	
		//Decoder 3 Write
		decoder_4 dec(dec3_enable, CWP[1:0], RFE);
	
		wire [31:0] decs_out1;
		wire [31:0] decs_out2;
		wire [31:0] decs_out3;
		wire [31:0] decs_out4;
	
		decoder_32 dec_1(decs_out1, A, dec3_enable[3]);
		decoder_32 dec_2(decs_out2, A, dec3_enable[2]);
		decoder_32 dec_3(decs_out3, A, dec3_enable[1]);
		decoder_32 dec_4(decs_out4, A, dec3_enable[0]);
	
		wire en_and0, en_and1, en_and2, en_and3, en_and4, en_and5, en_and6, en_and7;
		
		and and0(en_and0, decs_out1[0], decs_out2[0], decs_out3[0], decs_out4[0]);
		and and1(en_and1, decs_out1[1], decs_out2[1], decs_out3[1], decs_out4[1]);
		and and2(en_and2, decs_out1[2], decs_out2[2], decs_out3[2], decs_out4[2]);
		and and3(en_and3, decs_out1[3], decs_out2[3], decs_out3[3], decs_out4[3]);
		and and4(en_and4, decs_out1[4], decs_out2[4], decs_out3[4], decs_out4[4]);
		and and5(en_and5, decs_out1[5], decs_out2[5], decs_out3[5], decs_out4[5]);
		and and6(en_and6, decs_out1[6], decs_out2[6], decs_out3[6], decs_out4[6]);
		and and7(en_and7, decs_out1[7], decs_out2[7], decs_out3[7], decs_out4[7]);
	
		supply1 Vcc;
	
		// REGISTROS GLOBALES 
	
		// Register 0 contains the value 0	
		
		wire [31:0] Q_r0, Q_nr0; 
		register_32bits r0 (Q_r0, Q_nr0, 32'b00000000000000000000000000000000, Vcc, Clk, en_and0);
		initial begin
			r0.Q = 32'b00000000000000000000000000000000;
		end
		
		wire [31:0] Q_r1, Q_nr1;
		register_32bits r1 (Q_r1, Q_nr1, data, Vcc, Clk, en_and1);
	
		wire [31:0] Q_r2, Q_nr2;
		register_32bits r2 (Q_r2, Q_nr2, data, Vcc, Clk, en_and2);
	
		wire [31:0] Q_r3, Q_nr3;
		register_32bits r3 (Q_r3, Q_nr3, data, Vcc, Clk, en_and3);
	
		wire [31:0] Q_r4, Q_nr4;
		register_32bits r4 (Q_r4, Q_nr4, data, Vcc, Clk, en_and4);
	
		wire [31:0] Q_r5, Q_nr5;
		register_32bits r5 (Q_r5, Q_nr5, data, Vcc, Clk, en_and5);
	
		wire [31:0] Q_r6, Q_nr6;
		register_32bits r6 (Q_r6, Q_nr6, data, Vcc, Clk, en_and6);

		wire [31:0] Q_r7, Q_nr7;
		register_32bits r7 (Q_r7, Q_nr7, data, Vcc, Clk, en_and7);

		// REGISTROS COMPARTIDOS ENTRE WINDOWS UNO Y WINDOWS CUATRO
		
		wire en_and8, en_and9, en_and10, en_and11, en_and12, en_and13, en_and14, en_and15;
		
		and and8(en_and8, decs_out4[8], decs_out1[24]);
		and and9(en_and9, decs_out4[9], decs_out1[25]);
		and and10(en_and10, decs_out4[10], decs_out1[26]);
		and and11(en_and11, decs_out4[11], decs_out1[27]);
		and and12(en_and12, decs_out4[12], decs_out1[28]);
		and and13(en_and13, decs_out4[13], decs_out1[29]);
		and and14(en_and14, decs_out4[14], decs_out1[30]);
		and and15(en_and15, decs_out4[15], decs_out1[31]);  
		
		wire [31:0] Q_r8, Q_nr8;
		register_32bits r8 (Q_r8, Q_nr8, data, Vcc, Clk, en_and8);

		wire [31:0] Q_r9, Q_nr9;
		register_32bits r9 (Q_r9, Q_nr9, data, Vcc, Clk, en_and9);

		wire [31:0] Q_r10, Q_nr10;
		register_32bits r10 (Q_r10, Q_nr10, data, Vcc, Clk, en_and10);

		wire [31:0] Q_r11, Q_nr11;
		register_32bits r11 (Q_r11, Q_nr11, data, Vcc, Clk, en_and11);

		wire [31:0] Q_r12, Q_nr12;
		register_32bits r12 (Q_r12, Q_nr12, data, Vcc, Clk, en_and12);

		wire [31:0] Q_r13, Q_nr13;
		register_32bits r13 (Q_r13, Q_nr13, data, Vcc, Clk, en_and13);

		wire [31:0] Q_r14, Q_nr14;
		register_32bits r14 (Q_r14, Q_nr14, data, Vcc, Clk, en_and14);

		wire [31:0] Q_r15, Q_nr15;
		register_32bits r15 (Q_r15, Q_nr15, data, Vcc, Clk, en_and15);

		// REGISTROS LOCALES DEL PRIMER WINDOWS
		 
		wire [31:0] Q_r16, Q_nr16;
		register_32bits r16 (Q_r16, Q_nr16, data, Vcc, Clk, decs_out4[16]);

		wire [31:0] Q_r17, Q_nr17;
		register_32bits r17 (Q_r17, Q_nr17, data, Vcc, Clk, decs_out4[17]);

		wire [31:0] Q_r18, Q_nr18;
		register_32bits r18 (Q_r18, Q_nr18, data, Vcc, Clk, decs_out4[18]);

		wire [31:0] Q_r19, Q_nr19;
		register_32bits r19 (Q_r19, Q_nr19, data, Vcc, Clk, decs_out4[19]);

		wire [31:0] Q_r20, Q_nr20;
		register_32bits r20 (Q_r20, Q_nr20, data, Vcc, Clk, decs_out4[20]);

		wire [31:0] Q_r21, Q_nr21;
		register_32bits r21 (Q_r21, Q_nr21, data, Vcc, Clk, decs_out4[21]);

		wire [31:0] Q_r22, Q_nr22;
		register_32bits r22 (Q_r22, Q_nr22, data, Vcc, Clk, decs_out4[22]);

		wire [31:0] Q_r23, Q_nr23;
		register_32bits r23 (Q_r23, Q_nr23, data, Vcc, Clk, decs_out4[23]);
	
	
		// REGISTROS COMPARTIDOS ENTRE WINDOWS UNO Y WINDOWS DOS
		
		wire en_and24, en_and25, en_and26, en_and27, en_and28, en_and29, en_and30, en_and31;
		
		and and24(en_and24, decs_out3[8], decs_out4[24]);
		and and25(en_and25, decs_out3[9], decs_out4[25]);
		and and26(en_and26, decs_out3[10], decs_out4[26]);
		and and27(en_and27, decs_out3[11], decs_out4[27]);
		and and28(en_and28, decs_out3[12], decs_out4[28]);
		and and29(en_and29, decs_out3[13], decs_out4[29]);
		and and30(en_and30, decs_out3[14], decs_out4[30]);
		and and31(en_and31, decs_out3[15], decs_out4[31]);  

		wire [31:0] Q_r24, Q_nr24;
		register_32bits r24 (Q_r24, Q_nr24, data, Vcc, Clk, en_and24);

		wire [31:0] Q_r25, Q_nr25;
		register_32bits r25 (Q_r25, Q_nr25, data, Vcc, Clk, en_and25);

		wire [31:0] Q_r26, Q_nr26;
		register_32bits r26 (Q_r26, Q_nr26, data, Vcc, Clk, en_and26);

		wire [31:0] Q_r27, Q_nr27;
		register_32bits r27 (Q_r27, Q_nr27, data, Vcc, Clk, en_and27);

		wire [31:0] Q_r28, Q_nr28;
		register_32bits r28 (Q_r28, Q_nr28, data, Vcc, Clk, en_and28);

		wire [31:0] Q_r29, Q_nr29;
		register_32bits r29 (Q_r29, Q_nr29, data, Vcc, Clk, en_and29);

		wire [31:0] Q_r30, Q_nr30;
		register_32bits r30 (Q_r30, Q_nr30, data, Vcc, Clk, en_and30);

		wire [31:0] Q_r31, Q_nr31;
		register_32bits r31 (Q_r31, Q_nr31, data, Vcc, Clk, en_and31);
	
		// REGISTROS LOCALES DEL SEGUNDO WINDOWS
	
		wire [31:0] Q_r32, Q_nr32;
		register_32bits r32 (Q_r32, Q_nr32, data, Vcc, Clk, decs_out3[16]);
	
		wire [31:0] Q_r33, Q_nr33;
		register_32bits r33 (Q_r33, Q_nr33, data, Vcc, Clk, decs_out3[17]);
	
		wire [31:0] Q_r34, Q_nr34;
		register_32bits r34 (Q_r34, Q_nr34, data, Vcc, Clk, decs_out3[18]);
	
		wire [31:0] Q_r35, Q_nr35;
		register_32bits r35 (Q_r35, Q_nr35, data, Vcc, Clk, decs_out3[19]);
	
		wire [31:0] Q_r36, Q_nr36;
		register_32bits r36 (Q_r36, Q_nr36, data, Vcc, Clk, decs_out3[20]);
	
		wire [31:0] Q_r37, Q_nr37;
		register_32bits r37 (Q_r37, Q_nr37, data, Vcc, Clk, decs_out3[21]);
	
		wire [31:0] Q_r38, Q_nr38;
		register_32bits r38 (Q_r38, Q_nr38, data, Vcc, Clk, decs_out3[22]);

		wire [31:0] Q_r39, Q_nr39;
		register_32bits r39 (Q_r39, Q_nr39, data, Vcc, Clk, decs_out3[23]);

		// REGISTROS COMPARTIDOS ENTRE WINDOWS DOS Y WINDOWS TRES
		
		wire en_and40, en_and41, en_and42, en_and43, en_and44, en_and45, en_and46, en_and47;
	
		and and40(en_and40, decs_out2[8], decs_out3[24]);
		and and41(en_and41, decs_out2[9], decs_out3[25]);
		and and42(en_and42, decs_out2[10], decs_out3[26]);
		and and43(en_and43, decs_out2[11], decs_out3[27]);
		and and44(en_and44, decs_out2[12], decs_out3[28]);
		and and45(en_and45, decs_out2[13], decs_out3[29]);
		and and46(en_and46, decs_out2[14], decs_out3[30]);
		and and47(en_and47, decs_out2[15], decs_out3[31]); 

		wire [31:0] Q_r40, Q_nr40;
		register_32bits r40 (Q_r40, Q_nr40, data, Vcc, Clk, en_and40);
	
		wire [31:0] Q_r41, Q_nr41;
		register_32bits r41 (Q_r41, Q_nr41, data, Vcc, Clk, en_and41);
	
		wire [31:0] Q_r42, Q_nr42;
		register_32bits r42 (Q_r42, Q_nr42, data, Vcc, Clk, en_and42);
	
		wire [31:0] Q_r43, Q_nr43;
		register_32bits r43 (Q_r43, Q_nr43, data, Vcc, Clk, en_and43);
	
		wire [31:0] Q_r44, Q_nr44;
		register_32bits r44 (Q_r44, Q_nr44, data, Vcc, Clk, en_and44);
	
		wire [31:0] Q_r45, Q_nr45;
		register_32bits r45 (Q_r45, Q_nr45, data, Vcc, Clk, en_and45);
	
		wire [31:0] Q_r46, Q_nr46;
		register_32bits r46 (Q_r46, Q_nr46, data, Vcc, Clk, en_and46);
	
		wire [31:0] Q_r47, Q_nr47;
		register_32bits r47 (Q_r47, Q_nr47, data, Vcc, Clk, en_and47);
	
		// REGISTROS LOCALES DEL TERCER WINDOWS
		
		wire [31:0] Q_r48, Q_nr48;
		register_32bits r48 (Q_r48, Q_nr48, data, Vcc, Clk, decs_out2[16]);
	
		wire [31:0] Q_r49, Q_nr49;
		register_32bits r49 (Q_r49, Q_nr49, data, Vcc, Clk, decs_out2[17]);
	
		wire [31:0] Q_r50, Q_nr50;
		register_32bits r50 (Q_r50, Q_nr50, data, Vcc, Clk, decs_out2[18]);
	
		wire [31:0] Q_r51, Q_nr51;
		register_32bits r51 (Q_r51, Q_nr51, data, Vcc, Clk, decs_out2[19]);
	
		wire [31:0] Q_r52, Q_nr52;
		register_32bits r52 (Q_r52, Q_nr52, data, Vcc, Clk, decs_out2[20]);
	
		wire [31:0] Q_r53, Q_nr53;
		register_32bits r53 (Q_r53, Q_nr53, data, Vcc, Clk, decs_out2[21]);
	
		wire [31:0] Q_r54, Q_nr54;
		register_32bits r54 (Q_r54, Q_nr54, data, Vcc, Clk, decs_out2[22]);
	
		wire [31:0] Q_r55, Q_nr55;
		register_32bits r55 (Q_r55, Q_nr55, data, Vcc, Clk, decs_out2[23]);
		
		// REGISTROS COMPARTIDOS ENTRE WINDOWS TRES Y WINDOWS CUATRO
		
		wire en_and56, en_and57, en_and58, en_and59, en_and60, en_and61, en_and62, en_and63;
	
		and and56(en_and56, decs_out1[8], decs_out2[24]);
		and and57(en_and57, decs_out1[9], decs_out2[25]);
		and and58(en_and58, decs_out1[10], decs_out2[26]);
		and and59(en_and59, decs_out1[11], decs_out2[27]);
		and and60(en_and60, decs_out1[12], decs_out2[28]);
		and and61(en_and61, decs_out1[13], decs_out2[29]);
		and and62(en_and62, decs_out1[14], decs_out2[30]);
		and and63(en_and63, decs_out1[15], decs_out2[31]); 
	
		wire [31:0] Q_r56, Q_nr56;
		register_32bits r56 (Q_r56, Q_nr56, data, Vcc, Clk, en_and56);
	
		wire [31:0] Q_r57, Q_nr57;
		register_32bits r57 (Q_r57, Q_nr57, data, Vcc, Clk, en_and57);
	
		wire [31:0] Q_r58, Q_nr58;
		register_32bits r58 (Q_r58, Q_nr58, data, Vcc, Clk, en_and58);
	
		wire [31:0] Q_r59, Q_nr59;
		register_32bits r59 (Q_r59, Q_nr59, data, Vcc, Clk, en_and59);
	
		wire [31:0] Q_r60, Q_nr60;
		register_32bits r60 (Q_r60, Q_nr60, data, Vcc, Clk, en_and60);
	
		wire [31:0] Q_r61, Q_nr61;
		register_32bits r61 (Q_r61, Q_nr61, data, Vcc, Clk, en_and61);
	
		wire [31:0] Q_r62, Q_nr62;
		register_32bits r62 (Q_r62, Q_nr62, data, Vcc, Clk, en_and62);
	
		wire [31:0] Q_r63, Q_nr63;
		register_32bits r63 (Q_r63, Q_nr63, data, Vcc, Clk, en_and63);
	
		// REGISTROS LOCALES DEL CUARTO WINDOWS
		
		wire [31:0] Q_r64, Q_nr64;
		register_32bits r64 (Q_r64, Q_nr64, data, Vcc, Clk, decs_out1[16]);
	
		wire [31:0] Q_r65, Q_nr65;
		register_32bits r65 (Q_r65, Q_nr65, data, Vcc, Clk, decs_out1[17]);
			
		wire [31:0] Q_r66, Q_nr66;
		register_32bits r66 (Q_r66, Q_nr66, data, Vcc, Clk, decs_out1[18]);
		
		wire [31:0] Q_r67, Q_nr67;
		register_32bits r67 (Q_r67, Q_nr67, data, Vcc, Clk, decs_out1[19]);
		
		wire [31:0] Q_r68, Q_nr68;
		register_32bits r68 (Q_r68, Q_nr68, data, Vcc, Clk, decs_out1[20]);
		
		wire [31:0] Q_r69, Q_nr69;
		register_32bits r69 (Q_r69, Q_nr69, data, Vcc, Clk, decs_out1[21]);
		
		wire [31:0] Q_r70, Q_nr70;
		register_32bits r70 (Q_r70, Q_nr70, data, Vcc, Clk, decs_out1[22]);
		
		wire [31:0] Q_r71, Q_nr71;
		register_32bits r71 (Q_r71, Q_nr71, data, Vcc, Clk, decs_out1[23]);
		
	
		// Multiplexers que seleccionan uno de 4 entradas dependiendo del windows en el que estemos
	
		mux_4x1_32bits mux_31(r_mux_out[31], CWP[1:0], Q_r15, Q_r63, Q_r47, Q_r31);
		mux_4x1_32bits mux_30(r_mux_out[30], CWP[1:0], Q_r14, Q_r62, Q_r46, Q_r30);
		mux_4x1_32bits mux_29(r_mux_out[29], CWP[1:0], Q_r13, Q_r61, Q_r45, Q_r29);
		mux_4x1_32bits mux_28(r_mux_out[28], CWP[1:0], Q_r12, Q_r60, Q_r44, Q_r28);
		mux_4x1_32bits mux_27(r_mux_out[27], CWP[1:0], Q_r11, Q_r59, Q_r43, Q_r27);
		mux_4x1_32bits mux_26(r_mux_out[26], CWP[1:0], Q_r10, Q_r58, Q_r42, Q_r26);
		mux_4x1_32bits mux_25(r_mux_out[25], CWP[1:0], Q_r9, Q_r57, Q_r41, Q_r25);
		mux_4x1_32bits mux_24(r_mux_out[24], CWP[1:0], Q_r8, Q_r56, Q_r40, Q_r24);
	
		mux_4x1_32bits mux_23(r_mux_out[23], CWP[1:0], Q_r71, Q_r55, Q_r39, Q_r23);
		mux_4x1_32bits mux_22(r_mux_out[22], CWP[1:0], Q_r70, Q_r54, Q_r38, Q_r22);
		mux_4x1_32bits mux_21(r_mux_out[21], CWP[1:0], Q_r69, Q_r53, Q_r37, Q_r21);
		mux_4x1_32bits mux_20(r_mux_out[20], CWP[1:0], Q_r68, Q_r52, Q_r36, Q_r20);
		mux_4x1_32bits mux_19(r_mux_out[19], CWP[1:0], Q_r67, Q_r51, Q_r35, Q_r19);
		mux_4x1_32bits mux_18(r_mux_out[18], CWP[1:0], Q_r66, Q_r50, Q_r34, Q_r18);
		mux_4x1_32bits mux_17(r_mux_out[17], CWP[1:0], Q_r65, Q_r49, Q_r33, Q_r17);
		mux_4x1_32bits mux_16(r_mux_out[16], CWP[1:0], Q_r64, Q_r48, Q_r32, Q_r16);
	
		mux_4x1_32bits mux_15(r_mux_out[15], CWP[1:0], Q_r63, Q_r47, Q_r31, Q_r15);
		mux_4x1_32bits mux_14(r_mux_out[14], CWP[1:0], Q_r62, Q_r46, Q_r30, Q_r14);
		mux_4x1_32bits mux_13(r_mux_out[13], CWP[1:0], Q_r61, Q_r45, Q_r29, Q_r13);
		mux_4x1_32bits mux_12(r_mux_out[12], CWP[1:0], Q_r60, Q_r44, Q_r28, Q_r12);
		mux_4x1_32bits mux_11(r_mux_out[11], CWP[1:0], Q_r59, Q_r43, Q_r27, Q_r11);
		mux_4x1_32bits mux_10(r_mux_out[10], CWP[1:0], Q_r58, Q_r42, Q_r26, Q_r10);
		mux_4x1_32bits mux_9(r_mux_out[9], CWP[1:0], Q_r57, Q_r41, Q_r25, Q_r9);
		mux_4x1_32bits mux_8(r_mux_out[8], CWP[1:0], Q_r56, Q_r40, Q_r24, Q_r8);
	
		// OUTPUT B 
		mux_32x1_32bits mux_b (r_b, B, 
		r_mux_out[31], r_mux_out[30], r_mux_out[29], r_mux_out[28], r_mux_out[27], r_mux_out[26], r_mux_out[25], r_mux_out[24], r_mux_out[23], r_mux_out[22], r_mux_out[21],  r_mux_out[20],
		r_mux_out[19], r_mux_out[18],  r_mux_out[17],  r_mux_out[16],  r_mux_out[15],  r_mux_out[14],  r_mux_out[13], r_mux_out[12], r_mux_out[11], r_mux_out[10],
		r_mux_out[9], r_mux_out[8], Q_r7, Q_r6, Q_r5, Q_r4, Q_r3, Q_r2, Q_r1, Q_r0);
	
		// OUTPUT C 
		mux_32x1_32bits mux_c (r_c, C, 
		r_mux_out[31], r_mux_out[30], r_mux_out[29], r_mux_out[28], r_mux_out[27], r_mux_out[26], r_mux_out[25], r_mux_out[24], r_mux_out[23], r_mux_out[22], r_mux_out[21],  r_mux_out[20],
		r_mux_out[19], r_mux_out[18],  r_mux_out[17],  r_mux_out[16],  r_mux_out[15],  r_mux_out[14],  r_mux_out[13], r_mux_out[12], r_mux_out[11], r_mux_out[10],
		r_mux_out[9], r_mux_out[8], Q_r7, Q_r6, Q_r5, Q_r4, Q_r3, Q_r2, Q_r1, Q_r0);
endmodule