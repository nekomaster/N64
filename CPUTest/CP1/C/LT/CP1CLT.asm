; N64 'Bare Metal' CPU CP1/FPU Comparison Less Than Test Demo by krom (Peter Lemon):

PrintString: macro vram,xpos,ypos,fontfile,string,length ; Print Text String To VRAM Using Font At X,Y Position
  lui t0,vram ; T0 = Frame Buffer Pointer
  addi t0,((xpos*4)+((640*ypos)*4)) ; Place text at XY Position
  la t1,fontfile ; T1 = Characters
  la t2,string ; T2 = Text Offset
  li t3,length ; T3 = Number of Text Characters to Print
  DrawChars\@:
    li t4,7 ; T4 = Character X Pixel Counter
    li t5,7 ; T5 = Character Y Pixel Counter

    lb t6,0(t2) ; T6 = Next Text Character
    addi t2,1

    sll t6,8 ; Add Shift to Correct Position in Font (* 256)
    add t6,t1

    DrawCharX\@:
      lw t7,0(t6) ; Load Font Text Character Pixel
      addi t6,4
      sw t7,0(t0) ; Store Font Text Character Pixel into Frame Buffer
      addi t0,4

      bnez t4,DrawCharX\@ ; IF Character X Pixel Counter != 0 GOTO DrawCharX
      subi t4,1 ; Decrement Character X Pixel Counter

      addi t0,$9E0 ; Jump down 1 Scanline, Jump back 1 Char ((SCREEN_X * 4) - (CHAR_X * 4))
      li t4,7 ; Reset Character X Pixel Counter
      bnez t5,DrawCharX\@ ; IF Character Y Pixel Counter != 0 GOTO DrawCharX
      subi t5,1 ; Decrement Character Y Pixel Counter

    subi t0,$4FE0 ; ((SCREEN_X * 4) * CHAR_Y) - CHAR_X * 4
    bnez t3,DrawChars\@ ; Continue to Print Characters
    subi t3,1 ; Subtract Number of Text Characters to Print
    endm

PrintValue: macro vram,xpos,ypos,fontfile,value,length ; Print HEX Chars To VRAM Using Font At X,Y Position
  lui t0,vram ; T0 = Frame Buffer Pointer
  addi t0,((xpos*4)+((640*ypos)*4)) ; Place text at XY Position
  la t1,fontfile ; T1 = Characters
  la t2,value ; T2 = Value Offset
  li t3,length ; T3 = Number of HEX Chars to Print
  DrawHEXChars\@:
    li t4,7 ; T4 = Character X Pixel Counter
    li t5,7 ; T5 = Character Y Pixel Counter

    lb t6,0(t2) ; T6 = Next 2 HEX Chars
    addi t2,1

    srl t7,t6,4 ; T7 = 2nd Nibble
    andi t7,$F
    subi t8,t7,9
    bgtz t8,HEXLetters\@
    addi t7,$30 ; Delay Slot
    j HEXEnd\@
    nop ; Delay Slot

    HEXLetters\@:
    addi t7,7
    HEXEnd\@:

    sll t7,8 ; Add Shift to Correct Position in Font (* 256)
    add t7,t1

    DrawHEXCharX\@:
      lw t8,0(t7) ; Load Font Text Character Pixel
      addi t7,4
      sw t8,0(t0) ; Store Font Text Character Pixel into Frame Buffer
      addi t0,4

      bnez t4,DrawHEXCharX\@ ; IF Character X Pixel Counter != 0 GOTO DrawCharX
      subi t4,1 ; Decrement Character X Pixel Counter

      addi t0,$9E0 ; Jump down 1 Scanline, Jump back 1 Char ((SCREEN_X * 4) - (CHAR_X * 4))
      li t4,7 ; Reset Character X Pixel Counter
      bnez t5,DrawHEXCharX\@ ; IF Character Y Pixel Counter != 0 GOTO DrawCharX
      subi t5,1 ; Decrement Character Y Pixel Counter

    subi t0,$4FE0 ; ((SCREEN_X * 4) * CHAR_Y) - CHAR_X * 4

    li t5,7 ; Reset Character Y Pixel Counter

    andi t7,t6,$F ; T7 = 1st Nibble
    subi t8,t7,9
    bgtz t8,HEXLettersB\@
    addi t7,$30 ; Delay Slot
    j HEXEndB\@
    nop ; Delay Slot

    HEXLettersB\@:
    addi t7,7
    HEXEndB\@:

    sll t7,8 ; Add Shift to Correct Position in Font (* 256)
    add t7,t1

    DrawHEXCharXB\@:
      lw t8,0(t7) ; Load Font Text Character Pixel
      addi t7,4
      sw t8,0(t0) ; Store Font Text Character Pixel into Frame Buffer
      addi t0,4

      bnez t4,DrawHEXCharXB\@ ; IF Character X Pixel Counter != 0 GOTO DrawCharX
      subi t4,1 ; Decrement Character X Pixel Counter

      addi t0,$9E0 ; Jump down 1 Scanline, Jump back 1 Char ((SCREEN_X * 4) - (CHAR_X * 4))
      li t4,7 ; Reset Character X Pixel Counter
      bnez t5,DrawHEXCharXB\@ ; IF Character Y Pixel Counter != 0 GOTO DrawCharX
      subi t5,1 ; Decrement Character Y Pixel Counter

    subi t0,$4FE0 ; ((SCREEN_X * 4) * CHAR_Y) - CHAR_X * 4

    bnez t3,DrawHEXChars\@ ; Continue to Print Characters
    subi t3,1 ; Subtract Number of Text Characters to Print
    endm

  include LIB\N64.INC ; Include N64 Definitions
  dcb 2097152,$00 ; Set ROM Size
  org $80000000 ; Entry Point Of Code
  include LIB\N64_HEADER.ASM  ; Include 64 Byte Header & Vector Table
  incbin LIB\N64_BOOTCODE.BIN ; Include 4032 Byte Boot Code

