.org $0000

;Build config
include build_config.asm

;Defines and macros
include defines/drmario_ram_zp.asm
include defines/drmario_ram.asm
include defines/drmario_registers.asm
include defines/drmario_constants.asm
include defines/fds_defs.asm
include defines/drmario_macros.asm

;fds info block
include header/drmario_header_fds.asm

; CHR
	.db FileHeaderBlock
	.db $00, $00
	.db "GAMECHAR"
	.dw $0000
	.dw chr_end - chr_start
	.db CHR
	
	.db FileDataBlock
	chr_start:
	incbin bin/dr_mario_chr_001.chr ;just get the title screen tiles for now
	chr_end:

; PRG
	.db FileHeaderBlock
	.db $01, $01
	.db "GAMEPRGM"
	.dw $6000
	.dw prg_length
	.db PRG
	
	.db FileDataBlock
	oldaddr = $
	.base $6000
	prg_start:
	;PRG chunk 1
	include prg/drmario_prg_game_init.asm
	include prg/drmario_prg_level_init.asm
	include prg/drmario_prg_visual_nametable.asm
	include prg/drmario_prg_visual_sprites.asm
	include prg/drmario_prg_game_logic.asm

	;Data chunk 1
	include data/drmario_data_game.asm
	include data/drmario_data_metasprites.asm

	;PRG chunk 2
	include prg/drmario_prg_level_end.asm
	include prg/drmario_prg_general.asm

	;Data chunk 2
	include data/drmario_data_nametables.asm
	include data/drmario_data_demo_field_pills.asm
	align 256                                       ;Must be aligned on a 256-byte boundary (vanilla rom = $D000)
	include data/drmario_data_demo_inputs.asm

	;Audio engine - general & sfx
	align 256                                       ;Must be aligned on a 256-byte boundary (vanilla rom = $D200)
	include prg/drmario_prg_audio_general_a.asm
	align 256                                       ;Must be aligned on a 256-byte boundary (vanilla rom = $D300)
	include data/drmario_data_sfx.asm               
	include prg/drmario_prg_audio_general_b.asm
	include prg/drmario_prg_audio_sfx.asm

	;Audio engine - music
	include prg/drmario_prg_audio_music.asm
	include data/drmario_data_music.asm
	if ver_EU
		include prg/drmario_prg_reset.asm                  
	endif 
	
	;End of rom
	if !ver_EU
		include prg/drmario_prg_reset.asm
	else 
		include prg/routines/drmario_prg_audio_update.asm                  
	endif 
	include prg/drmario_prg_audio_linker.asm
	
	if $<$C000
		org $C000                                   ;Samples cannot be located before $C000
	endif
	align 64                                        ;Must be aligned on a 64-byte boundary (vanilla rom = $FD00)
	include samples/drmario_samples_dmc.asm

	;Interrupt vectors
	org NMI_3                                       ;Must be at this specific address             
	word bypass, reset, irq
	
	prg_end:
	prg_length = prg_end - prg_start
	.base oldaddr + prg_length
	
; kyodaku file
	.db FileHeaderBlock
	.db $02, $02
	.db "-BYPASS-"
	.dw PPUCTRL
	.dw $0001
	.db PRG

	.db FileDataBlock
	.db $90 ; enable NMI byte loaded into PPU control register - bypasses "KYODAKU-" file check
	
	.pad 65500

