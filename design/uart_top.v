module	uart_top(
	input				clk,
	input				rst_n,
	input				rs232_rx,
	output				rs232_tx
);

	wire			bps_start1,bps_start2;
	wire			clk_bps1,clk_bps2;
	wire	[7:0]	rx_data/*synthesis keep*/;
	wire			rx_int;
	
speed_select		speed_rx(
	.clk					(clk),
	.rst_n					(rst_n),
	.bps_start				(bps_start1),
	.clk_bps				(clk_bps1)
);

uart_rx				uart_rx_inst(
	.clk					(clk),		
	.rst_n					(rst_n),		
	.rs232_rx				(rs232_rx),	
	.clk_bps				(clk_bps1),	
	.bps_start				(bps_start1),	
	.rx_data				(rx_data),	
	.rx_int					(rx_int)		
);

speed_select		speed_tx(
	.clk					(clk),
	.rst_n					(rst_n),
	.bps_start				(bps_start2),
	.clk_bps				(clk_bps2)
);

uart_tx				uart_tx_inst(
	.clk					(clk),											
	.rst_n					(rst_n),											
	.clk_bps				(clk_bps2),										
	.rx_data				(rx_data),										
	.rx_int					(rx_int),										
	.rs232_tx				(rs232_tx),										
	.bps_start				(bps_start2)									
);


endmodule