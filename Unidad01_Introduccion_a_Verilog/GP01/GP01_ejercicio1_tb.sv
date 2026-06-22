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
    // Reference Model (Golden Model / Predictor)
    // -------------------------------------------------------------------------
    // Mirroring the internal RTL logic to predict the expected outputs.
    logic [3:0] ref_add_result;
    logic [3:0] ref_mux_result;
    logic [6:0] ref_sum;
    logic [6:0] ref_sum_q;

    assign ref_add_result = i_data1 + i_data2;

    always_comb begin
        case(i_sel)
            2'b00  : ref_mux_result = {1'b0, i_data2};
            2'b01  : ref_mux_result = ref_add_result;
            2'b10  : ref_mux_result = {1'b0, i_data1};
            default: ref_mux_result = 4'b0;
        endcase
    end

    // Note: ref_sum is calculated using the current value of ref_sum_q
    assign ref_sum = 6'(ref_mux_result) + ref_sum_q[5:0];

    // Reference register update aligned with the DUT clock cycle
    always_ff @(posedge clk or negedge i_rst_n) begin
        if(!i_rst_n) begin
            ref_sum_q <= 7'b0;
        end else begin
            ref_sum_q <= ref_sum;
        end
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

        #(CLK_PERIOD * 5);
        $display("[TB] --- Testbench completed SUCCESSFULY ---");
        $finish;
    end

    // -------------------------------------------------------------------------
    // Concurrent Assertions (Runtime Self-Checking)
    // -------------------------------------------------------------------------
    // Since outputs depend on the updated state of sum_q (which changes on posedge clk),
    // we validate the sampled outputs immediately after the clock edge.
    
    property p_check_outputs;
        @(posedge clk) disable iff (!i_rst_n)
        (o_data == ref_sum_q[5:0]) && (o_overflow == ref_sum_q[6]);
    endproperty

    assert_check_outputs: assert property (p_check_outputs) else begin
        $error("[TB ERROR] Mismatch detected at time %0t. DUT: data=%0d, ovf=%0b | REF: data=%0d, ovf=%0b", 
               $time, o_data, o_overflow, ref_sum_q[5:0], ref_sum_q[6]);
    end

    // Optional console monitoring for quick visual debugging
    initial begin
        $monitor("Time=%0t | rst_n=%0b | sel=%0b | d1=%0d d2=%0d | DUT_out=%0d (ovf=%0b) | REF_out=%0d (ovf=%0b)", 
                 $time, i_rst_n, i_sel, i_data1, i_data2, o_data, o_overflow, ref_sum_q[5:0], ref_sum_q[6]);
    end

endmodule