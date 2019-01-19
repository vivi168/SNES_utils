ca65 --cpu 65816 -s -o SpriteDemo.o SpriteDemo.s
ld65 -C MemoryMap.cfg -o FirstSprite.smc SpriteDemo.o
