//From Dally-Harting
//----------------------------------------------------------------------
// Seven Segment Decoder
//----------------------------------------------------------------------
// Figure 7.20
// define segment codes
// Modified for sinking cathodes (led on when bit is low)
// seven bit code - one bit per segment, segment is illuminated when
// bit is low.  Bits 6543210 correspond to: 
//
//         6666
//        1    5
//        1    5
//         0000
//        2    4
//        2    4
//     7   3333
// Notice that a bit 7 would turn on a decimal point if existent
//
//----------------------------------------------------------------------
//`define SS_0 7'b1111110
`define SS_0   7'b0000001
//`define SS_1 7'b0110000
`define SS_1   7'b1001111
//`define SS_2 7'b1101101
`define SS_2   7'b0010010
//`define SS_3 7'b1111001
`define SS_3   7'b0000110
//`define SS_4 7'b0110011 
`define SS_4   7'b1001100
//`define SS_5 7'b1011011
`define SS_5   7'b0100100 
//`define SS_6 7'b1011111
`define SS_6   7'b0100000
//`define SS_7 7'b1110000
`define SS_7   7'b0001111
//`define SS_8 7'b1111111
`define SS_8   7'b0000000
//`define SS_9 7'b1111011
`define SS_9   7'b0000100
`define SS_A   7'b0001000 
`define SS_B   7'b1100000             
`define SS_C   7'b0110001
`define SS_D   7'b1000010 
`define SS_E   7'b0110000
`define SS_F   7'b0111000

//Adding decimal point
`define SS_DP 1'b0