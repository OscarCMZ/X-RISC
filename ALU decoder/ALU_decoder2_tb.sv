`timescale 1ps/1ps
`include "ALU_decoder2.sv"
module ALU_decoder2_tb;
logic  [1:0] ALUOp;
logic  [2:0] funct3;
logic       opb5;
logic  [6:0] funct7;
logic  [3:0] ALUControl;

ALU_decoder2 dut (ALUOp,funct3,opb5,funct7,ALUControl);


initial begin // Apply stimulus
$dumpfile("ALU_decoder2_tb.vcd");
$dumpvars(0, ALU_decoder2_tb);

ALUOp = 00;
#10 ALUOp = 01;
#10 ALUOp = 10; funct3 = 3'b010;
#10 funct3 = 3'b110;
#10 funct3 = 3'b111;
#10 funct3 = 3'b100;
#10 funct3 = 3'b001;
#10 funct3 = 3'b101; funct7 = 7'b0100000;
#10 funct7 = 7'b0000000;
#10 funct3 = 3'b000; funct7 = 7'b0100000; opb5 = 1;
#10 funct7 = 7'b0000000; opb5 = 0;
#10 funct7 = 7'b0000001;

$finish; // This system tasks ends the simulation
end
initial begin // Response monitor
$monitor ("t = %3d, ALUOp = %b, funct3 = %b, opb5 = %b, funct7 = %b, ALUControl = %b", $time, ALUOp, funct3, opb5, funct7, ALUControl);
end
endmodule