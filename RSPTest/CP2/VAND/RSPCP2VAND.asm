; N64 'Bare Metal' RSP CP2 Vector Logical AND Short Elements Test Demo by krom (Peter Lemon):
  include LIB\N64.INC ; Include N64 Definitions
  dcb 1052672,$00 ; Set ROM Size
  org $80000000 ; Entry Point Of Code
  include LIB\N64_HEADER.ASM  ; Include 64 Byte Header & Vector Table
  incbin LIB\N64_BOOTCODE.BIN ; Include 4032 Byte Boot Code

PrintString: macro vram, xpos, ypos, fontfile, string, length ; Print Text String To VRAM Using Font At X,Y Position
  lui a0,vram ; A0 = Frame Buffer Pointer
  addi a0,((xpos*4)+((640*ypos)*4)) ; Place text at XY Position
  la a1,fontfile ; A1 = Characters
  la a2,string ; A2 = Text Offset
  li t0,length ; T0 = Number of Text Characters to Print
  DrawChars\@:
    li t1,7 ; T1 = Character X Pixel Counter
    li t2,7 ; T2 = Character Y Pixel Counter

    lb t3,0(a2) ; T3 = Next Text Character
    addi a2,1

    sll t3,8 ; Add Shift to Correct Position in Font (* 256)
    add t3,a1

    DrawCharX\@:
      lw t4,0(t3) ; Load Font Text Character Pixel
      addi t3,4
      sw t4,0(a0) ; Store Font Text Character Pixel into Frame Buffer
      addi a0,4

      bnez t1,DrawCharX\@ ; IF Character X Pixel Counter != 0 GOTO DrawCharX
      subi t1,1 ; Decrement Character X Pixel Counter

      addi a0,$9E0 ; Jump down 1 Scanline, Jump back 1 Char ((SCREEN_X * 4) - (CHAR_X * 4))
      li t1,7 ; Reset Character X Pixel Counter
      bnez t2,DrawCharX\@ ; IF Character Y Pixel Counter != 0 GOTO DrawCharX
      subi t2,1 ; Decrement Character Y Pixel Counter

    subi a0,$4FE0 ; ((SCREEN_X * 4) * CHAR_Y) - CHAR_X * 4
    bnez t0,DrawChars\@ ; Continue to Print Characters
    subi t0,1 ; Subtract Number of Text Characters to Print
    endm

PrintValue: macro vram, xpos, ypos, fontfile, value, length ; Print HEX Chars To VRAM Using Font At X,Y Position
  lui a0,vram ; A0 = Frame Buffer Pointer
  addi a0,((xpos*4)+((640*ypos)*4)) ; Place text at XY Position
  la a1,fontfile ; A1 = Characters
  la a2,value ; A2 = Value Offset
  li t0,length ; T0 = Number of HEX Chars to Print
  DrawHEXChars\@:
    li t1,7 ; T1 = Character X Pixel Counter
    li t2,7 ; T2 = Character Y Pixel Counter

    lb t3,0(a2) ; T3 = Next 2 HEX Chars
    addi a2,1

    srl t4,t3,4 ; T4 = 2nd Nibble
    andi t4,$F
    subi t5,t4,9
    bgtz t5,HEXLetters\@
    addi t4,$30 ; Delay Slot
    j HEXEnd\@
    nop ; Delay Slot

    HEXLetters\@:
    addi t4,7
    HEXEnd\@:

    sll t4,8 ; Add Shift to Correct Position in Font (* 256)
    add t4,a1

    DrawHEXCharX\@:
      lw t5,0(t4) ; Load Font Text Character Pixel
      addi t4,4
      sw t5,0(a0) ; Store Font Text Character Pixel into Frame Buffer
      addi a0,4

      bnez t1,DrawHEXCharX\@ ; IF Character X Pixel Counter != 0 GOTO DrawCharX
      subi t1,1 ; Decrement Character X Pixel Counter

      addi a0,$9E0 ; Jump down 1 Scanline, Jump back 1 Char ((SCREEN_X * 4) - (CHAR_X * 4))
      li t1,7 ; Reset Character X Pixel Counter
      bnez t2,DrawHEXCharX\@ ; IF Character Y Pixel Counter != 0 GOTO DrawCharX
      subi t2,1 ; Decrement Character Y Pixel Counter

    subi a0,$4FE0 ; ((SCREEN_X * 4) * CHAR_Y) - CHAR_X * 4

    li t2,7 ; Reset Character Y Pixel Counter

    andi t4,t3,$F ; T4 = 1st Nibble
    subi t5,t4,9
    bgtz t5,HEXLettersB\@
    addi t4,$30 ; Delay Slot
    j HEXEndB\@
    nop ; Delay Slot

    HEXLettersB\@:
    addi t4,7
    HEXEndB\@:

    sll t4,8 ; Add Shift to Correct Position in Font (* 256)
    add t4,a1

    DrawHEXCharXB\@:
      lw t5,0(t4) ; Load Font Text Character Pixel
      addi t4,4
      sw t5,0(a0) ; Store Font Text Character Pixel into Frame Buffer
      addi a0,4

      bnez t1,DrawHEXCharXB\@ ; IF Character X Pixel Counter != 0 GOTO DrawCharX
      subi t1,1 ; Decrement Character X Pixel Counter

      addi a0,$9E0 ; Jump down 1 Scanline, Jump back 1 Char ((SCREEN_X * 4) - (CHAR_X * 4))
      li t1,7 ; Reset Character X Pixel Counter
      bnez t2,DrawHEXCharXB\@ ; IF Character Y Pixel Counter != 0 GOTO DrawCharX
      subi t2,1 ; Decrement Character Y Pixel Counter

    subi a0,$4FE0 ; ((SCREEN_X * 4) * CHAR_Y) - CHAR_X * 4

    bnez t0,DrawHEXChars\@ ; Continue to Print Characters
    subi t0,1 ; Subtract Number of Text Characters to Print
    endm

Start:
  include LIB\N64_GFX.INC ; Include Graphics Macros
  include LIB\N64_RSP.INC ; Include RSP Macros
  N64_INIT ; Run N64 Initialisation Routine

  ScreenNTSC 640, 480, BPP32|INTERLACE|AA_MODE_2, $A0100000 ; Screen NTSC: 640x480, 32BPP, Interlace, Reample Only, DRAM Origin = $A0100000

  lui a0,$A010 ; A0 = VRAM Start Offset
  addi a1,a0,((640*480*4)-4) ; A1 = VRAM End Offset
  li t0,$000000FF ; T0 = Black
