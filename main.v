module main(in, row, column, clkin);
  //**********parmeters**************
  parameter n=32;
  parameter nl2=5;
  parameter cfd=4;
  parameter sfd = 17;
  parameter ofd = 17;
  parameter sts= 4;
  
  //**********inputs and outputs**************
  input [7:0] in;
  output [7:0] row, column;
  input clkin;
  wire clk, sclk;
  
  //**********states and stages**************
  wire [sts-1:0] stage;
  wire [nl2-2:0] cnt;
  reg [nl2+sts-2:0] state;
  assign cnt = state[nl2-2:0];
  assign stage = state[nl2+sts-2:nl2-1];
  
  
  //**********samples and data**************
  reg signed [7:0] samples[n-1:0];
  reg signed [15:0] data[n-1:0];
  integer i;
  
  //**************LUT********************
  wire [15:0] lut[n/2-1:0];
  assign lut[0] = 16'b01111111_00000000,
	lut[1] = 16'b01111101_00011000,
	lut[2] = 16'b01110110_00110000,
	lut[3] = 16'b01101010_01000111,
	lut[4] = 16'b01011010_01011010,
	lut[5] = 16'b01000111_01101010,
	lut[6] = 16'b00110000_01110110,
	lut[7] = 16'b00011000_01111101,
	lut[8] = 16'b00000000_01111111,
	lut[9] = 16'b11100111_01111101,
	lut[10] = 16'b11001111_01110110,
	lut[11] = 16'b10111000_01101010,
	lut[12] = 16'b10100101_01011010,
	lut[13] = 16'b10010101_01000111,
	lut[14] = 16'b10001001_00110000,
	lut[15] = 16'b10000010_00011000;
  
  
  
  
  
  
  //**********butterfly**************
  wire [15:0] bfin1, bfin2, tf, bfout1, bfout2;
  butterfly bfmod (bfin1, bfin2, tf, bfout1, bfout2);
  
  //**********butterfly indice**************
  wire [nl2-1:0] ind1, ind2;
  wire [nl2-2:0] tind;
  wire [sts-1:0] pos;
  
  //**********indice selection**************
  wire [nl2-1:0] mask;
  assign pos=stage-1,
    mask=({nl2{1'b1}}>>pos)<<pos,
      
    ind1 = ((cnt&mask)<<1)|(cnt&(~mask)),
    ind2 = ind1|(1'b1<<pos),
      
    tind=cnt<<(nl2-stage);
  
  //**********butterfly input selection *************
  assign bfin1 = data[ind1],
    bfin2 = data[ind2],
    tf=lut[tind];
  
  //**********bit reversal**************
  wire [nl2-1:0] c[n-1:0];
  wire [nl2-1:0] r[n-1:0];
  genvar k,l;
  generate
    for(k=0;k<n;k=k+1)
      begin:loop1
        assign c[k]=k;
        for(l=0;l<nl2;l=l+1)
          begin:loop2
            assign r[k][l]=c[k][nl2-1-l];
          end
      end
  endgenerate
  
  
  
  
  //*********power value**************
  wire [15:0] val;
  wire signed [7:0] re, im;
  wire signed [15:0] re2, im2, sum;
  wire [7:0] aval;
  wire sc;
  
  assign sc=(stage==nl2+2);
  assign val = data[cnt];
  assign re[7:0] = sc? data[n/2][15:8]:val[15:8]<<1,
    im[7:0]=sc? data[n/2][7:0]: (val[7:0]<<1),
    re2=re,
    im2=im,
    sum=re2*re2+im2*im2,
    aval=sum[14]?sum[14:6]-1:sum[14:6];
  
  //********output calculation*************
  reg [15:0] summer;
  reg [7:0] outr[7:0];
  wire [15:0] summed;
  assign summed = summer + aval;
  
  
  //final output
  reg [ofd+2:0] ocount;
  assign clk = ocount[cfd];
  assign sclk = ocount[sfd];
  wire [7:0] cur;
  wire [2:0] cc;
  assign cc= ocount[ofd+2:ofd],
    cur = outr[cc],
    column = 8'b10_00_00_00>>cc;
  
  assign row[7]=~cur[7];
  genvar m;
  generate
    for(m=0;m<7;m=m+1)
      begin:loop
        assign row[m]=row[m+1]&(~cur[m]);
      end
  endgenerate
  
  
  
  
  //**********initial state**************
  initial 
  begin
    state=(nl2+1)<<(nl2-1);
    ocount=0;
    for (i=0;i<n;i=i+1)
      begin
        samples[i]=0;
		  data[i]=0;
      end
  end
  
  
  
  
  always @(posedge clkin)
    begin
      ocount <= ocount + 1;
    end
  
  
  //**********next state logic**************
  always @(posedge clk)
    begin
      
      
      case (stage)
        0:
          begin
            for(i=0;i<n;i=i+1)
              begin
                data[c[i]]<={samples[r[i]], 8'b0};
              end
            
            state[nl2+sts-2:nl2-1]<=1;
            state[nl2-2:0]<=0;
          end
        
        4'd7:
          begin
            outr[7]<=summed;
            
            state<=0;
          end
        
        4'd6:
          begin
            case (cnt)
              0:
                summer<=aval;
              2:
                begin
                  outr[0]<=summed;
                  summer<=0;
                end
              4:
                begin
                  outr[1]<=summed;
                  summer<=0;
                end
              6:
                begin
                  outr[2]<=summed;
                  summer<=0;
                end
              8:
                begin
                  outr[3]<=summed;
                  summer<=0;
                end
              10:
                begin
                  outr[4]<=summed;
                  summer<=0;
                end
              12:
              begin
                  outr[5]<=summed;
                  summer<=0;
                end
              14:
                begin
                  outr[6]<=summed;
                  summer<=0;
                end
              
              default:
                summer<=summed;
              
            endcase
            state <= state + 1;
            
          end
        
        default:
          begin
            
            for(i=0;i<n;i=i+1)
              if(ind1==i)
                data[i]<=bfout1;
            for(i=0;i<n;i=i+1)
              if(ind2==i)
                data[i]<=bfout2;
            
            state<=state+1;
          end
        
      endcase
    end
    
  //**********sampling block**************
  always @(posedge sclk) 
    begin
      
      samples[0] <= in-8'd128;
      for (i=1;i<n;i=i+1)
        samples[i]<=samples[i-1];
    end 
     
  
endmodule 


