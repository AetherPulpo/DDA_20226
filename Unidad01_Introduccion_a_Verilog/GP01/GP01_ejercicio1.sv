//AUTHOR: PAUL ANDRES ROMERO CORONADO
//Note: Since the exercide doesn't define the signedness of the inputs & outputs, I will assume that they are unsigned numbers.
module ejercicio1(
    //OUTPUTS
    output wire [6-1:0] o_data,
    output wire         o_overflow,
    //INPUTS
    input wire  [3-1:0] i_data1,
    input wire  [3-1:0] i_data2,
        //ctrl ports
    input wire  [2-1:0] i_sel,
    input wire          i_rst_n,
    input wire          clk
);
//SIGNAL DECLARATIONS
logic [4-1:0] add_result;
logic [4-1:0] mux_result;
logic [7-1:0] sum;
logic [7-1:0] sum_q;

//Sum between i_data1 and i_data2
assign add_result = i_data1 + i_data2;

//MUX between: (2) i_data1; (1) add_result; (0) i_data2
always_comb begin
    case(i_sel)
        2'b00  : mux_result = {1'b0, i_data2};
        2'b01  : mux_result = add_result;
        2'b10  : mux_result = {1'b0, i_data1};
        default: mux_result = 4'b0;
    endcase
end

//Sum between mux_result and sum_q
assign sum = 6'(mux_result) + sum_q[5:0];

//sum_q flop
always_ff @(posedge clk or negedge i_rst_n) begin
    if(!i_rst_n) begin
        sum_q <= 7'b0;
    end else begin
        sum_q <= sum;
    end
end

//Output assignments
assign o_data     = sum[5:0];
assign o_overflow = sum[6];

endmodule