ClearScreen:
  sw t0,0(a0)
  bne a0,a1,ClearScreen
  addi a0,4 ; Delay Slot


  PrintString $A010,88,8,FontRed,VSVTHEX,10 ; Print Text String To VRAM Using Font At X,Y Position
  PrintString $A010,336,8,FontRed,VAVDHEX,10 ; Print Text String To VRAM Using Font At X,Y Position
  PrintString $A010,528,8,FontRed,TEST,10 ; Print Text String To VRAM Using Font At X,Y Position


  PrintString $A010,0,16,FontBlack,PAGEBREAK,79 ; Print Text String To VRAM Using Font At X,Y Position


  ; Load RSP Code To IMEM
  DMASPRD RSPVANDCode, RSPVANDCodeEND, SP_IMEM ; DMA Data Read MEM->RSP DRAM: Start Address, End Address, Destination RSP DRAM Address

  ; Load RSP Data To DMEM
  DMASPRD VALUEQUADA, VALUEQUADAEND, SP_DMEM    ; DMA Data Read MEM->RSP DRAM: Start Address, End Address, Destination RSP DRAM Address
  DMASPRD VALUEQUADB, VALUEQUADBEND, SP_DMEM+16 ; DMA Data Read MEM->RSP DRAM: Start Address, End Address, Destination RSP DRAM Address

  ; Set RSP Program Counter
  lui a0,SP_PC_BASE ; A0 = SP PC Base Register ($A4080000)
  li t0,$0000 ; T0 = RSP Program Counter Set To Zero (Start Of RSP Code)
  sw t0,SP_PC(a0) ; Store RSP Program Counter To SP PC Register ($A4080000)

  ; Set RSP Status (Start Execution)
  lui a0,SP_BASE ; A0 = SP Base Register ($A4040000)
  li t0,CLR_HLT|CLR_BRK|CLR_INT|CLR_STP|CLR_IOB ; T0 = RSP Status: Clear Halt, Broke, Interrupt, Single Step, Interrupt On Break
  sw t0,SP_STATUS(a0) ; Run RSP Code: Store RSP Status To SP Status Register ($A4040010)

  PrintString $A010,8,24,FontRed,VANDTEXT,3 ; Print Text String To VRAM Using Font At X,Y Position
  PrintString $A010,80,24,FontBlack,DOLLAR,0         ; Print Text String To VRAM Using Font At X,Y Position
  PrintValue  $A010,88,24,FontBlack,VALUEQUADA,1     ; Print HEX Chars To VRAM Using Font At X,Y Position
  PrintString $A010,128,24,FontBlack,DOLLAR,0        ; Print Text String To VRAM Using Font At X,Y Position
  PrintValue  $A010,136,24,FontBlack,VALUEQUADA+2,1  ; Print HEX Chars To VRAM Using Font At X,Y Position
  PrintString $A010,176,24,FontBlack,DOLLAR,0        ; Print Text String To VRAM Using Font At X,Y Position
  PrintValue  $A010,184,24,FontBlack,VALUEQUADA+4,1  ; Print HEX Chars To VRAM Using Font At X,Y Position
  PrintString $A010,224,24,FontBlack,DOLLAR,0        ; Print Text String To VRAM Using Font At X,Y Position
  PrintValue  $A010,232,24,FontBlack,VALUEQUADA+6,1  ; Print HEX Chars To VRAM Using Font At X,Y Position
  PrintString $A010,80,32,FontBlack,DOLLAR,0         ; Print Text String To VRAM Using Font At X,Y Position
  PrintValue  $A010,88,32,FontBlack,VALUEQUADA+8,1   ; Print HEX Chars To VRAM Using Font At X,Y Position
  PrintString $A010,128,32,FontBlack,DOLLAR,0        ; Print Text String To VRAM Using Font At X,Y Position
  PrintValue  $A010,136,32,FontBlack,VALUEQUADA+10,1 ; Print HEX Chars To VRAM Using Font At X,Y Position
  PrintString $A010,176,32,FontBlack,DOLLAR,0        ; Print Text String To VRAM Using Font At X,Y Position
  PrintValue  $A010,184,32,FontBlack,VALUEQUADA+12,1 ; Print HEX Chars To VRAM Using Font At X,Y Position
  PrintString $A010,224,32,FontBlack,DOLLAR,0        ; Print Text String To VRAM Using Font At X,Y Position
  PrintValue  $A010,232,32,FontBlack,VALUEQUADA+14,1 ; Print HEX Chars To VRAM Using Font At X,Y Position

  PrintString $A010,80,48,FontBlack,DOLLAR,0         ; Print Text String To VRAM Using Font At X,Y Position
  PrintValue  $A010,88,48,FontBlack,VALUEQUADB,1     ; Print HEX Chars To VRAM Using Font At X,Y Position
  PrintString $A010,128,48,FontBlack,DOLLAR,0        ; Print Text String To VRAM Using Font At X,Y Position
  PrintValue  $A010,136,48,FontBlack,VALUEQUADB+2,1  ; Print HEX Chars To VRAM Using Font At X,Y Position
  PrintString $A010,176,48,FontBlack,DOLLAR,0        ; Print Text String To VRAM Using Font At X,Y Position
  PrintValue  $A010,184,48,FontBlack,VALUEQUADB+4,1  ; Print HEX Chars To VRAM Using Font At X,Y Position
  PrintString $A010,224,48,FontBlack,DOLLAR,0        ; Print Text String To VRAM Using Font At X,Y Position
  PrintValue  $A010,232,48,FontBlack,VALUEQUADB+6,1  ; Print HEX Chars To VRAM Using Font At X,Y Position
  PrintString $A010,80,56,FontBlack,DOLLAR,0         ; Print Text String To VRAM Using Font At X,Y Position
  PrintValue  $A010,88,56,FontBlack,VALUEQUADB+8,1   ; Print HEX Chars To VRAM Using Font At X,Y Position
  PrintString $A010,128,56,FontBlack,DOLLAR,0        ; Print Text String To VRAM Using Font At X,Y Position
  PrintValue  $A010,136,56,FontBlack,VALUEQUADB+10,1 ; Print HEX Chars To VRAM Using Font At X,Y Position
  PrintString $A010,176,56,FontBlack,DOLLAR,0        ; Print Text String To VRAM Using Font At X,Y Position
  PrintValue  $A010,184,56,FontBlack,VALUEQUADB+12,1 ; Print HEX Chars To VRAM Using Font At X,Y Position
  PrintString $A010,224,56,FontBlack,DOLLAR,0        ; Print Text String To VRAM Using Font At X,Y Position
  PrintValue  $A010,232,56,FontBlack,VALUEQUADB+14,1 ; Print HEX Chars To VRAM Using Font At X,Y Position

  ; Store RSP Data To MEM
  lui a0,SP_MEM_BASE ; A0 = SP Memory Base Offset (DMEM)
  la a1,VDQUAD ; A1 = Quad Data Offset
  lw t0,0(a0)  ; T0 = Quad Data
  sw t0,0(a1)  ; Store Quad Data To MEM
  lw t0,4(a0)  ; T0 = Quad Data
  sw t0,4(a1)  ; Store Quad Data To MEM
  lw t0,8(a0)  ; T0 = Quad Data
  sw t0,8(a1)  ; Store Quad Data To MEM
  lw t0,12(a0) ; T0 = Quad Data
  sw t0,12(a1) ; Store Quad Data To MEM

  la a1,VAQUAD ; A1 = Quad Data Offset
  lw t0,16(a0) ; T0 = Quad Data
  sw t0,0(a1)  ; Store Quad Data To MEM
  lw t0,20(a0) ; T0 = Quad Data
  sw t0,4(a1)  ; Store Quad Data To MEM
  lw t0,24(a0) ; T0 = Quad Data
  sw t0,8(a1)  ; Store Quad Data To MEM
  lw t0,28(a0) ; T0 = Quad Data
  sw t0,12(a1) ; Store Quad Data To MEM

  la a1,VCOVCCWORD ; A1 = Word Data Offset
  lw t0,32(a0) ; T0 = Word Data
  sw t0,0(a1)  ; Store Word Data To MEM

  la a1,VCEBYTE ; A1 = Byte Data Offset
  lb t0,36(a0) ; T0 = Byte Data
  sb t0,0(a1)  ; Store Byte Data To MEM

  PrintString $A010,328,24,FontBlack,DOLLAR,0    ; Print Text String To VRAM Using Font At X,Y Position
  PrintValue  $A010,336,24,FontBlack,VAQUAD,1    ; Print HEX Chars To VRAM Using Font At X,Y Position
  PrintString $A010,376,24,FontBlack,DOLLAR,0    ; Print Text String To VRAM Using Font At X,Y Position
  PrintValue  $A010,384,24,FontBlack,VAQUAD+2,1  ; Print HEX Chars To VRAM Using Font At X,Y Position
  PrintString $A010,424,24,FontBlack,DOLLAR,0    ; Print Text String To VRAM Using Font At X,Y Position
  PrintValue  $A010,432,24,FontBlack,VAQUAD+4,1  ; Print HEX Chars To VRAM Using Font At X,Y Position
  PrintString $A010,472,24,FontBlack,DOLLAR,0    ; Print Text String To VRAM Using Font At X,Y Position
  PrintValue  $A010,480,24,FontBlack,VAQUAD+6,1  ; Print HEX Chars To VRAM Using Font At X,Y Position
  PrintString $A010,328,32,FontBlack,DOLLAR,0    ; Print Text String To VRAM Using Font At X,Y Position
  PrintValue  $A010,336,32,FontBlack,VAQUAD+8,1  ; Print HEX Chars To VRAM Using Font At X,Y Position
  PrintString $A010,376,32,FontBlack,DOLLAR,0    ; Print Text String To VRAM Using Font At X,Y Position
  PrintValue  $A010,384,32,FontBlack,VAQUAD+10,1 ; Print HEX Chars To VRAM Using Font At X,Y Position
  PrintString $A010,424,32,FontBlack,DOLLAR,0    ; Print Text String To VRAM Using Font At X,Y Position
  PrintValue  $A010,432,32,FontBlack,VAQUAD+12,1 ; Print HEX Chars To VRAM Using Font At X,Y Position
  PrintString $A010,472,32,FontBlack,DOLLAR,0    ; Print Text String To VRAM Using Font At X,Y Position
  PrintValue  $A010,480,32,FontBlack,VAQUAD+14,1 ; Print HEX Chars To VRAM Using Font At X,Y Position

  PrintString $A010,328,48,FontBlack,DOLLAR,0    ; Print Text String To VRAM Using Font At X,Y Position
  PrintValue  $A010,336,48,FontBlack,VDQUAD,1    ; Print HEX Chars To VRAM Using Font At X,Y Position
  PrintString $A010,376,48,FontBlack,DOLLAR,0    ; Print Text String To VRAM Using Font At X,Y Position
  PrintValue  $A010,384,48,FontBlack,VDQUAD+2,1  ; Print HEX Chars To VRAM Using Font At X,Y Position
  PrintString $A010,424,48,FontBlack,DOLLAR,0    ; Print Text String To VRAM Using Font At X,Y Position
  PrintValue  $A010,432,48,FontBlack,VDQUAD+4,1  ; Print HEX Chars To VRAM Using Font At X,Y Position
  PrintString $A010,472,48,FontBlack,DOLLAR,0    ; Print Text String To VRAM Using Font At X,Y Position
  PrintValue  $A010,480,48,FontBlack,VDQUAD+6,1  ; Print HEX Chars To VRAM Using Font At X,Y Position
  PrintString $A010,328,56,FontBlack,DOLLAR,0    ; Print Text String To VRAM Using Font At X,Y Position
  PrintValue  $A010,336,56,FontBlack,VDQUAD+8,1  ; Print HEX Chars To VRAM Using Font At X,Y Position
  PrintString $A010,376,56,FontBlack,DOLLAR,0    ; Print Text String To VRAM Using Font At X,Y Position
  PrintValue  $A010,384,56,FontBlack,VDQUAD+10,1 ; Print HEX Chars To VRAM Using Font At X,Y Position
  PrintString $A010,424,56,FontBlack,DOLLAR,0    ; Print Text String To VRAM Using Font At X,Y Position
  PrintValue  $A010,432,56,FontBlack,VDQUAD+12,1 ; Print HEX Chars To VRAM Using Font At X,Y Position
  PrintString $A010,472,56,FontBlack,DOLLAR,0    ; Print Text String To VRAM Using Font At X,Y Position
  PrintValue  $A010,480,56,FontBlack,VDQUAD+14,1 ; Print HEX Chars To VRAM Using Font At X,Y Position

  PrintString $A010,528,24,FontBlack,VCOHEX,5       ; Print Text String To VRAM Using Font At X,Y Position
  PrintValue  $A010,576,24,FontBlack,VCOVCCWORD,1   ; Print HEX Chars To VRAM Using Font At X,Y Position
  PrintString $A010,528,32,FontBlack,VCCHEX,5       ; Print Text String To VRAM Using Font At X,Y Position
  PrintValue  $A010,576,32,FontBlack,VCOVCCWORD+2,1 ; Print HEX Chars To VRAM Using Font At X,Y Position
  PrintString $A010,528,40,FontBlack,VCEHEX,5       ; Print Text String To VRAM Using Font At X,Y Position
  PrintValue  $A010,576,40,FontBlack,VCEBYTE,0      ; Print HEX Chars To VRAM Using Font At X,Y Position

  la a0,VDQUAD       ; A0 = Quad Data Offset
  ld t0,0(a0)        ; T0 = Quad Data
  la a0,VANDVDCHECKA ; A0 = Quad Check Data Offset
  ld t1,0(a0)        ; T1 = Quad Check Data
  bne t0,t1,VANDFAILA ; Compare Result Equality With Check Data
  nop ; Delay Slot
  la a0,VDQUAD       ; A0 = Quad Data Offset
  ld t0,8(a0)        ; T0 = Quad Data
  la a0,VANDVDCHECKA ; A0 = Quad Check Data Offset
  ld t1,8(a0)        ; T1 = Quad Check Data
  bne t0,t1,VANDFAILA ; Compare Result Equality With Check Data
  nop ; Delay Slot

  la a0,VAQUAD       ; A0 = Quad Data Offset
  ld t0,0(a0)        ; T0 = Quad Data
  la a0,VANDVACHECKA ; A0 = Quad Check Data Offset
  ld t1,0(a0)        ; T1 = Quad Check Data
  bne t0,t1,VANDFAILA ; Compare Result Equality With Check Data
  nop ; Delay Slot
  la a0,VAQUAD       ; A0 = Quad Data Offset
  ld t0,8(a0)        ; T0 = Quad Data
  la a0,VANDVACHECKA ; A0 = Quad Check Data Offset
  ld t1,8(a0)        ; T1 = Quad Check Data
  bne t0,t1,VANDFAILA ; Compare Result Equality With Check Data
  nop ; Delay Slot

  la a0,VCOVCCWORD       ; A0 = Word Data Offset
  lw t0,0(a0)            ; T0 = Word Data
  la a0,VANDVCOVCCCHECKA ; A0 = Word Check Data Offset
  lw t1,0(a0)            ; T1 = Word Check Data
  bne t0,t1,VANDFAILA ; Compare Result Equality With Check Data

  la a0,VCEBYTE       ; A0 = Byte Data Offset
  lb t0,0(a0)         ; T0 = Byte Data
  la a0,VANDVCECHECKA ; A0 = Byte Check Data Offset
  lb t1,0(a0)         ; T1 = Byte Check Data
  bne t0,t1,VANDFAILA ; Compare Result Equality With Check Data

  PrintString $A010,528,56,FontGreen,PASS,3 ; Print Text String To VRAM Using Font At X,Y Position
  j VANDENDA
  nop ; Delay Slot
  VANDFAILA:
  PrintString $A010,528,56,FontRed,FAIL,3 ; Print Text String To VRAM Using Font At X,Y Position
  VANDENDA:

  PrintString $A010,0,64,FontBlack,PAGEBREAK,79 ; Print Text String To VRAM Using Font At X,Y Position


  ; Load RSP Data To MEM
  DMASPRD VALUEQUADB, VALUEQUADBEND, SP_DMEM    ; DMA Data Read MEM->RSP DRAM: Start Address, End Address, Destination RSP DRAM Address
  DMASPRD VALUEQUADB, VALUEQUADBEND, SP_DMEM+16 ; DMA Data Read MEM->RSP DRAM: Start Address, End Address, Destination RSP DRAM Address

  ; Set RSP Status (Start Execution)
  lui a0,SP_BASE ; A0 = SP Base Register ($A4040000)
  li t0,CLR_HLT|CLR_BRK|CLR_INT|CLR_STP|CLR_IOB ; T0 = RSP Status: Clear Halt, Broke, Interrupt, Single Step, Interrupt On Break
  sw t0,SP_STATUS(a0) ; Run RSP Code: Store RSP Status To SP Status Register ($A4040010)

  PrintString $A010,80,72,FontBlack,DOLLAR,0         ; Print Text String To VRAM Using Font At X,Y Position
  PrintValue  $A010,88,72,FontBlack,VALUEQUADB,1     ; Print HEX Chars To VRAM Using Font At X,Y Position
  PrintString $A010,128,72,FontBlack,DOLLAR,0        ; Print Text String To VRAM Using Font At X,Y Position
  PrintValue  $A010,136,72,FontBlack,VALUEQUADB+2,1  ; Print HEX Chars To VRAM Using Font At X,Y Position
  PrintString $A010,176,72,FontBlack,DOLLAR,0        ; Print Text String To VRAM Using Font At X,Y Position
  PrintValue  $A010,184,72,FontBlack,VALUEQUADB+4,1  ; Print HEX Chars To VRAM Using Font At X,Y Position
  PrintString $A010,224,72,FontBlack,DOLLAR,0        ; Print Text String To VRAM Using Font At X,Y Position
  PrintValue  $A010,232,72,FontBlack,VALUEQUADB+6,1  ; Print HEX Chars To VRAM Using Font At X,Y Position
  PrintString $A010,80,80,FontBlack,DOLLAR,0         ; Print Text String To VRAM Using Font At X,Y Position
  PrintValue  $A010,88,80,FontBlack,VALUEQUADB+8,1   ; Print HEX Chars To VRAM Using Font At X,Y Position
  PrintString $A010,128,80,FontBlack,DOLLAR,0        ; Print Text String To VRAM Using Font At X,Y Position
  PrintValue  $A010,136,80,FontBlack,VALUEQUADB+10,1 ; Print HEX Chars To VRAM Using Font At X,Y Position
  PrintString $A010,176,80,FontBlack,DOLLAR,0        ; Print Text String To VRAM Using Font At X,Y Position
  PrintValue  $A010,184,80,FontBlack,VALUEQUADB+12,1 ; Print HEX Chars To VRAM Using Font At X,Y Position
  PrintString $A010,224,80,FontBlack,DOLLAR,0        ; Print Text String To VRAM Using Font At X,Y Position
  PrintValue  $A010,232,80,FontBlack,VALUEQUADB+14,1 ; Print HEX Chars To VRAM Using Font At X,Y Position

  PrintString $A010,80,96,FontBlack,DOLLAR,0         ; Print Text String To VRAM Using Font At X,Y Position
  PrintValue  $A010,88,96,FontBlack,VALUEQUADB,1     ; Print HEX Chars To VRAM Using Font At X,Y Position
  PrintString $A010,128,96,FontBlack,DOLLAR,0        ; Print Text String To VRAM Using Font At X,Y Position
  PrintValue  $A010,136,96,FontBlack,VALUEQUADB+2,1  ; Print HEX Chars To VRAM Using Font At X,Y Position
  PrintString $A010,176,96,FontBlack,DOLLAR,0        ; Print Text String To VRAM Using Font At X,Y Position
  PrintValue  $A010,184,96,FontBlack,VALUEQUADB+4,1  ; Print HEX Chars To VRAM Using Font At X,Y Position
  PrintString $A010,224,96,FontBlack,DOLLAR,0        ; Print Text String To VRAM Using Font At X,Y Position
  PrintValue  $A010,232,96,FontBlack,VALUEQUADB+6,1  ; Print HEX Chars To VRAM Using Font At X,Y Position
  PrintString $A010,80,104,FontBlack,DOLLAR,0         ; Print Text String To VRAM Using Font At X,Y Position
  PrintValue  $A010,88,104,FontBlack,VALUEQUADB+8,1   ; Print HEX Chars To VRAM Using Font At X,Y Position
  PrintString $A010,128,104,FontBlack,DOLLAR,0        ; Print Text String To VRAM Using Font At X,Y Position
  PrintValue  $A010,136,104,FontBlack,VALUEQUADB+10,1 ; Print HEX Chars To VRAM Using Font At X,Y Position
  PrintString $A010,176,104,FontBlack,DOLLAR,0        ; Print Text String To VRAM Using Font At X,Y Position
  PrintValue  $A010,184,104,FontBlack,VALUEQUADB+12,1 ; Print HEX Chars To VRAM Using Font At X,Y Position
  PrintString $A010,224,104,FontBlack,DOLLAR,0        ; Print Text String To VRAM Using Font At X,Y Position
  PrintValue  $A010,232,104,FontBlack,VALUEQUADB+14,1 ; Print HEX Chars To VRAM Using Font At X,Y Position

  ; Store RSP Data To MEM
  lui a0,SP_MEM_BASE ; A0 = SP Memory Base Offset (DMEM)
  la a1,VDQUAD ; A1 = Quad Data Offset
  lw t0,0(a0)  ; T0 = Quad Data
  sw t0,0(a1)  ; Store Quad Data To MEM
  lw t0,4(a0)  ; T0 = Quad Data
  sw t0,4(a1)  ; Store Quad Data To MEM
  lw t0,8(a0)  ; T0 = Quad Data
  sw t0,8(a1)  ; Store Quad Data To MEM
  lw t0,12(a0) ; T0 = Quad Data
  sw t0,12(a1) ; Store Quad Data To MEM

  la a1,VAQUAD ; A1 = Quad Data Offset
  lw t0,16(a0) ; T0 = Quad Data
  sw t0,0(a1)  ; Store Quad Data To MEM
  lw t0,20(a0) ; T0 = Quad Data
  sw t0,4(a1)  ; Store Quad Data To MEM
  lw t0,24(a0) ; T0 = Quad Data
  sw t0,8(a1)  ; Store Quad Data To MEM
  lw t0,28(a0) ; T0 = Quad Data
  sw t0,12(a1) ; Store Quad Data To MEM

  la a1,VCOVCCWORD ; A1 = Word Data Offset
  lw t0,32(a0) ; T0 = Word Data
  sw t0,0(a1)  ; Store Word Data To MEM

  la a1,VCEBYTE ; A1 = Byte Data Offset
  lb t0,36(a0) ; T0 = Byte Data
  sb t0,0(a1)  ; Store Byte Data To MEM

  PrintString $A010,328,72,FontBlack,DOLLAR,0    ; Print Text String To VRAM Using Font At X,Y Position
  PrintValue  $A010,336,72,FontBlack,VAQUAD,1    ; Print HEX Chars To VRAM Using Font At X,Y Position
  PrintString $A010,376,72,FontBlack,DOLLAR,0    ; Print Text String To VRAM Using Font At X,Y Position
  PrintValue  $A010,384,72,FontBlack,VAQUAD+2,1  ; Print HEX Chars To VRAM Using Font At X,Y Position
  PrintString $A010,424,72,FontBlack,DOLLAR,0    ; Print Text String To VRAM Using Font At X,Y Position
  PrintValue  $A010,432,72,FontBlack,VAQUAD+4,1  ; Print HEX Chars To VRAM Using Font At X,Y Position
  PrintString $A010,472,72,FontBlack,DOLLAR,0    ; Print Text String To VRAM Using Font At X,Y Position
  PrintValue  $A010,480,72,FontBlack,VAQUAD+6,1  ; Print HEX Chars To VRAM Using Font At X,Y Position
  PrintString $A010,328,80,FontBlack,DOLLAR,0    ; Print Text String To VRAM Using Font At X,Y Position
  PrintValue  $A010,336,80,FontBlack,VAQUAD+8,1  ; Print HEX Chars To VRAM Using Font At X,Y Position
  PrintString $A010,376,80,FontBlack,DOLLAR,0    ; Print Text String To VRAM Using Font At X,Y Position
  PrintValue  $A010,384,80,FontBlack,VAQUAD+10,1 ; Print HEX Chars To VRAM Using Font At X,Y Position
  PrintString $A010,424,80,FontBlack,DOLLAR,0    ; Print Text String To VRAM Using Font At X,Y Position
  PrintValue  $A010,432,80,FontBlack,VAQUAD+12,1 ; Print HEX Chars To VRAM Using Font At X,Y Position
  PrintString $A010,472,80,FontBlack,DOLLAR,0    ; Print Text String To VRAM Using Font At X,Y Position
  PrintValue  $A010,480,80,FontBlack,VAQUAD+14,1 ; Print HEX Chars To VRAM Using Font At X,Y Position

  PrintString $A010,328,96,FontBlack,DOLLAR,0    ; Print Text String To VRAM Using Font At X,Y Position
  PrintValue  $A010,336,96,FontBlack,VDQUAD,1    ; Print HEX Chars To VRAM Using Font At X,Y Position
  PrintString $A010,376,96,FontBlack,DOLLAR,0    ; Print Text String To VRAM Using Font At X,Y Position
  PrintValue  $A010,384,96,FontBlack,VDQUAD+2,1  ; Print HEX Chars To VRAM Using Font At X,Y Position
  PrintString $A010,424,96,FontBlack,DOLLAR,0    ; Print Text String To VRAM Using Font At X,Y Position
  PrintValue  $A010,432,96,FontBlack,VDQUAD+4,1  ; Print HEX Chars To VRAM Using Font At X,Y Position
  PrintString $A010,472,96,FontBlack,DOLLAR,0    ; Print Text String To VRAM Using Font At X,Y Position
  PrintValue  $A010,480,96,FontBlack,VDQUAD+6,1  ; Print HEX Chars To VRAM Using Font At X,Y Position
  PrintString $A010,328,104,FontBlack,DOLLAR,0    ; Print Text String To VRAM Using Font At X,Y Position
  PrintValue  $A010,336,104,FontBlack,VDQUAD+8,1  ; Print HEX Chars To VRAM Using Font At X,Y Position
  PrintString $A010,376,104,FontBlack,DOLLAR,0    ; Print Text String To VRAM Using Font At X,Y Position
  PrintValue  $A010,384,104,FontBlack,VDQUAD+10,1 ; Print HEX Chars To VRAM Using Font At X,Y Position
  PrintString $A010,424,104,FontBlack,DOLLAR,0    ; Print Text String To VRAM Using Font At X,Y Position
  PrintValue  $A010,432,104,FontBlack,VDQUAD+12,1 ; Print HEX Chars To VRAM Using Font At X,Y Position
  PrintString $A010,472,104,FontBlack,DOLLAR,0    ; Print Text String To VRAM Using Font At X,Y Position
  PrintValue  $A010,480,104,FontBlack,VDQUAD+14,1 ; Print HEX Chars To VRAM Using Font At X,Y Position

  PrintString $A010,528,72,FontBlack,VCOHEX,5       ; Print Text String To VRAM Using Font At X,Y Position
  PrintValue  $A010,576,72,FontBlack,VCOVCCWORD,1   ; Print HEX Chars To VRAM Using Font At X,Y Position
  PrintString $A010,528,80,FontBlack,VCCHEX,5       ; Print Text String To VRAM Using Font At X,Y Position
  PrintValue  $A010,576,80,FontBlack,VCOVCCWORD+2,1 ; Print HEX Chars To VRAM Using Font At X,Y Position
  PrintString $A010,528,88,FontBlack,VCEHEX,5       ; Print Text String To VRAM Using Font At X,Y Position
  PrintValue  $A010,576,88,FontBlack,VCEBYTE,0      ; Print HEX Chars To VRAM Using Font At X,Y Position

  la a0,VDQUAD       ; A0 = Quad Data Offset
  ld t0,0(a0)        ; T0 = Quad Data
  la a0,VANDVDCHECKB ; A0 = Quad Check Data Offset
  ld t1,0(a0)        ; T1 = Quad Check Data
  bne t0,t1,VANDFAILB ; Compare Result Equality With Check Data
  nop ; Delay Slot
  la a0,VDQUAD       ; A0 = Quad Data Offset
  ld t0,8(a0)        ; T0 = Quad Data
  la a0,VANDVDCHECKB ; A0 = Quad Check Data Offset
  ld t1,8(a0)        ; T1 = Quad Check Data
  bne t0,t1,VANDFAILB ; Compare Result Equality With Check Data
  nop ; Delay Slot

  la a0,VAQUAD       ; A0 = Quad Data Offset
  ld t0,0(a0)        ; T0 = Quad Data
  la a0,VANDVACHECKB ; A0 = Quad Check Data Offset
  ld t1,0(a0)        ; T1 = Quad Check Data
  bne t0,t1,VANDFAILB ; Compare Result Equality With Check Data
  nop ; Delay Slot
  la a0,VAQUAD       ; A0 = Quad Data Offset
  ld t0,8(a0)        ; T0 = Quad Data
  la a0,VANDVACHECKB ; A0 = Quad Check Data Offset
  ld t1,8(a0)        ; T1 = Quad Check Data
  bne t0,t1,VANDFAILB ; Compare Result Equality With Check Data
  nop ; Delay Slot

  la a0,VCOVCCWORD       ; A0 = Word Data Offset
  lw t0,0(a0)            ; T0 = Word Data
  la a0,VANDVCOVCCCHECKB ; A0 = Word Check Data Offset
  lw t1,0(a0)            ; T1 = Word Check Data
  bne t0,t1,VANDFAILB ; Compare Result Equality With Check Data

  la a0,VCEBYTE       ; A0 = Byte Data Offset
  lb t0,0(a0)         ; T0 = Byte Data
  la a0,VANDVCECHECKB ; A0 = Byte Check Data Offset
  lb t1,0(a0)         ; T1 = Byte Check Data
  bne t0,t1,VANDFAILB ; Compare Result Equality With Check Data

  PrintString $A010,528,104,FontGreen,PASS,3 ; Print Text String To VRAM Using Font At X,Y Position
  j VANDENDB
  nop ; Delay Slot
  VANDFAILB:
  PrintString $A010,528,104,FontRed,FAIL,3 ; Print Text String To VRAM Using Font At X,Y Position
  VANDENDB:

  PrintString $A010,0,112,FontBlack,PAGEBREAK,79 ; Print Text String To VRAM Using Font At X,Y Position


  ; Load RSP Data To MEM
  DMASPRD VALUEQUADB, VALUEQUADBEND, SP_DMEM    ; DMA Data Read MEM->RSP DRAM: Start Address, End Address, Destination RSP DRAM Address
  DMASPRD VALUEQUADC, VALUEQUADCEND, SP_DMEM+16 ; DMA Data Read MEM->RSP DRAM: Start Address, End Address, Destination RSP DRAM Address

  ; Set RSP Status (Start Execution)
  lui a0,SP_BASE ; A0 = SP Base Register ($A4040000)
  li t0,CLR_HLT|CLR_BRK|CLR_INT|CLR_STP|CLR_IOB ; T0 = RSP Status: Clear Halt, Broke, Interrupt, Single Step, Interrupt On Break
  sw t0,SP_STATUS(a0) ; Run RSP Code: Store RSP Status To SP Status Register ($A4040010)

  PrintString $A010,80,120,FontBlack,DOLLAR,0         ; Print Text String To VRAM Using Font At X,Y Position
  PrintValue  $A010,88,120,FontBlack,VALUEQUADB,1     ; Print HEX Chars To VRAM Using Font At X,Y Position
  PrintString $A010,128,120,FontBlack,DOLLAR,0        ; Print Text String To VRAM Using Font At X,Y Position
  PrintValue  $A010,136,120,FontBlack,VALUEQUADB+2,1  ; Print HEX Chars To VRAM Using Font At X,Y Position
  PrintString $A010,176,120,FontBlack,DOLLAR,0        ; Print Text String To VRAM Using Font At X,Y Position
  PrintValue  $A010,184,120,FontBlack,VALUEQUADB+4,1  ; Print HEX Chars To VRAM Using Font At X,Y Position
  PrintString $A010,224,120,FontBlack,DOLLAR,0        ; Print Text String To VRAM Using Font At X,Y Position
  PrintValue  $A010,232,120,FontBlack,VALUEQUADB+6,1  ; Print HEX Chars To VRAM Using Font At X,Y Position
  PrintString $A010,80,128,FontBlack,DOLLAR,0         ; Print Text String To VRAM Using Font At X,Y Position
  PrintValue  $A010,88,128,FontBlack,VALUEQUADB+8,1   ; Print HEX Chars To VRAM Using Font At X,Y Position
  PrintString $A010,128,128,FontBlack,DOLLAR,0        ; Print Text String To VRAM Using Font At X,Y Position
  PrintValue  $A010,136,128,FontBlack,VALUEQUADB+10,1 ; Print HEX Chars To VRAM Using Font At X,Y Position
  PrintString $A010,176,128,FontBlack,DOLLAR,0        ; Print Text String To VRAM Using Font At X,Y Position
  PrintValue  $A010,184,128,FontBlack,VALUEQUADB+12,1 ; Print HEX Chars To VRAM Using Font At X,Y Position
  PrintString $A010,224,128,FontBlack,DOLLAR,0        ; Print Text String To VRAM Using Font At X,Y Position
  PrintValue  $A010,232,128,FontBlack,VALUEQUADB+14,1 ; Print HEX Chars To VRAM Using Font At X,Y Position

  PrintString $A010,80,144,FontBlack,DOLLAR,0         ; Print Text String To VRAM Using Font At X,Y Position
  PrintValue  $A010,88,144,FontBlack,VALUEQUADC,1     ; Print HEX Chars To VRAM Using Font At X,Y Position
  PrintString $A010,128,144,FontBlack,DOLLAR,0        ; Print Text String To VRAM Using Font At X,Y Position
  PrintValue  $A010,136,144,FontBlack,VALUEQUADC+2,1  ; Print HEX Chars To VRAM Using Font At X,Y Position
  PrintString $A010,176,144,FontBlack,DOLLAR,0        ; Print Text String To VRAM Using Font At X,Y Position
  PrintValue  $A010,184,144,FontBlack,VALUEQUADC+4,1  ; Print HEX Chars To VRAM Using Font At X,Y Position
  PrintString $A010,224,144,FontBlack,DOLLAR,0        ; Print Text String To VRAM Using Font At X,Y Position
  PrintValue  $A010,232,144,FontBlack,VALUEQUADC+6,1  ; Print HEX Chars To VRAM Using Font At X,Y Position
  PrintString $A010,80,152,FontBlack,DOLLAR,0         ; Print Text String To VRAM Using Font At X,Y Position
  PrintValue  $A010,88,152,FontBlack,VALUEQUADC+8,1   ; Print HEX Chars To VRAM Using Font At X,Y Position
  PrintString $A010,128,152,FontBlack,DOLLAR,0        ; Print Text String To VRAM Using Font At X,Y Position
  PrintValue  $A010,136,152,FontBlack,VALUEQUADC+10,1 ; Print HEX Chars To VRAM Using Font At X,Y Position
  PrintString $A010,176,152,FontBlack,DOLLAR,0        ; Print Text String To VRAM Using Font At X,Y Position
  PrintValue  $A010,184,152,FontBlack,VALUEQUADC+12,1 ; Print HEX Chars To VRAM Using Font At X,Y Position
  PrintString $A010,224,152,FontBlack,DOLLAR,0        ; Print Text String To VRAM Using Font At X,Y Position
  PrintValue  $A010,232,152,FontBlack,VALUEQUADC+14,1 ; Print HEX Chars To VRAM Using Font At X,Y Position

  ; Store RSP Data To MEM
  lui a0,SP_MEM_BASE ; A0 = SP Memory Base Offset (DMEM)
  la a1,VDQUAD ; A1 = Quad Data Offset
  lw t0,0(a0)  ; T0 = Quad Data
  sw t0,0(a1)  ; Store Quad Data To MEM
  lw t0,4(a0)  ; T0 = Quad Data
  sw t0,4(a1)  ; Store Quad Data To MEM
  lw t0,8(a0)  ; T0 = Quad Data
  sw t0,8(a1)  ; Store Quad Data To MEM
  lw t0,12(a0) ; T0 = Quad Data
  sw t0,12(a1) ; Store Quad Data To MEM

  la a1,VAQUAD ; A1 = Quad Data Offset
  lw t0,16(a0) ; T0 = Quad Data
  sw t0,0(a1)  ; Store Quad Data To MEM
  lw t0,20(a0) ; T0 = Quad Data
  sw t0,4(a1)  ; Store Quad Data To MEM
  lw t0,24(a0) ; T0 = Quad Data
  sw t0,8(a1)  ; Store Quad Data To MEM
  lw t0,28(a0) ; T0 = Quad Data
  sw t0,12(a1) ; Store Quad Data To MEM

  la a1,VCOVCCWORD ; A1 = Word Data Offset
  lw t0,32(a0) ; T0 = Word Data
  sw t0,0(a1)  ; Store Word Data To MEM

  la a1,VCEBYTE ; A1 = Byte Data Offset
  lb t0,36(a0) ; T0 = Byte Data
  sb t0,0(a1)  ; Store Byte Data To MEM

  PrintString $A010,328,120,FontBlack,DOLLAR,0    ; Print Text String To VRAM Using Font At X,Y Position
  PrintValue  $A010,336,120,FontBlack,VAQUAD,1    ; Print HEX Chars To VRAM Using Font At X,Y Position
  PrintString $A010,376,120,FontBlack,DOLLAR,0    ; Print Text String To VRAM Using Font At X,Y Position
  PrintValue  $A010,384,120,FontBlack,VAQUAD+2,1  ; Print HEX Chars To VRAM Using Font At X,Y Position
  PrintString $A010,424,120,FontBlack,DOLLAR,0    ; Print Text String To VRAM Using Font At X,Y Position
  PrintValue  $A010,432,120,FontBlack,VAQUAD+4,1  ; Print HEX Chars To VRAM Using Font At X,Y Position
  PrintString $A010,472,120,FontBlack,DOLLAR,0    ; Print Text String To VRAM Using Font At X,Y Position
  PrintValue  $A010,480,120,FontBlack,VAQUAD+6,1  ; Print HEX Chars To VRAM Using Font At X,Y Position
  PrintString $A010,328,128,FontBlack,DOLLAR,0    ; Print Text String To VRAM Using Font At X,Y Position
  PrintValue  $A010,336,128,FontBlack,VAQUAD+8,1  ; Print HEX Chars To VRAM Using Font At X,Y Position
  PrintString $A010,376,128,FontBlack,DOLLAR,0    ; Print Text String To VRAM Using Font At X,Y Position
  PrintValue  $A010,384,128,FontBlack,VAQUAD+10,1 ; Print HEX Chars To VRAM Using Font At X,Y Position
  PrintString $A010,424,128,FontBlack,DOLLAR,0    ; Print Text String To VRAM Using Font At X,Y Position
  PrintValue  $A010,432,128,FontBlack,VAQUAD+12,1 ; Print HEX Chars To VRAM Using Font At X,Y Position
  PrintString $A010,472,128,FontBlack,DOLLAR,0    ; Print Text String To VRAM Using Font At X,Y Position
  PrintValue  $A010,480,128,FontBlack,VAQUAD+14,1 ; Print HEX Chars To VRAM Using Font At X,Y Position

  PrintString $A010,328,144,FontBlack,DOLLAR,0    ; Print Text String To VRAM Using Font At X,Y Position
  PrintValue  $A010,336,144,FontBlack,VDQUAD,1    ; Print HEX Chars To VRAM Using Font At X,Y Position
  PrintString $A010,376,144,FontBlack,DOLLAR,0    ; Print Text String To VRAM Using Font At X,Y Position
  PrintValue  $A010,384,144,FontBlack,VDQUAD+2,1  ; Print HEX Chars To VRAM Using Font At X,Y Position
  PrintString $A010,424,144,FontBlack,DOLLAR,0    ; Print Text String To VRAM Using Font At X,Y Position
  PrintValue  $A010,432,144,FontBlack,VDQUAD+4,1  ; Print HEX Chars To VRAM Using Font At X,Y Position
  PrintString $A010,472,144,FontBlack,DOLLAR,0    ; Print Text String To VRAM Using Font At X,Y Position
  PrintValue  $A010,480,144,FontBlack,VDQUAD+6,1  ; Print HEX Chars To VRAM Using Font At X,Y Position
  PrintString $A010,328,152,FontBlack,DOLLAR,0    ; Print Text String To VRAM Using Font At X,Y Position
  PrintValue  $A010,336,152,FontBlack,VDQUAD+8,1  ; Print HEX Chars To VRAM Using Font At X,Y Position
  PrintString $A010,376,152,FontBlack,DOLLAR,0    ; Print Text String To VRAM Using Font At X,Y Position
  PrintValue  $A010,384,152,FontBlack,VDQUAD+10,1 ; Print HEX Chars To VRAM Using Font At X,Y Position
  PrintString $A010,424,152,FontBlack,DOLLAR,0    ; Print Text String To VRAM Using Font At X,Y Position
  PrintValue  $A010,432,152,FontBlack,VDQUAD+12,1 ; Print HEX Chars To VRAM Using Font At X,Y Position
  PrintString $A010,472,152,FontBlack,DOLLAR,0    ; Print Text String To VRAM Using Font At X,Y Position
  PrintValue  $A010,480,152,FontBlack,VDQUAD+14,1 ; Print HEX Chars To VRAM Using Font At X,Y Position

  PrintString $A010,528,120,FontBlack,VCOHEX,5       ; Print Text String To VRAM Using Font At X,Y Position
  PrintValue  $A010,576,120,FontBlack,VCOVCCWORD,1   ; Print HEX Chars To VRAM Using Font At X,Y Position
  PrintString $A010,528,128,FontBlack,VCCHEX,5       ; Print Text String To VRAM Using Font At X,Y Position
  PrintValue  $A010,576,128,FontBlack,VCOVCCWORD+2,1 ; Print HEX Chars To VRAM Using Font At X,Y Position
  PrintString $A010,528,136,FontBlack,VCEHEX,5       ; Print Text String To VRAM Using Font At X,Y Position
  PrintValue  $A010,576,136,FontBlack,VCEBYTE,0      ; Print HEX Chars To VRAM Using Font At X,Y Position

  la a0,VDQUAD       ; A0 = Quad Data Offset
  ld t0,0(a0)        ; T0 = Quad Data
  la a0,VANDVDCHECKC ; A0 = Quad Check Data Offset
  ld t1,0(a0)        ; T1 = Quad Check Data
  bne t0,t1,VANDFAILC ; Compare Result Equality With Check Data
  nop ; Delay Slot
  la a0,VDQUAD       ; A0 = Quad Data Offset
  ld t0,8(a0)        ; T0 = Quad Data
  la a0,VANDVDCHECKC ; A0 = Quad Check Data Offset
  ld t1,8(a0)        ; T1 = Quad Check Data
  bne t0,t1,VANDFAILC ; Compare Result Equality With Check Data
  nop ; Delay Slot

  la a0,VAQUAD       ; A0 = Quad Data Offset
  ld t0,0(a0)        ; T0 = Quad Data
  la a0,VANDVACHECKC ; A0 = Quad Check Data Offset
  ld t1,0(a0)        ; T1 = Quad Check Data
  bne t0,t1,VANDFAILC ; Compare Result Equality With Check Data
  nop ; Delay Slot
  la a0,VAQUAD       ; A0 = Quad Data Offset
  ld t0,8(a0)        ; T0 = Quad Data
  la a0,VANDVACHECKC ; A0 = Quad Check Data Offset
  ld t1,8(a0)        ; T1 = Quad Check Data
  bne t0,t1,VANDFAILC ; Compare Result Equality With Check Data
  nop ; Delay Slot

  la a0,VCOVCCWORD       ; A0 = Word Data Offset
  lw t0,0(a0)            ; T0 = Word Data
  la a0,VANDVCOVCCCHECKC ; A0 = Word Check Data Offset
  lw t1,0(a0)            ; T1 = Word Check Data
  bne t0,t1,VANDFAILC ; Compare Result Equality With Check Data

  la a0,VCEBYTE       ; A0 = Byte Data Offset
  lb t0,0(a0)         ; T0 = Byte Data
  la a0,VANDVCECHECKC ; A0 = Byte Check Data Offset
  lb t1,0(a0)         ; T1 = Byte Check Data
  bne t0,t1,VANDFAILC ; Compare Result Equality With Check Data

  PrintString $A010,528,152,FontGreen,PASS,3 ; Print Text String To VRAM Using Font At X,Y Position
  j VANDENDC
  nop ; Delay Slot
  VANDFAILC:
  PrintString $A010,528,152,FontRed,FAIL,3 ; Print Text String To VRAM Using Font At X,Y Position
  VANDENDC:

  PrintString $A010,0,160,FontBlack,PAGEBREAK,79 ; Print Text String To VRAM Using Font At X,Y Position


  ; Load RSP Data To DMEM
  DMASPRD VALUEQUADC, VALUEQUADCEND, SP_DMEM    ; DMA Data Read MEM->RSP DRAM: Start Address, End Address, Destination RSP DRAM Address
  DMASPRD VALUEQUADC, VALUEQUADCEND, SP_DMEM+16 ; DMA Data Read MEM->RSP DRAM: Start Address, End Address, Destination RSP DRAM Address

  ; Set RSP Status (Start Execution)
  lui a0,SP_BASE ; A0 = SP Base Register ($A4040000)
  li t0,CLR_HLT|CLR_BRK|CLR_INT|CLR_STP|CLR_IOB ; T0 = RSP Status: Clear Halt, Broke, Interrupt, Single Step, Interrupt On Break
  sw t0,SP_STATUS(a0) ; Run RSP Code: Store RSP Status To SP Status Register ($A4040010)

  PrintString $A010,80,168,FontBlack,DOLLAR,0         ; Print Text String To VRAM Using Font At X,Y Position
  PrintValue  $A010,88,168,FontBlack,VALUEQUADC,1     ; Print HEX Chars To VRAM Using Font At X,Y Position
  PrintString $A010,128,168,FontBlack,DOLLAR,0        ; Print Text String To VRAM Using Font At X,Y Position
  PrintValue  $A010,136,168,FontBlack,VALUEQUADC+2,1  ; Print HEX Chars To VRAM Using Font At X,Y Position
  PrintString $A010,176,168,FontBlack,DOLLAR,0        ; Print Text String To VRAM Using Font At X,Y Position
  PrintValue  $A010,184,168,FontBlack,VALUEQUADC+4,1  ; Print HEX Chars To VRAM Using Font At X,Y Position
  PrintString $A010,224,168,FontBlack,DOLLAR,0        ; Print Text String To VRAM Using Font At X,Y Position
  PrintValue  $A010,232,168,FontBlack,VALUEQUADC+6,1  ; Print HEX Chars To VRAM Using Font At X,Y Position
  PrintString $A010,80,176,FontBlack,DOLLAR,0         ; Print Text String To VRAM Using Font At X,Y Position
  PrintValue  $A010,88,176,FontBlack,VALUEQUADC+8,1   ; Print HEX Chars To VRAM Using Font At X,Y Position
  PrintString $A010,128,176,FontBlack,DOLLAR,0        ; Print Text String To VRAM Using Font At X,Y Position
  PrintValue  $A010,136,176,FontBlack,VALUEQUADC+10,1 ; Print HEX Chars To VRAM Using Font At X,Y Position
  PrintString $A010,176,176,FontBlack,DOLLAR,0        ; Print Text String To VRAM Using Font At X,Y Position
  PrintValue  $A010,184,176,FontBlack,VALUEQUADC+12,1 ; Print HEX Chars To VRAM Using Font At X,Y Position
  PrintString $A010,224,176,FontBlack,DOLLAR,0        ; Print Text String To VRAM Using Font At X,Y Position
  PrintValue  $A010,232,176,FontBlack,VALUEQUADC+14,1 ; Print HEX Chars To VRAM Using Font At X,Y Position

  PrintString $A010,80,192,FontBlack,DOLLAR,0         ; Print Text String To VRAM Using Font At X,Y Position
  PrintValue  $A010,88,192,FontBlack,VALUEQUADC,1     ; Print HEX Chars To VRAM Using Font At X,Y Position
  PrintString $A010,128,192,FontBlack,DOLLAR,0        ; Print Text String To VRAM Using Font At X,Y Position
  PrintValue  $A010,136,192,FontBlack,VALUEQUADC+2,1  ; Print HEX Chars To VRAM Using Font At X,Y Position
  PrintString $A010,176,192,FontBlack,DOLLAR,0        ; Print Text String To VRAM Using Font At X,Y Position
  PrintValue  $A010,184,192,FontBlack,VALUEQUADC+4,1  ; Print HEX Chars To VRAM Using Font At X,Y Position
  PrintString $A010,224,192,FontBlack,DOLLAR,0        ; Print Text String To VRAM Using Font At X,Y Position
  PrintValue  $A010,232,192,FontBlack,VALUEQUADC+6,1  ; Print HEX Chars To VRAM Using Font At X,Y Position
  PrintString $A010,80,200,FontBlack,DOLLAR,0         ; Print Text String To VRAM Using Font At X,Y Position
  PrintValue  $A010,88,200,FontBlack,VALUEQUADC+8,1   ; Print HEX Chars To VRAM Using Font At X,Y Position
  PrintString $A010,128,200,FontBlack,DOLLAR,0        ; Print Text String To VRAM Using Font At X,Y Position
  PrintValue  $A010,136,200,FontBlack,VALUEQUADC+10,1 ; Print HEX Chars To VRAM Using Font At X,Y Position
  PrintString $A010,176,200,FontBlack,DOLLAR,0        ; Print Text String To VRAM Using Font At X,Y Position
  PrintValue  $A010,184,200,FontBlack,VALUEQUADC+12,1 ; Print HEX Chars To VRAM Using Font At X,Y Position
  PrintString $A010,224,200,FontBlack,DOLLAR,0        ; Print Text String To VRAM Using Font At X,Y Position
  PrintValue  $A010,232,200,FontBlack,VALUEQUADC+14,1 ; Print HEX Chars To VRAM Using Font At X,Y Position

  ; Store RSP Data To MEM
  lui a0,SP_MEM_BASE ; A0 = SP Memory Base Offset (DMEM)
  la a1,VDQUAD ; A1 = Quad Data Offset
  lw t0,0(a0)  ; T0 = Quad Data
  sw t0,0(a1)  ; Store Quad Data To MEM
  lw t0,4(a0)  ; T0 = Quad Data
  sw t0,4(a1)  ; Store Quad Data To MEM
  lw t0,8(a0)  ; T0 = Quad Data
  sw t0,8(a1)  ; Store Quad Data To MEM
  lw t0,12(a0) ; T0 = Quad Data
  sw t0,12(a1) ; Store Quad Data To MEM

  la a1,VAQUAD ; A1 = Quad Data Offset
  lw t0,16(a0) ; T0 = Quad Data
  sw t0,0(a1)  ; Store Quad Data To MEM
  lw t0,20(a0) ; T0 = Quad Data
  sw t0,4(a1)  ; Store Quad Data To MEM
  lw t0,24(a0) ; T0 = Quad Data
  sw t0,8(a1)  ; Store Quad Data To MEM
  lw t0,28(a0) ; T0 = Quad Data
  sw t0,12(a1) ; Store Quad Data To MEM

  la a1,VCOVCCWORD ; A1 = Word Data Offset
  lw t0,32(a0) ; T0 = Word Data
  sw t0,0(a1)  ; Store Word Data To MEM

  la a1,VCEBYTE ; A1 = Byte Data Offset
  lb t0,36(a0) ; T0 = Byte Data
  sb t0,0(a1)  ; Store Byte Data To MEM

  PrintString $A010,328,168,FontBlack,DOLLAR,0    ; Print Text String To VRAM Using Font At X,Y Position
  PrintValue  $A010,336,168,FontBlack,VAQUAD,1    ; Print HEX Chars To VRAM Using Font At X,Y Position
  PrintString $A010,376,168,FontBlack,DOLLAR,0    ; Print Text String To VRAM Using Font At X,Y Position
  PrintValue  $A010,384,168,FontBlack,VAQUAD+2,1  ; Print HEX Chars To VRAM Using Font At X,Y Position
  PrintString $A010,424,168,FontBlack,DOLLAR,0    ; Print Text String To VRAM Using Font At X,Y Position
  PrintValue  $A010,432,168,FontBlack,VAQUAD+4,1  ; Print HEX Chars To VRAM Using Font At X,Y Position
  PrintString $A010,472,168,FontBlack,DOLLAR,0    ; Print Text String To VRAM Using Font At X,Y Position
  PrintValue  $A010,480,168,FontBlack,VAQUAD+6,1  ; Print HEX Chars To VRAM Using Font At X,Y Position
  PrintString $A010,328,176,FontBlack,DOLLAR,0    ; Print Text String To VRAM Using Font At X,Y Position
  PrintValue  $A010,336,176,FontBlack,VAQUAD+8,1  ; Print HEX Chars To VRAM Using Font At X,Y Position
  PrintString $A010,376,176,FontBlack,DOLLAR,0    ; Print Text String To VRAM Using Font At X,Y Position
  PrintValue  $A010,384,176,FontBlack,VAQUAD+10,1 ; Print HEX Chars To VRAM Using Font At X,Y Position
  PrintString $A010,424,176,FontBlack,DOLLAR,0    ; Print Text String To VRAM Using Font At X,Y Position
  PrintValue  $A010,432,176,FontBlack,VAQUAD+12,1 ; Print HEX Chars To VRAM Using Font At X,Y Position
  PrintString $A010,472,176,FontBlack,DOLLAR,0    ; Print Text String To VRAM Using Font At X,Y Position
  PrintValue  $A010,480,176,FontBlack,VAQUAD+14,1 ; Print HEX Chars To VRAM Using Font At X,Y Position

  PrintString $A010,328,192,FontBlack,DOLLAR,0    ; Print Text String To VRAM Using Font At X,Y Position
  PrintValue  $A010,336,192,FontBlack,VDQUAD,1    ; Print HEX Chars To VRAM Using Font At X,Y Position
  PrintString $A010,376,192,FontBlack,DOLLAR,0    ; Print Text String To VRAM Using Font At X,Y Position
  PrintValue  $A010,384,192,FontBlack,VDQUAD+2,1  ; Print HEX Chars To VRAM Using Font At X,Y Position
  PrintString $A010,424,192,FontBlack,DOLLAR,0    ; Print Text String To VRAM Using Font At X,Y Position
  PrintValue  $A010,432,192,FontBlack,VDQUAD+4,1  ; Print HEX Chars To VRAM Using Font At X,Y Position
  PrintString $A010,472,192,FontBlack,DOLLAR,0    ; Print Text String To VRAM Using Font At X,Y Position
  PrintValue  $A010,480,192,FontBlack,VDQUAD+6,1  ; Print HEX Chars To VRAM Using Font At X,Y Position
  PrintString $A010,328,200,FontBlack,DOLLAR,0    ; Print Text String To VRAM Using Font At X,Y Position
  PrintValue  $A010,336,200,FontBlack,VDQUAD+8,1  ; Print HEX Chars To VRAM Using Font At X,Y Position
  PrintString $A010,376,200,FontBlack,DOLLAR,0    ; Print Text String To VRAM Using Font At X,Y Position
  PrintValue  $A010,384,200,FontBlack,VDQUAD+10,1 ; Print HEX Chars To VRAM Using Font At X,Y Position
  PrintString $A010,424,200,FontBlack,DOLLAR,0    ; Print Text String To VRAM Using Font At X,Y Position
  PrintValue  $A010,432,200,FontBlack,VDQUAD+12,1 ; Print HEX Chars To VRAM Using Font At X,Y Position
  PrintString $A010,472,200,FontBlack,DOLLAR,0    ; Print Text String To VRAM Using Font At X,Y Position
  PrintValue  $A010,480,200,FontBlack,VDQUAD+14,1 ; Print HEX Chars To VRAM Using Font At X,Y Position

  PrintString $A010,528,168,FontBlack,VCOHEX,5       ; Print Text String To VRAM Using Font At X,Y Position
  PrintValue  $A010,576,168,FontBlack,VCOVCCWORD,1   ; Print HEX Chars To VRAM Using Font At X,Y Position
  PrintString $A010,528,176,FontBlack,VCCHEX,5       ; Print Text String To VRAM Using Font At X,Y Position
  PrintValue  $A010,576,176,FontBlack,VCOVCCWORD+2,1 ; Print HEX Chars To VRAM Using Font At X,Y Position
  PrintString $A010,528,184,FontBlack,VCEHEX,5       ; Print Text String To VRAM Using Font At X,Y Position
  PrintValue  $A010,576,184,FontBlack,VCEBYTE,0      ; Print HEX Chars To VRAM Using Font At X,Y Position

  la a0,VDQUAD       ; A0 = Quad Data Offset
  ld t0,0(a0)        ; T0 = Quad Data
  la a0,VANDVDCHECKD ; A0 = Quad Check Data Offset
  ld t1,0(a0)        ; T1 = Quad Check Data
  bne t0,t1,VANDFAILD ; Compare Result Equality With Check Data
  nop ; Delay Slot
  la a0,VDQUAD       ; A0 = Quad Data Offset
  ld t0,8(a0)        ; T0 = Quad Data
  la a0,VANDVDCHECKD ; A0 = Quad Check Data Offset
  ld t1,8(a0)        ; T1 = Quad Check Data
  bne t0,t1,VANDFAILD ; Compare Result Equality With Check Data
  nop ; Delay Slot

  la a0,VAQUAD       ; A0 = Quad Data Offset
  ld t0,0(a0)        ; T0 = Quad Data
  la a0,VANDVACHECKD ; A0 = Quad Check Data Offset
  ld t1,0(a0)        ; T1 = Quad Check Data
  bne t0,t1,VANDFAILD ; Compare Result Equality With Check Data
  nop ; Delay Slot
  la a0,VAQUAD       ; A0 = Quad Data Offset
  ld t0,8(a0)        ; T0 = Quad Data
  la a0,VANDVACHECKD ; A0 = Quad Check Data Offset
  ld t1,8(a0)        ; T1 = Quad Check Data
  bne t0,t1,VANDFAILD ; Compare Result Equality With Check Data
  nop ; Delay Slot

  la a0,VCOVCCWORD       ; A0 = Word Data Offset
  lw t0,0(a0)            ; T0 = Word Data
  la a0,VANDVCOVCCCHECKD ; A0 = Word Check Data Offset
  lw t1,0(a0)            ; T1 = Word Check Data
  bne t0,t1,VANDFAILD ; Compare Result Equality With Check Data

  la a0,VCEBYTE       ; A0 = Byte Data Offset
  lb t0,0(a0)         ; T0 = Byte Data
  la a0,VANDVCECHECKD ; A0 = Byte Check Data Offset
  lb t1,0(a0)         ; T1 = Byte Check Data
  bne t0,t1,VANDFAILD ; Compare Result Equality With Check Data

  PrintString $A010,528,200,FontGreen,PASS,3 ; Print Text String To VRAM Using Font At X,Y Position
  j VANDENDD
  nop ; Delay Slot
  VANDFAILD:
  PrintString $A010,528,200,FontRed,FAIL,3 ; Print Text String To VRAM Using Font At X,Y Position
  VANDENDD:

  PrintString $A010,0,208,FontBlack,PAGEBREAK,79 ; Print Text String To VRAM Using Font At X,Y Position


  ; Load RSP Code To IMEM
  DMASPRD RSPVNANDCode, RSPVNANDCodeEND, SP_IMEM ; DMA Data Read MEM->RSP DRAM: Start Address, End Address, Destination RSP DRAM Address

  ; Load RSP Data To DMEM
  DMASPRD VALUEQUADA, VALUEQUADAEND, SP_DMEM    ; DMA Data Read MEM->RSP DRAM: Start Address, End Address, Destination RSP DRAM Address
  DMASPRD VALUEQUADB, VALUEQUADBEND, SP_DMEM+16 ; DMA Data Read MEM->RSP DRAM: Start Address, End Address, Destination RSP DRAM Address

  ; Set RSP Program Counter
  lui a0,SP_PC_BASE ; A0 = SP PC Base Register ($A4080000)
  li t0,$0000 ; T0 = RSP Program Counter Set To Zero (Start Of RSP Code)
  sw t0,SP_PC(a0) ; Store RSP Program Counter To SP PC Register ($A4080000)

  ; Set RSP Status (Start Execution)
  lui a0,SP_BASE ; A0 = SP Base Register ($A4040000)
  li t0,CLR_HLT|CLR_BRK|CLR_INT|CLR_STP|CLR_IOB ; T0 = RSP Status: Clear Halt, Broke, Interrupt, Single Step, Interrupt On Break
  sw t0,SP_STATUS(a0) ; Run RSP Code: Store RSP Status To SP Status Register ($A4040010)

  PrintString $A010,8,216,FontRed,VNANDTEXT,4 ; Print Text String To VRAM Using Font At X,Y Position
  PrintString $A010,80,216,FontBlack,DOLLAR,0         ; Print Text String To VRAM Using Font At X,Y Position
  PrintValue  $A010,88,216,FontBlack,VALUEQUADA,1     ; Print HEX Chars To VRAM Using Font At X,Y Position
  PrintString $A010,128,216,FontBlack,DOLLAR,0        ; Print Text String To VRAM Using Font At X,Y Position
  PrintValue  $A010,136,216,FontBlack,VALUEQUADA+2,1  ; Print HEX Chars To VRAM Using Font At X,Y Position
  PrintString $A010,176,216,FontBlack,DOLLAR,0        ; Print Text String To VRAM Using Font At X,Y Position
  PrintValue  $A010,184,216,FontBlack,VALUEQUADA+4,1  ; Print HEX Chars To VRAM Using Font At X,Y Position
  PrintString $A010,224,216,FontBlack,DOLLAR,0        ; Print Text String To VRAM Using Font At X,Y Position
  PrintValue  $A010,232,216,FontBlack,VALUEQUADA+6,1  ; Print HEX Chars To VRAM Using Font At X,Y Position
  PrintString $A010,80,224,FontBlack,DOLLAR,0         ; Print Text String To VRAM Using Font At X,Y Position
  PrintValue  $A010,88,224,FontBlack,VALUEQUADA+8,1   ; Print HEX Chars To VRAM Using Font At X,Y Position
  PrintString $A010,128,224,FontBlack,DOLLAR,0        ; Print Text String To VRAM Using Font At X,Y Position
  PrintValue  $A010,136,224,FontBlack,VALUEQUADA+10,1 ; Print HEX Chars To VRAM Using Font At X,Y Position
  PrintString $A010,176,224,FontBlack,DOLLAR,0        ; Print Text String To VRAM Using Font At X,Y Position
  PrintValue  $A010,184,224,FontBlack,VALUEQUADA+12,1 ; Print HEX Chars To VRAM Using Font At X,Y Position
  PrintString $A010,224,224,FontBlack,DOLLAR,0        ; Print Text String To VRAM Using Font At X,Y Position
  PrintValue  $A010,232,224,FontBlack,VALUEQUADA+14,1 ; Print HEX Chars To VRAM Using Font At X,Y Position

  PrintString $A010,80,240,FontBlack,DOLLAR,0         ; Print Text String To VRAM Using Font At X,Y Position
  PrintValue  $A010,88,240,FontBlack,VALUEQUADB,1     ; Print HEX Chars To VRAM Using Font At X,Y Position
  PrintString $A010,128,240,FontBlack,DOLLAR,0        ; Print Text String To VRAM Using Font At X,Y Position
  PrintValue  $A010,136,240,FontBlack,VALUEQUADB+2,1  ; Print HEX Chars To VRAM Using Font At X,Y Position
  PrintString $A010,176,240,FontBlack,DOLLAR,0        ; Print Text String To VRAM Using Font At X,Y Position
  PrintValue  $A010,184,240,FontBlack,VALUEQUADB+4,1  ; Print HEX Chars To VRAM Using Font At X,Y Position
  PrintString $A010,224,240,FontBlack,DOLLAR,0        ; Print Text String To VRAM Using Font At X,Y Position
  PrintValue  $A010,232,240,FontBlack,VALUEQUADB+6,1  ; Print HEX Chars To VRAM Using Font At X,Y Position
  PrintString $A010,80,248,FontBlack,DOLLAR,0         ; Print Text String To VRAM Using Font At X,Y Position
  PrintValue  $A010,88,248,FontBlack,VALUEQUADB+8,1   ; Print HEX Chars To VRAM Using Font At X,Y Position
  PrintString $A010,128,248,FontBlack,DOLLAR,0        ; Print Text String To VRAM Using Font At X,Y Position
  PrintValue  $A010,136,248,FontBlack,VALUEQUADB+10,1 ; Print HEX Chars To VRAM Using Font At X,Y Position
  PrintString $A010,176,248,FontBlack,DOLLAR,0        ; Print Text String To VRAM Using Font At X,Y Position
  PrintValue  $A010,184,248,FontBlack,VALUEQUADB+12,1 ; Print HEX Chars To VRAM Using Font At X,Y Position
  PrintString $A010,224,248,FontBlack,DOLLAR,0        ; Print Text String To VRAM Using Font At X,Y Position
  PrintValue  $A010,232,248,FontBlack,VALUEQUADB+14,1 ; Print HEX Chars To VRAM Using Font At X,Y Position

  ; Store RSP Data To MEM
  lui a0,SP_MEM_BASE ; A0 = SP Memory Base Offset (DMEM)
  la a1,VDQUAD ; A1 = Quad Data Offset
  lw t0,0(a0)  ; T0 = Quad Data
  sw t0,0(a1)  ; Store Quad Data To MEM
  lw t0,4(a0)  ; T0 = Quad Data
  sw t0,4(a1)  ; Store Quad Data To MEM
  lw t0,8(a0)  ; T0 = Quad Data
  sw t0,8(a1)  ; Store Quad Data To MEM
  lw t0,12(a0) ; T0 = Quad Data
  sw t0,12(a1) ; Store Quad Data To MEM

  la a1,VAQUAD ; A1 = Quad Data Offset
  lw t0,16(a0) ; T0 = Quad Data
  sw t0,0(a1)  ; Store Quad Data To MEM
  lw t0,20(a0) ; T0 = Quad Data
  sw t0,4(a1)  ; Store Quad Data To MEM
  lw t0,24(a0) ; T0 = Quad Data
  sw t0,8(a1)  ; Store Quad Data To MEM
  lw t0,28(a0) ; T0 = Quad Data
  sw t0,12(a1) ; Store Quad Data To MEM

  la a1,VCOVCCWORD ; A1 = Word Data Offset
  lw t0,32(a0) ; T0 = Word Data
  sw t0,0(a1)  ; Store Word Data To MEM

  la a1,VCEBYTE ; A1 = Byte Data Offset
  lb t0,36(a0) ; T0 = Byte Data
  sb t0,0(a1)  ; Store Byte Data To MEM

  PrintString $A010,328,216,FontBlack,DOLLAR,0    ; Print Text String To VRAM Using Font At X,Y Position
  PrintValue  $A010,336,216,FontBlack,VAQUAD,1    ; Print HEX Chars To VRAM Using Font At X,Y Position
  PrintString $A010,376,216,FontBlack,DOLLAR,0    ; Print Text String To VRAM Using Font At X,Y Position
  PrintValue  $A010,384,216,FontBlack,VAQUAD+2,1  ; Print HEX Chars To VRAM Using Font At X,Y Position
  PrintString $A010,424,216,FontBlack,DOLLAR,0    ; Print Text String To VRAM Using Font At X,Y Position
  PrintValue  $A010,432,216,FontBlack,VAQUAD+4,1  ; Print HEX Chars To VRAM Using Font At X,Y Position
  PrintString $A010,472,216,FontBlack,DOLLAR,0    ; Print Text String To VRAM Using Font At X,Y Position
  PrintValue  $A010,480,216,FontBlack,VAQUAD+6,1  ; Print HEX Chars To VRAM Using Font At X,Y Position
  PrintString $A010,328,224,FontBlack,DOLLAR,0    ; Print Text String To VRAM Using Font At X,Y Position
  PrintValue  $A010,336,224,FontBlack,VAQUAD+8,1  ; Print HEX Chars To VRAM Using Font At X,Y Position
  PrintString $A010,376,224,FontBlack,DOLLAR,0    ; Print Text String To VRAM Using Font At X,Y Position
  PrintValue  $A010,384,224,FontBlack,VAQUAD+10,1 ; Print HEX Chars To VRAM Using Font At X,Y Position
  PrintString $A010,424,224,FontBlack,DOLLAR,0    ; Print Text String To VRAM Using Font At X,Y Position
  PrintValue  $A010,432,224,FontBlack,VAQUAD+12,1 ; Print HEX Chars To VRAM Using Font At X,Y Position
  PrintString $A010,472,224,FontBlack,DOLLAR,0    ; Print Text String To VRAM Using Font At X,Y Position
  PrintValue  $A010,480,224,FontBlack,VAQUAD+14,1 ; Print HEX Chars To VRAM Using Font At X,Y Position

  PrintString $A010,328,240,FontBlack,DOLLAR,0    ; Print Text String To VRAM Using Font At X,Y Position
  PrintValue  $A010,336,240,FontBlack,VDQUAD,1    ; Print HEX Chars To VRAM Using Font At X,Y Position
  PrintString $A010,376,240,FontBlack,DOLLAR,0    ; Print Text String To VRAM Using Font At X,Y Position
  PrintValue  $A010,384,240,FontBlack,VDQUAD+2,1  ; Print HEX Chars To VRAM Using Font At X,Y Position
  PrintString $A010,424,240,FontBlack,DOLLAR,0    ; Print Text String To VRAM Using Font At X,Y Position
  PrintValue  $A010,432,240,FontBlack,VDQUAD+4,1  ; Print HEX Chars To VRAM Using Font At X,Y Position
  PrintString $A010,472,240,FontBlack,DOLLAR,0    ; Print Text String To VRAM Using Font At X,Y Position
  PrintValue  $A010,480,240,FontBlack,VDQUAD+6,1  ; Print HEX Chars To VRAM Using Font At X,Y Position
  PrintString $A010,328,248,FontBlack,DOLLAR,0    ; Print Text String To VRAM Using Font At X,Y Position
  PrintValue  $A010,336,248,FontBlack,VDQUAD+8,1  ; Print HEX Chars To VRAM Using Font At X,Y Position
  PrintString $A010,376,248,FontBlack,DOLLAR,0    ; Print Text String To VRAM Using Font At X,Y Position
  PrintValue  $A010,384,248,FontBlack,VDQUAD+10,1 ; Print HEX Chars To VRAM Using Font At X,Y Position
  PrintString $A010,424,248,FontBlack,DOLLAR,0    ; Print Text String To VRAM Using Font At X,Y Position
  PrintValue  $A010,432,248,FontBlack,VDQUAD+12,1 ; Print HEX Chars To VRAM Using Font At X,Y Position
  PrintString $A010,472,248,FontBlack,DOLLAR,0    ; Print Text String To VRAM Using Font At X,Y Position
  PrintValue  $A010,480,248,FontBlack,VDQUAD+14,1 ; Print HEX Chars To VRAM Using Font At X,Y Position

  PrintString $A010,528,216,FontBlack,VCOHEX,5       ; Print Text String To VRAM Using Font At X,Y Position
  PrintValue  $A010,576,216,FontBlack,VCOVCCWORD,1   ; Print HEX Chars To VRAM Using Font At X,Y Position
  PrintString $A010,528,224,FontBlack,VCCHEX,5       ; Print Text String To VRAM Using Font At X,Y Position
  PrintValue  $A010,576,224,FontBlack,VCOVCCWORD+2,1 ; Print HEX Chars To VRAM Using Font At X,Y Position
  PrintString $A010,528,232,FontBlack,VCEHEX,5       ; Print Text String To VRAM Using Font At X,Y Position
  PrintValue  $A010,576,232,FontBlack,VCEBYTE,0      ; Print HEX Chars To VRAM Using Font At X,Y Position

  la a0,VDQUAD        ; A0 = Quad Data Offset
  ld t0,0(a0)         ; T0 = Quad Data
  la a0,VNANDVDCHECKA ; A0 = Quad Check Data Offset
  ld t1,0(a0)         ; T1 = Quad Check Data
  bne t0,t1,VNANDFAILA ; Compare Result Equality With Check Data
  nop ; Delay Slot
  la a0,VDQUAD        ; A0 = Quad Data Offset
  ld t0,8(a0)         ; T0 = Quad Data
  la a0,VNANDVDCHECKA ; A0 = Quad Check Data Offset
  ld t1,8(a0)         ; T1 = Quad Check Data
  bne t0,t1,VNANDFAILA ; Compare Result Equality With Check Data
  nop ; Delay Slot

  la a0,VAQUAD        ; A0 = Quad Data Offset
  ld t0,0(a0)         ; T0 = Quad Data
  la a0,VNANDVACHECKA ; A0 = Quad Check Data Offset
  ld t1,0(a0)         ; T1 = Quad Check Data
  bne t0,t1,VNANDFAILA ; Compare Result Equality With Check Data
  nop ; Delay Slot
  la a0,VAQUAD        ; A0 = Quad Data Offset
  ld t0,8(a0)         ; T0 = Quad Data
  la a0,VNANDVACHECKA ; A0 = Quad Check Data Offset
  ld t1,8(a0)         ; T1 = Quad Check Data
  bne t0,t1,VNANDFAILA ; Compare Result Equality With Check Data
  nop ; Delay Slot

  la a0,VCOVCCWORD        ; A0 = Word Data Offset
  lw t0,0(a0)             ; T0 = Word Data
  la a0,VNANDVCOVCCCHECKA ; A0 = Word Check Data Offset
  lw t1,0(a0)             ; T1 = Word Check Data
  bne t0,t1,VNANDFAILA ; Compare Result Equality With Check Data

  la a0,VCEBYTE        ; A0 = Byte Data Offset
  lb t0,0(a0)          ; T0 = Byte Data
  la a0,VNANDVCECHECKA ; A0 = Byte Check Data Offset
  lb t1,0(a0)          ; T1 = Byte Check Data
  bne t0,t1,VNANDFAILA ; Compare Result Equality With Check Data

  PrintString $A010,528,248,FontGreen,PASS,3 ; Print Text String To VRAM Using Font At X,Y Position
  j VNANDENDA
  nop ; Delay Slot
  VNANDFAILA:
  PrintString $A010,528,248,FontRed,FAIL,3 ; Print Text String To VRAM Using Font At X,Y Position
  VNANDENDA:

  PrintString $A010,0,256,FontBlack,PAGEBREAK,79 ; Print Text String To VRAM Using Font At X,Y Position


  ; Load RSP Data To DMEM
  DMASPRD VALUEQUADB, VALUEQUADBEND, SP_DMEM    ; DMA Data Read MEM->RSP DRAM: Start Address, End Address, Destination RSP DRAM Address
  DMASPRD VALUEQUADB, VALUEQUADBEND, SP_DMEM+16 ; DMA Data Read MEM->RSP DRAM: Start Address, End Address, Destination RSP DRAM Address

  ; Set RSP Status (Start Execution)
  lui a0,SP_BASE ; A0 = SP Base Register ($A4040000)
  li t0,CLR_HLT|CLR_BRK|CLR_INT|CLR_STP|CLR_IOB ; T0 = RSP Status: Clear Halt, Broke, Interrupt, Single Step, Interrupt On Break
  sw t0,SP_STATUS(a0) ; Run RSP Code: Store RSP Status To SP Status Register ($A4040010)

  PrintString $A010,80,264,FontBlack,DOLLAR,0         ; Print Text String To VRAM Using Font At X,Y Position
  PrintValue  $A010,88,264,FontBlack,VALUEQUADB,1     ; Print HEX Chars To VRAM Using Font At X,Y Position
  PrintString $A010,128,264,FontBlack,DOLLAR,0        ; Print Text String To VRAM Using Font At X,Y Position
  PrintValue  $A010,136,264,FontBlack,VALUEQUADB+2,1  ; Print HEX Chars To VRAM Using Font At X,Y Position
  PrintString $A010,176,264,FontBlack,DOLLAR,0        ; Print Text String To VRAM Using Font At X,Y Position
  PrintValue  $A010,184,264,FontBlack,VALUEQUADB+4,1  ; Print HEX Chars To VRAM Using Font At X,Y Position
  PrintString $A010,224,264,FontBlack,DOLLAR,0        ; Print Text String To VRAM Using Font At X,Y Position
  PrintValue  $A010,232,264,FontBlack,VALUEQUADB+6,1  ; Print HEX Chars To VRAM Using Font At X,Y Position
  PrintString $A010,80,272,FontBlack,DOLLAR,0         ; Print Text String To VRAM Using Font At X,Y Position
  PrintValue  $A010,88,272,FontBlack,VALUEQUADB+8,1   ; Print HEX Chars To VRAM Using Font At X,Y Position
  PrintString $A010,128,272,FontBlack,DOLLAR,0        ; Print Text String To VRAM Using Font At X,Y Position
  PrintValue  $A010,136,272,FontBlack,VALUEQUADB+10,1 ; Print HEX Chars To VRAM Using Font At X,Y Position
  PrintString $A010,176,272,FontBlack,DOLLAR,0        ; Print Text String To VRAM Using Font At X,Y Position
  PrintValue  $A010,184,272,FontBlack,VALUEQUADB+12,1 ; Print HEX Chars To VRAM Using Font At X,Y Position
  PrintString $A010,224,272,FontBlack,DOLLAR,0        ; Print Text String To VRAM Using Font At X,Y Position
  PrintValue  $A010,232,272,FontBlack,VALUEQUADB+14,1 ; Print HEX Chars To VRAM Using Font At X,Y Position

  PrintString $A010,80,288,FontBlack,DOLLAR,0         ; Print Text String To VRAM Using Font At X,Y Position
  PrintValue  $A010,88,288,FontBlack,VALUEQUADB,1     ; Print HEX Chars To VRAM Using Font At X,Y Position
  PrintString $A010,128,288,FontBlack,DOLLAR,0        ; Print Text String To VRAM Using Font At X,Y Position
  PrintValue  $A010,136,288,FontBlack,VALUEQUADB+2,1  ; Print HEX Chars To VRAM Using Font At X,Y Position
  PrintString $A010,176,288,FontBlack,DOLLAR,0        ; Print Text String To VRAM Using Font At X,Y Position
  PrintValue  $A010,184,288,FontBlack,VALUEQUADB+4,1  ; Print HEX Chars To VRAM Using Font At X,Y Position
  PrintString $A010,224,288,FontBlack,DOLLAR,0        ; Print Text String To VRAM Using Font At X,Y Position
  PrintValue  $A010,232,288,FontBlack,VALUEQUADB+6,1  ; Print HEX Chars To VRAM Using Font At X,Y Position
  PrintString $A010,80,296,FontBlack,DOLLAR,0         ; Print Text String To VRAM Using Font At X,Y Position
  PrintValue  $A010,88,296,FontBlack,VALUEQUADB+8,1   ; Print HEX Chars To VRAM Using Font At X,Y Position
  PrintString $A010,128,296,FontBlack,DOLLAR,0        ; Print Text String To VRAM Using Font At X,Y Position
  PrintValue  $A010,136,296,FontBlack,VALUEQUADB+10,1 ; Print HEX Chars To VRAM Using Font At X,Y Position
  PrintString $A010,176,296,FontBlack,DOLLAR,0        ; Print Text String To VRAM Using Font At X,Y Position
  PrintValue  $A010,184,296,FontBlack,VALUEQUADB+12,1 ; Print HEX Chars To VRAM Using Font At X,Y Position
  PrintString $A010,224,296,FontBlack,DOLLAR,0        ; Print Text String To VRAM Using Font At X,Y Position
  PrintValue  $A010,232,296,FontBlack,VALUEQUADB+14,1 ; Print HEX Chars To VRAM Using Font At X,Y Position

  ; Store RSP Data To MEM
  lui a0,SP_MEM_BASE ; A0 = SP Memory Base Offset (DMEM)
  la a1,VDQUAD ; A1 = Quad Data Offset
  lw t0,0(a0)  ; T0 = Quad Data
  sw t0,0(a1)  ; Store Quad Data To MEM
  lw t0,4(a0)  ; T0 = Quad Data
  sw t0,4(a1)  ; Store Quad Data To MEM
  lw t0,8(a0)  ; T0 = Quad Data
  sw t0,8(a1)  ; Store Quad Data To MEM
  lw t0,12(a0) ; T0 = Quad Data
  sw t0,12(a1) ; Store Quad Data To MEM

  la a1,VAQUAD ; A1 = Quad Data Offset
  lw t0,16(a0) ; T0 = Quad Data
  sw t0,0(a1)  ; Store Quad Data To MEM
  lw t0,20(a0) ; T0 = Quad Data
  sw t0,4(a1)  ; Store Quad Data To MEM
  lw t0,24(a0) ; T0 = Quad Data
  sw t0,8(a1)  ; Store Quad Data To MEM
  lw t0,28(a0) ; T0 = Quad Data
  sw t0,12(a1) ; Store Quad Data To MEM

  la a1,VCOVCCWORD ; A1 = Word Data Offset
  lw t0,32(a0) ; T0 = Word Data
  sw t0,0(a1)  ; Store Word Data To MEM

  la a1,VCEBYTE ; A1 = Byte Data Offset
  lb t0,36(a0) ; T0 = Byte Data
  sb t0,0(a1)  ; Store Byte Data To MEM

  PrintString $A010,328,264,FontBlack,DOLLAR,0    ; Print Text String To VRAM Using Font At X,Y Position
  PrintValue  $A010,336,264,FontBlack,VAQUAD,1    ; Print HEX Chars To VRAM Using Font At X,Y Position
  PrintString $A010,376,264,FontBlack,DOLLAR,0    ; Print Text String To VRAM Using Font At X,Y Position
  PrintValue  $A010,384,264,FontBlack,VAQUAD+2,1  ; Print HEX Chars To VRAM Using Font At X,Y Position
  PrintString $A010,424,264,FontBlack,DOLLAR,0    ; Print Text String To VRAM Using Font At X,Y Position
  PrintValue  $A010,432,264,FontBlack,VAQUAD+4,1  ; Print HEX Chars To VRAM Using Font At X,Y Position
  PrintString $A010,472,264,FontBlack,DOLLAR,0    ; Print Text String To VRAM Using Font At X,Y Position
  PrintValue  $A010,480,264,FontBlack,VAQUAD+6,1  ; Print HEX Chars To VRAM Using Font At X,Y Position
  PrintString $A010,328,272,FontBlack,DOLLAR,0    ; Print Text String To VRAM Using Font At X,Y Position
  PrintValue  $A010,336,272,FontBlack,VAQUAD+8,1  ; Print HEX Chars To VRAM Using Font At X,Y Position
  PrintString $A010,376,272,FontBlack,DOLLAR,0    ; Print Text String To VRAM Using Font At X,Y Position
  PrintValue  $A010,384,272,FontBlack,VAQUAD+10,1 ; Print HEX Chars To VRAM Using Font At X,Y Position
  PrintString $A010,424,272,FontBlack,DOLLAR,0    ; Print Text String To VRAM Using Font At X,Y Position
  PrintValue  $A010,432,272,FontBlack,VAQUAD+12,1 ; Print HEX Chars To VRAM Using Font At X,Y Position
  PrintString $A010,472,272,FontBlack,DOLLAR,0    ; Print Text String To VRAM Using Font At X,Y Position
  PrintValue  $A010,480,272,FontBlack,VAQUAD+14,1 ; Print HEX Chars To VRAM Using Font At X,Y Position

  PrintString $A010,328,288,FontBlack,DOLLAR,0    ; Print Text String To VRAM Using Font At X,Y Position
  PrintValue  $A010,336,288,FontBlack,VDQUAD,1    ; Print HEX Chars To VRAM Using Font At X,Y Position
  PrintString $A010,376,288,FontBlack,DOLLAR,0    ; Print Text String To VRAM Using Font At X,Y Position
  PrintValue  $A010,384,288,FontBlack,VDQUAD+2,1  ; Print HEX Chars To VRAM Using Font At X,Y Position
  PrintString $A010,424,288,FontBlack,DOLLAR,0    ; Print Text String To VRAM Using Font At X,Y Position
  PrintValue  $A010,432,288,FontBlack,VDQUAD+4,1  ; Print HEX Chars To VRAM Using Font At X,Y Position
  PrintString $A010,472,288,FontBlack,DOLLAR,0    ; Print Text String To VRAM Using Font At X,Y Position
  PrintValue  $A010,480,288,FontBlack,VDQUAD+6,1  ; Print HEX Chars To VRAM Using Font At X,Y Position
  PrintString $A010,328,296,FontBlack,DOLLAR,0    ; Print Text String To VRAM Using Font At X,Y Position
  PrintValue  $A010,336,296,FontBlack,VDQUAD+8,1  ; Print HEX Chars To VRAM Using Font At X,Y Position
  PrintString $A010,376,296,FontBlack,DOLLAR,0    ; Print Text String To VRAM Using Font At X,Y Position
  PrintValue  $A010,384,296,FontBlack,VDQUAD+10,1 ; Print HEX Chars To VRAM Using Font At X,Y Position
  PrintString $A010,424,296,FontBlack,DOLLAR,0    ; Print Text String To VRAM Using Font At X,Y Position
  PrintValue  $A010,432,296,FontBlack,VDQUAD+12,1 ; Print HEX Chars To VRAM Using Font At X,Y Position
  PrintString $A010,472,296,FontBlack,DOLLAR,0    ; Print Text String To VRAM Using Font At X,Y Position
  PrintValue  $A010,480,296,FontBlack,VDQUAD+14,1 ; Print HEX Chars To VRAM Using Font At X,Y Position

  PrintString $A010,528,264,FontBlack,VCOHEX,5       ; Print Text String To VRAM Using Font At X,Y Position
  PrintValue  $A010,576,264,FontBlack,VCOVCCWORD,1   ; Print HEX Chars To VRAM Using Font At X,Y Position
  PrintString $A010,528,272,FontBlack,VCCHEX,5       ; Print Text String To VRAM Using Font At X,Y Position
  PrintValue  $A010,576,272,FontBlack,VCOVCCWORD+2,1 ; Print HEX Chars To VRAM Using Font At X,Y Position
  PrintString $A010,528,280,FontBlack,VCEHEX,5       ; Print Text String To VRAM Using Font At X,Y Position
  PrintValue  $A010,576,280,FontBlack,VCEBYTE,0      ; Print HEX Chars To VRAM Using Font At X,Y Position

  la a0,VDQUAD        ; A0 = Quad Data Offset
  ld t0,0(a0)         ; T0 = Quad Data
  la a0,VNANDVDCHECKB ; A0 = Quad Check Data Offset
  ld t1,0(a0)         ; T1 = Quad Check Data
  bne t0,t1,VNANDFAILB ; Compare Result Equality With Check Data
  nop ; Delay Slot
  la a0,VDQUAD        ; A0 = Quad Data Offset
  ld t0,8(a0)         ; T0 = Quad Data
  la a0,VNANDVDCHECKB ; A0 = Quad Check Data Offset
  ld t1,8(a0)         ; T1 = Quad Check Data
  bne t0,t1,VNANDFAILB ; Compare Result Equality With Check Data
  nop ; Delay Slot

  la a0,VAQUAD        ; A0 = Quad Data Offset
  ld t0,0(a0)         ; T0 = Quad Data
  la a0,VNANDVACHECKB ; A0 = Quad Check Data Offset
  ld t1,0(a0)         ; T1 = Quad Check Data
  bne t0,t1,VNANDFAILB ; Compare Result Equality With Check Data
  nop ; Delay Slot
  la a0,VAQUAD        ; A0 = Quad Data Offset
  ld t0,8(a0)         ; T0 = Quad Data
  la a0,VNANDVACHECKB ; A0 = Quad Check Data Offset
  ld t1,8(a0)         ; T1 = Quad Check Data
  bne t0,t1,VNANDFAILB ; Compare Result Equality With Check Data
  nop ; Delay Slot

  la a0,VCOVCCWORD        ; A0 = Word Data Offset
  lw t0,0(a0)             ; T0 = Word Data
  la a0,VNANDVCOVCCCHECKB ; A0 = Word Check Data Offset
  lw t1,0(a0)             ; T1 = Word Check Data
  bne t0,t1,VNANDFAILB ; Compare Result Equality With Check Data

  la a0,VCEBYTE        ; A0 = Byte Data Offset
  lb t0,0(a0)          ; T0 = Byte Data
  la a0,VNANDVCECHECKB ; A0 = Byte Check Data Offset
  lb t1,0(a0)          ; T1 = Byte Check Data
  bne t0,t1,VNANDFAILB ; Compare Result Equality With Check Data

  PrintString $A010,528,296,FontGreen,PASS,3 ; Print Text String To VRAM Using Font At X,Y Position
  j VNANDENDB
  nop ; Delay Slot
  VNANDFAILB:
  PrintString $A010,528,296,FontRed,FAIL,3 ; Print Text String To VRAM Using Font At X,Y Position
  VNANDENDB:

  PrintString $A010,0,304,FontBlack,PAGEBREAK,79 ; Print Text String To VRAM Using Font At X,Y Position


  ; Load RSP Data To DMEM
  DMASPRD VALUEQUADB, VALUEQUADBEND, SP_DMEM    ; DMA Data Read MEM->RSP DRAM: Start Address, End Address, Destination RSP DRAM Address
  DMASPRD VALUEQUADC, VALUEQUADCEND, SP_DMEM+16 ; DMA Data Read MEM->RSP DRAM: Start Address, End Address, Destination RSP DRAM Address

  ; Set RSP Status (Start Execution)
  lui a0,SP_BASE ; A0 = SP Base Register ($A4040000)
  li t0,CLR_HLT|CLR_BRK|CLR_INT|CLR_STP|CLR_IOB ; T0 = RSP Status: Clear Halt, Broke, Interrupt, Single Step, Interrupt On Break
  sw t0,SP_STATUS(a0) ; Run RSP Code: Store RSP Status To SP Status Register ($A4040010)

  PrintString $A010,80,312,FontBlack,DOLLAR,0         ; Print Text String To VRAM Using Font At X,Y Position
  PrintValue  $A010,88,312,FontBlack,VALUEQUADB,1     ; Print HEX Chars To VRAM Using Font At X,Y Position
  PrintString $A010,128,312,FontBlack,DOLLAR,0        ; Print Text String To VRAM Using Font At X,Y Position
  PrintValue  $A010,136,312,FontBlack,VALUEQUADB+2,1  ; Print HEX Chars To VRAM Using Font At X,Y Position
  PrintString $A010,176,312,FontBlack,DOLLAR,0        ; Print Text String To VRAM Using Font At X,Y Position
  PrintValue  $A010,184,312,FontBlack,VALUEQUADB+4,1  ; Print HEX Chars To VRAM Using Font At X,Y Position
  PrintString $A010,224,312,FontBlack,DOLLAR,0        ; Print Text String To VRAM Using Font At X,Y Position
  PrintValue  $A010,232,312,FontBlack,VALUEQUADB+6,1  ; Print HEX Chars To VRAM Using Font At X,Y Position
  PrintString $A010,80,320,FontBlack,DOLLAR,0         ; Print Text String To VRAM Using Font At X,Y Position
  PrintValue  $A010,88,320,FontBlack,VALUEQUADB+8,1   ; Print HEX Chars To VRAM Using Font At X,Y Position
  PrintString $A010,128,320,FontBlack,DOLLAR,0        ; Print Text String To VRAM Using Font At X,Y Position
  PrintValue  $A010,136,320,FontBlack,VALUEQUADB+10,1 ; Print HEX Chars To VRAM Using Font At X,Y Position
  PrintString $A010,176,320,FontBlack,DOLLAR,0        ; Print Text String To VRAM Using Font At X,Y Position
  PrintValue  $A010,184,320,FontBlack,VALUEQUADB+12,1 ; Print HEX Chars To VRAM Using Font At X,Y Position
  PrintString $A010,224,320,FontBlack,DOLLAR,0        ; Print Text String To VRAM Using Font At X,Y Position
  PrintValue  $A010,232,320,FontBlack,VALUEQUADB+14,1 ; Print HEX Chars To VRAM Using Font At X,Y Position

  PrintString $A010,80,336,FontBlack,DOLLAR,0         ; Print Text String To VRAM Using Font At X,Y Position
  PrintValue  $A010,88,336,FontBlack,VALUEQUADC,1     ; Print HEX Chars To VRAM Using Font At X,Y Position
  PrintString $A010,128,336,FontBlack,DOLLAR,0        ; Print Text String To VRAM Using Font At X,Y Position
  PrintValue  $A010,136,336,FontBlack,VALUEQUADC+2,1  ; Print HEX Chars To VRAM Using Font At X,Y Position
  PrintString $A010,176,336,FontBlack,DOLLAR,0        ; Print Text String To VRAM Using Font At X,Y Position
  PrintValue  $A010,184,336,FontBlack,VALUEQUADC+4,1  ; Print HEX Chars To VRAM Using Font At X,Y Position
  PrintString $A010,224,336,FontBlack,DOLLAR,0        ; Print Text String To VRAM Using Font At X,Y Position
  PrintValue  $A010,232,336,FontBlack,VALUEQUADC+6,1  ; Print HEX Chars To VRAM Using Font At X,Y Position
  PrintString $A010,80,344,FontBlack,DOLLAR,0         ; Print Text String To VRAM Using Font At X,Y Position
  PrintValue  $A010,88,344,FontBlack,VALUEQUADC+8,1   ; Print HEX Chars To VRAM Using Font At X,Y Position
  PrintString $A010,128,344,FontBlack,DOLLAR,0        ; Print Text String To VRAM Using Font At X,Y Position
  PrintValue  $A010,136,344,FontBlack,VALUEQUADC+10,1 ; Print HEX Chars To VRAM Using Font At X,Y Position
  PrintString $A010,176,344,FontBlack,DOLLAR,0        ; Print Text String To VRAM Using Font At X,Y Position
  PrintValue  $A010,184,344,FontBlack,VALUEQUADC+12,1 ; Print HEX Chars To VRAM Using Font At X,Y Position
  PrintString $A010,224,344,FontBlack,DOLLAR,0        ; Print Text String To VRAM Using Font At X,Y Position
  PrintValue  $A010,232,344,FontBlack,VALUEQUADC+14,1 ; Print HEX Chars To VRAM Using Font At X,Y Position

  ; Store RSP Data To MEM
  lui a0,SP_MEM_BASE ; A0 = SP Memory Base Offset (DMEM)
  la a1,VDQUAD ; A1 = Quad Data Offset
  lw t0,0(a0)  ; T0 = Quad Data
  sw t0,0(a1)  ; Store Quad Data To MEM
  lw t0,4(a0)  ; T0 = Quad Data
  sw t0,4(a1)  ; Store Quad Data To MEM
  lw t0,8(a0)  ; T0 = Quad Data
  sw t0,8(a1)  ; Store Quad Data To MEM
  lw t0,12(a0) ; T0 = Quad Data
  sw t0,12(a1) ; Store Quad Data To MEM

  la a1,VAQUAD ; A1 = Quad Data Offset
  lw t0,16(a0) ; T0 = Quad Data
  sw t0,0(a1)  ; Store Quad Data To MEM
  lw t0,20(a0) ; T0 = Quad Data
  sw t0,4(a1)  ; Store Quad Data To MEM
  lw t0,24(a0) ; T0 = Quad Data
  sw t0,8(a1)  ; Store Quad Data To MEM
  lw t0,28(a0) ; T0 = Quad Data
  sw t0,12(a1) ; Store Quad Data To MEM

  la a1,VCOVCCWORD ; A1 = Word Data Offset
  lw t0,32(a0) ; T0 = Word Data
  sw t0,0(a1)  ; Store Word Data To MEM

  la a1,VCEBYTE ; A1 = Byte Data Offset
  lb t0,36(a0) ; T0 = Byte Data
  sb t0,0(a1)  ; Store Byte Data To MEM

  PrintString $A010,328,312,FontBlack,DOLLAR,0    ; Print Text String To VRAM Using Font At X,Y Position
  PrintValue  $A010,336,312,FontBlack,VAQUAD,1    ; Print HEX Chars To VRAM Using Font At X,Y Position
  PrintString $A010,376,312,FontBlack,DOLLAR,0    ; Print Text String To VRAM Using Font At X,Y Position
  PrintValue  $A010,384,312,FontBlack,VAQUAD+2,1  ; Print HEX Chars To VRAM Using Font At X,Y Position
  PrintString $A010,424,312,FontBlack,DOLLAR,0    ; Print Text String To VRAM Using Font At X,Y Position
  PrintValue  $A010,432,312,FontBlack,VAQUAD+4,1  ; Print HEX Chars To VRAM Using Font At X,Y Position
  PrintString $A010,472,312,FontBlack,DOLLAR,0    ; Print Text String To VRAM Using Font At X,Y Position
  PrintValue  $A010,480,312,FontBlack,VAQUAD+6,1  ; Print HEX Chars To VRAM Using Font At X,Y Position
  PrintString $A010,328,320,FontBlack,DOLLAR,0    ; Print Text String To VRAM Using Font At X,Y Position
  PrintValue  $A010,336,320,FontBlack,VAQUAD+8,1  ; Print HEX Chars To VRAM Using Font At X,Y Position
  PrintString $A010,376,320,FontBlack,DOLLAR,0    ; Print Text String To VRAM Using Font At X,Y Position
  PrintValue  $A010,384,320,FontBlack,VAQUAD+10,1 ; Print HEX Chars To VRAM Using Font At X,Y Position
  PrintString $A010,424,320,FontBlack,DOLLAR,0    ; Print Text String To VRAM Using Font At X,Y Position
  PrintValue  $A010,432,320,FontBlack,VAQUAD+12,1 ; Print HEX Chars To VRAM Using Font At X,Y Position
  PrintString $A010,472,320,FontBlack,DOLLAR,0    ; Print Text String To VRAM Using Font At X,Y Position
  PrintValue  $A010,480,320,FontBlack,VAQUAD+14,1 ; Print HEX Chars To VRAM Using Font At X,Y Position

  PrintString $A010,328,336,FontBlack,DOLLAR,0    ; Print Text String To VRAM Using Font At X,Y Position
  PrintValue  $A010,336,336,FontBlack,VDQUAD,1    ; Print HEX Chars To VRAM Using Font At X,Y Position
  PrintString $A010,376,336,FontBlack,DOLLAR,0    ; Print Text String To VRAM Using Font At X,Y Position
  PrintValue  $A010,384,336,FontBlack,VDQUAD+2,1  ; Print HEX Chars To VRAM Using Font At X,Y Position
  PrintString $A010,424,336,FontBlack,DOLLAR,0    ; Print Text String To VRAM Using Font At X,Y Position
  PrintValue  $A010,432,336,FontBlack,VDQUAD+4,1  ; Print HEX Chars To VRAM Using Font At X,Y Position
  PrintString $A010,472,336,FontBlack,DOLLAR,0    ; Print Text String To VRAM Using Font At X,Y Position
  PrintValue  $A010,480,336,FontBlack,VDQUAD+6,1  ; Print HEX Chars To VRAM Using Font At X,Y Position
  PrintString $A010,328,344,FontBlack,DOLLAR,0    ; Print Text String To VRAM Using Font At X,Y Position
  PrintValue  $A010,336,344,FontBlack,VDQUAD+8,1  ; Print HEX Chars To VRAM Using Font At X,Y Position
  PrintString $A010,376,344,FontBlack,DOLLAR,0    ; Print Text String To VRAM Using Font At X,Y Position
  PrintValue  $A010,384,344,FontBlack,VDQUAD+10,1 ; Print HEX Chars To VRAM Using Font At X,Y Position
  PrintString $A010,424,344,FontBlack,DOLLAR,0    ; Print Text String To VRAM Using Font At X,Y Position
  PrintValue  $A010,432,344,FontBlack,VDQUAD+12,1 ; Print HEX Chars To VRAM Using Font At X,Y Position
  PrintString $A010,472,344,FontBlack,DOLLAR,0    ; Print Text String To VRAM Using Font At X,Y Position
  PrintValue  $A010,480,344,FontBlack,VDQUAD+14,1 ; Print HEX Chars To VRAM Using Font At X,Y Position

  PrintString $A010,528,312,FontBlack,VCOHEX,5       ; Print Text String To VRAM Using Font At X,Y Position
  PrintValue  $A010,576,312,FontBlack,VCOVCCWORD,1   ; Print HEX Chars To VRAM Using Font At X,Y Position
  PrintString $A010,528,320,FontBlack,VCCHEX,5       ; Print Text String To VRAM Using Font At X,Y Position
  PrintValue  $A010,576,320,FontBlack,VCOVCCWORD+2,1 ; Print HEX Chars To VRAM Using Font At X,Y Position
  PrintString $A010,528,328,FontBlack,VCEHEX,5       ; Print Text String To VRAM Using Font At X,Y Position
  PrintValue  $A010,576,328,FontBlack,VCEBYTE,0      ; Print HEX Chars To VRAM Using Font At X,Y Position

  la a0,VDQUAD        ; A0 = Quad Data Offset
  ld t0,0(a0)         ; T0 = Quad Data
  la a0,VNANDVDCHECKC ; A0 = Quad Check Data Offset
  ld t1,0(a0)         ; T1 = Quad Check Data
  bne t0,t1,VNANDFAILC ; Compare Result Equality With Check Data
  nop ; Delay Slot
  la a0,VDQUAD        ; A0 = Quad Data Offset
  ld t0,8(a0)         ; T0 = Quad Data
  la a0,VNANDVDCHECKC ; A0 = Quad Check Data Offset
  ld t1,8(a0)         ; T1 = Quad Check Data
  bne t0,t1,VNANDFAILC ; Compare Result Equality With Check Data
  nop ; Delay Slot

  la a0,VAQUAD        ; A0 = Quad Data Offset
  ld t0,0(a0)         ; T0 = Quad Data
  la a0,VNANDVACHECKC ; A0 = Quad Check Data Offset
  ld t1,0(a0)         ; T1 = Quad Check Data
  bne t0,t1,VNANDFAILC ; Compare Result Equality With Check Data
  nop ; Delay Slot
  la a0,VAQUAD        ; A0 = Quad Data Offset
  ld t0,8(a0)         ; T0 = Quad Data
  la a0,VNANDVACHECKC ; A0 = Quad Check Data Offset
  ld t1,8(a0)         ; T1 = Quad Check Data
  bne t0,t1,VNANDFAILC ; Compare Result Equality With Check Data
  nop ; Delay Slot

  la a0,VCOVCCWORD        ; A0 = Word Data Offset
  lw t0,0(a0)             ; T0 = Word Data
  la a0,VNANDVCOVCCCHECKC ; A0 = Word Check Data Offset
  lw t1,0(a0)             ; T1 = Word Check Data
  bne t0,t1,VNANDFAILC ; Compare Result Equality With Check Data

  la a0,VCEBYTE        ; A0 = Byte Data Offset
  lb t0,0(a0)          ; T0 = Byte Data
  la a0,VNANDVCECHECKC ; A0 = Byte Check Data Offset
  lb t1,0(a0)          ; T1 = Byte Check Data
  bne t0,t1,VNANDFAILC ; Compare Result Equality With Check Data

  PrintString $A010,528,344,FontGreen,PASS,3 ; Print Text String To VRAM Using Font At X,Y Position
  j VNANDENDC
  nop ; Delay Slot
  VNANDFAILC:
  PrintString $A010,528,344,FontRed,FAIL,3 ; Print Text String To VRAM Using Font At X,Y Position
  VNANDENDC:

  PrintString $A010,0,352,FontBlack,PAGEBREAK,79 ; Print Text String To VRAM Using Font At X,Y Position


  ; Load RSP Data To DMEM
  DMASPRD VALUEQUADC, VALUEQUADCEND, SP_DMEM    ; DMA Data Read MEM->RSP DRAM: Start Address, End Address, Destination RSP DRAM Address
  DMASPRD VALUEQUADC, VALUEQUADCEND, SP_DMEM+16 ; DMA Data Read MEM->RSP DRAM: Start Address, End Address, Destination RSP DRAM Address

  ; Set RSP Status (Start Execution)
  lui a0,SP_BASE ; A0 = SP Base Register ($A4040000)
  li t0,CLR_HLT|CLR_BRK|CLR_INT|CLR_STP|CLR_IOB ; T0 = RSP Status: Clear Halt, Broke, Interrupt, Single Step, Interrupt On Break
  sw t0,SP_STATUS(a0) ; Run RSP Code: Store RSP Status To SP Status Register ($A4040010)

  PrintString $A010,80,360,FontBlack,DOLLAR,0         ; Print Text String To VRAM Using Font At X,Y Position
  PrintValue  $A010,88,360,FontBlack,VALUEQUADC,1     ; Print HEX Chars To VRAM Using Font At X,Y Position
  PrintString $A010,128,360,FontBlack,DOLLAR,0        ; Print Text String To VRAM Using Font At X,Y Position
  PrintValue  $A010,136,360,FontBlack,VALUEQUADC+2,1  ; Print HEX Chars To VRAM Using Font At X,Y Position
  PrintString $A010,176,360,FontBlack,DOLLAR,0        ; Print Text String To VRAM Using Font At X,Y Position
  PrintValue  $A010,184,360,FontBlack,VALUEQUADC+4,1  ; Print HEX Chars To VRAM Using Font At X,Y Position
  PrintString $A010,224,360,FontBlack,DOLLAR,0        ; Print Text String To VRAM Using Font At X,Y Position
  PrintValue  $A010,232,360,FontBlack,VALUEQUADC+6,1  ; Print HEX Chars To VRAM Using Font At X,Y Position
  PrintString $A010,80,368,FontBlack,DOLLAR,0         ; Print Text String To VRAM Using Font At X,Y Position
  PrintValue  $A010,88,368,FontBlack,VALUEQUADC+8,1   ; Print HEX Chars To VRAM Using Font At X,Y Position
  PrintString $A010,128,368,FontBlack,DOLLAR,0        ; Print Text String To VRAM Using Font At X,Y Position
  PrintValue  $A010,136,368,FontBlack,VALUEQUADC+10,1 ; Print HEX Chars To VRAM Using Font At X,Y Position
  PrintString $A010,176,368,FontBlack,DOLLAR,0        ; Print Text String To VRAM Using Font At X,Y Position
  PrintValue  $A010,184,368,FontBlack,VALUEQUADC+12,1 ; Print HEX Chars To VRAM Using Font At X,Y Position
  PrintString $A010,224,368,FontBlack,DOLLAR,0        ; Print Text String To VRAM Using Font At X,Y Position
  PrintValue  $A010,232,368,FontBlack,VALUEQUADC+14,1 ; Print HEX Chars To VRAM Using Font At X,Y Position

  PrintString $A010,80,384,FontBlack,DOLLAR,0         ; Print Text String To VRAM Using Font At X,Y Position
  PrintValue  $A010,88,384,FontBlack,VALUEQUADC,1     ; Print HEX Chars To VRAM Using Font At X,Y Position
  PrintString $A010,128,384,FontBlack,DOLLAR,0        ; Print Text String To VRAM Using Font At X,Y Position
  PrintValue  $A010,136,384,FontBlack,VALUEQUADC+2,1  ; Print HEX Chars To VRAM Using Font At X,Y Position
  PrintString $A010,176,384,FontBlack,DOLLAR,0        ; Print Text String To VRAM Using Font At X,Y Position
  PrintValue  $A010,184,384,FontBlack,VALUEQUADC+4,1  ; Print HEX Chars To VRAM Using Font At X,Y Position
  PrintString $A010,224,384,FontBlack,DOLLAR,0        ; Print Text String To VRAM Using Font At X,Y Position
  PrintValue  $A010,232,384,FontBlack,VALUEQUADC+6,1  ; Print HEX Chars To VRAM Using Font At X,Y Position
  PrintString $A010,80,392,FontBlack,DOLLAR,0         ; Print Text String To VRAM Using Font At X,Y Position
  PrintValue  $A010,88,392,FontBlack,VALUEQUADC+8,1   ; Print HEX Chars To VRAM Using Font At X,Y Position
  PrintString $A010,128,392,FontBlack,DOLLAR,0        ; Print Text String To VRAM Using Font At X,Y Position
  PrintValue  $A010,136,392,FontBlack,VALUEQUADC+10,1 ; Print HEX Chars To VRAM Using Font At X,Y Position
  PrintString $A010,176,392,FontBlack,DOLLAR,0        ; Print Text String To VRAM Using Font At X,Y Position
  PrintValue  $A010,184,392,FontBlack,VALUEQUADC+12,1 ; Print HEX Chars To VRAM Using Font At X,Y Position
  PrintString $A010,224,392,FontBlack,DOLLAR,0        ; Print Text String To VRAM Using Font At X,Y Position
  PrintValue  $A010,232,392,FontBlack,VALUEQUADC+14,1 ; Print HEX Chars To VRAM Using Font At X,Y Position

  ; Store RSP Data To MEM
  lui a0,SP_MEM_BASE ; A0 = SP Memory Base Offset (DMEM)
  la a1,VDQUAD ; A1 = Quad Data Offset
  lw t0,0(a0)  ; T0 = Quad Data
  sw t0,0(a1)  ; Store Quad Data To MEM
  lw t0,4(a0)  ; T0 = Quad Data
  sw t0,4(a1)  ; Store Quad Data To MEM
  lw t0,8(a0)  ; T0 = Quad Data
  sw t0,8(a1)  ; Store Quad Data To MEM
  lw t0,12(a0) ; T0 = Quad Data
  sw t0,12(a1) ; Store Quad Data To MEM

  la a1,VAQUAD ; A1 = Quad Data Offset
  lw t0,16(a0) ; T0 = Quad Data
  sw t0,0(a1)  ; Store Quad Data To MEM
  lw t0,20(a0) ; T0 = Quad Data
  sw t0,4(a1)  ; Store Quad Data To MEM
  lw t0,24(a0) ; T0 = Quad Data
  sw t0,8(a1)  ; Store Quad Data To MEM
  lw t0,28(a0) ; T0 = Quad Data
  sw t0,12(a1) ; Store Quad Data To MEM

  la a1,VCOVCCWORD ; A1 = Word Data Offset
  lw t0,32(a0) ; T0 = Word Data
  sw t0,0(a1)  ; Store Word Data To MEM

  la a1,VCEBYTE ; A1 = Byte Data Offset
  lb t0,36(a0) ; T0 = Byte Data
  sb t0,0(a1)  ; Store Byte Data To MEM

  PrintString $A010,328,360,FontBlack,DOLLAR,0    ; Print Text String To VRAM Using Font At X,Y Position
  PrintValue  $A010,336,360,FontBlack,VAQUAD,1    ; Print HEX Chars To VRAM Using Font At X,Y Position
  PrintString $A010,376,360,FontBlack,DOLLAR,0    ; Print Text String To VRAM Using Font At X,Y Position
  PrintValue  $A010,384,360,FontBlack,VAQUAD+2,1  ; Print HEX Chars To VRAM Using Font At X,Y Position
  PrintString $A010,424,360,FontBlack,DOLLAR,0    ; Print Text String To VRAM Using Font At X,Y Position
  PrintValue  $A010,432,360,FontBlack,VAQUAD+4,1  ; Print HEX Chars To VRAM Using Font At X,Y Position
  PrintString $A010,472,360,FontBlack,DOLLAR,0    ; Print Text String To VRAM Using Font At X,Y Position
  PrintValue  $A010,480,360,FontBlack,VAQUAD+6,1  ; Print HEX Chars To VRAM Using Font At X,Y Position
  PrintString $A010,328,368,FontBlack,DOLLAR,0    ; Print Text String To VRAM Using Font At X,Y Position
  PrintValue  $A010,336,368,FontBlack,VAQUAD+8,1  ; Print HEX Chars To VRAM Using Font At X,Y Position
  PrintString $A010,376,368,FontBlack,DOLLAR,0    ; Print Text String To VRAM Using Font At X,Y Position
  PrintValue  $A010,384,368,FontBlack,VAQUAD+10,1 ; Print HEX Chars To VRAM Using Font At X,Y Position
  PrintString $A010,424,368,FontBlack,DOLLAR,0    ; Print Text String To VRAM Using Font At X,Y Position
  PrintValue  $A010,432,368,FontBlack,VAQUAD+12,1 ; Print HEX Chars To VRAM Using Font At X,Y Position
  PrintString $A010,472,368,FontBlack,DOLLAR,0    ; Print Text String To VRAM Using Font At X,Y Position
  PrintValue  $A010,480,368,FontBlack,VAQUAD+14,1 ; Print HEX Chars To VRAM Using Font At X,Y Position

  PrintString $A010,328,384,FontBlack,DOLLAR,0    ; Print Text String To VRAM Using Font At X,Y Position
  PrintValue  $A010,336,384,FontBlack,VDQUAD,1    ; Print HEX Chars To VRAM Using Font At X,Y Position
  PrintString $A010,376,384,FontBlack,DOLLAR,0    ; Print Text String To VRAM Using Font At X,Y Position
  PrintValue  $A010,384,384,FontBlack,VDQUAD+2,1  ; Print HEX Chars To VRAM Using Font At X,Y Position
  PrintString $A010,424,384,FontBlack,DOLLAR,0    ; Print Text String To VRAM Using Font At X,Y Position
  PrintValue  $A010,432,384,FontBlack,VDQUAD+4,1  ; Print HEX Chars To VRAM Using Font At X,Y Position
  PrintString $A010,472,384,FontBlack,DOLLAR,0    ; Print Text String To VRAM Using Font At X,Y Position
  PrintValue  $A010,480,384,FontBlack,VDQUAD+6,1  ; Print HEX Chars To VRAM Using Font At X,Y Position
  PrintString $A010,328,392,FontBlack,DOLLAR,0    ; Print Text String To VRAM Using Font At X,Y Position
  PrintValue  $A010,336,392,FontBlack,VDQUAD+8,1  ; Print HEX Chars To VRAM Using Font At X,Y Position
  PrintString $A010,376,392,FontBlack,DOLLAR,0    ; Print Text String To VRAM Using Font At X,Y Position
  PrintValue  $A010,384,392,FontBlack,VDQUAD+10,1 ; Print HEX Chars To VRAM Using Font At X,Y Position
  PrintString $A010,424,392,FontBlack,DOLLAR,0    ; Print Text String To VRAM Using Font At X,Y Position
  PrintValue  $A010,432,392,FontBlack,VDQUAD+12,1 ; Print HEX Chars To VRAM Using Font At X,Y Position
  PrintString $A010,472,392,FontBlack,DOLLAR,0    ; Print Text String To VRAM Using Font At X,Y Position
  PrintValue  $A010,480,392,FontBlack,VDQUAD+14,1 ; Print HEX Chars To VRAM Using Font At X,Y Position

  PrintString $A010,528,360,FontBlack,VCOHEX,5       ; Print Text String To VRAM Using Font At X,Y Position
  PrintValue  $A010,576,360,FontBlack,VCOVCCWORD,1   ; Print HEX Chars To VRAM Using Font At X,Y Position
  PrintString $A010,528,368,FontBlack,VCCHEX,5       ; Print Text String To VRAM Using Font At X,Y Position
  PrintValue  $A010,576,368,FontBlack,VCOVCCWORD+2,1 ; Print HEX Chars To VRAM Using Font At X,Y Position
  PrintString $A010,528,376,FontBlack,VCEHEX,5       ; Print Text String To VRAM Using Font At X,Y Position
  PrintValue  $A010,576,376,FontBlack,VCEBYTE,0      ; Print HEX Chars To VRAM Using Font At X,Y Position

  la a0,VDQUAD        ; A0 = Quad Data Offset
  ld t0,0(a0)         ; T0 = Quad Data
  la a0,VNANDVDCHECKD ; A0 = Quad Check Data Offset
  ld t1,0(a0)         ; T1 = Quad Check Data
  bne t0,t1,VNANDFAILD ; Compare Result Equality With Check Data
  nop ; Delay Slot
  la a0,VDQUAD        ; A0 = Quad Data Offset
  ld t0,8(a0)         ; T0 = Quad Data
  la a0,VNANDVDCHECKD ; A0 = Quad Check Data Offset
  ld t1,8(a0)         ; T1 = Quad Check Data
  bne t0,t1,VNANDFAILD ; Compare Result Equality With Check Data
  nop ; Delay Slot

  la a0,VAQUAD        ; A0 = Quad Data Offset
  ld t0,0(a0)         ; T0 = Quad Data
  la a0,VNANDVACHECKD ; A0 = Quad Check Data Offset
  ld t1,0(a0)         ; T1 = Quad Check Data
  bne t0,t1,VNANDFAILD ; Compare Result Equality With Check Data
  nop ; Delay Slot
  la a0,VAQUAD        ; A0 = Quad Data Offset
  ld t0,8(a0)         ; T0 = Quad Data
  la a0,VNANDVACHECKD ; A0 = Quad Check Data Offset
  ld t1,8(a0)         ; T1 = Quad Check Data
  bne t0,t1,VNANDFAILD ; Compare Result Equality With Check Data
  nop ; Delay Slot

  la a0,VCOVCCWORD        ; A0 = Word Data Offset
  lw t0,0(a0)             ; T0 = Word Data
  la a0,VNANDVCOVCCCHECKD ; A0 = Word Check Data Offset
  lw t1,0(a0)             ; T1 = Word Check Data
  bne t0,t1,VNANDFAILD ; Compare Result Equality With Check Data

  la a0,VCEBYTE        ; A0 = Byte Data Offset
  lb t0,0(a0)          ; T0 = Byte Data
  la a0,VNANDVCECHECKD ; A0 = Byte Check Data Offset
  lb t1,0(a0)          ; T1 = Byte Check Data
  bne t0,t1,VNANDFAILD ; Compare Result Equality With Check Data

  PrintString $A010,528,392,FontGreen,PASS,3 ; Print Text String To VRAM Using Font At X,Y Position
  j VNANDENDD
  nop ; Delay Slot
  VNANDFAILD:
  PrintString $A010,528,392,FontRed,FAIL,3 ; Print Text String To VRAM Using Font At X,Y Position
  VNANDENDD:

  PrintString $A010,0,400,FontBlack,PAGEBREAK,79 ; Print Text String To VRAM Using Font At X,Y Position


