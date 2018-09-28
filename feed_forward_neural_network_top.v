//TODO non-integer weights
//TODO dynamic number of hidden layers?
module feed_forward_neural_network_top #(parameter
	BITS_PER_WORD = 8,
	INPUT_VECTOR_SIZE = 2,
	INPUT_VECTOR_COUNT = 1,
	HIDDEN_LAYER_SIZE = 2,
	OUTPUT_VECTOR_SIZE = 1,
	BIAS_SIZE = 1,
	CLOG2_MAX_WEIGHTS_N = 2,
	CLOG2_MAX_WEIGHTS_M = 2
) (
	input clk,
	input reset_n,
	input weights_en,
	input [0:0] weights_layer_address,
	input [CLOG2_MAX_WEIGHTS_N-1:0] weights_n_address,
	input [CLOG2_MAX_WEIGHTS_M-1:0] weights_m_address,
	input signed [BITS_PER_WORD-1:0] weights_data,

	input in_en,
	input[INPUT_VECTOR_SIZE-1:0] in_data,

	output reg out_en,
	output reg[OUTPUT_VECTOR_SIZE-1:0] out_data
);

wire[0:0] x [INPUT_VECTOR_COUNT-1:0][INPUT_VECTOR_SIZE+BIAS_SIZE-1:0];
reg signed [BITS_PER_WORD-1:0]  w1 [INPUT_VECTOR_SIZE+BIAS_SIZE-1:0][HIDDEN_LAYER_SIZE-1:0];
reg [BITS_PER_WORD-1:0] h1 [INPUT_VECTOR_COUNT-1:0][HIDDEN_LAYER_SIZE+BIAS_SIZE-1:0];
reg signed [BITS_PER_WORD-1:0] w2 [HIDDEN_LAYER_SIZE+BIAS_SIZE-1:0][OUTPUT_VECTOR_SIZE-1:0];

function relu;
	input signed [BITS_PER_WORD-1:0] value;
	begin
		relu = value & ~value[7];
	end
endfunction
	
assign x[0][0] = 1;
assign x[0][1] = in_data[0];
assign x[0][2] = in_data[1];

integer i, j, k;

always @( posedge clk) begin
	if (!reset_n) begin
		out_en <= 0;
		out_data <= 0;
	end else begin
		if (weights_en) begin
			if (weights_layer_address == 0) begin
				w1[weights_n_address][weights_m_address] <= weights_data;
			end else if (weights_layer_address == 1) begin
				w2[weights_n_address][weights_m_address] <= weights_data;
			end
		end
	
		if (in_en) begin	
			for(i = 0; i < INPUT_VECTOR_COUNT; i=i+1) begin
			h1[i][0] = 1;
				for(j = 0; j < HIDDEN_LAYER_SIZE; j=j+1) begin
					h1[i][j+1] = 0;
					for(k = 0; k < INPUT_VECTOR_SIZE + BIAS_SIZE; k=k+1) begin
						h1[i][j+1] = h1[i][j+1] + (x[i][k] * w1[k][j]);
					end
		 			h1[i][j+1] = relu(h1[i][j+1]);
				end
			end
		
			
			for(i = 0; i < OUTPUT_VECTOR_SIZE; i=i+1) begin
				out_data[i] = 0;
				for(j = 0; j < HIDDEN_LAYER_SIZE + BIAS_SIZE; j=j+1) begin
					for(k = 0; k < INPUT_VECTOR_COUNT; k=k+1) begin
						out_data[i] = out_data[i] + (h1[k][j] * w2[j][i]);
					end
				end
			end
			
			out_en <= 1;
		
		end
		out_data <= out_data;
	end
end

endmodule


