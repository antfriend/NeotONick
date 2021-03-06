{{****************************************
*                                        *
*             Neot'O'NICK                *
*                                        *
******************************************

NeotoNick19 : working CMU cam! printing crappy squares to screen
NeotoNick18 has correct CMU cam pin settings - hardware reconfigured to boost the propeller out to cam recieve at 5v via 74LS04 
Compatible with Arduino version 5
NeotoNick17 begins changes to support baseband video out
  
SD card file names
(must be 7 characters or less before ".wav"):
        dictate.wav
        hello.wav
        hello1.wav
        hello2.wav
        hello3.wav
        hello4.wav
        hello5.wav 
        never.wav
        origin.wav
        synthescape.wav         'doesn't play
        think1.wav         
        think2.wav          
        wakeup.wav              'doesn't play

}}

CON
  _clkmode = xtal1 + pll16x
  _xinfreq = 5_000_000
  '_text_out_base_pin = 16 'for VGA
  _text_out_base_pin = 12 'for TV  

CON
  ColPos = 8  
  'CMUcam pins
  CAM_TX = 6        '6          'The pin connected to CMUcam's TX pin, the white wire in the cable, goes to a resister before going in P6(set to input)
  CAM_RX = 7        '7          'The pin connected to CMUcam's RX pin, the black wire goes to an 74LS04 inverter from out from P7

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
  ARDU_TX = 4   '4                'Arduino communication
  ARDU_RX = 5   '5                'Arduino communication

  'Wave Player
  bufferLen = 800    
  sdBasePin = 0
  HeadphoneRightPin = 10
  HeadphoneLeftPin = 11

'Mental Representation
  Default_Color = 8
  Primary_Color = 7
  Secondary_Color = 1
  
  Left_Box_X1 = 1
  Left_Box_X2 = 7
  Left_Box_Y1 = 1
  Left_Box_Y2 = 8

  Right_Box_X1 = 25
  Right_Box_X2 = 31   
  Right_Box_Y1 = Left_Box_Y1
  Right_Box_Y2 = Left_Box_Y2

  Song_Count_On_Beep_1 = 420000000
  

OBJ 
  CAM   :   "CMUcamDriver"
  'text  :   "vga_text"
  ardu  :   "FullDuplexSerialPlus"
  spare :   "sparecogs"
  audio :   "WavePlayerSdAccess"
  text : "tv_text" 
  tv    : "tv"
  gr    : "graphics"
    
VAR 
  BYTE N_PACK[9], S_PACK[7] 'for CMUcamDriver
  BYTE ToggleColor
  BYTE ArduByteArray[100]
  LONG SoundStack[128]
  byte buff[bufferLen]
  long stack[50]
  LONG Song_Start_Count
  LONG Song_Cog_ID
  
PUB Main | value, daIndex1, daIndex2', base, width, offset
  'initialize
  Song_Cog_ID := -1
  
  'PlayThis(string("hello.wav"))  'hello Lila
  PlayThis(string("hello5.wav")) 
  'LongPause
  'Do_TV_out
  'start vga term
  text.start(_text_out_base_pin)

  'start fullduplex connection to arduino 
  if ardu.start(ARDU_RX,ARDU_TX,4,115200) '9600, 14400, 19200, 28800, 38400, 57600, or 115200
    {          bit 0 inverts rx
               bit 1 inverts tx
               bit 2 open drain/source tx
               bit 3 ignore tx echo on rx
    }
    text.str(string($C,1,"Connected to Arduino",$C,8))
    repeat 3
      Wait_for_Arduino
    SpinalTippingOn

  else
    text.str(string($C,1,"NOT Connected to Arduino",$C,8))
  
'==================CMU CAM======CMU CAM=====CMU CAM========CMU CAM======CMU CAM=====CMU CAM================
  SetCurser(0,1)
  text.str(string($C,1,"Connecting to CMU ...   ",$C,8))

'set Rx and Tx, to output

'set them low