Loop:
  WaitScanline $1E0 ; Wait For Scanline To Reach Vertical Blank
  WaitScanline $1E2

  li t0,$00000800 ; Even Field
  sw t0,VI_Y_SCALE(a0)

  WaitScanline $1E0 ; Wait For Scanline To Reach Vertical Blank
  WaitScanline $1E2

  li t0,$02000800 ; Odd Field
  sw t0,VI_Y_SCALE(a0)

  j Loop
  nop ; Delay Slot

VANDTEXT:  db "VAND"
VNANDTEXT: db "VNAND"

VAVDHEX: db "VA/VD (Hex)"
VSVTHEX: db "VS/VT (Hex)"
TEST: db "Test Result"
FAIL: db "FAIL"
PASS: db "PASS"

DOLLAR: db "$"

VCOHEX: db "VCO: $"
VCCHEX: db "VCC: $"
VCEHEX: db "VCE: $"

PAGEBREAK: db "--------------------------------------------------------------------------------"

  align 8 ; Align 64-Bit
VALUEQUADA: dh $0000, $0000, $0000, $0000, $0000, $0000, $0000, $0000
VALUEQUADAEND:

VALUEQUADB: dh $0011, $2233, $4455, $6677, $8899, $AABB, $CCDD, $EEFF
VALUEQUADBEND:

