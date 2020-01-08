module GCD(
input [15:0] SW,
input CLK100MHZ,
input BTNC,
output [7:0] CA,
output [7:0] AN,
output [15:0] LED
);

parameter START = 3'b000, S1 = 3'b001, S2 = 3'b010, S3 = 3'b011, SET = 3'b100;
reg [2:0] state, nextstate;
reg [7:0] GCD, A, B, regCA,regAN;
reg val;
wire [7:0] cath[7:0];
wire SLOWCLK;

SLOW_CLK s1(CLK100MHZ,SLOWCLK);

display  d1(GCD[7:4],cath[1]);
display  d2(GCD[3:0],cath[0]);

assign AN[1:0] = regAN;
assign CA = regCA;

initial val = 1'b0;
initial regAN[1:0] = 2'b10;

always @(posedge SLOWCLK) begin
    val = val + 1'b1;
    regAN[1:0] = {regAN[0], regAN[1]};
    regCA = cath[val];
end

always @(posedge CLK100MHZ) begin
    state <= nextstate;
end

initial state = SET;

always @(state or BTNC) begin
    case(state)
          SET: begin 
            if(BTNC) 
                nextstate <= START;
            else 
                nextstate <= SET;
            end
        START: begin
            if(A == B) nextstate <= S3;
            else if(A > B) nextstate <= S1;
            else nextstate <= S2;
        end
        S1: nextstate <= START;
        S2: nextstate <= START;
        S3: nextstate <= SET;    
    endcase
end

always @(posedge CLK100MHZ) begin
    case(state)
       SET: begin 
                A <= SW[15:8]; 
                B <= SW[7:0]; 
            end
        S1: A <= A - B;
        S2: B <= B - A;
        S3: GCD <= A;
    endcase
end

assign LED = SW;
endmodule

module display(
input      [7:0] num,
output reg [7:0] cathodes
);

always @(num) begin
    case(num)
        8'h0:   cathodes = 7'b1111110;
        8'h1:   cathodes = 7'b0110000;
        8'h2:   cathodes = 7'b1101101;
        8'h3:   cathodes = 7'b1111001;
        
        8'h4:   cathodes = 7'b0110011;
        8'h5:   cathodes = 7'b1011011;
        8'h6:   cathodes = 7'b1011111;
        8'h7:   cathodes = 7'b1110000;
        
        8'h8:   cathodes = 7'b1111111;
        8'h9:   cathodes = 7'b1111011;
        8'hA:   cathodes = 7'b1110111;
        8'hB:   cathodes = 7'b0011111;
        
        8'hC:   cathodes = 7'b1001110;
        8'hD:   cathodes = 7'b0111101;
        8'hE:   cathodes = 7'b1001111;
        8'hF:   cathodes = 7'b1000111;
     default:   cathodes = 7'b1111110;
    endcase
    
    cathodes = {cathodes, 1'b0}; //for decimal point
    cathodes = ~cathodes; //for active low
end

endmodule

module SLOW_CLK(
    input FASTCLK,
    output reg SLOWCLK
);

reg [31:0] ctr;
initial ctr = 32'h0000_0000;
initial SLOWCLK = 0;

always@(posedge FASTCLK) begin
    ctr = ctr + 32'h0000_0001;
    if(ctr >= 32'h0001_86A0 ) begin
            ctr = 32'h0000_0000;
            SLOWCLK = ~SLOWCLK;
    end
end

endmodule
