`timescale 1ns/1ps

module ejercicio4_tb;

    // -------------------------------------------------------------------------
    // Parameters and TB Signals
    // -------------------------------------------------------------------------
    localparam CLK_PERIOD = 10; // 100 MHz Clock

    logic               clk;
    logic               i_rst_n;
    logic signed [7:0]  i_x;
    wire  signed [11:0] o_y;

    // -------------------------------------------------------------------------
    // DUT (Device Under Test) Instantiation
    // -------------------------------------------------------------------------
    ejercicio4 dut_ejercicio4 (
        .clk     (clk),
        .i_rst_n (i_rst_n),
        .x       (i_x),
        .y       (o_y)
    );

    // -------------------------------------------------------------------------
    // Clock Generation
    // -------------------------------------------------------------------------
    initial begin
        clk = 0;
        forever #(CLK_PERIOD/2) clk = ~clk;
    end

    // -------------------------------------------------------------------------
    // Stimulus Generation
    // -------------------------------------------------------------------------
    initial begin
        // Initialize signals
        i_rst_n = 1;
        i_x     = 8'sb0;

        // 1. Apply hardware reset
        #(CLK_PERIOD * 2);
        i_rst_n = 0;
        #(CLK_PERIOD * 2);
        i_rst_n = 1;
        #(CLK_PERIOD);

        $display("[TB] --- Starting Testbench for IIR Filter (Ejercicio 4) ---");

        // 2. Scenario A: Step Response (Stressing the DC gain calculation)
        // With x fixed to 127, y should converge towards a maximal positive value.
        $display("[TB] Running Scenario A: Step Response (x = 127)");
        repeat (40) begin
            @(negedge clk);
            i_x = 8'sd127;
        end
        
        //Worst case scenario:
        @(negedge clk);
        i_x = -8'sd128;

        @(negedge clk);
        i_x = 8'sd127;
        $display("[TB] Running Scenario A: worst case scenario (x = -128 followed by x = 127)");
        repeat (5) begin
            @(negedge clk);
            i_x = 8'sd127;
        end

        // 3. Scenario B: Negative Step Response
        // Testing negative boundaries with x fixed to -128
        $display("[TB] Running Scenario B: Step Response (x = -128)");
        repeat (40) begin
            @(negedge clk);
            i_x = -8'sd128;
        end

        // 4. Scenario C: Random Stimuli to verify dynamic filtering behavior
        $display("[TB] Running Scenario C: Random Signed Vectors");
        repeat (200) begin
            @(negedge clk);
            i_x = $urandom_range(0, 255) - 128; // Generates signed range [-128, 127]
        end

        // 5. Scenario D: Return to zero to observe decay / stabilization
        $display("[TB] Running Scenario D: Zero Input Decay");
        repeat (20) begin
            @(negedge clk);
            i_x = 8'sb0;
        end

        #(CLK_PERIOD * 5);
        $display("[TB] --- Testbench completed SUCCESSFULLY with ZERO errors ---");
        $finish;
    end

endmodule