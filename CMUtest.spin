{{****************************************
*                                        *
*             Neot'O'NICK                *
*                                        *
******************************************
SD card file names are:
        dictate.wav
        hello.wav
        original.wav
        synthescape.wav         'doesn't play
        wakeup.wav              'doesn't play
}}

CON
  _clkmode = xtal1 + pll16x
  _xinfreq = 5_000_000

CON
  ColPos = 8  
  'CMUcam pins
  CAM_TX = 7        '7          'The pin connected to CMUcam's TX pin
  CAM_RX = 6        '6          'The pin connected to CMUcam's RX pin

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

  'Arduino
  ARDU_TX = 4   '4                'The pin connected to CMUcam's TX pin
  ARDU_RX = 5   '5                'The pin connected to CMUcam's RX pin

  'Wave Player
  bufferLen = 800    
  sdBasePin = 0
  HeadphoneRightPin = 10
  HeadphoneLeftPin = 11

OBJ 
  CAM   :   "CMUcamDriver"
  text  :   "vga_text"
  'ardu  :   "FullDuplexSerialPlus"
  spare :   "sparecogs"
  'audio :   "WavePlayerSdAccess"
  
VAR 
  BYTE N_PACK[9], S_PACK[7] 'for CMUcamDriver
  BYTE ToggleColor
  BYTE ArduByteArray[100]
  LONG SoundStack[128]
  byte buff[bufferLen]
  long stack[50] 
  
PUB Main | value, daIndex1, daIndex2', base, width, offset

'set them, Rx and Tx, to output

'set them low

'set them to input

 
  'PlayThis(string("hello.wav"))
  
  'start vga term
  text.start(16)
  PrintFreeCogs
  AnimateIt

  SetCurser(0,0)
  waitcnt(50_000_000 + cnt)
  {
  'start fullduplex connection to arduino 
  if ardu.start(ARDU_RX,ARDU_TX,4,115200) '9600, 14400, 19200, 28800, 38400, 57600, or 115200
    {          bit 0 inverts rx
               bit 1 inverts tx
               bit 2 open drain/source tx
               bit 3 ignore tx echo on rx
    }
    text.str(string($C,1,"Connected to Arduino",$C,8))
    waitcnt(50_000_000 + cnt)
    SpinalTippingOn
    SetCurser(0,0)
    text.str(string($C,1,"spinal tipping on      ",$C,8)) 
  else
    text.str(string($C,1,"NOT Connected to Arduino",$C,8))
  waitcnt(500_000_000 + cnt)
  }
  SetCurser(0,1)
  text.str(string($C,1,"Connecting to CMU ...   ",$C,8))   
  if ConnectToCMUCam 'With CMUcam on, this call never returns ************************************************************************
    text.str(string($C,1,"So far so good",$C,8))
    waitcnt(50_000_000 + cnt)
    'DoFunnyGuy(15)
    'track window
    N_PACK := CAM.TRACK_WINDOW
    NToScreen
  else
    SetCurser(0,3)
    text.str(string($C,1,"Not Connected to CMUcam    ",$C,8))
  'waitcnt(50_000_000 + cnt)
  NToScreen
  SetCurser(0,4)
  text.str(string($C,1,"check, roger, good times    ",$C,8))  
  repeat
    text.out($00)
    PrintFreeCogs
    'NToScreen
    'SpinalTippingOff
     'PrintX
     'PrintY
     PrintFreeCogs
     repeat 5
        CAM.UPDATE
        UpdateTheNPack
      
      
      {
      waitcnt(5_000_000 + cnt)
      daIndex1 := ardu.rxcheck
      'SetCurser(0,0)
      if daIndex1 == -1
        text.str(string(" "))
      else
        GetArduMessage(daIndex1)
      }
{
PRI PlayIt
  Cognew (PlayHello, @SoundStack)

PRI PlayThis(daFileToPlay)
  Cognew (PlayFile(daFileToPlay), @SoundStack)

PRI PlayHello
  audio.start(sdBasePin, HeadphoneRightPin, HeadphoneLeftPin, @buff, bufferLen)
  audio.setStack(@stack)
  'audio.playbgwave(string("hello.wav"))
  audio.playbgwave(string("original.wav"))

PRI PlayFile(daFileToPlay)
  audio.start(sdBasePin, HeadphoneRightPin, HeadphoneLeftPin, @buff, bufferLen)
  audio.setStack(@stack)
  'audio.playbgwave(string("hello.wav"))
  audio.playbgwave(daFileToPlay)
}     
PRI WaitForSerialLatency
      waitcnt(5_000_000 + cnt)
{
PRI GetArduMessage(daValue)
    SetCurser(0,1)
    text.str(string(" "))   
    repeat while daValue => 0
      ifnot (daValue == 13) or (daValue == 10) or (daValue == 138)
        text.dec(daValue)
        text.str(string(" "))
      daValue := ardu.rxcheck
      
    ardu.rxflush

PRI SetHead(daHeadPosition) |  daValue
      ardu.tx(3)  
      WaitForSerialLatency
      daValue := ardu.rxcheck
      ifnot daValue == -1
        if daValue == 3
          ardu.tx(daHeadPosition)
        
PRI SetNeck(daNeckPosition)
      ardu.tx(4)
      
PRI PrintX  |  daValue 
      ardu.tx(5)
      WaitForSerialLatency
      daValue := ardu.rxcheck
      ifnot daValue == -1
        SetCurser(0,3)
        text.str(string("X=    "))
        SetCurser(2,3)
        text.dec(daValue)
      ardu.rxflush
        
PRI PrintY  |  daValue   
      ardu.tx(6)
      WaitForSerialLatency
      daValue := ardu.rxcheck
      ifnot daValue == -1
        SetCurser(0,4)
        text.str(string("Y=    "))
        SetCurser(2,4)
        text.dec(daValue)
      ardu.rxflush
            
PRI SpinalTippingOn
     ardu.tx(1)  ' comes back as "52"=4 "56"=8 *** 48=ascii "0"
     
PRI SpinalTippingOff
    ardu.tx(0)'49="1"
}    
PRI ConnectToCMUCam | daResult
  daResult :=  CAM.START(CAM_TX, CAM_RX, @N_PACK, @S_PACK)
  RETURN daResult

