module ADD(
    input signed [31:0] a,
    input signed [31:0] b,
    output reg signed [31:0] r,
    output overflow
    );
    always@(*)
    begin
       r<=a+b;
    end
    assign overflow=((a[31]==0)&&(b[31]==0)&&(r[31]==1))||((a[31]==1)&&(b[31]==1)&&(r[31]==0));
endmodule