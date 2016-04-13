`timescale		1ns/1ns

module	uart_tb;

	reg			clk;
	reg			rst_n;
	reg			rs232_rx;
	wire		rs232_tx;
	
uart_top		uart_top_inst(
	.clk							(clk),
	.rst_n							(rst_n),
	.rs232_rx						(rs232_rx),
	.rs232_tx						(rs232_tx)
);

initial
	begin
		clk	=	0;
		rst_n	=0;
		rs232_rx	=1;
		#200	
		rst_n	=1;
		
		#200			rs232_rx	=	0;
		#1100	rs232_rx	=	0;
		#1100	rs232_rx	=	1;
		#1100	rs232_rx	=	1;
		#1100	rs232_rx	=	0;
		#1100	rs232_rx	=	0;
		#1100	rs232_rx	=	1;
		#1100	rs232_rx	=	0;
		#1100	rs232_rx	=	0;
		#1100	rs232_rx	=	1;
		#1500		$stop;
	end
	
always	#10		clk	=	~clk;

endmodule
	
	
	