@echo off
asm68k /o op+ /o os+ /o ow+ /o oz+ /o oaq+ /o osq+ /o omq+ /p /o ae- sonic1.asm, s1built.bin, sonic1.sym, sonic1.lst
convsym sonic1.sym sonic1.symcmp
copy /B s1built.bin+sonic1.symcmp s1built.bin /Y
del sonic1.symcmp
pause