'set them to input
  
   
  if ConnectToCMUCam 'With CMUcam on, this call never returns ************************************************************************
    'text.str(string($C,1,"So far so good",$C,8))
    'waitcnt(50_000_000 + cnt)
    'DoFunnyGuy(15)
    'track window
    N_PACK := CAM.TRACK_WINDOW
    'NToScreen
    'text.str(string($C,1,"check, roger, good times!    ",$C,8))
  else
    SetCurser(0,3)
    text.str(string($C,1,"Not Connected to CMUcam    ",$C,8))
    waitcnt(50_000_000 + cnt)
    waitcnt(50_000_000 + cnt)
  'NToScreen
  SetCurser(0,4)
  
  'waitcnt(50_000_000 + cnt)
  'waitcnt(50_000_000 + cnt)
  text.out($00)'clear the screen
'&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&  
'========================================
'==a fun, long, startup routine==========
'========================================
  Song_Start_Count := cnt'===============
  PlayThis(string("never.wav"))'  "never.wav"  "origin.wav"   "think1.wav"
'  PrintSongCount'to see the time=========
                'while building animation
  text.out($00)'clear the screen========
  AnimateIt'=============================
'========================================
'&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&
'========================================
'== another startup routine =============
'========================================
  'PlayThis(string("i never full.wav"))'==
  'ColorTrickTest'========================
  'text.out($00)'clear the screen========
  'DoFunnyGuy(10)'========================
'========================================
'&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&& 
  repeat
    Main_Loop
   
PRI Main_Loop| value
    CAM.UPDATE
    text.out($00)
    PrintTheNPack
    'SpinalTippingOff
     'PrintX
     'PrintY
     'GetArduMessage(value)
     'PrintX
     'if value > 0
        'PrintSTRMessage(value)
     'waitcnt(5_000_000 + cnt)
     repeat 4
        CAM.UPDATE
        PrintTheNPack
      '  waitcnt(5_000_000 + cnt)
        'UpdateTheNPack

      {
      waitcnt(5_000_000 + cnt)
      daIndex1 := ardu.rxcheck
      'SetCurser(0,0)
      if daIndex1 == -1
        text.str(string(" "))
      else
        GetArduMessage(daIndex1)
      }



      

'***************************************
'*** General Utilities               ***
'***************************************

PRI Wait_For_Count(daCount)                       'song time synchronization utility
  'repeat until
  repeat until (Song_Count_On_Beep_1 =< (cnt - Song_Start_Count))
     waitcnt(1_000_000 + cnt)

PRI Quarter_Pause                                'timing utility
    waitcnt(5_000_000 + cnt)'waitcnt(30_000_000 + cnt)
  
PRI Pause                                        'timing utility
    waitcnt(20_000_000 + cnt)'waitcnt(30_000_000 + cnt)
    PrintSongCount 

PRI LongPause                                    'timing utility
  Pause
  Pause
  Pause
  Pause

     
     


'***************************************
'*** Mixes Mixes Mixes               ***
'***************************************
PRI PrintSongCount                                 'debug
  SetCurser(0,0)
  text.str(string($C,1,"Since Song Start=",$C,8))
  text.dec(cnt - Song_Start_Count)
  text.str(string("  "))
            
PRI PrintX  |  daValue 
      daValue := GetX
      ifnot daValue == -1
        SetCurser(0,3)
        text.str(string("X=    "))
        SetCurser(2,3)
        text.dec(daValue)
        if daValue > 150
          PlayThis(string("hello5.wav"))
          waitcnt(60_000_000 + cnt)
          waitcnt(60_000_000 + cnt)
          waitcnt(60_000_000 + cnt)
          waitcnt(60_000_000 + cnt)
          waitcnt(60_000_000 + cnt)
          daValue := GetX
          if daValue > 150
            PlayThis(string("hello.wav"))
            waitcnt(60_000_000 + cnt)
            waitcnt(60_000_000 + cnt)
            waitcnt(60_000_000 + cnt)
            waitcnt(60_000_000 + cnt)
            waitcnt(60_000_000 + cnt)                    
          PlayThis(string("think1.wav"))

