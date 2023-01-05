`timescale 1ps/1ps
`include "extendunit.sv"
module extendunit_tb;
logic [31:0]instr;
logic [1:0]  immsrc;
logic [31:0] immext;
extendunit dut (instr, immsrc, immext);


initial begin // Apply stimulus
$dumpfile("extendunit_tb.vcd");
$dumpvars(0, extendunit_tb);

instr = 32'hFFC4A303; 


#10 immsrc = 00;
#10 immsrc = 01;
#10 immsrc = 10;
#10;


$finish; // This system tasks ends the simulation
end
initial begin // Response monitor
$monitor ("t = %3d, instr = %b, immsrc = %b, immext = %b", $time, instr, immsrc, immext);
end
endmodule
