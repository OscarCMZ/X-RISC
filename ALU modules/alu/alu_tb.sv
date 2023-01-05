`timescale 1ps/1ps
`include "alu.sv"
module alu_tb;
logic [31:0] A;
logic [31:0] B;
logic [3:0] ALUControl;
logic [31:0] ALUResult;
logic CarryOut;

alu dut (A, B, ALUControl, ALUResult, CarryOut);


initial begin // Apply stimulus
$dumpfile("alu_tb.vcd");
$dumpvars(0, alu_tb);

A = 8; B = 3; ALUControl = 4'b0000;
#10 ALUControl = 4'b0001;
#10 ALUControl = 4'b1001;
#10 ALUControl = 4'b0100;
#10 ALUControl = 4'b1000;
#10 ALUControl = 4'b0111;
#10 ALUControl = 4'b0010;
#10 ALUControl = 4'b0011;
#10 ALUControl = 4'b0111;
$finish; // This system tasks ends the simulation
end
initial begin // Response monitor
$monitor ("t = %3d, A = %b, B = %b, ALUControl = %b, ALUResult = %b, CarryOut = %b", $time, A, B, ALUControl, ALUResult, CarryOut);
end
endmodule
