`timescale 1ns / 1ps
module asynchronous_fifo(data_out, write_full, read_empty,read_clk, write_clk, reset);
parameter WIDTH = 8;
parameter POINTER = 4;
output [WIDTH-1 : 0] data_out;
output write_full;
output read_empty;
wire [WIDTH-1 : 0] data_in;
input read_clk, write_clk;
input reset;

reg [POINTER : 0] read_ptr, read_snc_1, read_snc_2;
reg [POINTER : 0] write_ptr, write_snc_1, write_snc_2;
wire [POINTER:0] read_ptr_g,write_ptr_g;

parameter DEPTH = 1 << POINTER;

reg [WIDTH-1 : 0] mem [DEPTH-1 : 0];

wire [POINTER : 0] read_ptr_snc;
wire [POINTER: 0] write_ptr_snc;
reg full,empty;
reg [7:0] tr_ptr;

//--write logic--//

always @(posedge write_clk or posedge reset) begin
if (reset) begin
write_ptr <= 0;
tr_ptr<=0;
end
else if (full == 1'b0) begin
write_ptr <= write_ptr + 1;
tr_ptr<=tr_ptr+1;
mem[write_ptr[POINTER-1 : 0]] <= data_in;
end
end

data_transfer s(tr_ptr,data_in);

//--read pointer synchronizer controled by write clock--//

always @(posedge write_clk) begin
read_snc_1 <= read_ptr_g;
read_snc_2 <= read_snc_1;
end

//--read logic--//

always @(posedge read_clk or posedge reset) begin
if (reset) begin
read_ptr <= 0;
end
else if (empty == 1'b0) begin
read_ptr <= read_ptr + 1;
end
end

//--write pointer synchronizer controled by read clock--//

always @(posedge read_clk) begin
write_snc_1 <= write_ptr_g;
write_snc_2 <= write_snc_1;
end

//--Combinational logic--//
//--Binary pointer--//

always @(*)
begin
if({~write_ptr[POINTER],write_ptr[POINTER-1:0]}==read_ptr_snc)
full = 1;
else
full = 0;
end


always @(*)
begin
if(write_ptr_snc==read_ptr)
empty = 1;
else
empty = 0;
end

assign data_out = mem[read_ptr[POINTER-1 : 0]];


//--binary code to gray code--//

assign write_ptr_g = write_ptr ^ (write_ptr >> 1);
assign read_ptr_g = read_ptr ^ (read_ptr >> 1);

//--gray code to binary code--//

assign write_ptr_snc[4]=write_snc_2[4];
assign write_ptr_snc[3]=write_snc_2[3] ^ write_ptr_snc[4];
assign write_ptr_snc[2]=write_snc_2[2] ^ write_ptr_snc[3];
assign write_ptr_snc[1]=write_snc_2[1] ^ write_ptr_snc[2];
assign write_ptr_snc[0]=write_snc_2[0] ^ write_ptr_snc[1];


assign read_ptr_snc[4]=read_snc_2[4];
assign read_ptr_snc[3]=read_snc_2[3] ^ read_ptr_snc[4];
assign read_ptr_snc[2]=read_snc_2[2] ^ read_ptr_snc[3];
assign read_ptr_snc[1]=read_snc_2[1] ^ read_ptr_snc[2];
assign read_ptr_snc[0]=read_snc_2[0] ^ read_ptr_snc[1];

assign write_full = full;
assign read_empty = empty;
endmodule



module data_transfer(write_ptr,data_out);
output [7:0] data_out;
input [7:0] write_ptr;
reg [7:0] input_rom [127:0];
integer i;
initial begin

for(i=0;i<128;i=i+1)
input_rom[i] = i+(30*0.75);
end

assign data_out = input_rom[write_ptr];

endmodule









