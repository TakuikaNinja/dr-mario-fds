; Disk info + file amount blocks
	.db DiskInfoBlock
	.db "*NINTENDO-HVC*"
	.db 0												; manufacturer
	.db "DRM "											; game title + space for normal disk
	.db 0, 0, 0, 0, 0									; game version, side, disk, disk type, unknown
	.db FILE_COUNT										; boot file count
	.db $ff, $ff, $ff, $ff, $ff
	.db $02, $07, $27									; release date (Heisei year)
	.db $49, $61, 0, 0, 2, 0, 0, 0, 0, 0				; region stuff
	.db $34, $10, $16									; disk write date (Heisei year), use fork creation date
	.db 0, $80, 0, 0, 7, 0, 0, 0, 0						; unknown data, disk writer serial no., actual disk side, price

	.db FileAmountBlock
	.db FILE_COUNT