VALUEQUADC: dh $FFEE, $DDCC, $BBAA, $9988, $7766, $5544, $3322, $1100
VALUEQUADCEND:

VANDVDCHECKA: dh $0000, $0000, $0000, $0000, $0000, $0000, $0000, $0000
VANDVDCHECKB: dh $0011, $2233, $4455, $6677, $8899, $AABB, $CCDD, $EEFF
VANDVDCHECKC: dh $0000, $0000, $0000, $0000, $0000, $0000, $0000, $0000
VANDVDCHECKD: dh $FFEE, $DDCC, $BBAA, $9988, $7766, $5544, $3322, $1100

VNANDVDCHECKA: dh $FFFF, $FFFF, $FFFF, $FFFF, $FFFF, $FFFF, $FFFF, $FFFF
VNANDVDCHECKB: dh $FFEE, $DDCC, $BBAA, $9988, $7766, $5544, $3322, $1100
VNANDVDCHECKC: dh $FFFF, $FFFF, $FFFF, $FFFF, $FFFF, $FFFF, $FFFF, $FFFF
VNANDVDCHECKD: dh $0011, $2233, $4455, $6677, $8899, $AABB, $CCDD, $EEFF

VANDVACHECKA: dh $0000, $0000, $0000, $0000, $0000, $0000, $0000, $0000
VANDVACHECKB: dh $0011, $2233, $4455, $6677, $8899, $AABB, $CCDD, $EEFF
VANDVACHECKC: dh $0000, $0000, $0000, $0000, $0000, $0000, $0000, $0000
VANDVACHECKD: dh $FFEE, $DDCC, $BBAA, $9988, $7766, $5544, $3322, $1100