Start:
  include LIB\N64_INIT.ASM ; Include Initialisation Routine
  include LIB\N64_GFX.INC  ; Include Graphics Macros

  ScreenNTSC 640,480, BPP32|INTERLACE|AA_MODE_2, $A0100000 ; Screen NTSC: 640x480, 32BPP, Interlace, Reample Only, DRAM Origin = $A0100000

  lui t0,$A010 ; T0 = VRAM Start Offset
  addi t1,t0,((640*480*4)-4) ; T1 = VRAM End Offset
  li t2,$000000FF ; T2 = Black
ClearScreen:
  sw t2,0(t0)
  bne t0,t1,ClearScreen
  addi t0,4 ; Delay Slot




  PrintString $A010,88,8,FontRed,FSFTHEX,10 ; Print Text String To VRAM Using Font At X,Y Position
  PrintString $A010,232,8,FontRed,FSFTDEC,14 ; Print Text String To VRAM Using Font At X,Y Position
  PrintString $A010,528,8,FontRed,TEST,10 ; Print Text String To VRAM Using Font At X,Y Position


  PrintString $A010,0,16,FontBlack,PAGEBREAK,79 ; Print Text String To VRAM Using Font At X,Y Position


  PrintString $A010,8,24,FontRed,CLTD,5 ; Print Text String To VRAM Using Font At X,Y Position
  la t0,VALUEDOUBLEA ; T0 = Double Data Offset
  ldc1 f0,0(t0)      ; F0 = Double Data
  la t0,VALUEDOUBLEB ; T0 = Double Data Offset
  ldc1 f1,0(t0)      ; F1 = Double Data
  c.lt.d f0,f1 ; Comparison Test
  PrintString $A010,80,24,FontBlack,DOLLAR,0       ; Print Text String To VRAM Using Font At X,Y Position
  PrintValue  $A010,88,24,FontBlack,VALUEDOUBLEA,7 ; Print HEX Chars To VRAM Using Font At X,Y Position
  PrintString $A010,344,24,FontBlack,TEXTDOUBLEA,2 ; Print Text String To VRAM Using Font At X,Y Position
  PrintString $A010,80,32,FontBlack,DOLLAR,0       ; Print Text String To VRAM Using Font At X,Y Position
  PrintValue  $A010,88,32,FontBlack,VALUEDOUBLEB,7 ; Print HEX Chars To VRAM Using Font At X,Y Position
  PrintString $A010,232,32,FontBlack,TEXTDOUBLEB,16 ; Print Text String To VRAM Using Font At X,Y Position
  bc1t CLTDPASSA ; Branch On FP True
  nop ; Delay Slot
  PrintString $A010,528,32,FontRed,FAIL,3 ; Print Text String To VRAM Using Font At X,Y Position
  j CLTDENDA
  nop ; Delay Slot
  CLTDPASSA:
  PrintString $A010,528,32,FontGreen,PASS,3 ; Print Text String To VRAM Using Font At X,Y Position
  CLTDENDA:

  la t0,VALUEDOUBLEB ; T0 = Double Data Offset
  ldc1 f0,0(t0)      ; F0 = Double Data
  la t0,VALUEDOUBLEC ; T0 = Double Data Offset
  ldc1 f1,0(t0)      ; F1 = Double Data
  c.lt.d f0,f1 ; Comparison Test
  PrintString $A010,80,48,FontBlack,DOLLAR,0       ; Print Text String To VRAM Using Font At X,Y Position
  PrintValue  $A010,88,48,FontBlack,VALUEDOUBLEB,7 ; Print HEX Chars To VRAM Using Font At X,Y Position
  PrintString $A010,232,48,FontBlack,TEXTDOUBLEB,16 ; Print Text String To VRAM Using Font At X,Y Position
  PrintString $A010,80,56,FontBlack,DOLLAR,0       ; Print Text String To VRAM Using Font At X,Y Position
  PrintValue  $A010,88,56,FontBlack,VALUEDOUBLEC,7 ; Print HEX Chars To VRAM Using Font At X,Y Position
  PrintString $A010,288,56,FontBlack,TEXTDOUBLEC,9 ; Print Text String To VRAM Using Font At X,Y Position
  bc1f CLTDPASSB ; Branch On FP False
  nop ; Delay Slot
  PrintString $A010,528,56,FontRed,FAIL,3 ; Print Text String To VRAM Using Font At X,Y Position
  j CLTDENDB
  nop ; Delay Slot
  CLTDPASSB:
  PrintString $A010,528,56,FontGreen,PASS,3 ; Print Text String To VRAM Using Font At X,Y Position
  CLTDENDB:

  la t0,VALUEDOUBLEC ; T0 = Double Data Offset
  ldc1 f0,0(t0)      ; F0 = Double Data
  la t0,VALUEDOUBLED ; T0 = Double Data Offset
  ldc1 f1,0(t0)      ; F1 = Double Data
  c.lt.d f0,f1 ; Comparison Test
  PrintString $A010,80,72,FontBlack,DOLLAR,0       ; Print Text String To VRAM Using Font At X,Y Position
  PrintValue  $A010,88,72,FontBlack,VALUEDOUBLEC,7 ; Print HEX Chars To VRAM Using Font At X,Y Position
  PrintString $A010,288,72,FontBlack,TEXTDOUBLEC,9 ; Print Text String To VRAM Using Font At X,Y Position
  PrintString $A010,80,80,FontBlack,DOLLAR,0       ; Print Text String To VRAM Using Font At X,Y Position
  PrintValue  $A010,88,80,FontBlack,VALUEDOUBLED,7 ; Print HEX Chars To VRAM Using Font At X,Y Position
  PrintString $A010,232,80,FontBlack,TEXTDOUBLED,16 ; Print Text String To VRAM Using Font At X,Y Position
  bc1f CLTDPASSC ; Branch On FP False
  nop ; Delay Slot
  PrintString $A010,528,80,FontRed,FAIL,3 ; Print Text String To VRAM Using Font At X,Y Position
  j CLTDENDC
  nop ; Delay Slot
  CLTDPASSC:
  PrintString $A010,528,80,FontGreen,PASS,3 ; Print Text String To VRAM Using Font At X,Y Position
  CLTDENDC:

  la t0,VALUEDOUBLED ; T0 = Double Data Offset
  ldc1 f0,0(t0)      ; F0 = Double Data
  la t0,VALUEDOUBLEE ; T0 = Double Data Offset
  ldc1 f1,0(t0)      ; F1 = Double Data
  c.lt.d f0,f1 ; Comparison Test
  PrintString $A010,80,96,FontBlack,DOLLAR,0       ; Print Text String To VRAM Using Font At X,Y Position
  PrintValue  $A010,88,96,FontBlack,VALUEDOUBLED,7 ; Print HEX Chars To VRAM Using Font At X,Y Position
  PrintString $A010,232,96,FontBlack,TEXTDOUBLED,16 ; Print Text String To VRAM Using Font At X,Y Position
  PrintString $A010,80,104,FontBlack,DOLLAR,0       ; Print Text String To VRAM Using Font At X,Y Position
  PrintValue  $A010,88,104,FontBlack,VALUEDOUBLEE,7 ; Print HEX Chars To VRAM Using Font At X,Y Position
  PrintString $A010,224,104,FontBlack,TEXTDOUBLEE,17 ; Print Text String To VRAM Using Font At X,Y Position
  bc1f CLTDPASSD ; Branch On FP False
  nop ; Delay Slot
  PrintString $A010,528,104,FontRed,FAIL,3 ; Print Text String To VRAM Using Font At X,Y Position
  j CLTDENDD
  nop ; Delay Slot
  CLTDPASSD:
  PrintString $A010,528,104,FontGreen,PASS,3 ; Print Text String To VRAM Using Font At X,Y Position
  CLTDENDD:

  la t0,VALUEDOUBLEE ; T0 = Double Data Offset
  ldc1 f0,0(t0)      ; F0 = Double Data
  la t0,VALUEDOUBLEF ; T0 = Double Data Offset
  ldc1 f1,0(t0)      ; F1 = Double Data
  c.lt.d f0,f1 ; Comparison Test
  PrintString $A010,80,120,FontBlack,DOLLAR,0       ; Print Text String To VRAM Using Font At X,Y Position
  PrintValue  $A010,88,120,FontBlack,VALUEDOUBLEE,7 ; Print HEX Chars To VRAM Using Font At X,Y Position
  PrintString $A010,224,120,FontBlack,TEXTDOUBLEE,17 ; Print Text String To VRAM Using Font At X,Y Position
  PrintString $A010,80,128,FontBlack,DOLLAR,0       ; Print Text String To VRAM Using Font At X,Y Position
  PrintValue  $A010,88,128,FontBlack,VALUEDOUBLEF,7 ; Print HEX Chars To VRAM Using Font At X,Y Position
  PrintString $A010,280,128,FontBlack,TEXTDOUBLEF,10 ; Print Text String To VRAM Using Font At X,Y Position
  bc1f CLTDPASSE ; Branch On FP False
  nop ; Delay Slot
  PrintString $A010,528,128,FontRed,FAIL,3 ; Print Text String To VRAM Using Font At X,Y Position
  j CLTDENDE
  nop ; Delay Slot
  CLTDPASSE:
  PrintString $A010,528,128,FontGreen,PASS,3 ; Print Text String To VRAM Using Font At X,Y Position
  CLTDENDE:

  la t0,VALUEDOUBLEF ; T0 = Double Data Offset
  ldc1 f0,0(t0)      ; F0 = Double Data
  la t0,VALUEDOUBLEG ; T0 = Double Data Offset
  ldc1 f1,0(t0)      ; F1 = Double Data
  c.lt.d f0,f1 ; Comparison Test
  PrintString $A010,80,144,FontBlack,DOLLAR,0       ; Print Text String To VRAM Using Font At X,Y Position
  PrintValue  $A010,88,144,FontBlack,VALUEDOUBLEF,7 ; Print HEX Chars To VRAM Using Font At X,Y Position
  PrintString $A010,280,144,FontBlack,TEXTDOUBLEF,10 ; Print Text String To VRAM Using Font At X,Y Position
  PrintString $A010,80,152,FontBlack,DOLLAR,0       ; Print Text String To VRAM Using Font At X,Y Position
  PrintValue  $A010,88,152,FontBlack,VALUEDOUBLEG,7 ; Print HEX Chars To VRAM Using Font At X,Y Position
  PrintString $A010,224,152,FontBlack,TEXTDOUBLEG,17 ; Print Text String To VRAM Using Font At X,Y Position
  bc1f CLTDPASSF ; Branch On FP False
  nop ; Delay Slot
  PrintString $A010,528,152,FontRed,FAIL,3 ; Print Text String To VRAM Using Font At X,Y Position
  j CLTDENDF
  nop ; Delay Slot
  CLTDPASSF:
  PrintString $A010,528,152,FontGreen,PASS,3 ; Print Text String To VRAM Using Font At X,Y Position
  CLTDENDF:

  la t0,VALUEDOUBLEA ; T0 = Double Data Offset
  ldc1 f0,0(t0)      ; F0 = Double Data
  la t0,VALUEDOUBLEG ; T0 = Double Data Offset
  ldc1 f1,0(t0)      ; F1 = Double Data
  c.lt.d f0,f1 ; Comparison Test
  PrintString $A010,80,168,FontBlack,DOLLAR,0       ; Print Text String To VRAM Using Font At X,Y Position
  PrintValue  $A010,88,168,FontBlack,VALUEDOUBLEA,7 ; Print HEX Chars To VRAM Using Font At X,Y Position
  PrintString $A010,344,168,FontBlack,TEXTDOUBLEA,2 ; Print Text String To VRAM Using Font At X,Y Position
  PrintString $A010,80,176,FontBlack,DOLLAR,0       ; Print Text String To VRAM Using Font At X,Y Position
  PrintValue  $A010,88,176,FontBlack,VALUEDOUBLEG,7 ; Print HEX Chars To VRAM Using Font At X,Y Position
  PrintString $A010,224,176,FontBlack,TEXTDOUBLEG,17 ; Print Text String To VRAM Using Font At X,Y Position
  bc1f CLTDPASSG ; Branch On FP False
  nop ; Delay Slot
  PrintString $A010,528,176,FontRed,FAIL,3 ; Print Text String To VRAM Using Font At X,Y Position
  j CLTDENDG
  nop ; Delay Slot
  CLTDPASSG:
  PrintString $A010,528,176,FontGreen,PASS,3 ; Print Text String To VRAM Using Font At X,Y Position
  CLTDENDG:

  la t0,VALUEDOUBLED ; T0 = Double Data Offset
  ldc1 f0,0(t0)      ; F0 = Double Data
  la t0,VALUEDOUBLED ; T0 = Double Data Offset
  ldc1 f1,0(t0)      ; F1 = Double Data
  c.lt.d f0,f1 ; Comparison Test
  PrintString $A010,80,192,FontBlack,DOLLAR,0       ; Print Text String To VRAM Using Font At X,Y Position
  PrintValue  $A010,88,192,FontBlack,VALUEDOUBLED,7 ; Print HEX Chars To VRAM Using Font At X,Y Position
  PrintString $A010,232,192,FontBlack,TEXTDOUBLED,16 ; Print Text String To VRAM Using Font At X,Y Position
  PrintString $A010,80,200,FontBlack,DOLLAR,0       ; Print Text String To VRAM Using Font At X,Y Position
  PrintValue  $A010,88,200,FontBlack,VALUEDOUBLED,7 ; Print HEX Chars To VRAM Using Font At X,Y Position
  PrintString $A010,232,200,FontBlack,TEXTDOUBLED,16 ; Print Text String To VRAM Using Font At X,Y Position
  bc1f CLTDPASSH ; Branch On FP False
  nop ; Delay Slot
  PrintString $A010,528,200,FontRed,FAIL,3 ; Print Text String To VRAM Using Font At X,Y Position
  j CLTDENDH
  nop ; Delay Slot
  CLTDPASSH:
  PrintString $A010,528,200,FontGreen,PASS,3 ; Print Text String To VRAM Using Font At X,Y Position
  CLTDENDH:

  la t0,VALUEDOUBLEE ; T0 = Double Data Offset
  ldc1 f0,0(t0)      ; F0 = Double Data
  la t0,VALUEDOUBLEE ; T0 = Double Data Offset
  ldc1 f1,0(t0)      ; F1 = Double Data
  c.lt.d f0,f1 ; Comparison Test
  PrintString $A010,80,216,FontBlack,DOLLAR,0       ; Print Text String To VRAM Using Font At X,Y Position
  PrintValue  $A010,88,216,FontBlack,VALUEDOUBLEE,7 ; Print HEX Chars To VRAM Using Font At X,Y Position
  PrintString $A010,224,216,FontBlack,TEXTDOUBLEE,17 ; Print Text String To VRAM Using Font At X,Y Position
  PrintString $A010,80,224,FontBlack,DOLLAR,0       ; Print Text String To VRAM Using Font At X,Y Position
  PrintValue  $A010,88,224,FontBlack,VALUEDOUBLEE,7 ; Print HEX Chars To VRAM Using Font At X,Y Position
  PrintString $A010,224,224,FontBlack,TEXTDOUBLEE,17 ; Print Text String To VRAM Using Font At X,Y Position
  bc1f CLTDPASSI ; Branch On FP False
  nop ; Delay Slot
  PrintString $A010,528,224,FontRed,FAIL,3 ; Print Text String To VRAM Using Font At X,Y Position
  j CLTDENDI
  nop ; Delay Slot
  CLTDPASSI:
  PrintString $A010,528,224,FontGreen,PASS,3 ; Print Text String To VRAM Using Font At X,Y Position
  CLTDENDI:


  PrintString $A010,8,240,FontRed,CLTS,5 ; Print Text String To VRAM Using Font At X,Y Position
  la t0,VALUEFLOATA ; T0 = Float Data Offset
  lwc1 f0,0(t0)     ; F0 = Float Data
  la t0,VALUEFLOATB ; T0 = Float Data Offset
  lwc1 f1,0(t0)     ; F1 = Float Data
  c.lt.s f0,f1 ; Comparison Test
  PrintString $A010,144,240,FontBlack,DOLLAR,0      ; Print Text String To VRAM Using Font At X,Y Position
  PrintValue  $A010,152,240,FontBlack,VALUEFLOATA,3 ; Print HEX Chars To VRAM Using Font At X,Y Position
  PrintString $A010,344,240,FontBlack,TEXTFLOATA,2  ; Print Text String To VRAM Using Font At X,Y Position
  PrintString $A010,144,248,FontBlack,DOLLAR,0      ; Print Text String To VRAM Using Font At X,Y Position
  PrintValue  $A010,152,248,FontBlack,VALUEFLOATB,3 ; Print HEX Chars To VRAM Using Font At X,Y Position
  PrintString $A010,296,248,FontBlack,TEXTFLOATB,8  ; Print Text String To VRAM Using Font At X,Y Position
  bc1t CLTSPASSA ; Branch On FP True
  nop ; Delay Slot
  PrintString $A010,528,248,FontRed,FAIL,3 ; Print Text String To VRAM Using Font At X,Y Position
  j CLTSENDA
  nop ; Delay Slot
  CLTSPASSA:
  PrintString $A010,528,248,FontGreen,PASS,3 ; Print Text String To VRAM Using Font At X,Y Position
  CLTSENDA:

  la t0,VALUEFLOATB ; T0 = Float Data Offset
  lwc1 f0,0(t0)     ; F0 = Float Data
  la t0,VALUEFLOATC ; T0 = Float Data Offset
  lwc1 f1,0(t0)     ; F1 = Float Data
  c.lt.s f0,f1 ; Comparison Test
  PrintString $A010,144,264,FontBlack,DOLLAR,0      ; Print Text String To VRAM Using Font At X,Y Position
  PrintValue  $A010,152,264,FontBlack,VALUEFLOATB,3 ; Print HEX Chars To VRAM Using Font At X,Y Position
  PrintString $A010,296,264,FontBlack,TEXTFLOATB,8  ; Print Text String To VRAM Using Font At X,Y Position
  PrintString $A010,144,272,FontBlack,DOLLAR,0      ; Print Text String To VRAM Using Font At X,Y Position
  PrintValue  $A010,152,272,FontBlack,VALUEFLOATC,3 ; Print HEX Chars To VRAM Using Font At X,Y Position
  PrintString $A010,320,272,FontBlack,TEXTFLOATC,5  ; Print Text String To VRAM Using Font At X,Y Position
  bc1f CLTSPASSB ; Branch On FP False
  nop ; Delay Slot
  PrintString $A010,528,272,FontRed,FAIL,3 ; Print Text String To VRAM Using Font At X,Y Position
  j CLTSENDB
  nop ; Delay Slot
  CLTSPASSB:
  PrintString $A010,528,272,FontGreen,PASS,3 ; Print Text String To VRAM Using Font At X,Y Position
  CLTSENDB:

  la t0,VALUEFLOATC ; T0 = Float Data Offset
  lwc1 f0,0(t0)     ; F0 = Float Data
  la t0,VALUEFLOATD ; T0 = Float Data Offset
  lwc1 f1,0(t0)     ; F1 = Float Data
  c.lt.s f0,f1 ; Comparison Test
  PrintString $A010,144,288,FontBlack,DOLLAR,0      ; Print Text String To VRAM Using Font At X,Y Position
  PrintValue  $A010,152,288,FontBlack,VALUEFLOATC,3 ; Print HEX Chars To VRAM Using Font At X,Y Position
  PrintString $A010,320,288,FontBlack,TEXTFLOATC,5  ; Print Text String To VRAM Using Font At X,Y Position
  PrintString $A010,144,296,FontBlack,DOLLAR,0      ; Print Text String To VRAM Using Font At X,Y Position
  PrintValue  $A010,152,296,FontBlack,VALUEFLOATD,3 ; Print HEX Chars To VRAM Using Font At X,Y Position
  PrintString $A010,296,296,FontBlack,TEXTFLOATD,8  ; Print Text String To VRAM Using Font At X,Y Position
  bc1f CLTSPASSC ; Branch On FP False
  nop ; Delay Slot
  PrintString $A010,528,296,FontRed,FAIL,3 ; Print Text String To VRAM Using Font At X,Y Position
  j CLTSENDC
  nop ; Delay Slot
  CLTSPASSC:
  PrintString $A010,528,296,FontGreen,PASS,3 ; Print Text String To VRAM Using Font At X,Y Position
  CLTSENDC:

  la t0,VALUEFLOATD ; T0 = Float Data Offset
  lwc1 f0,0(t0)     ; F0 = Float Data
  la t0,VALUEFLOATE ; T0 = Float Data Offset
  lwc1 f1,0(t0)     ; F1 = Float Data
  c.lt.s f0,f1 ; Comparison Test
  PrintString $A010,144,312,FontBlack,DOLLAR,0      ; Print Text String To VRAM Using Font At X,Y Position
  PrintValue  $A010,152,312,FontBlack,VALUEFLOATD,3 ; Print HEX Chars To VRAM Using Font At X,Y Position
  PrintString $A010,296,312,FontBlack,TEXTFLOATD,8  ; Print Text String To VRAM Using Font At X,Y Position
  PrintString $A010,144,320,FontBlack,DOLLAR,0      ; Print Text String To VRAM Using Font At X,Y Position
  PrintValue  $A010,152,320,FontBlack,VALUEFLOATE,3 ; Print HEX Chars To VRAM Using Font At X,Y Position
  PrintString $A010,288,320,FontBlack,TEXTFLOATE,9  ; Print Text String To VRAM Using Font At X,Y Position
  bc1f CLTSPASSD ; Branch On FP False
  nop ; Delay Slot
  PrintString $A010,528,320,FontRed,FAIL,3 ; Print Text String To VRAM Using Font At X,Y Position
  j CLTSENDD
  nop ; Delay Slot
  CLTSPASSD:
  PrintString $A010,528,320,FontGreen,PASS,3 ; Print Text String To VRAM Using Font At X,Y Position
  CLTSENDD:

  la t0,VALUEFLOATE ; T0 = Float Data Offset
  lwc1 f0,0(t0)     ; F0 = Float Data
  la t0,VALUEFLOATF ; T0 = Float Data Offset
  lwc1 f1,0(t0)     ; F1 = Float Data
  c.lt.s f0,f1 ; Comparison Test
  PrintString $A010,144,336,FontBlack,DOLLAR,0      ; Print Text String To VRAM Using Font At X,Y Position
  PrintValue  $A010,152,336,FontBlack,VALUEFLOATE,3 ; Print HEX Chars To VRAM Using Font At X,Y Position
  PrintString $A010,288,336,FontBlack,TEXTFLOATE,9  ; Print Text String To VRAM Using Font At X,Y Position
  PrintString $A010,144,344,FontBlack,DOLLAR,0      ; Print Text String To VRAM Using Font At X,Y Position
  PrintValue  $A010,152,344,FontBlack,VALUEFLOATF,3 ; Print HEX Chars To VRAM Using Font At X,Y Position
  PrintString $A010,312,344,FontBlack,TEXTFLOATF,6  ; Print Text String To VRAM Using Font At X,Y Position
  bc1f CLTSPASSE ; Branch On FP False
  nop ; Delay Slot
  PrintString $A010,528,344,FontRed,FAIL,3 ; Print Text String To VRAM Using Font At X,Y Position
  j CLTSENDE
  nop ; Delay Slot
  CLTSPASSE:
  PrintString $A010,528,344,FontGreen,PASS,3 ; Print Text String To VRAM Using Font At X,Y Position
  CLTSENDE:

  la t0,VALUEFLOATF ; T0 = Float Data Offset
  lwc1 f0,0(t0)     ; F0 = Float Data
  la t0,VALUEFLOATG ; T0 = Float Data Offset
  lwc1 f1,0(t0)     ; F1 = Float Data
  c.lt.s f0,f1 ; Comparison Test
  PrintString $A010,144,360,FontBlack,DOLLAR,0      ; Print Text String To VRAM Using Font At X,Y Position
  PrintValue  $A010,152,360,FontBlack,VALUEFLOATF,3 ; Print HEX Chars To VRAM Using Font At X,Y Position
  PrintString $A010,312,360,FontBlack,TEXTFLOATF,6  ; Print Text String To VRAM Using Font At X,Y Position
  PrintString $A010,144,368,FontBlack,DOLLAR,0      ; Print Text String To VRAM Using Font At X,Y Position
  PrintValue  $A010,152,368,FontBlack,VALUEFLOATG,3 ; Print HEX Chars To VRAM Using Font At X,Y Position
  PrintString $A010,288,368,FontBlack,TEXTFLOATG,9  ; Print Text String To VRAM Using Font At X,Y Position
  bc1f CLTSPASSF ; Branch On FP False
  nop ; Delay Slot
  PrintString $A010,528,368,FontRed,FAIL,3 ; Print Text String To VRAM Using Font At X,Y Position
  j CLTSENDF
  nop ; Delay Slot
  CLTSPASSF:
  PrintString $A010,528,368,FontGreen,PASS,3 ; Print Text String To VRAM Using Font At X,Y Position
  CLTSENDF:

  la t0,VALUEFLOATA ; T0 = Float Data Offset
  lwc1 f0,0(t0)     ; F0 = Float Data
  la t0,VALUEFLOATG ; T0 = Float Data Offset
  lwc1 f1,0(t0)     ; F1 = Float Data
  c.lt.s f0,f1 ; Comparison Test
  PrintString $A010,144,384,FontBlack,DOLLAR,0      ; Print Text String To VRAM Using Font At X,Y Position
  PrintValue  $A010,152,384,FontBlack,VALUEFLOATA,3 ; Print HEX Chars To VRAM Using Font At X,Y Position
  PrintString $A010,344,384,FontBlack,TEXTFLOATA,2  ; Print Text String To VRAM Using Font At X,Y Position
  PrintString $A010,144,392,FontBlack,DOLLAR,0      ; Print Text String To VRAM Using Font At X,Y Position
  PrintValue  $A010,152,392,FontBlack,VALUEFLOATG,3 ; Print HEX Chars To VRAM Using Font At X,Y Position
  PrintString $A010,288,392,FontBlack,TEXTFLOATG,9  ; Print Text String To VRAM Using Font At X,Y Position
  bc1f CLTSPASSG ; Branch On FP False
  nop ; Delay Slot
  PrintString $A010,528,392,FontRed,FAIL,3 ; Print Text String To VRAM Using Font At X,Y Position
  j CLTSENDG
  nop ; Delay Slot
  CLTSPASSG:
  PrintString $A010,528,392,FontGreen,PASS,3 ; Print Text String To VRAM Using Font At X,Y Position
  CLTSENDG:

  la t0,VALUEFLOATD ; T0 = Float Data Offset
  lwc1 f0,0(t0)     ; F0 = Float Data
  la t0,VALUEFLOATD ; T0 = Float Data Offset
  lwc1 f1,0(t0)     ; F1 = Float Data
  c.lt.s f0,f1 ; Comparison Test
  PrintString $A010,144,408,FontBlack,DOLLAR,0      ; Print Text String To VRAM Using Font At X,Y Position
  PrintValue  $A010,152,408,FontBlack,VALUEFLOATD,3 ; Print HEX Chars To VRAM Using Font At X,Y Position
  PrintString $A010,296,408,FontBlack,TEXTFLOATD,8  ; Print Text String To VRAM Using Font At X,Y Position
  PrintString $A010,144,416,FontBlack,DOLLAR,0      ; Print Text String To VRAM Using Font At X,Y Position
  PrintValue  $A010,152,416,FontBlack,VALUEFLOATD,3 ; Print HEX Chars To VRAM Using Font At X,Y Position
  PrintString $A010,296,416,FontBlack,TEXTFLOATD,8  ; Print Text String To VRAM Using Font At X,Y Position
  bc1f CLTSPASSH ; Branch On FP False
  nop ; Delay Slot
  PrintString $A010,528,416,FontRed,FAIL,3 ; Print Text String To VRAM Using Font At X,Y Position
  j CLTSENDH
  nop ; Delay Slot
  CLTSPASSH:
  PrintString $A010,528,416,FontGreen,PASS,3 ; Print Text String To VRAM Using Font At X,Y Position
  CLTSENDH:

  la t0,VALUEFLOATE ; T0 = Float Data Offset
  lwc1 f0,0(t0)     ; F0 = Float Data
  la t0,VALUEFLOATE ; T0 = Float Data Offset
  lwc1 f1,0(t0)     ; F1 = Float Data
  c.lt.s f0,f1 ; Comparison Test
  PrintString $A010,144,432,FontBlack,DOLLAR,0      ; Print Text String To VRAM Using Font At X,Y Position
  PrintValue  $A010,152,432,FontBlack,VALUEFLOATE,3 ; Print HEX Chars To VRAM Using Font At X,Y Position
  PrintString $A010,288,432,FontBlack,TEXTFLOATE,9  ; Print Text String To VRAM Using Font At X,Y Position
  PrintString $A010,144,440,FontBlack,DOLLAR,0      ; Print Text String To VRAM Using Font At X,Y Position
  PrintValue  $A010,152,440,FontBlack,VALUEFLOATE,3 ; Print HEX Chars To VRAM Using Font At X,Y Position
  PrintString $A010,288,440,FontBlack,TEXTFLOATE,9  ; Print Text String To VRAM Using Font At X,Y Position
  bc1f CLTSPASSI ; Branch On FP False
  nop ; Delay Slot
  PrintString $A010,528,440,FontRed,FAIL,3 ; Print Text String To VRAM Using Font At X,Y Position
  j CLTSENDI
  nop ; Delay Slot
  CLTSPASSI:
  PrintString $A010,528,440,FontGreen,PASS,3 ; Print Text String To VRAM Using Font At X,Y Position
  CLTSENDI:


  PrintString $A010,0,448,FontBlack,PAGEBREAK,79 ; Print Text String To VRAM Using Font At X,Y Position


  lui t0,VI_BASE ; Load VI Base Register
