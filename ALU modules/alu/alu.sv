module alu(input logic          [31:0] A,B,  // ALU 32-bit Inputs                 
           input logic          [3:0] ALUControl,// ALU Control signal from ALU decoder
           output logic         [31:0] ALUResult, // ALU 32-bit Output
           output logic         CarryOut); // Carry Out Flag
   
    logic [32:0] ALU_Result;
    wire [32:0] tmp;
    assign ALU_Out = ALUResult; // ALU out
    assign tmp = {1'b0,A} + {1'b0,B};
    assign CarryOut = tmp[32]; // Carryout flag
    
    always_comb
        case(ALUControl)
            4'b0000: // Addition
               ALUResult = A + B ; 
            4'b0001: // Subtraction
               ALUResult = A - B ;
            4'b1001: // Multiplication
               ALUResult = A * B;
            4'b0100: // Division
               ALUResult = A / B;
            4'b1000: // shift left logical
               ALUResult = A << B;
            4'b0111: // Logical shift right
               ALUResult = A >> B;
            4'b0010: //  and 
               ALUResult = A & B;
            4'b0011: //  or
               ALUResult = A | B;
            4'b0111: // shift right arithmetic
               ALUResult = A >>> B;       
        endcase


endmodule
