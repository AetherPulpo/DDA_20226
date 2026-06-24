`timescale 1ns/1ps

module ejercicio1_tb;

    // -------------------------------------------------------------------------
    // Parameters and TB Signals
    // -------------------------------------------------------------------------
    localparam CLK_PERIOD = 10; // 100 MHz Clock

    logic clk;
    logic i_rst_n;
    logic [2:0] i_data1;
    logic [2:0] i_data2;
    logic [1:0] i_sel;
    
    wire [5:0] o_data;
    wire       o_overflow;

    // -------------------------------------------------------------------------
    // DUT (Device Under Test) Instantiation
    // -------------------------------------------------------------------------
    ejercicio1 dut_ejercicio1 (
        .clk        (clk),
        .i_rst_n    (i_rst_n),
        .i_data1    (i_data1),
        .i_data2    (i_data2),
        .i_sel      (i_sel),
        .o_data     (o_data),
        .o_overflow (o_overflow)
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
        // Initial values
        i_rst_n = 1;
        i_data1 = 3'b0;
        i_data2 = 3'b0;
        i_sel   = 2'b0;

        // 1. Apply Reset
        #(CLK_PERIOD * 2);
        i_rst_n = 0;
        #(CLK_PERIOD * 2);
        i_rst_n = 1;
        #(CLK_PERIOD);

        $display("[TB] --- Starting Testbench with Random Stimuli ---");

        // 2. Run n cycles of random data to stress the accumulator
        repeat (100) begin
            @(negedge clk); // Drive inputs on negative edge to avoid simulation race conditions
            i_data1 = $urandom_range(0, 7);
            i_data2 = $urandom_range(0, 7);
            i_sel   = $urandom_range(0, 3); // Also tests the default case (2'b11)
        end

        // 3. Force intentional overflow conditions to verify o_overflow
        $display("[TB] --- Forcing Overflow Conditions ---");
        repeat (5) begin
            @(negedge clk);
            i_data1 = 3'd7;
            i_data2 = 3'd7;
            i_sel   = 2'b01; // mux_result = 14 (4'b1110)
        end

        // 4. Apply an intermediate reset to validate hot-clean behavior
        $display("[TB] --- Applying Intermediate Reset ---");
        @(negedge clk);
        i_rst_n = 0;
        #(CLK_PERIOD * 2);
        i_rst_n = 1;
        
        repeat (20) begin
            @(negedge clk);
            i_data1 = $urandom_range(0, 7);
            i_data2 = $urandom_range(0, 7);
            i_sel   = $urandom_range(0, 2);
        end

         // 5. Inputs fixed to 1 and wait to overflow go high
        $display("[TB] --- Starting Target Test: Inputs fixed to 1 ---");
        @(negedge clk);
        i_rst_n = 0;
        #(CLK_PERIOD * 2);
        i_rst_n = 1;
        @(negedge clk);
        i_data1 = 3'd1;
        i_data2 = 3'd1;
        i_sel   = 2'b01; // Selects add_result (1 + 1 = 2)

        // Run for exactly 35 cycles to observe the transition and stable overflow
        repeat (35) begin
            @(negedge clk);
        end
        #(CLK_PERIOD * 5);
        $display("[TB] --- Testbench completed SUCCESSFULY ---");
        $finish;
    end

endmodule