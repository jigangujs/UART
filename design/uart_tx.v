module		uart_tx(
	input				clk,											//50MHz主时钟
	input				rst_n,											//低电平复位信号
	input				clk_bps,										//clk_bps_r高电平作为发送数据改变点
	input		[7:0]	rx_data,										//接收数据寄存器
	input				rx_int,											//接收数据中断信号（由rx模块产生）
	output				rs232_tx,										//rs232发送数据信号
	output				bps_start										//接收或要发送数据，波特率时钟启动信号置位
);

/***************************************************************
*边沿检测，检测rx_int信号的下降沿，rx_int信号的下降沿表示接收完成
*****************************************************************/
	reg		rx_int0,rx_int1,rx_int2;									//rx_int信号寄存器，捕捉下降沿滤波用
	wire	neg_rx_int;													//定义rx_int下降沿标志位

always	@(posedge	clk	or	negedge	rst_n)
	begin
		if(!rst_n)
			begin
				rx_int0		<=		1'b0;
				rx_int1		<=		1'b0;
				rx_int2		<=		1'b0;
			end
		else
			begin
				rx_int0		<=		rx_int;								//详情请参考边沿检测电路原理//
				rx_int1		<=	    rx_int0;	
				rx_int2		<=	    rx_int1;
			end
	end

assign		neg_rx_int	=	~rx_int1	&	rx_int2;					//捕捉到下降沿后，neg_rx_int拉高保持一个主时钟周期
/******************************************************
*以下为将接收到的数据存储到寄存器中程序
******************************************************/
	reg	[7:0]		tx_data;											//定义一个寄存器来存储待发送的数据（即接收到的数据）
	reg				bps_start_r;										//定义一个寄存器，用来存储波特率时钟启动信号。
	reg	[3:0]		num;												//定义一个计数寄存器，用来存储发送数据位信号。
always	@(posedge	clk	or	negedge	rst_n)
	begin
		if(!rst_n)
			begin
				bps_start_r		<=		1'b0;
				tx_data			<=		8'd0;
			end
		else
			if(neg_rx_int)
				begin
					bps_start_r		<=		1'b1;
					tx_data			<=		rx_data;
				end
			else
				if(num==4'd11)
					begin
						bps_start_r		<=		1'b0;
					end
	end
assign		bps_start	=	bps_start_r;
/***********************************************************
*以下为数据发送程序
************************************************************/
	reg				rs232_tx_r;											//定义一个寄存器来存储待发送的数据
always	@(posedge	clk	or	negedge	rst_n)
	begin
		if(!rst_n)														//复位有效时，执行复位程序，计数器清零，发送端电平拉高
			begin
				num			<=		4'd0;
				rs232_tx_r	<=		1'b1;
			end
		else
			begin
				if(clk_bps)												//检测波特率时钟变为高电平时，执行以下程序(其实相当于发送使能标志位)
					begin
						num		<=		num	+	1'b1;					//每计数一次，rs232_tx_r寄存器就保存一次数据
							case(num)
							4'd0:	rs232_tx_r	<=	1'b0;				//发送起始位
							4'd1:	rs232_tx_r	<=	tx_data[0];			//发送数据位bit0
							4'd2:	rs232_tx_r	<=	tx_data[1];         //发送数据位bit1
							4'd3:	rs232_tx_r	<=	tx_data[2];         //发送数据位bit2
							4'd4:	rs232_tx_r	<=	tx_data[3];         //发送数据位bit3
							4'd5:	rs232_tx_r	<=	tx_data[4];         //发送数据位bit4
							4'd6:	rs232_tx_r	<=	tx_data[5];         //发送数据位bit5
							4'd7:	rs232_tx_r	<=	tx_data[6];         //发送数据位bit6
							4'd8:	rs232_tx_r	<=	tx_data[7];         //发送数据位bit7
							4'd9:	rs232_tx_r	<=	1'b1;				//发送停止位
							default:	rs232_tx_r	<=	1'b1;			//默认一直是拉高电平
							endcase
					end
				else
					if(num	==	4'd11)									//如果计数器计满（即发送完成）
					num		<=	4'd0;									//计数器清空复位
			end
	end
assign		rs232_tx	=	rs232_tx_r;									//将存储器rs232_tx_r数据放到数据输出总线rs232_tx上,供给外部设备读取

endmodule