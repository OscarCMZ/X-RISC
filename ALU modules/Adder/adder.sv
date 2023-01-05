module adder(input logic  [31:0] a,
             input logic  [31:0] b,
             output logic  [31:0] c,
             output logic C_out);
  //logic [32:0] y_test;
    assign {C_out,c} = a + b;
                                      
  
endmodule
