// Figure 7.22
// invsseg - converts seven segment code to binary - signals if valid
//
// segs  - seven segment code in
// bin   - binary code out
// valid - true if input is a valid seven segment code
//
//      segs = legal code (0-9) ==> valid = 1, bin = binary
//      segs = zero ==> valid = 0, bin = 0
//      segs = any other code ==> valid = 0, bin = 1
//----------------------------------------------------------------------
module invsseg(segs, bin, valid) ;
  input  [6:0] segs ;           // seven segment code in 
  output [3:0] bin ;            // four-bit binary output
  output       valid ;          // true if input code is valid
  reg    [3:0] bin ;
  reg          valid ;

  always@(*) begin
    case(segs)
      `SS_0: {valid,bin} = 5'h10 ;
      `SS_1: {valid,bin} = 5'h11 ; 
      `SS_2: {valid,bin} = 5'h12 ; 
      `SS_3: {valid,bin} = 5'h13 ; 
      `SS_4: {valid,bin} = 5'h14 ; 
      `SS_5: {valid,bin} = 5'h15 ; 
      `SS_6: {valid,bin} = 5'h16 ; 
      `SS_7: {valid,bin} = 5'h17 ; 
      `SS_8: {valid,bin} = 5'h18 ; 
      `SS_9: {valid,bin} = 5'h19 ; 
      0:     {valid,bin} = 5'h00 ;
      default: {valid,bin} = 5'h01 ;
    endcase
  end
endmodule