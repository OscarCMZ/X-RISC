//Top-level Module
module top(input         clk, reset, 
           output [31:0] WriteData, DataAdr, 
           output        MemWrite);

  logic [31:0] PC, Instr, ReadData;
  
  // instantiate processor and memories
  XRISC_single XRISC(clk, reset, PC, Instr, MemWrite, DataAdr, WriteData, ReadData);
  imem imem(PC, Instr);
  dmem dmem(clk, Memwrite, DataAdr, WriteData, ReadData);
endmodule

//Single-cycle RISC-V processor
module XRISC_single(input  logic clk,reset,
                    output logic [31:0] PC,
                    input  logic [31:0] Instr,
                    output logic        MemWrite,
                    output logic [31:0] ALUResult,WriteData,
                    input  logic [31:0] ReadData);

    logic ALUSrc, RegWrite, Jump, Zero;
    logic [1:0] ResultSrc, ImmSrc;
    logic [3:0] ALUControl;

    controller c(Instr[6:0],Instr[14:12],Instr[30], Zero, ResultSrc, MemWrite, PCSrc, ALUSrc, RegWrite, Jump, ImmSrc, ALUControl);

    datapath dp(clk, reset, ResultSrc, PCSrc, ALUSrc, RegWrite, ImmSrc, ALUControl, Zero, PC, Instr, ALUResult, WriteData, ReadData);

endmodule

//Controller
module controller(  input logic [6:0] op,
                    input logic [2:0] funct3,
                    input logic [6:0] funct7,
                    input logic       Zero,
                    output logic [1:0] ResultSrc,
                    output logic       MemWrite,
                    output logic       PCSrc, ALUSrc,
                    output logic       RegWrite, Jump,
                    output logic [1:0] ImmSrc,
                    output logic [3:0] ALUControl);
    logic [1:0] ALUOp;
    logic Branch;

    Main_decoder md(op, ResultSrc,MemWrite, Branch, ALUSrc, RegWrite, Jump, ImmSrc, ALUOp);
    ALU_decoder ad(op[5], funct3, funct7, ALUOp, ALUControl);

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

//Datapath
module datapath(input  logic        clk,reset,
                input  logic [1:0]  ResultSrc,
                input  logic        PCSrc,ALUSrc,
                input  logic        RegWrite,
                input  logic [1:0]  ImmSrc,
                input  logic [3:0]  ALUControl,
                output logic        Zero,
                output logic [31:0] PC,
                output logic [31:0] ALUResult, WriteData,
                input  logic [31:0] ReadData);
    logic [31:0] PCNext, PCPlus4, PCTarget;
    logic [31:0] ImmExt;
    logic [31:0] SrcA, SrcB;
    logic [31:0] Result;

    //next PC logic
    resettable_ff #(32) pcreg(clk, reset, PCNext, PC);
    adder       pcadd4(PC,32'd4, PCPlus4);
    adder       pcaddbranch(PC, ImmExt, PCTarget);
    mux2 #(32)  pcmux(PCPlus4, PCTarget, PCSrc, PCNext);

    //register file logic
    regfile     rf(clk, RegWrite, Instr[19:15], Instr[24:20], Instr[11:7], Result, SrcA, WriteData);
    extendunit      ext(Instr[31:7], ImmSrc, ImmExt);

    //ALU logic
    mux2 #(32)  srcbmux(WriteData,ImmExt, ALUSrc, SrcB);
    alu         alu(SrcA, SrcB, ALUControl, ALUResult, Zero);
    mux3 #(32)  resultmux(ALUResult, ReadData, PCPlus4, ResultSrc, Result);

endmodule

module alu(input logic          [31:0] SrcA,SrcB,  // ALU 32-bit Inputs                 
           input logic          [3:0] ALUControl,// ALU Control signal from ALU decoder
           output logic         [31:0] ALUResult, // ALU 32-bit Output
           output logic         Zero); // Zero Flag
   
    logic [32:0] ALU_Result;
    wire [32:0] tmp;
    assign ALU_Out = ALUResult; // ALU out
    assign tmp = {1'b0,SrcA} + {1'b0,SrcB};
    assign Zero = (ALUResult == 32'b0); // Zero flag
    //assign CarryOut = tmp[32]; // Carryout flag
    
    always_comb
        case(ALUControl)
            4'b0000: // Addition
               ALUResult = SrcA + SrcB ; 
            4'b0001: // Subtraction
               ALUResult = SrcA - SrcB ;
            4'b1001: // Multiplication
               ALUResult = SrcA * SrcB;
            4'b0100: // Division
               ALUResult = SrcA / SrcB;
            4'b1000: // shift left logical
               ALUResult = SrcA << SrcB;
            4'b0111: // Logical shift right
               ALUResult = SrcA >> SrcB;
            4'b0010: //  and 
               ALUResult = SrcA & SrcB;
            4'b0011: //  or
               ALUResult = SrcA | SrcB;
            4'b0111: // shift right arithmetic
               ALUResult = SrcA >>> SrcB;       
            
        endcase
endmodule 

module adder(input logic  [31:0] a,
             input logic  [31:0] b,
             output logic  [31:0] c);
  //logic [32:0] y_test;
    assign c = a + b;
                                
endmodule

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
            // J type
            2'b11: immext = {{12{instr[31]}}, {instr[19:12]}, { instr[20]}, {instr[30:21]}, 1'b0};
            default: immext = 32'bx;
        endcase
endmodule

module resettable_ff_enable #(parameter WIDTH = 32)
                (input logic            clk, reset, en,
                 input logic [WIDTH-1:0]d,
                 output logic [WIDTH-1:0]q);
always_ff@(posedge clk, posedge reset)
    if (reset) q <= 0;
    else if (en) q <= d;
endmodule

module resettable_ff #(parameter WIDTH = 32)
                (input logic            clk, reset,
                 input logic [WIDTH-1:0]d,
                 output logic [WIDTH-1:0]q);
always_ff@(posedge clk, posedge reset)
    if (reset)  q <= 0;
    else        q <= d;
endmodule

module mux3 #(parameter WIDTH = 8)
            (input logic [WIDTH-1:0] d0, d1, d2,
            input logic  [1:0]       s,
            output logic [WIDTH-1:0] y);

assign y = s[1] ? d2 : (s[0] ? d1 : d0);
endmodule

module mux2 #(parameter WIDTH = 8)
            (input logic [WIDTH-1:0] d0, d1, 
            input logic              s,
            output logic [WIDTH-1:0] y);

assign y = s ? d1 : d0;
endmodule

//data memory
module dmem(input  logic            clk, we,
            input  logic    [31:0] a, wd,
            output logic    [31:0] rd);

  logic  [31:0] RAM[63:0];

  assign rd = RAM[a[31:2]]; // word aligned

  always @(posedge clk)
    if (we)
      RAM[a[31:2]] <= wd;
endmodule

//instruction memory
module imem(input  logic    [31:0] a,
            output logic    [31:0] rd);

  logic  [31:0] RAM[63:0];

  initial
    begin
      $readmemh("riscvtest1.txt",RAM);
    end

  assign rd = RAM[a]; // word aligned
endmodule

module regfile(input logic      clk, 
               input            WE3, 
               input  [4:0]     A1, A2, A3, 
               input  [31:0]    WD3, 
               output [31:0]    RD1, RD2);
    reg [31:0] rf[31:0];
    always @(posedge clk)
        if (WE3) rf[A3] <= WD3;	

    assign RD1 = (A1 != 0) ? rf[A1] : 0;
    assign RD2 = (A2 != 0) ? rf[A2] : 0;
endmodule

