//TODO  bus protocol
//TODO  matrix input, vector output
//TODO  FSM
//TODO  move some logic to combinational?
//TODO  Allow weights to be passed in
//TODO  reset_m support
//TODO dynamic layer sizes
//TODO dynamic number of hidden layers?
module xor_nn(	input clk,
		input reset_n,
		input[1:0] input_data,

		output reg prediction_data
);

wire[2:0] x = {input_data, 1'b1};

reg signed [7:0]  w1 [2:0][1:0];
reg signed [7:0]  h1 [2:0][0:0];
reg [7:0] a1 [2:0][0:0];
reg signed [7:0] w2 [2:0][0:0];

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

	h1[0][0] <= 1;
	h1[1][0] <= x[0] * w1[0][0] + x[1] * w1[1][0] + x[2] * w1[2][0];
	h1[2][0] <= x[0] * w1[0][1] + x[1] * w1[1][1] + x[2] * w1[2][1];

	a1[0][0] <= 1;
	if (h1[1][0] < 0)
		a1[1][0] <= 0;
	else
		a1[1][0] <= h1[1][0];

	if (h1[2][0] < 0)
		a1[2][0] <= 0;
	else
		a1[2][0] <= h1[2][0];

	prediction_data <= a1[0][0] * w2[0][0] + a1[1][0] * w2[1][0] + a1[2][0] * w2[2][0];


end

endmodule


