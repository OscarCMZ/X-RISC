//Single-cycle RISC-V processor
module XRISC_single(input  logic clk,reset,
                    output logic [31:0] PC,
                    input  logic [31:0] Instr,
                    output logic        MemWrite,
                    output logic [31:0] ALUResult,WriteData,
                    input  logic [31:0] ReadData);

    logic ALUSrc, RegWrite, Jump, Zero;
    logic [1:0] ResultSrc, ImmSrc;
    logic [2:0] ALUControl;

    controller c(Instr[6:0],Instr[14:12],Instr[30], Zero, ResultSrc, MemWrite, PCSrc, ALUSrc, RegWrite, Jump, ImmSrc, ALUControl);

    datapath dp(clk, reset, ResultSrc, PCSrc, ALUSrc, RegWrite, ImmSrc, ALUControl, Zero, PC, Instr, ALUResult, WriteData, ReadData);

endmodule

//Controller
module controller(  input logic [6:0] op,
                    input logic [2:0] funct3,
                    input logic       funct7b5,
                    input logic       Zero,
                    output logic [1:0] ResultSrc,
                    output logic       MemWrite,
                    output logic       PCSrc, ALUSrc,
                    output logic       RegWrite, Jump,
                    output logic [1:0] ImmSrc,
                    output logic [2:0] ALUControl);
    logic [1:0] ALUOp;
    logic Branch;

    Main_decoder md(op, ResultSrc,MemWrite, Branch, ALUSrc, RegWrite, Jump, ImmSrc, ALUOp);
    ALU_decoder ad(op[5], funct3, funct7b5, ALUOp, ALUControl);

    assign PCSrc = Branch & Zero | Jump;
endmodule

//Main decoder
module Main_decoder(input logic [6:0] op,
                    output logic [1:0] ResultSrc,
                    output logic       MemWrite,
                    output logic       Branch, ALUSrc,
                    output logic       RegWrite, Jump,
                    output logic [1:0] ImmSrc,
                    output logic [1:0] ALUOp);
    logic [10:0] controls;

    assign {RegWrite, ImmSrc, ALUSrc, MemWrite, ResultSrc, Branch, ALUOp, Jump} = controls;

    always_comb  
    
        case(op)
        //RegWrite_ImmSrc_ALUSrc_MemWrite_ResultSrc_Branch_ALUOp_Jump
        7'b0000011: controls = 11'b1_00_1_0_01_0_00_0; //lw
        7'b0100011: controls = 11'b0_01_1_1_00_0_00_0; //sw
        7'b0110011: controls = 11'b1_xx_0_0_00_0_10_0; //R-type
        7'b1100011: controls = 11'b0_10_0_0_00_1_01_0; //beq
        7'b0010011: controls = 11'b1_00_1_0_00_0_10_0; //I-type ALU
        7'b1101111: controls = 11'b1_11_0_0_10_0_00_1; //jal
        default:    controls = 11'bx_xx_x_x_xx_x_xx_x; //???
        endcase
endmodule

//ALU decoder
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

//Datapath
module datapath(input  logic        clk,reset,
                input  logic [1:0]  ResultSrc,
                input  logic        PCSrc,ALUSrc,
                input  logic        RegWrite,
                input  logic [1:0]  ImmSrc,
                input  logic [2:0]  ALUControl,
                output logic        Zero,
                output logic [31:0] PC,
                output logic [31:0] ALUResult, WriteData,
                input  logic [31:0] ReadData);
    logic [31:0] PCNext, PCPlus4, PCTarget;
    logic [31:0] ImmExt,
    logic [31:0] SrcA, SrcB;
    logic [31:0] Result;

    //next PC logic
    flopr #(32) pcreg(clk, reset, PCNext, PC);
    adder       pcadd4(PC,32'd4, PCPlus4);
    adder       pcaddbranch(PC, ImmExt, PCTarget);
    mux2 #(32)  pcmux(PCPlus4, PCTarget, PCSrc, PCNext);

    //register file logic
    regfile     rf(clk, RegWrite, Instr[19:15], Instr[24:20], Instr[11:7], Result, SrcA, WriteData);
    extend      ext(Instr[31:7], ImmSrc, ImmExt);

    //ALU logic
    mux2 #(32)  srcbmux(WriteData,ImmExt, ALUSrc, SrcB);
    alu         alu(SrcA, SrcB, ALUControl, ALUResult, Zero);
    mux3 #(32)  resultmux(ALUResult, ReadData, PCPlus4, ResultSrc, Result);

endmodule

   

