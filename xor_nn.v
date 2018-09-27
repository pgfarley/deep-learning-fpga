//TODO  bus protocol
//TODO  Allow weights to be passed in
//TODO  reset_m support
//TODO dynamic layer sizes
//TODO dynamic number of hidden layers?
module xor_nn(	input clk,
		input reset_n,
		input[0:1] input_data,

		output reg[0:0] prediction_data
);

wire[2:0] x = {input_data, 1'b1};

reg signed [7:0]  w1 [2:0][1:0];
wire [7:0] a1 [2:0][0:0];
reg signed [7:0] w2 [2:0][0:0];

function relu;
	input signed [7:0] value;
	begin
		relu = value & ~value[7];
	end
endfunction
	
assign a1[0][0] = 1;
assign a1[1][0] = relu(x[0] * w1[0][0] + x[1] * w1[1][0] + x[2] * w1[2][0]);
assign a1[2][0] = relu(x[0] * w1[0][1] + x[1] * w1[1][1] + x[2] * w1[2][1]);

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


	prediction_data <= a1[0][0] * w2[0][0] + a1[1][0] * w2[1][0] + a1[2][0] * w2[2][0];


end

endmodule


