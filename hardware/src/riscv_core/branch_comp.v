module branch_comp (
    input [31:0] ra1,
    input [31:0] ra2,
    input BrUn,
    output BrEq,
    output BrLT
);

    assign BrEq = BrUn ? ($unsigned(ra1) == $unsigned(ra2)) : ($signed(ra1) == $signed(ra2));
    assign BrLT = BrUn ? ($unsigned(ra1) < $unsigned(ra2)) : ($signed(ra1) < $signed(ra2));

endmodule