PRI PrintY  |  daValue   
      ardu.tx(6)
      WaitForSerialLatency
      daValue := ardu.rxcheck
      ifnot daValue == -1
        SetCurser(0,4)
        text.str(string("Y="))
        SetCurser(2,4)
        text.dec(daValue)
      ardu.rxflush
            
  




      
'***************************************
'*** Arduino Arduino Arduino Arduino ***
'***************************************
PRI Wait_for_Arduino
    waitcnt(50_000_000 + cnt)

     
PRI WaitForSerialLatency
      waitcnt(5_000_000 + cnt)

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

PRI GetX | daV
      ardu.tx(5)
      WaitForSerialLatency
      daV := ardu.rxcheck
      ardu.rxflush
      RETURN daV

PRI SpinalTippingOn
     ardu.tx(1)  ' comes back as "52"=4 "56"=8 *** 48=ascii "0"
     Wait_for_Arduino
     
PRI SpinalTippingOff
    ardu.tx(0)'49="1"
    Wait_for_Arduino
    
PRI BumpForward
    ardu.tx(7)'49="1"
    Wait_for_Arduino
    
PRI BumpBack
    ardu.tx(6)'49="1"
    Wait_for_Arduino






    
'***************************************
'*** Sounds and Songs                ***
'***************************************    
PRI PlayIt
  Cognew (PlayHello, @SoundStack)

PRI PlayThis(daFileToPlay)
  if Song_Cog_ID > -1
    audio.stopbgWave
    COGSTOP(Song_Cog_ID)
  Song_Cog_ID := Cognew (PlayFile(daFileToPlay), @SoundStack)

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




  


'***************************************
'*** CMU CAM CMU CAM CMU CAM CMU CAM ***
'*************************************** 
PRI ConnectToCMUCam | daResult
  text.str(string($C,1,"Here we go",$C,8)) 
  daResult :=  CAM.START(CAM_TX, CAM_RX, @N_PACK, @S_PACK)
  
  RETURN daResult



  
  

  
'***************************************
'*** Mental Monitor Mental Monitor   ***
'*************************************** 
PRI ToggleMyColorPlease' : daReturnedColor
  ToggleColor++
  if ToggleColor > 8
      ToggleColor:=1
  'daReturnedColor := ToggleColor
  RETURN ToggleColor
  

PRI UpdateTheNPack                                'debug model values
  
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

PRI PrintTheNPack                                 'draw model
  'draw the box
  DrawABox(ScaleTheNPACK(3),ScaleTheNPACK(4),ScaleTheNPACK(5),ScaleTheNPACK(6),ToggleMyColorPlease, String("‣"))
  'draw the centroid
  SetCurser(ScaleTheNPACK(1),ScaleTheNPACK(2))
  text.out($C)
  text.out(ToggleMyColorPlease)
  text.str(string(""))    

PRI ScaleTheNPACK(daNpackNumber) : daScaledNumber 'CMUcam utility
  CASE daNpackNumber
    1 : daScaledNumber:=N_PACK[1]/3 'middle X
    2 : daScaledNumber:=N_PACK[2]/14 'middle Y
    3 : daScaledNumber:=N_PACK[3]/12
    4 : daScaledNumber:=N_PACK[4]/27
    5 : daScaledNumber:=N_PACK[5]/12
    6 : daScaledNumber:=N_PACK[6]/27
    
PRI NToScreen                                     'CMUcam debug
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

PRI DoFunnyGuy(ThisManyTimes)                     're-creation of one of my first Commodore 64 programs
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

PRI ColorTrickTest | Index                         'debug test
  text.out($01)'home
  repeat 3
    repeat Index from 0 to 7
      text.out($01)'home
      text.out($0C)'set color to...
      text.out(Index)
      text.str(string("X"))
      text.str(string(" "))
      text.dec(Index)
      waitcnt(40_000_000 + cnt)

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

PRI Draw_Left_Box_Default_Color
  'DrawABox(daX1, daY1, daX2, daY2, WhatColor, WhatCharacter)
  'DrawABox(Left_Box_X1, Left_Box_Y1, Left_Box_X2, Left_Box_Y2, Default_Color, string(""))
  'DrawABox(Right_Box_X1, Right_Box_Y1, Right_Box_X2, Right_Box_Y2, Default_Color, string(""))
  
  DrawABox(Left_Box_X1, Left_Box_Y1, Left_Box_X2, Left_Box_Y2, Default_Color, string(""))
                       