VNANDVACHECKA: dh $FFFF, $FFFF, $FFFF, $FFFF, $FFFF, $FFFF, $FFFF, $FFFF
VNANDVACHECKB: dh $FFEE, $DDCC, $BBAA, $9988, $7766, $5544, $3322, $1100
VNANDVACHECKC: dh $FFFF, $FFFF, $FFFF, $FFFF, $FFFF, $FFFF, $FFFF, $FFFF
VNANDVACHECKD: dh $0011, $2233, $4455, $6677, $8899, $AABB, $CCDD, $EEFF

VAQUAD: dh $0000, $0000, $0000, $0000, $0000, $0000, $0000, $0000
VDQUAD: dh $0000, $0000, $0000, $0000, $0000, $0000, $0000, $0000

VANDVCOVCCCHECKA: dh $0000, $0000
VANDVCOVCCCHECKB: dh $0000, $0000
VANDVCOVCCCHECKC: dh $0000, $0000
VANDVCOVCCCHECKD: dh $0000, $0000

VNANDVCOVCCCHECKA: dh $0000, $0000
VNANDVCOVCCCHECKB: dh $0000, $0000
VNANDVCOVCCCHECKC: dh $0000, $0000
VNANDVCOVCCCHECKD: dh $0000, $0000

VCOVCCWORD: dh $0000, $0000