Loop:
  WaitScanline $200 ; Wait For Scanline To Reach Vertical Blank
  WaitScanline $202

  li t1,$00000800 ; Even Field
  sw t1,VI_Y_SCALE(t0)

  WaitScanline $200 ; Wait For Scanline To Reach Vertical Blank
  WaitScanline $202

  li t1,$02000800 ; Odd Field
  sw t1,VI_Y_SCALE(t0)

  j Loop
  nop ; Delay Slot

CLTD: db "C.LT.D"
CLTS: db "C.LT.S"

FSFTHEX: db "FS/FT (Hex)"
FSFTDEC: db "FS/FT (Decimal)"
TEST: db "Test Result"
FAIL: db "FAIL"
PASS: db "PASS"

DOLLAR: db "$"

TEXTDOUBLEA: db "0.0"
TEXTDOUBLEB: db "12345678.67891234"
TEXTDOUBLEC: db "12345678.5"
TEXTDOUBLED: db "12345678.12345678"
TEXTDOUBLEE: db "-12345678.12345678"
TEXTDOUBLEF: db "-12345678.5"
TEXTDOUBLEG: db "-12345678.67891234"

TEXTFLOATA: db "0.0"
TEXTFLOATB: db "1234.6789"
TEXTFLOATC: db "1234.5"
TEXTFLOATD: db "1234.1234"
TEXTFLOATE: db "-1234.1234"
TEXTFLOATF: db "-1234.5"
TEXTFLOATG: db "-1234.6789"

PAGEBREAK: db "--------------------------------------------------------------------------------"

  align 8 ; Align 64-bit
VALUEDOUBLEA: IEEE64 0.0
VALUEDOUBLEB: IEEE64 12345678.67891234
VALUEDOUBLEC: IEEE64 12345678.5
VALUEDOUBLED: IEEE64 12345678.12345678
VALUEDOUBLEE: IEEE64 -12345678.12345678
VALUEDOUBLEF: IEEE64 -12345678.5
VALUEDOUBLEG: IEEE64 -12345678.67891234

VALUEFLOATA: IEEE32 0.0
VALUEFLOATB: IEEE32 1234.6789
VALUEFLOATC: IEEE32 1234.5
VALUEFLOATD: IEEE32 1234.1234
VALUEFLOATE: IEEE32 -1234.1234
VALUEFLOATF: IEEE32 -1234.5
VALUEFLOATG: IEEE32 -1234.6789

FontBlack: incbin FontBlack8x8.bin
FontGreen: incbin FontGreen8x8.bin
FontRed: incbin FontRed8x8.bin