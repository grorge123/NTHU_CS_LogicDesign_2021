/////////////////////////////////////////////////
//                caculate AI action
// I/O
// clk            : system clock signal
// ball*_posx     : ball x-axis position
// ball*_posy     : ball y-axis position
// paddle10_posx  : left paddle1 x-axis position
// paddle10_posy  : left paddle1 y-axis position
// paddle11_posx  : left paddle2 x-axis position
// paddle11_posy  : left paddle2 y-axis position
// action         :	predict AI action
/////////////////////////////////////////////////
module AI(
	input wire clk,
	input signed [10:0] ball1_posx,
	input signed [10:0] ball1_posy,
	input signed [10:0] ball2_posx,
	input signed [10:0] ball2_posy,
	input signed [10:0] ball3_posx,
	input signed [10:0] ball3_posy,
	input signed [10:0] ball4_posx,
	input signed [10:0] ball4_posy,
	input signed [10:0] ball5_posx,
	input signed [10:0] ball5_posy,
	input signed [10:0] ball1_velx,
	input signed [10:0] ball1_vely,
	input signed [10:0] ball2_velx,
	input signed [10:0] ball2_vely,
	input signed [10:0] ball3_velx,
	input signed [10:0] ball3_vely,
	input signed [10:0] ball4_velx,
	input signed [10:0] ball4_vely,
	input signed [10:0] ball5_velx,
	input signed [10:0] ball5_vely,
	input signed [10:0] paddle10_posx,
	input signed [10:0] paddle10_posy,
	input signed [10:0] paddle11_posx,
	input signed [10:0] paddle11_posy,
	output [2:0] action
);
	parameter signed BALL_RADIUS = 11'd10;
	parameter signed PAD_HEIGHT = 11'd80;
	parameter signed HALF_PAD_HEIGHT = PAD_HEIGHT / 2;
	wire [1:0] data;
	wire [15:0] address;
	wire [1:0] outdata;
	wire signed [10:0] tmp_future_ball_pos[4:0][1:0];
	wire signed [10:0] future_ball_pos[4:0][1:0];
	reg signed [10:0] order_ball_pos[4:0][1:0];
	reg signed [10:0] sorted_bus[4:0][1:0];
	reg [15:0] ty[4:0][1:0];
	reg [2:0] i;
    reg [2:0] temp;
    reg [2:0] array [1:5];
    integer j;
	assign tmp_future_ball_pos[0][0] = ball1_posx + 11'd3 * ball1_velx;
	assign tmp_future_ball_pos[0][1] = ball1_posy + 11'd3 * ball1_vely;
	assign tmp_future_ball_pos[1][0] = ball2_posx + 11'd3 * ball2_velx;
	assign tmp_future_ball_pos[1][1] = ball2_posy + 11'd3 * ball2_vely;
	assign tmp_future_ball_pos[2][0] = ball3_posx + 11'd3 * ball3_velx;
	assign tmp_future_ball_pos[2][1] = ball3_posy + 11'd3 * ball3_vely;
	assign tmp_future_ball_pos[3][0] = ball4_posx + 11'd3 * ball4_velx;
	assign tmp_future_ball_pos[3][1] = ball4_posy + 11'd3 * ball4_vely;
	assign tmp_future_ball_pos[4][0] = ball5_posx + 11'd3 * ball5_velx;
	assign tmp_future_ball_pos[4][1] = ball5_posy + 11'd3 * ball5_vely;
	assign future_ball_pos[0][0] = tmp_future_ball_pos[0][0][10] == 1'd0 ? tmp_future_ball_pos[0][0] : 11'd0;
	assign future_ball_pos[0][1] = tmp_future_ball_pos[0][1][10] == 1'd0 ? tmp_future_ball_pos[0][1] : tmp_future_ball_pos[0][1] * -11'd1;
	assign future_ball_pos[1][0] = tmp_future_ball_pos[1][0][10] == 1'd0 ? tmp_future_ball_pos[1][0] : 11'd0;
	assign future_ball_pos[1][1] = tmp_future_ball_pos[1][1][10] == 1'd0 ? tmp_future_ball_pos[1][1] : tmp_future_ball_pos[1][1] * -11'd1;
	assign future_ball_pos[2][0] = tmp_future_ball_pos[2][0][10] == 1'd0 ? tmp_future_ball_pos[2][0] : 11'd0;
	assign future_ball_pos[2][1] = tmp_future_ball_pos[2][1][10] == 1'd0 ? tmp_future_ball_pos[2][1] : tmp_future_ball_pos[2][1] * -11'd1;
	assign future_ball_pos[3][0] = tmp_future_ball_pos[3][0][10] == 1'd0 ? tmp_future_ball_pos[3][0] : 11'd0;
	assign future_ball_pos[3][1] = tmp_future_ball_pos[3][1][10] == 1'd0 ? tmp_future_ball_pos[3][1] : tmp_future_ball_pos[3][1] * -11'd1;
	assign future_ball_pos[4][0] = tmp_future_ball_pos[4][0][10] == 1'd0 ? tmp_future_ball_pos[4][0] : 11'd0;
	assign future_ball_pos[4][1] = tmp_future_ball_pos[4][1][10] == 1'd0 ? tmp_future_ball_pos[4][1] : tmp_future_ball_pos[4][1] * -11'd1;
	assign data = 12'd0;
	assign action = {1'd0, outdata} + 3'd1;

 	blk_mem_gen_0 blk_mem_gen_0_inst(
      .clka(clk),
      .wea(0),
      .addra(address),
      .dina(data),
      .douta(outdata)
    ); 

	always @(posedge clk) begin
        order_ball_pos[0][0] <= sorted_bus[0][0];
        order_ball_pos[0][1] <= sorted_bus[0][1];
		order_ball_pos[1][0] <= sorted_bus[1][0];
        order_ball_pos[1][1] <= sorted_bus[1][1];
		order_ball_pos[2][0] <= sorted_bus[2][0];
        order_ball_pos[2][1] <= sorted_bus[2][1];
		order_ball_pos[3][0] <= sorted_bus[3][0];
        order_ball_pos[3][1] <= sorted_bus[3][1];
		order_ball_pos[4][0] <= sorted_bus[4][0];
        order_ball_pos[4][1] <= sorted_bus[4][1];
    end
	
    always @(*) begin
        for (i = 3'd0; i < 3'd5; i = i + 3'd1) begin
            array[i+1] = i;
        end

        for (i = 5; i > 0; i = i - 1) begin
            for (j = 1 ; j < i; j = j + 1) begin
                if (future_ball_pos[array[j]][0] > future_ball_pos[array[j + 1]][0]) begin
                    temp         = array[j];
                    array[j]     = array[j + 1];
                    array[j + 1] = temp;
                end 
            end
        end

       for (i = 0; i < 5; i = i + 1) begin
            sorted_bus[i][0] = future_ball_pos[array[i+1]][0];
            sorted_bus[i][1] = future_ball_pos[array[i+1]][1];
       end
    end
	wire signed [10:0] UPPER0, LOWER0, UPPER1, LOWER1;
	assign UPPER0 = paddle10_posy + HALF_PAD_HEIGHT;
	assign LOWER0 = paddle10_posy - HALF_PAD_HEIGHT;
	assign UPPER1 = paddle11_posy + HALF_PAD_HEIGHT;
	assign LOWER1 = paddle11_posy - HALF_PAD_HEIGHT;
	always@(*)begin
		if(order_ball_pos[0][1] > UPPER0)
			ty[0][0] = 16'd1;
		else if(order_ball_pos[0][1] < LOWER0)
			ty[0][0] = 16'd2;
		else
			ty[0][0] = 16'd0;
		
		if(order_ball_pos[0][1] > UPPER1)
			ty[0][1] = 16'd1*16'd3;
		else if(order_ball_pos[0][1] < LOWER1)
			ty[0][1] = 16'd2*16'd3;
		else
			ty[0][1] = 16'd0;

		if(order_ball_pos[1][1] > UPPER0)
			ty[1][0] = 16'd1*16'd9;
		else if(order_ball_pos[1][1] < LOWER0)
			ty[1][0] = 16'd2*16'd9;
		else
			ty[1][0] = 16'd0;
		
		if(order_ball_pos[1][1] > UPPER1)
			ty[1][1] = 16'd1*16'd27;
		else if(order_ball_pos[1][1] < LOWER1)
			ty[1][1] = 16'd2*16'd27;
		else
			ty[1][1] = 16'd0;

		if(order_ball_pos[2][1] > UPPER0)
			ty[2][0] = 16'd1*16'd81;
		else if(order_ball_pos[2][1] < LOWER0)
			ty[2][0] = 16'd2*16'd81;
		else
			ty[2][0] = 16'd0;
		
		if(order_ball_pos[2][1] > UPPER1)
			ty[2][1] = 16'd1*16'd243;
		else if(order_ball_pos[2][1] < LOWER1)
			ty[2][1] = 16'd2*16'd243;
		else
			ty[2][1] = 16'd0;
		
		if(order_ball_pos[3][1] > UPPER0)
			ty[3][0] = 16'd1*16'd729;
		else if(order_ball_pos[3][1] < LOWER0)
			ty[3][0] = 16'd2*16'd729;
		else
			ty[3][0] = 16'd0;
		
		if(order_ball_pos[3][1] > UPPER1)
			ty[3][1] = 16'd1*16'd2187;
		else if(order_ball_pos[3][1] < LOWER1)
			ty[3][1] = 16'd2*16'd2187;
		else
			ty[3][1] = 16'd0;
		
		if(order_ball_pos[4][1] > UPPER0)
			ty[4][0] = 16'd1*16'd6561;
		else if(order_ball_pos[4][1] < LOWER0)
			ty[4][0] = 16'd2*16'd6561;
		else
			ty[4][0] = 16'd0;
		
		if(order_ball_pos[4][1] > UPPER1)
			ty[4][1] = 16'd1*16'd19683;
		else if(order_ball_pos[4][1] < LOWER1)
			ty[4][1] = 16'd2*16'd19683;
		else
			ty[4][1] = 16'd0;
	end

	assign address = ty[0][0] + ty[0][1] + ty[1][0] + ty[1][1] + ty[2][0] + ty[2][1] + ty[3][0] + ty[3][1] + ty[4][0] + ty[4][1];
endmodule