`timescale 1ps/1ps
`include "adder.sv"
module adder_tb;
logic  [31:0] a, b;
logic  [31:0] c;
logic C_out;

adder dut (a,b,c,C_out);


initial begin // Apply stimulus
$dumpfile("adder_tb.vcd");
$dumpvars(0, adder_tb);
a = 0; b = 0; 

#10 a = -1;
#15 b = -1;
#20 a = 1;
#10 a = 2147483648;
#10 b = 2147483648;
#10 a = 4294967296;
#10 b = 4294967296;



$finish; // This system tasks ends the simulation
end
initial begin // Response monitor
$monitor ("t = %3d, a = %b, b = %b, c = %b, C_out = %b", $time, a,b,c,C_out);
end
endmodule