VANDVCECHECKA: db $00
VANDVCECHECKB: db $00
VANDVCECHECKC: db $00
VANDVCECHECKD: db $00

VNANDVCECHECKA: db $00
VNANDVCECHECKB: db $00
VNANDVCECHECKC: db $00
VNANDVCECHECKD: db $00

VCEBYTE: db $00

  align 8 ; Align 64-Bit
RSPVANDCode:
  obj $0000 ; Set Base Of RSP Code Object To Zero
  lqv v00,(e0),$00,(0) ; V0 = 128-Bit DMEM $000(R0), Load Quad To Vector: LQV VT[ELEMENT],$OFFSET(BASE)
  lqv v01,(e0),$01,(0) ; V1 = 128-Bit DMEM $010(R0), Load Quad To Vector: LQV VT[ELEMENT],$OFFSET(BASE)
  vand v00,v00,v01,(e0) ; V0 = V0 & V1[0], Vector Logical AND Short Elements: VAND VD,VS,VT[ELEMENT]
  sqv v00,(e0),$00,(0)  ; 128-Bit DMEM $000(R0) = V0, Store Vector To Quad: SQV VT[ELEMENT],$OFFSET(BASE)
  vsar v00,v00,v00,(e10) ; V0 = Vector Accumulator, Vector Accumulator Read: VSAR VD,VS,VT[ELEMENT]
  sqv v00,(e0),$01,(0)   ; 128-Bit DMEM $010(R0) = V0, Store Vector To Quad: SQV VT[ELEMENT],$OFFSET(BASE)
  cfc2 t0,vco   ; T0 = RSP CP2 Control Register VCO: VCO (Vector Carry Out)
  sh t0,$20(r0) ; 16-Bit DMEM $020(R0) = T0
  cfc2 t0,vcc   ; T0 = RSP CP2 Control Register VCC: VCC (Vector Compare Code)
  sh t0,$22(r0) ; 16-Bit DMEM $022(R0) = T0
  cfc2 t0,vce   ; T0 = RSP CP2 Control Register VCE: VCE (Vector Compare Extension)
  sb t0,$24(r0) ;  8-Bit DMEM $024(R0) = T0
  break $0000 ; Set SP Status Halt, Broke & Check For Interrupt, Set SP Program Counter To $0000
  align 8 ; Align 64-Bit
  objend ; Set End Of RSP Code Object
