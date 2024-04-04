# Dr. Mario FDS

https://github.com/TakuikaNinja/dr-mario-fds

This is a port of Dr. Mario for the Famicom Disk System.
It abuses the fact that most of the variables and routines originate from the [FDS BIOS](https://www.nesdev.org/wiki/FDS_BIOS).
See [Tetris](https://github.com/TakuikaNinja/TetrisFDS) for another game ported in this manner.

It builds `drmario.fds` using ASM6f (https://github.com/freem/asm6f).
The differences from the original game are as follows:
- Boots and runs on FDS, bypassing the BIOS' license message check.
- Most of the generic subroutines have been replaced with calls to the BIOS routines.
   - This fixes glitches caused by/related to input polling. (big combo glitch, DMC input corruption)
- Everything except the title screen has incorrect CHR banks. (no easy way to include all the unique banks)
   - Tile animations using CHR bankswitching have been disabled as a result.
- The anti-piracy/anti-tamper check on the title screen has been disabled.
   - This was unfortunately necessary as code after the title screen data is also checked.

Possibilities opened up by this port (but no immediate plans to implement them):
- Hi-score saving using disk I/O.
- Restoration of the demo recording mode by writing $FF to RAM address $0741 (flag_demo).
- Extra features/bugfixes due to some PRG-RAM space being freed up by the BIOS routines.

This port is based on: https://github.com/Nostaljipi/dr-mario-disassembly

## Original README (continued)

Thanks to Sour, author of the excellent NES emulator Mesen (https://www.mesen.ca/), which debug options were vital to this project.

Also, thanks to all contributors of the Dr.Mario articles at Data Crystal (https://datacrystal.romhacking.net/wiki/Dr._Mario) and The Cutting Room Floor (https://tcrf.net/Dr._Mario_(NES)).
