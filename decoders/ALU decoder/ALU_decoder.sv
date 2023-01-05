module ALU_decoder(input logic  [1:0] ALUOp,
                    input logic [2:0] funct3,
                    input logic       opb5,
                    input logic       funct7b5,
                    
                    output logic [2:0] ALUControl);
    
    always_comb 

        case(ALUOp)
            2'b00:                      ALUControl = 000; // performs addition;
            2'b01:                       ALUControl = 001; // performs branch if equal;
            default: case(funct3)
                3'b000: if (funct7b5 & opb5 == 1)
                                        ALUControl = 001; // R type subtraction;
                        else
                                        ALUControl = 000; // add;
                3'b010:                 ALUControl = 101; // set less than;
                3'b110:                 ALUControl = 011; // or;
                3'b111:                 ALUControl = 010; // and;
                
            endcase
        endcase
endmodule


