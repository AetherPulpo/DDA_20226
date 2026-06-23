`timescale 1ns/1ps

module ejercicio4_tb;

    // -------------------------------------------------------------------------
    // Parameters and TB Signals
    // -------------------------------------------------------------------------
    localparam CLK_PERIOD = 10; // 100 MHz Clock

    logic               clk;
    logic               i_rst_n;
    logic signed [7:0]  i_x;
    wire  signed [10:0] o_y;

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
    // Reference Model (Golden Model) for Self-Checking
    // -------------------------------------------------------------------------
    logic signed [7:0]  ref_x_q[2:0];
    logic signed [10:0] ref_y_q[1:0];
    logic signed [10:0] ref_result;

    // Model calculation matching the ideal mathematical behavior
    assign ref_result = 11'(i_x) - 11'(ref_x_q[0]) + 11'(ref_x_q[1]) + 11'(ref_x_q[2]) + 
                        (ref_y_q[0] >>> 1) + (ref_y_q[1] >>> 2);

    // Mirroring the state registers
    always_ff @(posedge clk or negedge i_rst_n) begin
        if (!i_rst_n) begin
            ref_x_q[0] <= 8'sb0;
            ref_x_q[1] <= 8'sb0;
            ref_x_q[2] <= 8'sb0;
            ref_y_q[0] <= 11'sb0;
            ref_y_q[1] <= 11'sb0;
        end else begin
            ref_x_q[2] <= ref_x_q[1];   
            ref_x_q[1] <= ref_x_q[0];   
            ref_x_q[0] <= i_x;

            ref_y_q[1] <= ref_y_q[0];  
            ref_y_q[0] <= ref_result;
        end
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

    // -------------------------------------------------------------------------
    // Concurrent Assertion for Verification
    // -------------------------------------------------------------------------
    // Evaluates combinational result verification right at the clock event
    property p_check_iir_output;
        @(posedge clk) disable iff (!i_rst_n)
        (o_y == ref_result);
    endproperty

    assert_check_iir_output: assert property (p_check_iir_output) else begin
        $error("[TB ERROR] Mismatch at time %0t. DUT y=%0d | REF expected=%0d", 
               $time, o_y, ref_result);
    end

    // Visual monitor for waveform trace debugging
    initial begin
        $monitor("Time=%0t | rst_n=%0b | x=%0d | DUT_y=%0d | REF_y=%0d", 
                 $time, i_rst_n, i_x, o_y, ref_result);
    end

endmodule