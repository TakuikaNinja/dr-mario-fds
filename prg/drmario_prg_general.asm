;;
;; visualAudioUpdate_NMI [$B66E]
;;
;; Performs visual and audio update then waits for a NMI, then clear sprites memory. Effectively advances 1 frame.
;; This routine is called every frame when not changing screen
;;
visualAudioUpdate_NMI:                              
        lda flag_inLevel_NMI                        
        beq @audioUpdate_then_clearNMIFlag          ;If not in level, skip the level sprites update
        jsr updateSprites_lvl    
    @audioUpdate_then_clearNMIFlag:
    if !optimize
        jsr toAudioUpdate
    else 
        jsr audioUpdate
    endif         
        lda #$00                 
        sta nmiFlag              
    @NMI_then_clearSprites:  
        lda nmiFlag                                 ;Loop here until return from NMI           
        beq @NMI_then_clearSprites
        lda #$FF                                    ;This resets the sprite memory       
        ldx #>sprites                               
        ldy #>sprites                 
        jsr copy_valueA_fromX00_toY00_plusFF
        rts                      

;;
;; audioUpdate_then_NMI [$B68A]
;;
;; Performs audio update then waits for a NMI. Only called when changing screen (except pause).
;;
audioUpdate_then_NMI:    
    if !optimize
        jsr toAudioUpdate
    else 
        jsr audioUpdate
    endif                               
        lda #$00                 
        sta nmiFlag              
    @waitNMI:                
        lda nmiFlag              
        beq @waitNMI             
        rts                      

;;
;; audioUpdate_NMI_disableRendering [$B696]
;;
;; Performs audioUpdate_then_NMI then disables rendering
;;
audioUpdate_NMI_disableRendering:
        jsr audioUpdate_then_NMI 
        lda PPUMASK_RAM          
        and #~ppumask_enable_all    ;This disables rendering            
    _setPPUMASK:                     
        sta PPUMASK                 ;This sub routine part is used by the next routine as well
        sta PPUMASK_RAM          
        rts                      

;;
;; audioUpdate_NMI_enableRendering [$B6A3]
;;
;; Performs audioUpdate_then_NMI then enables rendering
;;
audioUpdate_NMI_enableRendering:
        jsr audioUpdate_then_NMI 
        jsr setPPUSCROLL_and_PPUCTRL
        lda PPUMASK_RAM          
        ora #ppumask_enable_all     ;This enables rendering
        bne _setPPUMASK          

;;
;; finishVblank_NMI_on [$B6AF]
;;
;; As its name suggests, finishes vblank then enables NMI
;;
finishVblank_NMI_on: 
        lda PPUSTATUS            
        and #ppustatus_vblank_in                           
        bne finishVblank_NMI_on         ;Loop this while in vblank
        lda PPUCTRL_RAM                 
        ora #ppuctrl_nmi_on             ;Then enable NMI                 
        bne _storeA_PPUCTRL      

;;
;; NMI_off [$B6BC]
;;
;; Simply deactivates NMI
;;
NMI_off:
        lda PPUCTRL_RAM          
        and #<~ppuctrl_nmi_on           ;Deactivates NMI
    _storeA_PPUCTRL:         
        sta PPUCTRL                     ;This sub routine part is used by the previous routine as well    
        sta PPUCTRL_RAM
        rts

;;
;; initPPU_addrA_hiByte [$B6C6]
;;
;; Simply sets the values to use to init PPU memory
;;
;; Input:
;;  A = high byte of PPU address to init
;; 
initPPU_addrA_hiByte:    
        ldx #$FF                        ;Value used to init PPU nametable                 
        ldy #$00                        ;Value used to init PPU attribute table
        jsr initPPU_addrA_dataX_then_attrY
        rts                      

;;
;; setPPUSCROLL_and_PPUCTRL [$B6CE]
;;
;; Sets the PPUSCROLL to coordinates 0,0 and updates PPUCTRL with RAM
;;
setPPUSCROLL_and_PPUCTRL = SetScroll

;;
;; copyBkgOrPalToPPU [$B6DC]
;;
;; Copies the nametable data for a bkg or palette from RAM to PPU
;;
;; Input:
;;  The address to the data for the bkg/pal must be right after the  "jsr copyBkgOrPalToPPU" used to get to this routine (this is because we use stack manipulations to access this data)
;;
copyBkgOrPalToPPU = VRAMStructWrite                    

;;
;; randomNumberGenerator [$B78B]
;;
;; Generates random number(s) into a given address
;; Always used with x=$17 and y=$02... fill 2 bytes, starting at memory $17 
;;
;; Inputs:
;;  X: The address at which to start generating random number(s)
;;  Y: The qty of numbers (and thus bytes)
;; 
;; Local variables:
randomNumberGenerator = Random                      

