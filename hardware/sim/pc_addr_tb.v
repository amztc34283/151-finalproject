`DEFINE PC_BUS_WIDTH 14
module pc_adder_tb();
  reg [`PC_BUS_WIDTH - 1:0] pc;
  wire [`PC_BUS_WIDTH - 1:0] pc_plus_4;
  
  pc_addr DUT(.PC(pc), .PC_out(pc_plus_4));
  
  initial begin
  	pc = 0;
    #(1)
    if (pc_plus_4 != 4)
      $display("failed");
    
    $finish();
   end
endmodule