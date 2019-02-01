ca65 --cpu 65816 -s -o obj/main.o main.asm
# ca65 --cpu 65816 -s -o obj/init_reg.o init_reg.asm
ld65 -C memory.cfg -o rpg.smc obj/main.o