PRI Draw_Right_Box_Default_Color
  DrawABox(Right_Box_X1, Right_Box_Y1, Right_Box_X2, Right_Box_Y2, Default_Color, string(""))

PRI Draw_Left_Box_Primary_Color
  DrawABox(Left_Box_X1, Left_Box_Y1, Left_Box_X2, Left_Box_Y2, Primary_Color, string(""))
  
PRI Draw_Right_Box_Primary_Color
  DrawABox(Right_Box_X1, Right_Box_Y1, Right_Box_X2, Right_Box_Y2, Primary_Color, string(""))
  
PRI Draw_Left_Box_Secondary_Color
  DrawABox(Left_Box_X1, Left_Box_Y1, Left_Box_X2, Left_Box_Y2, Secondary_Color, string(""))

PRI Draw_Right_Box_Secondary_Color
  DrawABox(Right_Box_X1, Right_Box_Y1, Right_Box_X2, Right_Box_Y2, Secondary_Color, string(""))

PRI Draw_Focal_1(X,Y)                                   'draw model
  Draw_Focal_1_in_Left_Box(X,Y)
  Draw_Focal_1_in_Right_Box(X,Y)  

PRI Clear_Focal_1(X,Y)                                  'draw model
  Clear_Focal_1_in_Left_Box(X,Y)
  Clear_Focal_1_in_Right_Box(X,Y)

PRI Focal_1_in_Left_Box(X,Y) | daX, daY                 'draw model
  daX:=X
  daY:=Y
  if daX > (Left_Box_X2 - Left_Box_X1)
    daX:=(Left_Box_X2 - Left_Box_X1)
  if daY > (Left_Box_Y2 - Left_Box_Y1)
    daY:=(Left_Box_Y2 - Left_Box_Y1)
  SetCurser(Left_Box_X1+daX,Left_Box_Y1+daY)
  text.str(string(""))  

PRI Focal_1_in_Right_Box(X,Y) | daX, daY                'draw model
  daX:=X
  daY:=Y
  if daX > (Right_Box_X2 - Right_Box_X1)
    daX:=(Right_Box_X2 - Right_Box_X1)
  if daY > (Right_Box_Y2 - Right_Box_Y1)
    daY:=(Right_Box_Y2 - Right_Box_Y1)
  SetCurser(Right_Box_X1+daX,Right_Box_Y1+daY)
  text.str(string(""))  
     
PRI Draw_Focal_1_in_Left_Box(X,Y)                       'draw model
  SetPrimaryColor
  Focal_1_in_Left_Box(X,Y)

PRI Clear_Focal_1_in_Left_Box(X,Y)                      'draw model
  SetSecondaryColor
  Focal_1_in_Left_Box(X,Y)

PRI Draw_Focal_1_in_Right_Box(X,Y)                      'draw model
  SetPrimaryColor
  Focal_1_in_Right_Box(X,Y)

PRI Clear_Focal_1_in_Right_Box(X,Y)                     'draw model
  SetSecondaryColor
  Focal_1_in_Right_Box(X,Y)

PRI SetPrimaryColor
  text.str(string($C,7))  'set color to light blue
  
PRI SetSecondaryColor
  text.str(string($C,1))  'set color to yello

PRI SetTertiaryColor
  text.str(string($C,2))  'set color to ?
  
PRI SetDefaultColor
  text.str(string($C,8))  'set color back to default

     
