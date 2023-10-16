; defines
	.enum $0000

; Disk definitions (taken from SMB2J's disassembly)
	DiskInfoBlock     = 1
	FileAmountBlock   = 2
	FileHeaderBlock   = 3
	FileDataBlock     = 4
	PRG = 0
	CHR = 1
	VRAM = 2
	FILE_COUNT = 4 ; 1 more than actual file count to distract the FDS before NMI kicks in

; FDS hardware defines
	FDS_IRQ_TIMER_LOW = $4020
	FDS_IRQ_TIMER_HI  = $4021
	FDS_IRQ_TIMER_CTRL = $4022
	FDS_IO_ENABLE = $4023
	FDS_WRITE_DATA = $4024
	FDS_CTRL = $4025
	FDS_EXT = $4026 ; connector on back of RAM adaptor
	FDS_STATUS = $4030
	FDS_READ_DATA = $4031
	FDS_DRIVE_STATUS = $4032
	FDS_BATTERY_EXT = $4033 ; bit 7 = battery, rest are shared with FDS_EXT

; FDS BIOS defines
; game vectors
	NMI_1 = $dff6
	NMI_2 = $dff8
	NMI_3 = $dffa ; default
	RESET = $dffc
	IRQ = $dffe

; disk access
	LoadFiles = $e1f8
	AppendFile = $e237
	WriteFile = $e239
	CheckFileCount = $e2b7
	AdjustFileCount = $e2bb
	SetFileCount1 = $e301
	SetFileCount = $e305
	GetDiskInfo = $e32a

; low-level disk access
	CheckDiskHeader = $e445
	GetNumFiles = $e484
	SetNumFiles = $e492
	FileMatchTest = $e4a0
	SkipFiles = $e4da

; delays
	Delay132 = $e149 ; 132 clock cycle delay
	Delayms = $e153 ; delay = 1790*Y+5 cycles

; sprite/bg rendering
	DisPFObj = $e161
	EnPFObj = $e16b
	DisObj = $e171
	EnObj = $e178
	DisPF = $e17e
	EnPF = $e185

	VINTWait = $e1b2 ; wait for NMI

	VRAMStructWrite = $e7bb ; custom VRAM buffer transfer

	FetchDirectPointer = $e844

; VRAM buffer routines
	WriteVRAMBuffer = $e86a
	ReadVRAMBuffer = $e8b3
	PrepareVRAMString = $e8d2
	PrepareVRAMStrings = $e8e1
	GetVRAMBufferByte = $e94f

; pixel <-> nametable address conversion (single screen)
	Pixel2NamConv = $e97d
	Nam2PixelConv = $e997

	Random = $e9b1

	SpriteDMA = $e9c8

	CounterLogic = $e9d3 ; decrements several decimal counters in zeropage

; controller polling
	ReadPads = $e9eb
	ReadDownPads = $ea1a
	ReadOrDownPads = $ea1f
	ReadDownVerifyPads = $ea36
	ReadOrDownVerifyPads = $ea4c
	ReadDownExpPads = $ea68

; memory filling
	VRAMFill = $ea84
	MemFill = $ead2

	SetScroll = $eaea

	JumpEngine = $eafd

	ReadKeyboard = $eb13

	LoadTileset = $ebaf

	UploadObject = $ec22 ; apparently adds an object to OAM
	
	.ende
