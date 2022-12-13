module extendunit(input logic [31:0] instr,
                  input logic [1:0]  immsrc,
                  output logic [31:0] immext);
    always@*
        case(immsrc)
            // I type
            2'b00: immext = {{20{instr[31]}}, {instr[31:20]}};
            // S type
            2'b01: immext = {{20{instr[31]}}, {instr[31:25]}, {instr[11:7]}};
            // B type
            2'b10: immext = {{20{instr[31]}}, {instr[7]}, { instr[30:25]}, {instr[11:8]}, 1'b0};
            default: immext = 32'bx;
        endcase
endmodule
