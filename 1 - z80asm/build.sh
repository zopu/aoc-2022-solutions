z80asm -o build/puzzle1.bin puzzle1.asm
./bin2tap/bin2tap -b -o build/puzzle1.tap build/puzzle1.bin

z80asm -o build/puzzle1_2.bin puzzle1_2.asm
./bin2tap/bin2tap -b -o build/puzzle1_2.tap build/puzzle1_2.bin