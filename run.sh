#!/bin/bash

iverilog Arithmetic_Logic_Unit.v Control_Unit.v Data_Path.v Decoder_32.v Decoder_4.v Memoria_RAM_512x8.v Mux_16x1_32bits.v Mux_2x1_32bits.v Mux_32x1_32bits.v Mux_4x1_32bits.v Mux_8x1_32bits.v Register_32bits.v Register_Windows_32bits.v Test_Data_Path.v 
echo "iVerilog Command Executed 'a.out' was generated".
echo "Executing a.out"
./a.out
echo "Removing a.out"
rm a.out
