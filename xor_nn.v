module xorNN(	input clk,
		output reg rdy
);

always @ (posedge clk)
begin
	rdy <= 1;
end

endmodule