PRI AnimateIt | Index, Previous_Index                  'The GINORMOUS animation sequence
  '|                 ─ │ ┼ ╋ ┤ ├ ┴ ┬ ┫ ┣ ┻ ┳ ┘ └ ┐ ┌   ‣
  waitcnt(5_000_000 + cnt)'sync with audio
  Pause
  LongPause
  LongPause
  
  text.out($C)
  text.out(8)
  SetCurser(14,12)
  text.str(string(""))    'on beep

  LongPause

  SetCurser(15,11)
  text.str(string(""))
  
  Pause

  SetCurser(16,10)
  text.str(string(""))
  
  Wait_For_Count(Song_Count_On_Beep_1)
  SetPrimaryColor
  SetCurser(16,9)
  text.str(string("│"))           'on beep
  'SetDefaultColor  'set color back to default

  'PrintSongCount

  SetCurser(13,13)
  text.str(string(""))
  SetCurser(19,13)
  text.str(string(""))
  SetDefaultColor  'set color back to default 
  
  LongPause

  SetCurser(15,8)
  text.str(string("┬"))

  LongPause

  SetCurser(14,8)
  text.str(string(""))
  SetCurser(18,8)
  text.str(string(""))
  
  Pause
  Pause
  Pause
  Pause
  
  SetSecondaryColor        
  SetCurser(11,10) 
  text.str(string("o"))              'on beep 
  SetCurser(21,10)
  text.str(string("o"))
  SetDefaultColor  'set color back to default
  
  Pause

  SetCurser(13,8)
  text.str(string(""))     
  SetCurser(19,8)
  text.str(string(""))

  LongPause

  SetCurser(12,8)
  text.str(string(""))
  SetCurser(20,8)
  text.str(string(""))

  LongPause

  SetCurser(11,8)
  text.str(string("┬"))
  SetCurser(21,8)
  text.str(string("┬"))

  Pause
  Pause

  SetPrimaryColor
  SetCurser(11,9)
  text.str(string(""))
  SetCurser(21,9)
  text.str(string(""))
  SetDefaultColor
  
  LongPause
  
  SetCurser(10,8)
  text.str(string(""))
  SetCurser(22,8)            
  text.str(string(""))
  
  LongPause

  SetCurser(9,8)
  text.str(string(""))
  SetCurser(23,8)
  text.str(string(""))   '

  LongPause
  
  SetPrimaryColor  'Set Primary Color   
  SetCurser(8,7)
  text.str(string(""))
  SetCurser(24,7)
  text.str(string(""))
  SetDefaultColor 'Set Default Color
  
  Pause
  
  SetCurser(9,7)
  text.str(string(""))
  SetCurser(23,7)            
  text.str(string(""))

  Pause
  
  SetCurser(10,7)
  text.str(string("┐"))
  SetCurser(22,7)            
  text.str(string("┌"))

  Pause
  
  SetCurser(10,8)
  text.str(string("│"))    'beep
  SetCurser(22,8)            
  text.str(string("│"))

  Pause
  
  SetCurser(10,9)
  text.str(string("┘"))
  SetCurser(22,9)            
  text.str(string("└"))

  Pause
  
  SetCurser(7,7)
  text.str(string("└"))
  SetCurser(25,7)            
  text.str(string("┘"))  
  
  SetCurser(9,9)
  text.str(string(""))
  SetCurser(23,9)            
  text.str(string(""))
  
  Pause

  SetCurser(8,8)
  text.str(string(""))
  SetCurser(24,8)            
  text.str(string(""))
    
  SetCurser(8,9)
  text.str(string(""))
  SetCurser(24,9)            
  text.str(string(""))

  Pause
  
  SetCurser(7,9)
  text.str(string(""))
  SetCurser(25,9)            
  text.str(string(""))

  SetCurser(7,8)
  text.str(string(""))
  SetCurser(25,8)            
  text.str(string(""))
  
  Pause
  
  SetCurser(6,9)
  text.str(string(""))
  SetCurser(26,9)            
  text.str(string(""))

  SetCurser(6,8)
  text.str(string(""))
  SetCurser(26,8)            
  text.str(string(""))
  
  Pause
  
  SetCurser(5,9)
  text.str(string(""))
  SetCurser(27,9)            
  text.str(string(""))

  SetCurser(5,8)
  text.str(string(""))
  SetCurser(27,8)            
  text.str(string(""))
  
  Pause
  
  SetCurser(4,9)
  text.str(string(""))
  SetCurser(28,9)            
  text.str(string(""))

  SetCurser(3,9)
  text.str(string("└"))
  SetCurser(29,9)            
  text.str(string("┘"))

  Pause

  SetCurser(3,8)
  text.str(string("│"))
  SetCurser(29,8)            
  text.str(string("│"))

  'Pause
  
  'draw a box
  'DrawABox(daX1, daY1, daX2, daY2, WhatColor, WhatCharacter)  
  Draw_Left_Box_Secondary_Color
  Draw_Right_Box_Secondary_Color
  SetDefaultColor 'Set Default Color
  
  Pause

  SetCurser(3,7)
  text.str(string("│"))
  SetCurser(29,7)            
  text.str(string("│"))

  SetCurser(5,7)
  text.str(string("│"))
  SetCurser(27,7)            
  text.str(string("│"))

  Pause

  SetCurser(8,3)
  text.str(string(""))
  SetCurser(24,3)            
  text.str(string(""))

  SetCurser(8,2)
  text.str(string(""))
  SetCurser(24,2)            
  text.str(string(""))

  Pause          '

  SetCurser(9,3)        ''  ┬   
  text.str(string(""))
  SetCurser(23,3)            
  text.str(string(""))

  SetCurser(9,2)
  text.str(string(""))
  SetCurser(23,2)            
  text.str(string(""))
  
  Pause

  SetCurser(10,3)
  text.str(string("┘"))
  SetCurser(22,3)            
  text.str(string("└"))

  SetCurser(10,2)
  text.str(string("┤"))
  SetCurser(22,2)            
  text.str(string("├"))

  Pause
  
  SetCurser(10,1)
  text.str(string("‣"))
  SetCurser(22,1)            
  text.str(string("‣"))
  
  LongPause
  Pause
  Pause
  'Pause 
  
  SetTertiaryColor
  SetCurser(10,1)
  text.str(string("‣"))
  SetCurser(22,1)            
  text.str(string("‣"))
  
  LongPause 

  SetPrimaryColor  'Set Primary Color
  SetCurser(8,4)        ''  ┬      
  text.str(string(""))
  SetCurser(24,4)            
  text.str(string(""))
  SetDefaultColor 'Set Default Color

  BumpForward
  Pause
  BumpBack
  Pause
  BumpBack
  Pause
  
  repeat 4
    repeat Index from 0 to 8
      'DrawABox(daX1, daY1, daX2, daY2, WhatColor, WhatCharacter)
      DrawABox(Left_Box_X1, Left_Box_Y1, Left_Box_X2, Left_Box_Y2, Index, string(""))
      DrawABox(Right_Box_X1, Right_Box_Y1, Right_Box_X2, Right_Box_Y2, Index, string(""))
      Quarter_Pause
      Quarter_Pause

  Draw_Left_Box_Secondary_Color
  Draw_Right_Box_Secondary_Color

  Previous_Index := 1
  repeat 4
    
    repeat Index from 0 to 6
      Clear_Focal_1(Previous_Index,Previous_Index)
      Draw_Focal_1(Index,Index)
      Previous_Index:=Index
      Pause

    repeat Index from 6 to 0
      Clear_Focal_1(Previous_Index,Previous_Index)
      Draw_Focal_1(Index,Index)
      Previous_Index:=Index
      Pause      
    
  repeat 2
    LongPause
    
PRI PrintFreeCogs                                        'Debug
  SetCurser(0,0)
  text.str(string($C,1,"Free Cogs ",$C,8))
  text.dec(spare.freecount)

PRI PrintSTRMessage(daValue)                             'Utility
  SetCurser(3,3)
  text.str(string($C,1,"Message is ",$C,8))
  'text.str(daValue)

PRI Do_TV_out | i                                        'Utility
  'start term
  text.start(_text_out_base_pin)
  text.str(string(13,"   TV Text Demo...",13,13,$C,5," OBJ and VAR require only 2.8KB ",$C,1))
  repeat 14
    text.out(" ")
  repeat i from $0E to $FF
    text.out(i)
  text.str(string($C,6,"     Uses internal ROM font     ",$C,2))
  repeat
    text.str(string($A,16,$B,12))
    text.hex(i++, 8)