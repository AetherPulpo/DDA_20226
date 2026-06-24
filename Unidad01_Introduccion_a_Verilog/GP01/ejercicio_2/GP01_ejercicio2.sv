module ejercicio2(
    //OUTPUTS
    output wire signed [16-1:0] o_datac,
    //INPUTS
    input wire signed  [16-1:0] i_dataa,
    input wire signed  [16-1:0] i_datab,
        //ctrl ports
    input wire  [2-1:0] i_sel
);

//SIGNAL DECLARATIONS
logic signed [16-1:0] case_result;
//Operation Selector
always_comb begin
    case(i_sel)
        2'b00  : case_result = i_dataa + i_datab;// Addition
        2'b01  : case_result = i_dataa - i_datab;// Subtraction
        2'b10  : case_result = i_dataa & i_datab;// Bitwise AND
        default: case_result = i_dataa | i_datab;// Bitwise OR
    endcase
end
//Output assignments
assign o_datac = case_result;
endmodule 