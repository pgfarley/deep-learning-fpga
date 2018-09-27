//TODO  bus protocol
//TODO  Allow weights to be passed in
//TODO  reset_m support
//TODO non-integer weights
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
reg [BITS_PER_WORD-1:0] h1 [CLOG2_INPUT_VECTOR_COUNT-1:0][CLOG2_HIDDEN_LAYER_SIZE:0];
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

integer i, j, k;
always @( posedge clk)
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


	for(i = 0; i < CLOG2_INPUT_VECTOR_COUNT; i=i+1) begin
	h1[i][0] = 1;
		for(j = 0; j < CLOG2_HIDDEN_LAYER_SIZE; j=j+1) begin
			h1[i][j+1] = 0;
			for(k = 0; k < CLOG2_INPUT_VECTOR_SIZE + 1; k=k+1) begin
				h1[i][j+1] = h1[i][j+1] + (x[i][k] * w1[k][j]);
			end
 			h1[i][i+1] = relu(h1[i][i+1]);
		end
	end
	
	for(i = 0; i < CLOG2_OUTPUT_VECTOR_SIZE; i=i+1) begin
		prediction_data[i] = 0;
		for(j = 0; j < CLOG2_HIDDEN_LAYER_SIZE + 1; j=j+1) begin
			for(k = 0; k < CLOG2_INPUT_VECTOR_COUNT; k=k+1) begin
				prediction_data[i] = prediction_data[i] + (h1[k][j] * w2[j][i]);
			end
		end
	end
	

end

endmodule


