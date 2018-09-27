//TODO  bus protocol
//TODO  Allow weights to be passed in
//TODO  reset_m support
//TODO non-integer weights
//TODO dynamic layer sizes
//TODO dynamic number of hidden layers?
module xor_nn #(parameter
	BITS_PER_WORD = 8,
	CLOG2_INPUT_VECTOR_SIZE = 2,
	CLOG2_INPUT_VECTOR_COUNT = 1,
	CLOG2_HIDDEN_LAYER_SIZE = 2,
	CLOG2_OUTPUT_VECTOR_SIZE = 1
) (
	input clk,
	input reset_n,
	input[CLOG2_INPUT_VECTOR_SIZE-1:0] input_data,

	output reg[CLOG2_OUTPUT_VECTOR_SIZE-1:0] prediction_data
);

wire[0:0] x [CLOG2_INPUT_VECTOR_COUNT-1:0][CLOG2_INPUT_VECTOR_SIZE:0];
reg signed [BITS_PER_WORD-1:0]  w1 [CLOG2_INPUT_VECTOR_SIZE:0][CLOG2_HIDDEN_LAYER_SIZE-1:0];
wire [BITS_PER_WORD-1:0] a1 [CLOG2_INPUT_VECTOR_COUNT-1:0][CLOG2_HIDDEN_LAYER_SIZE:0];
reg signed [BITS_PER_WORD-1:0] w2 [CLOG2_HIDDEN_LAYER_SIZE:0][CLOG2_OUTPUT_VECTOR_SIZE-1:0];

function relu;
	input signed [BITS_PER_WORD-1:0] value;
	begin
		relu = value & ~value[7];
	end
endfunction
	
assign x[0][0] = 1;
assign x[0][1] = input_data[0];
assign x[0][2] = input_data[1];

assign a1[0][0] = 1;
assign a1[0][1] = relu(x[0][0] * w1[0][0] + x[0][1] * w1[1][0] + x[0][2] * w1[2][0]);
assign a1[0][2] = relu(x[0][1] * w1[0][1] + x[0][1] * w1[1][1] + x[0][2] * w1[2][1]);

always @ (posedge clk)
begin
	w1[0][0] <= 0;
	w1[0][1] <= -1;
	w1[1][0] <= 1;
	w1[1][1] <= 1;
	w1[2][0] <= 1;
	w1[2][1] <= 1;

	w2[0][0] <= 0;
	w2[1][0] <= 1;
	w2[2][0] <= -2;


	prediction_data <= a1[0][0] * w2[0][0] + a1[0][1] * w2[1][0] + a1[0][2] * w2[2][0];


end

endmodule


