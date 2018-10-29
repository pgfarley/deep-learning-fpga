module feed_forward_neural_network_top #(parameter
    BITS_PER_WORD = 32,
    INPUT_VECTOR_COUNT = 1,
    INPUT_VECTOR_SIZE=2,
    INPUT_WORD_SIZE=1,
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
    output reg[(BITS_PER_WORD * OUTPUT_VECTOR_SIZE)-1:0] out_data
);


reg [BITS_PER_WORD-1:0] x [INPUT_VECTOR_COUNT-1:0][INPUT_VECTOR_SIZE / INPUT_WORD_SIZE+BIAS_SIZE-1:0];
reg signed [BITS_PER_WORD-1:0]  w1 [INPUT_VECTOR_SIZE / INPUT_WORD_SIZE + BIAS_SIZE-1:0][HIDDEN_LAYER_SIZE-1:0];
reg signed [BITS_PER_WORD-1:0] h1 [INPUT_VECTOR_COUNT-1:0][HIDDEN_LAYER_SIZE+BIAS_SIZE-1:0];
reg signed [BITS_PER_WORD-1:0] w2 [HIDDEN_LAYER_SIZE+BIAS_SIZE-1:0][OUTPUT_VECTOR_SIZE-1:0];

localparam MULTIPLY_RESULT_HI_BIT = BITS_PER_WORD + BITS_PER_WORD/2 - 1;
localparam MULTIPLY_RESULT_LOW_BIT = BITS_PER_WORD/2;
reg [(BITS_PER_WORD*2)-1:0] multiply_result;

function automatic [BITS_PER_WORD-1:0] relu ;
    input signed [BITS_PER_WORD-1:0] value;
    begin
        relu = (value[BITS_PER_WORD-1] == 1) ? 0 : value;
    end
endfunction

genvar i_gen, j_gen, k_gen;
for(i_gen = 0; i_gen < INPUT_VECTOR_COUNT; i_gen=i_gen+1) begin
    for(j_gen = 0; j_gen < INPUT_VECTOR_SIZE / INPUT_WORD_SIZE; j_gen=j_gen+1) begin
        always @( posedge clk) begin
            x[i_gen][j_gen+1] = (in_data[INPUT_WORD_SIZE * j_gen + INPUT_WORD_SIZE - 1:INPUT_WORD_SIZE * j_gen]  << BITS_PER_WORD/2);
        end
    end
end

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
                x[i][0] = 1  << BITS_PER_WORD/2;
            end
            for(i = 0; i < INPUT_VECTOR_COUNT; i=i+1) begin
                h1[i][0] = 1  << BITS_PER_WORD/2;;
                for(j = 0; j < HIDDEN_LAYER_SIZE; j=j+1) begin
                    h1[i][j+1] = 0;
                    for(k = 0; k < INPUT_VECTOR_SIZE / INPUT_WORD_SIZE + BIAS_SIZE; k=k+1) begin
                        multiply_result =  {{BITS_PER_WORD{x[i][k][BITS_PER_WORD-1]}}, x[i][k]} * {{BITS_PER_WORD{w1[k][j][BITS_PER_WORD-1]}}, w1[k][j]};
                        h1[i][j+1] = h1[i][j+1] + multiply_result[MULTIPLY_RESULT_HI_BIT:MULTIPLY_RESULT_LOW_BIT];
                    end
                     h1[i][j+1] = relu(h1[i][j+1]);
                end
            end
        
            for(i = 0; i < OUTPUT_VECTOR_SIZE; i=i+1) begin
                out_data = 0;
                for(j = 0; j < HIDDEN_LAYER_SIZE + BIAS_SIZE; j=j+1) begin
                    for(k = 0; k < INPUT_VECTOR_COUNT; k=k+1) begin
                        multiply_result =  {{BITS_PER_WORD{h1[k][j][BITS_PER_WORD-1]}}, h1[k][j]} * {{BITS_PER_WORD{w2[j][i][BITS_PER_WORD-1]}}, w2[j][i]};
                        out_data = out_data + (multiply_result[MULTIPLY_RESULT_HI_BIT:MULTIPLY_RESULT_LOW_BIT] << (i * BITS_PER_WORD));
                    end
                end
            end
            
            out_en <= 1;
        
        end
        
        out_data <= out_data;
    end
end

`ifdef COCOTB_SIM
initial begin
     $dumpvars;   
      #1;
end
genvar dump_x_i, dump_x_j, dump_w1_i, dump_w1_j, dump_w2_i, dump_w2_j, dump_h1_i, dump_h1_j;

for(dump_x_i = 0; dump_x_i < INPUT_VECTOR_COUNT; dump_x_i=dump_x_i+1) begin
    for(dump_x_j = 0; dump_x_j < INPUT_VECTOR_SIZE / INPUT_WORD_SIZE + BIAS_SIZE; dump_x_j=dump_x_j+1) begin
        initial $dumpvars (0, x[dump_x_i][dump_x_j]);
    end
end

for(dump_h1_i = 0; dump_h1_i < INPUT_VECTOR_COUNT; dump_h1_i=dump_h1_i+1) begin
    for(dump_h1_j = 0; dump_h1_j < HIDDEN_LAYER_SIZE+BIAS_SIZE; dump_h1_j=dump_h1_j+1) begin
        initial $dumpvars (0, h1[dump_h1_i][dump_h1_j]);
    end
end



for(dump_w1_i = 0; dump_w1_i < INPUT_VECTOR_SIZE / INPUT_WORD_SIZE + BIAS_SIZE; dump_w1_i=dump_w1_i+1) begin
    for(dump_w1_j = 0; dump_w1_j < HIDDEN_LAYER_SIZE; dump_w1_j=dump_w1_j+1) begin
        initial $dumpvars (0, w1[dump_w1_i][dump_w1_j]);
    end
end



for(dump_w2_i = 0; dump_w2_i < HIDDEN_LAYER_SIZE+BIAS_SIZE; dump_w2_i=dump_w2_i+1) begin
    for(dump_w2_j = 0; dump_w2_j <OUTPUT_VECTOR_SIZE; dump_w2_j=dump_w2_j+1) begin
        initial $dumpvars (0, w2[dump_w2_i][dump_w2_j]);
    end
end



`endif
endmodule