;;
;; render_sprites [$B7A2]
;;
;; Copies sprite data from RAM to PPUOAM
;;
render_sprites = SpriteDMA                      

;; controller
getInputs = ReadOrDownVerifyPads

;;
;; initPPU_addrA_dataX_then_attrY [$B860]
;;
;; Init PPU addresses (mainly nametables), with an optional different value for the pattern table
;;
;; Input:
;;  A = high byte of PPU address to init
;;  X = the value to copy in PPUDATA nametable
;;  Y = the value to copy in PPUDATA nametable attribute
;; 
initPPU_addrA_dataX_then_attrY = VRAMFill

;;
;; copy_valueA_fromX00_toY00_plusFF [$B8AE]
;;
;; Initializes values from a given address range with a specified value
;;
;; Inputs:
;;  A: The value to copy
;;  X: The starting high byte (start adress is $xx00)
;;  Y: The ending high byte (end address is $yyFF)
;;
copy_valueA_fromX00_toY00_plusFF = MemFill

;;
;; toAddressAtStackPointer_indexA [$B8C6]
;;
;; Jumps to the address stored at the last stack address (in other words, one jsr ago) plus an index specified in A
;; 
;; Input:
;;  A: the index to get to the address that contains the address we want to jump to
;;  Last stack address: base offset of the array of addresses that we can jump to
;;
toAddressAtStackPointer_indexA = JumpEngine

; disk access routine
loadCHRFromDisk:
		jsr FetchDirectPointer ; fetch load list from stack
		lda tmp1 ; check if this pointer was already loaded from
		cmp loadList+1
		bne +
		lda tmp0
		cmp loadList
		bne +
		rts ; exit if load list pointer matches
+
		lda tmp0 ; save load list pointer
		sta loadList
		lda tmp1
		sta loadList+1
        jsr initAPU_status ; reset APU
		
load:
		jsr audioUpdate_NMI_disableRendering
        jsr NMI_off
		jsr LoadFiles ; load CHR files
	.dw diskID
loadList:
	.dw $0000 ; dummy value which should be overwritten on the first load
		bne _error ; Check if there is an error
		rts ; exit if no error
_error:
		jsr printError      ;If so print the error code to screen
_sideError:
		lda FDS_DRIVE_STATUS
		and #$01
		beq _sideError     ;Wait until disk is ejected
_insert:
		lda FDS_DRIVE_STATUS
		and #$01
		bne _insert      ;Wait until disk is inserted
		beq load

; print the disk error code on screen
printError:
		pha ; save error code for later
		ldy #$10 ; high address
		lda #$00 ; low address = 0, normal 2bpp, write tiles, no fill
		ldx #16 ; number of tiles
		jsr LoadTileset ; load temporary BG tiles into $1000 for the error code
	.dw tempBGTiles
		ldy #$1F ; high address
		lda #$F0 ; low address = F, normal 2bpp, write tiles, no fill
		ldx #1 ; number of tiles
		jsr LoadTileset ; load temporary blank tile into $1FF0 to keep the nametable clean
	.dw tempBlankTile
		lda #>nametable0
        jsr initPPU_addrA_hiByte ; clear nametable
        lda #$21 ; display the error code (rendering is disabled so it's safe to do this right now)
        sta PPUADDR
        lda #$EF
        sta PPUADDR
        pla ; get error code
        jsr renderLevelNb_2digits ; write to PPUDATA
        jsr finishVblank_NMI_on
        jmp audioUpdate_NMI_enableRendering

; temporary BG tiles for displaying hexadecimal numbers (0~F)
tempBGTiles:
	incbin "bin/drmario_chr_05.chr", $0000, $100
; temporary blank tile to put at $1FF0 to keep the nametable clean
tempBlankTile:
	incbin "bin/drmario_chr_05.chr", $0FF0, $10

; this structure is checked when accessing the disk
diskID:
	.db 0												; manufacturer
	.db "VUS "											; game title + space for normal disk
	.db 1, 0, 0, 0, 0									; game version, side, disk, disk type, unknown

; these are the lists of files to load for each mode
levelLoadList:
	.db $C0, $C2, $FF

titleLoadList:
	.db $C2, $C3, $FF

optionsLoadList:
	.db $C5, $FF ; single pattern table shared by sprites & background

cutsceneLoadList:
	.db $C6, $C7, $FF

; faking CHR bankswitching using PPUCTRL pattern table access bits
changeCHRBank0:
		tay
		lda PPUCTRL_RAM
		and #%11110111
		ora ppuctrl_sprite_bits,y
		sta PPUCTRL_RAM
		rts

; background pattern table access never changes
changeCHRBank1:
		rts

; options screen (index 5) uses the same pattern table as the background
ppuctrl_sprite_bits:
	.db %00000000, %00000000, %00000000, %00000000
	.db %00000000, %00001000, %00000000, %00000000

