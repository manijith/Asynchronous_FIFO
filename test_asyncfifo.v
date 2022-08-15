`timescale 1ns / 1ps

module test_asyncfifo;
reg write_clk,read_clk,reset;
wire write_full,read_empty;
wire [7:0] data_out;

asynchronous_fifo dut(data_out, write_full, read_empty,read_clk, write_clk, reset);


initial 
begin
write_clk=0;
read_clk=0;
reset=1;

#8000 $stop;

end


initial
#5 reset=0;

always
#25 write_clk=~write_clk;

always
#250 read_clk=~read_clk;

endmodule