RSPVANDCodeEND:

  align 8 ; Align 64-Bit
RSPVNANDCode:
  obj $0000 ; Set Base Of RSP Code Object To Zero
  lqv v00,(e0),$00,(0) ; V0 = 128-Bit DMEM $000(R0), Load Quad To Vector: LQV VT[ELEMENT],$OFFSET(BASE)
  lqv v01,(e0),$01,(0) ; V1 = 128-Bit DMEM $010(R0), Load Quad To Vector: LQV VT[ELEMENT],$OFFSET(BASE)
  vnand v00,v00,v01,(e0) ; V0 = !(V0 & V1[0]), Vector Logical NOT AND Short Elements: VNAND VD,VS,VT[ELEMENT]
  sqv v00,(e0),$00,(0)   ; 128-Bit DMEM $000(R0) = V0, Store Vector To Quad: SQV VT[ELEMENT],$OFFSET(BASE)
  vsar v00,v00,v00,(e10) ; V0 = Vector Accumulator, Vector Accumulator Read: VSAR VD,VS,VT[ELEMENT]
  sqv v00,(e0),$01,(0)   ; 128-Bit DMEM $010(R0) = V0, Store Vector To Quad: SQV VT[ELEMENT],$OFFSET(BASE)
  cfc2 t0,vco   ; T0 = RSP CP2 Control Register VCO: VCO (Vector Carry Out)
  sh t0,$20(r0) ; 16-Bit DMEM $020(R0) = T0
  cfc2 t0,vcc   ; T0 = RSP CP2 Control Register VCC: VCC (Vector Compare Code)
  sh t0,$22(r0) ; 16-Bit DMEM $022(R0) = T0
  cfc2 t0,vce   ; T0 = RSP CP2 Control Register VCE: VCE (Vector Compare Extension)
  sb t0,$24(r0) ;  8-Bit DMEM $024(R0) = T0
  break $0000 ; Set SP Status Halt, Broke & Check For Interrupt, Set SP Program Counter To $0000
  align 8 ; Align 64-Bit
  objend ; Set End Of RSP Code Object
RSPVNANDCodeEND:

FontBlack: incbin FontBlack8x8.bin
FontGreen: incbin FontGreen8x8.bin
FontRed: incbin FontRed8x8.bin