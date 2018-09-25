module xor_nn(	input clk,
		output reg rdy
);

always @ (posedge clk)
begin
	rdy <= 1;
end

endmodule


