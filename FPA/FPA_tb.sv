`timescale 1ps/1ps
`include "FPA.sv"
module FPA_tb;
logic  [31:0] a, b;
logic  [31:0] s;


FPA dut (a,b,s);


initial begin // Apply stimulus
$dumpfile("FPA_tb.vcd");
$dumpvars(0, FPA_tb);
a = 1; b = 1; 


#20 a = 1.25;
#10 a = 2.68;
#10 b = 3.14159;
#10 a = 4.62;
#10 b = 5.3;



$finish; // This system tasks ends the simulation
end
initial begin // Response monitor
$monitor ("t = %3d, a = %b, b = %b, s = %b", $time, a,b,s);
end
endmodule