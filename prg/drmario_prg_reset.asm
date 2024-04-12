;;
;; reset handler [$FF00]
;;
;; 
;; 

reset = init

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
