`timescale 1ps/1ps
`include "ALU_decoder.sv"
module ALU_decoder_tb;
logic  [1:0] ALUOp;
logic  [2:0] funct3;
logic       opb5;
logic       funct7b5;
logic  [2:0] ALUControl;

ALU_decoder dut (ALUOp,funct3,opb5,funct7b5,ALUControl);


initial begin // Apply stimulus
$dumpfile("ALU_decoder_tb.vcd");
$dumpvars(0, ALU_decoder_tb);
ALUOp = 00;

#10 ALUOp = 01;

#10 ALUOp = 10; funct3 = 3'b010;
#10 funct3 = 3'b110;
#10 funct3 = 3'b111;
#10 funct3 = 3'b000; funct7b5 = 1; opb5 = 1;
#10 funct7b5 = 0; opb5 = 0;

$finish; // This system tasks ends the simulation
end
initial begin // Response monitor
$monitor ("t = %3d, ALUOp = %b, funct3 = %b, opb5 = %b, funct7b5 = %b, ALUControl = %b", $time, ALUOp, funct3, opb5, funct7b5, ALUControl);
end
endmodule
