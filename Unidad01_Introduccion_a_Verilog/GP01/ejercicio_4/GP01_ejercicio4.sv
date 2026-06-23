//AUTHOR: PAUL ANDRES ROMERO CORONADO
//NOTE: the given formula is y[n] = x[n] - x[n-1] + x[n-2] + x[n-3] + 0.5y[n-1] + 0.25y[n-2]
//NOTE: output y full-resolution analysis:
/* taking into account that x range is [-128, 127], the maximum value of x is |128|. So, the maximum value of y can be calculated as follows:
        Ymax = Xmax - Xmax + Xmax + Xmax + 0.5Ymax + 0.25Ymax
        Ymax - 0.75Ymax = 2Xmax
        0.25Ymax = 2Xmax
        Ymax = (2/0.25) Xmax = 8Xmax
        => Ymax = 8 * |128| = |1024|
    So, the output y needs to be at least 11 bits wide to avoid overflow. => Ymax range is [-1024, 1023]
*/

module ejercicio4(
    //OUTPUTS
    output wire signed [11-1:0] y,
    //INPUTS
    input wire signed  [8-1:0] x,
        //ctrl ports
    input wire          i_rst_n,
    input wire          clk
);

//SIGNAL DECLARATIONS
logic signed  [8-1:0] x_q[3-1:0];     // Flops to store the last 3 values of x
logic signed [11-1:0] y_q[2-1:0];    // Flops to store the last 2 values of y
logic signed [11-1:0] result;       // combinational signal for the final output y

//Shift register to store the last 3 values of x
always_ff @(posedge clk or negedge i_rst_n) begin
    if (!i_rst_n) begin
        x_q[2] <= '0;
        x_q[1] <= '0;
        x_q[0] <= '0;
    end else begin
        x_q[2] <= x_q[1];   
        x_q[1] <= x_q[0];   
        x_q[0] <= x;
    end
end

// Calculate the final output y according to the given formula
assign result = 11'(x) - 11'(x_q[0]) + 11'(x_q[1]) + 11'(x_q[2]) + (y_q[0] >>> 1) + (y_q[1] >>> 2); // y[n] = x[n] - x[n-1] + x[n-2] + x[n-3] + 0.5y[n-1] + 0.25y[n-2]

//Shift register to store the last 2 values of y
always_ff @(posedge clk or negedge i_rst_n) begin
    if (!i_rst_n) begin
        y_q[1] <= '0;
        y_q[0] <= '0;
    end else begin
        y_q[1] <= y_q[0];  
        y_q[0] <= result; 
    end
end

// Output assignment
assign y = result;
endmodule