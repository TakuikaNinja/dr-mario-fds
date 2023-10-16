;;
;; reset handler [$FF00]
;;
;; 
;; 

reset:
;		inc reset               ;Value at this address must be $80 or higher to reset the MMC properly (vanilla rom = $FF00)
;		lda #mmc_chr_4kb + mmc_prg_switch + mmc_mirroring_one_lower               
;		jsr basicMMCConfig      ;Perform a couple MMC operations  
;		lda #CHR_titleSprites
;		jsr changeCHRBank0
;		lda #CHR_titleTiles_frame0
;		jsr changeCHRBank1
;		lda #$00                ;We never change PRG, always set to the same 32 kb                
;		jsr changePRGBank
        jmp init              ;Finally, jump to init
        
; "NMI" routine which is entered to bypass the BIOS check
bypass:
		lda #$00										; disable NMIs since we don't need them anymore
		sta PPUCTRL
		
		lda #<nmi										; put real NMI handler in NMI vector 3
		sta NMI_3
		lda #>nmi
		sta NMI_3+1
		
		lda #$35										; tell the FDS that the BIOS "did its job"
		sta RST_FLAG
		lda #$ac
		sta RST_TYPE
;		sta RST_TYPE_MIRROR								; save reset type to mirror as it will be clobbered
		
		jmp ($fffc)										; jump to reset FDS
