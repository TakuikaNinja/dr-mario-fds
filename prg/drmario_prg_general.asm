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

;;
;; CHR-RAM routines
;;
;; to be implemented
;;
;;             

changeCHRBank0:
        rts                      

changeCHRBank1:
        rts                      
                    
