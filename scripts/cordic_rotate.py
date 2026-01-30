

import math
import sys
from random import randint


def cordic_phase_shifter (x,y,p ,n , LOG2_PHASE_SCALE) :

   # x,y coordinates in integer
   # required phase shift scaled to (2**PHASE_WIDTH)/360 
   # n is Number of Stages applied, will effect accuracy
   # PHASE_WIDTH_PARAM is an agreed scale representation of the phase
   # the value is phase*(2^LOG2_PHASE_SCALE)/360
   
   for i in range (n) :  # iterate number of stages
   
     # enable this print if you want to see cordic convergence
     #print ("STEP%3d: x=%10d  ,  y=%10d  ,  p=%10d" % (i,x,y,p)) 
          
     atan_val = arctan(i,LOG2_PHASE_SCALE) # = arctng(2**i)*(2**LOG2_PHASE_SCALE)

     dy = math.floor(y/(2**i))
     dx = math.floor(x/(2**i))
     
     if p > 0 :     
       new_x = x - dy 
       new_y = y + dx
       new_p = p - atan_val
     else :
       new_x = x + dy 
       new_y = y - dx
       new_p = p + atan_val
       
     x = new_x
     y = new_y
     p = new_p
          
     
   # OUTPUT
   
   LOG2_GAIN_SCALE = 16 # Scaling calculation to avoid float multiplication
   CORDIC_K = 1.6467
   scaled_gain = math.floor((2**LOG2_GAIN_SCALE)/CORDIC_K) # constant integer
   
   x = math.floor((x * scaled_gain)/(2**LOG2_GAIN_SCALE))  # de-scaling
   y = math.floor((y * scaled_gain)/(2**LOG2_GAIN_SCALE))  # de-scaling

   return(x,y)
   
#------------------------------------------------------------------------------

def arctan(stage,LOG2_PHASE_SCALE) :

   # returns constant pgase value value of arctan(2**n) 
   # the returned phase value scaled (2^PHASE_SCALE)/360

   TABLE_DEPTH = 31
   LOG2_ATAN_TABLE_SCALE = 32
   
   atan_table = [None]*31  # List for max n=31 
 
   atan_table[0]  = int32b("00100000000000000000000000000000") # 45.000 degrees -> atan(2^0)  , scaled by (2^32)/360  degree bit resolution
   atan_table[1]  = int32b("00010010111001000000010100011101") # 26.565 degrees -> atan(2^-1)
   atan_table[2]  = int32b("00001001111110110011100001011011") # 14.036 degrees -> atan(2^-2)
   atan_table[3]  = int32b("00000101000100010001000111010100") # atan(2^-n) ...
   atan_table[4]  = int32b("00000010100010110000110101000011")
   atan_table[5]  = int32b("00000001010001011101011111100001")
   atan_table[6]  = int32b("00000000101000101111011000011110")
   atan_table[7]  = int32b("00000000010100010111110001010101")
   atan_table[8]  = int32b("00000000001010001011111001010011")
   atan_table[9]  = int32b("00000000000101000101111100101110")
   atan_table[10] = int32b("00000000000010100010111110011000")
   atan_table[11] = int32b("00000000000001010001011111001100")
   atan_table[12] = int32b("00000000000000101000101111100110")
   atan_table[13] = int32b("00000000000000010100010111110011")
   atan_table[14] = int32b("00000000000000001010001011111001")
   atan_table[15] = int32b("00000000000000000101000101111101")
   atan_table[16] = int32b("00000000000000000010100010111110")
   atan_table[17] = int32b("00000000000000000001010001011111")
   atan_table[18] = int32b("00000000000000000000101000101111")
   atan_table[19] = int32b("00000000000000000000010100011000")
   atan_table[20] = int32b("00000000000000000000001010001100")
   atan_table[21] = int32b("00000000000000000000000101000110")
   atan_table[22] = int32b("00000000000000000000000010100011")
   atan_table[23] = int32b("00000000000000000000000001010001")
   atan_table[24] = int32b("00000000000000000000000000101000")
   atan_table[25] = int32b("00000000000000000000000000010100")
   atan_table[26] = int32b("00000000000000000000000000001010")
   atan_table[27] = int32b("00000000000000000000000000000101")
   atan_table[28] = int32b("00000000000000000000000000000010")
   atan_table[29] = int32b("00000000000000000000000000000001")
   atan_table[30] = int32b("00000000000000000000000000000000")

   return atan_table[stage]/(2**(32-LOG2_PHASE_SCALE)) # get the most significant PHASE_SCALE bits
   
#----------------------------------------------------------------- 
  
def int32b(bin_str) :
     return int(bin_str,2)

#-----------------------------------------------------------------     
# main - TEST

LOG2_PHASE_SCALE = 32
PHASE_SCALE = (2**LOG2_PHASE_SCALE)/360

with open('x_in.mem', 'w') as fx_in, open('y_in.mem', 'w') as fy_in, open('p_in.mem', 'w') as fp_in,\
     open('x_out_ref.mem', 'w') as fx_out, open('y_out_ref.mem', 'w') as fy_out:
  for i in range (20) :

    x_in = randint(20,100)
    y_in = randint(20,100)  
    p_in = randint(0,90)
    p_in_scaled = p_in * PHASE_SCALE

    amp_in_ideal = math.sqrt(x_in**2 + y_in**2)
    amp_in = math.floor(amp_in_ideal)
    p_orig = math.degrees(math.atan(y_in/x_in))
    if (p_orig<0) and (y_in>0) : 
      p_orig = p_orig + 180
    p_out_ideal = p_in + p_orig
    x_out_ideal = amp_in * math.cos(math.radians(p_out_ideal))
    y_out_ideal = amp_in * math.sin(math.radians(p_out_ideal))

    (x_out,y_out) = cordic_phase_shifter(x=x_in,y=y_in, p=p_in_scaled, n=20, LOG2_PHASE_SCALE=LOG2_PHASE_SCALE) 

  
    amp_out = math.floor(math.sqrt(x_out**2 + y_out**2))
    p_out = math.degrees(math.atan(y_out/x_out)) if x_out!=0 else (90 if y_out>0 else 270)
    if (p_out<0) and (y_out>0) :
      p_out = p_out + 180

    sys.stdout.write (" INPUT:  x=%3d, y=%3d (amp=%3d, ph=%3d) p=%3d \n"                % (x_in,y_in,amp_in,p_orig,p_in))
    sys.stdout.write (" OUTPUT: x=%3d, y=%3d (amp=%3d, ph=%3d)\n"                      % (x_out,y_out,amp_out,p_out))
    sys.stdout.write (" IDEAL:  x=%6.1f, y=%6.1f (amp_out_ideal=%5.1f, ph=%6.1f)\n"    % (x_out_ideal,y_out_ideal,amp_in,p_out_ideal))
    sys.stdout.write (" PHASE_ERROR=%5.1f\n\n"  % (p_out-p_out_ideal))

##################################################################################

    x_out = int(x_out)
    y_out = int(y_out)
    
    fx_in.write("%02x\n" % (x_in & 0xFF))
    fy_in.write("%02x\n" % (y_in & 0xFF))
    fp_in.write("%08x\n" % (int(p_in_scaled) & 0xFFFFFFFF))
    fx_out.write("%02x\n" % (x_out & 0xFF))
    fy_out.write("%02x\n" % (y_out & 0xFF))
