'CMUCam Test
OBJ
      CAM : "CMUcamDriver"
   
VAR
      BYTE N_PACK[9], S_PACK[7]

CON
      _CLKMODE = XTAL1 + PLL16X
      _XINFREQ = 5_000_000

      'CMUcam pins
      CAM_TX = 22                   'The pin connected to CMUcam's TX pin
      CAM_RX = 23                   'The pin connected to CMUcam's RX pin

      'N Packet
      SPOS     = 0                  '<< "SPOS" used for S Packet too << Servo position
      MIDX     = 1                  'Middle-X
      MIDY     = 2                  'Middle-Y
      OBX1     = 3                  'Object size-X1
      OBY1     = 4                  'Object size-Y1
      OBX2     = 5                  'Object size-X2
      OBY2     = 6                  'Object size-Y2
      PIXCNT   = 7                  'Tracked pixel count
      CONFID   = 8                  'Confidence
       
      'S Packet
      RMEAN    = 1                  'Red mean
      GMEAN    = 2                  'Green mean
      BMEAN    = 3                  'Blue mean
      RDEV     = 4                  'Red deviation
      GDEV     = 5                  'Green deviation
      BDEV     = 6                  'Blue deviation
      
PUB MAIN
      CAM.START(CAM_TX, CAM_RX, @N_PACK, @S_PACK)
      

{
   Packets:
    N Packet: [0]Servo position, [1]Middle-X, [2]Middle-Y, [3]Object size-X1, [4]Object size-Y1,
              [5]Object size-X2, [6]Object size-Y2, [7]Tracked pixel count, [8]Confidence
    S Packet: [0]Servo position, [1]Red mean, [2]Green mean, [3]Blue mean,
              [4]Red deviation, [5]Green deviation, [6]Blue deviation


   Notes:
     * I've made the TX and RX family of subroutines (at the bottom) public so that you may
       send custom commands to the CMUcam if so needed.
     * I specifically chose to use only the N and S packets to give you nearly the most
       information possible.
     * No external objects needed for this program, completely self-contained.    
     * See the subroutines below for information about their functions and how to use them. 
}