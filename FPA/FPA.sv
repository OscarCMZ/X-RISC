module FPA(input logic [31:0] a, b,
output logic [31:0] s);
logic [7:0] expa, expb, exp_pre, exp, shamt;
logic alessb;
logic [23:0] manta, mantb, shmant;
logic [22:0] fract;
assign {expa, manta} = {a[30:23], 1'b1, a[22:0]};
assign {expb, mantb} = {b[30:23], 1'b1, b[22:0]};
assign s = {1'b0, exp, fract};
expcomp expcomp1(expa, expb, alessb, exp_pre,
shamt);
shiftmant shiftmant1(alessb, manta, mantb,
shamt, shmant);
addmant addmant1(alessb, manta, mantb,
shmant, exp_pre, fract, exp);
endmodule

module expcomp(input logic [7:0] expa, expb,
output logic alessb,
output logic [7:0] exp, shamt);
logic [7:0] aminusb, bminusa;
assign aminusb = expa - expb;
assign bminusa = expb - expa;
assign alessb = aminusb[7];
always_comb
if (alessb) begin
exp = expb;
shamt = bminusa;
end
else begin
exp = expa;
shamt = aminusb;
end
endmodule

module shiftmant(input logic alessb,
input logic [23:0] manta, mantb,
input logic [7:0] shamt,
output logic [23:0] shmant);
    logic [23:0] shiftedval;
    assign shiftedval = alessb ?
    (manta >> shamt) : (mantb >> shamt);
    
    always@*
    if (shamt[7] | shamt[6] | shamt[5] | (shamt[4] && shamt[3]))
        shmant = 24'b0;
    else                        shmant = shiftedval;
endmodule

module addmant(input logic alessb,
input logic [23:0] manta,
mantb, shmant,
input logic [7:0] exp_pre,
output logic [22:0] fract,
output logic [7:0] exp);
logic [24:0] addresult;
logic [23:0] addval;
assign addval = alessb ? mantb : manta;
assign addresult = shmant + addval;
assign fract = addresult[24] ?
addresult[23:1] :
addresult[22:0];
assign exp = addresult[24] ?
(exp_pre + 1) :
exp_pre;
endmodule