PRI ToggleMyColorPlease' : daReturnedColor
  ToggleColor++
  if ToggleColor > 8
      ToggleColor:=1
  'daReturnedColor := ToggleColor
  RETURN ToggleColor

PRI UpdateTheNPack
  text.out($C)
  text.out(8)  
  SetCurser(22,1)
  'vp.Str(String("Servo position="))
  text.dec(N_PACK[0])  
  text.str(string("   "))
  SetCurser(22,2)
  'vp.Str(String("Middle-X="))
  text.dec(N_PACK[1])
  text.str(string("   "))
  SetCurser(22,3)
  'vp.Str(String("Middle-Y="))
  text.dec(N_PACK[2]) 
  text.str(string("   "))
  SetCurser(22,4)
  'vp.Str(String("Object size-X1="))
  text.dec(N_PACK[3])
  text.str(string("   "))
  SetCurser(22,5)
  'vp.Str(String("Object size-Y1="))
  text.dec(N_PACK[4])
  text.str(string("   "))
  SetCurser(22,6)
  'vp.Str(String("Object size-X2="))
  text.dec(N_PACK[5])
  text.str(string("   "))
  SetCurser(22,7)
  'vp.Str(String("Object size-Y2="))
  text.dec(N_PACK[6])  
  text.str(string("   "))
  SetCurser(22,8)
  'vp.Str(String("Tracked pixel count="))
  text.dec(N_PACK[7])
  text.str(string("   "))
  SetCurser(22,9)
  'vp.Str(String("Confidence="))
  text.dec(N_PACK[8])   
  text.str(string("   "))
  PrintTheNPack      

PRI PrintTheNPack
  'draw the box
  'DrawABox(ScaleTheNPACK(3),ScaleTheNPACK(4),ScaleTheNPACK(5),ScaleTheNPACK(6),ToggleMyColorPlease, String("‣"))
  'draw the centroid
  SetCurser(ScaleTheNPACK(1),ScaleTheNPACK(2))
  text.out($C)
  text.out(ToggleMyColorPlease)
  text.str(string(""))    

PRI ScaleTheNPACK(daNpackNumber) : daScaledNumber
  CASE daNpackNumber
    1 : daScaledNumber:=N_PACK[1]/3 'middle X
    2 : daScaledNumber:=N_PACK[2]/14 'middle Y
    3 : daScaledNumber:=N_PACK[3]/12
    4 : daScaledNumber:=N_PACK[4]/27
    5 : daScaledNumber:=N_PACK[5]/12
    6 : daScaledNumber:=N_PACK[6]/27
    
