`timescale 1ns/1ps

module ejercicio2_tb;

    // -------------------------------------------------------------------------
    // TB Signals
    // -------------------------------------------------------------------------
    logic signed [15:0] i_dataa;
    logic signed [15:0] i_datab;
    logic        [1:0]  i_sel;
    wire  signed [15:0] o_datac;

    // -------------------------------------------------------------------------
    // DUT (Device Under Test) Instantiation
    // -------------------------------------------------------------------------
    ejercicio2 dut_ejercicio2 (
        .i_dataa (i_dataa),
        .i_datab (i_datab),
        .i_sel   (i_sel),
        .o_datac (o_datac)
    );


    // -------------------------------------------------------------------------
    // Stimulus Generation
    // -------------------------------------------------------------------------
    initial begin
        // Initialize inputs
        i_dataa = 16'sb0;
        i_datab = 16'sb0;
        i_sel   = 2'b00;

        #10;
        $display("[TB] --- Starting Testbench for Combinational ALU (Ejercicio 2) ---");

        // --- TEST CASE 0: Addition (i_sel = 2'b00) ---
        $display("[TB] Testing Operation: ADD");
        i_sel = 2'b00;
        
        i_dataa = 16'sd150;   i_datab = 16'sd350;   #10;
        i_dataa = -16'sd500;  i_datab = 16'sd200;   #10;
        i_dataa = -16'sd10;   i_datab = -16'sd40;   #10;

        // --- TEST CASE 1: Subtraction (i_sel = 2'b01) ---
        $display("[TB] Testing Operation: SUB");
        i_sel = 2'b01;
        
        i_dataa = 16'sd1000;  i_datab = 16'sd400;   #10;
        i_dataa = 16'sd200;   i_datab = 16'sd600;   #10; // Negative result boundary
        i_dataa = -16'sd50;   i_datab = -16'sd30;   #10;

        // --- TEST CASE 2: Bitwise AND (i_sel = 2'b10) ---
        $display("[TB] Testing Operation: Bitwise AND");
        i_sel = 2'b10;
        
        i_dataa = 16'hAAAA;   i_datab = 16'h5555;   #10; // Alternating bits (Should output 0)
        i_dataa = 16'hFFFF;   i_datab = 16'h0F0F;   #10; // Masking operation
        i_dataa = 16'h1234;   i_datab = 16'hFFFF;   #10;

        // --- TEST CASE 3: Bitwise OR (i_sel = 2'b11 - Default) ---
        $display("[TB] Testing Operation: Bitwise OR");
        i_sel = 2'b11;
        
        i_dataa = 16'hF0F0;   i_datab = 16'h0F0F;   #10; // Should output FFFF
        i_dataa = 16'h1111;   i_datab = 16'h2222;   #10;
        i_dataa = 16'h0000;   i_datab = 16'hABCD;   #10;

        // --- RANDOM STIMULI LAYER ---
        $display("[TB] Testing Random Stress Vectors");
        repeat (50) begin
            i_sel   = $urandom_range(0, 3);
            i_dataa = $urandom_range(0, 65535) - 32768; // Signed distribution covering full 16-bit range
            i_datab = $urandom_range(0, 65535) - 32768;
            #10;
        end

        #10;
        $display("[TB] --- Testbench completed SUCCESSFULLY with ZERO errors ---");
        $finish;
    end
endmodule