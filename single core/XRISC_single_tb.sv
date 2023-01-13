`timescale 1ns/1ps
`include "XRISC_single.sv"

module XRISC_single_tb();

    logic           clk;
    logic           reset;
    logic   [31:0]  WriteData, DataAdr;
    logic           MemWrite;

top dut(clk, reset,WriteData, DataAdr,MemWrite);

//initialize test
initial 
    begin
        reset <= 1;#22; reset <= 0;
    end

//generate clock to sequence tests
always
    begin
        clk <= 1; #5; clk <=0; #5;
    end

//check results
/*always@(negedge clk)
    begin
        if(MemWrite) begin
            if (DataAdr === 100 & WriteData === 25) begin
                $display("Simulation succeeded");
                $stop;
            end else if (DataAdr !== 96) begin
                $display("Simulation failed");
                $stop;
            end
        end
    end*/

initial begin
    $dumpfile("XRISC_single_tb.vcd");$dumpvars;
    #100;
    $finish;
end

initial begin // Response monitor
    $monitor ("t = %3d, clk = %b, reset = %b, WriteData = %b, DataAdr = %b, MemWrite = %b", $time, clk, reset, WriteData, DataAdr, MemWrite);
end


endmodule