PRI NToScreen
  text.out($01)'home
  text.str(string($C,1,"    *** Neot'O'NICK ***         ",$C,8))
  text.str(string("     Servo position = "))
  text.dec(N_PACK[0])
  text.str(string(13,"           Middle-X = "))
  text.dec(N_PACK[1])
  text.str(string(13,"           Middle-Y = "))
  text.dec(N_PACK[2])
  text.str(string(13,"     Object size-X1 = "))
  text.dec(N_PACK[3])
  text.str(string(13,"     Object size-Y1 = "))
  text.dec(N_PACK[4])
  text.str(string(13,"     Object size-X2 = "))
  text.dec(N_PACK[5])
  text.str(string(13,"     Object size-Y2 = "))
  text.dec(N_PACK[6])
  text.str(string(13,"Tracked pixel count = "))
  text.dec(N_PACK[7])
  text.str(string(13,"         Confidence = "))
  text.dec(N_PACK[8])

PRI SetCurser(daX,daY)
  text.out($0A) 'Set X
  text.out(daX)
  text.out($0B) 'Set Y
  text.out(daY)

PRI DoFunnyGuy(ThisManyTimes)
  SetCurser(0,8)
  text.str(string(13,"     "))
  text.str(string(13," ┌─┼─┐"))
  text.str(string(13,"  │ "))
  text.str(string(13," ┌┐"))
  text.str(string(13," │   │"))
  text.str(string(13," ┘   └"))
  repeat ThisManyTimes
    SetCurser(3,12)
    text.str(string(""))
    waitcnt(7_000_000 + cnt)
    SetCurser(3,12)
    text.str(string(""))
    waitcnt(7_000_000 + cnt)
  ColorTrickTest

PRI ColorTrickTest | Index
  text.out($01)'home
  repeat 10
    repeat Index from 0 to 7
      text.out($01)'home
      text.out($0C)'set color to...
      text.out(Index)
      text.str(string("X"))
      waitcnt(5_000_000 + cnt)

PRI DrawABox(daX1, daY1, daX2, daY2, WhatColor, WhatCharacter) | daXndex, daYndex
  'SetCurser(daX1,daY1)
  repeat daYndex from daY1 to daY2
    repeat daXndex from daX1 to daX2
      SetCurser(daXndex,daYndex)
      text.out($0C)'set color to...
      text.out(WhatColor)
      'text.str(string(""))
      text.str(WhatCharacter)
      'text.str(string("‣"))

PRI Pause
    waitcnt(30_000_000 + cnt)
    
PRI AnimateIt
  '|─│┼╋┤├┴┬┫┣┻┳┘└┐┌
  text.out($C)
  text.out(8)
  SetCurser(14,14)
  text.str(string(""))
  Pause
  'text.out($00)
  Pause
  Pause
  Pause
  Pause
  SetCurser(14,14)
  text.str(string(""))
  Pause

  SetCurser(15,13)
  text.str(string(""))
  Pause

  SetCurser(16,12)
  text.str(string(""))
  Pause

  SetCurser(16,11)
  text.str(string("│"))
  Pause

  SetCurser(15,10)
  text.str(string("┬"))
  Pause

  SetCurser(14,10)
  text.str(string(""))
  SetCurser(18,10)
  text.str(string(""))
  Pause

  SetCurser(13,10)
  text.str(string(""))
  SetCurser(19,10)
  text.str(string(""))
  Pause

  SetCurser(12,10)
  text.str(string(""))
  SetCurser(20,10)
  text.str(string(""))
  Pause

  SetCurser(11,10)
  text.str(string("┬"))
  SetCurser(21,10)
  text.str(string("┬"))
  Pause

  SetCurser(10,10)
  text.str(string(""))
  SetCurser(11,11)
  text.str(string(""))
  SetCurser(22,10)
  text.str(string(""))
  SetCurser(21,11)
  text.str(string(""))
  Pause
  
  SetCurser(9,10)
  text.str(string(""))
  SetCurser(11,12)
  text.str(string("o"))
  SetCurser(23,10)
  text.str(string(""))
  SetCurser(21,12)
  text.str(string("o"))
  Pause


PRI PrintFreeCogs
  SetCurser(0,0)
  text.str(string($C,1,"Free Cogs ",$C,8))
  text.dec(spare.freecount)

  