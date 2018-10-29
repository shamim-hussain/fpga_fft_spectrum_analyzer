


module butterfly(in1, in2, tf, out1, out2);
	
  input [15:0] in1, in2, tf;
  output [15:0] out1, out2;
	
  wire signed [7:0] in1r, in1i, in2r, in2i, tfr, tfi,out1r, out1i, out2r, out2i;
  wire signed [15:0] i1r, i1i, i2r, i2i, tr, ti, t1r, t1i, t2r, t2i, o1r, o1i, o2r, o2i;
	
  assign in1r[7:0] = in1[15:8],
    in1i[7:0] = in1[7:0],
    in2r[7:0] = in2[15:8],
    in2i[7:0] = in2[7:0],
    tfr[7:0] = tf[15:8],
    tfi[7:0] = tf[7:0],
    out1[15:8] = out1r[7:0],
    out1[7:0] = out1i[7:0],
    out2[15:8] = out2r[7:0],
    out2[7:0] = out2i[7:0];
	
  assign i1r=in1r,
      i1i=in1i,
      i2r=in2r,
      i2i=in2i,
      tr=tfr,
      ti=tfi;
  
  assign t1r=i1r<<7,
    t1i=i1i<<7;
	
  assign t2r=i2r*tr-i2i*ti,
    t2i=i2r*ti+i2i*tr;
		
  assign o1r=t1r+t2r,
    o1i=t1i+t2i;
		
  assign o2r=t1r-t2r,
    o2i=t1i-t2i;
		
  assign out1r[7:0]=o1r[15:8],
    out1i[7:0]=o1i[15:8];
		
  assign out2r[7:0]=o2r[15:8],
    out2i[7:0]=o2i[15:8];

endmodule
