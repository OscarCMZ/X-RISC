module ALU_decoder2(input logic  [1:0] ALUOp,
                    input logic [2:0] funct3,
                    input logic       opb5,
                    input logic [6:0] funct7,
                    
                    output logic [3:0] ALUControl);
    
   
    always_comb

        case(ALUOp)
            2'b00:                      ALUControl = 4'b0000; // performs addition;
            2'b01:                       ALUControl = 4'b0001; // performs subtraction;
            default: case(funct3)
                    3'b000: 
                        case(funct7)
                            7'b0000000:         ALUControl = 4'b0000; // add,addi;
                            7'b0000001:         ALUControl = 4'b1001; // multiply;
                            7'b0100000:         ALUControl = 4'b0001; // R type subtraction;
                        endcase
                    3'b010:                 ALUControl = 4'b0101; // set less than,slti;
                    3'b110:                 ALUControl = 4'b0011; // or,ori;
                    3'b111:                 ALUControl = 4'b0010; // and,andi;
                    3'b100:                 ALUControl = 4'b0100; // divide(signed)
                    3'b101: if (funct7 == 7'b0100000)        
                                            ALUControl = 4'b0110; // shift right arithmetic
                            else
                                            ALUControl = 4'b0111; // shift right logical
                    3'b001:                 ALUControl = 4'b1000; // shift left logical
                    default:                ALUControl = 4'bxxxx; // ???
            endcase
        endcase
endmodule
