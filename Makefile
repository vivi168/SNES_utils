MMAP=memory.cfg
EXEC=demo.smc

AS=ca65
AS_FLAGS=--cpu 65816 -s
LD=ld65
LD_FLAGS=-C $(MMAP)

OBJDIR=obj
SRC=$(wildcard *.asm)
OBJ=$(patsubst %.asm, $(OBJDIR)/%.o, $(SRC))

ASSETS_DIR=assets
ASSETS_SRC=$(wildcard $(ASSETS_DIR)/*.png)
ASSETS_BIN=$(patsubst $(ASSETS_DIR)/%.png, $(ASSETS_DIR)/%.bin, $(ASSETS_SRC))

TMAP_SRC=$(wildcard $(ASSETS_DIR)/*.tmx)
TMAP_BIN=$(patsubst $(ASSETS_DIR)/%.tmx, $(ASSETS_DIR)/%.map, $(TMAP_SRC))

all: dir $(ASSETS_BIN) $(TMAP_BIN) $(EXEC)

$(EXEC): $(OBJ)
	$(LD) $(LD_FLAGS) -o $@ $^

$(OBJDIR)/%.o: %.asm
	$(AS) $(AS_FLAGS) -o $@ $<

.PHONY: clean
clean:
	@rm -f $(OBJDIR)/*.o
	@rm -f $(ASSETS_DIR)/*.bin
	@rm -f $(ASSETS_DIR)/*.map
	@rm -f $(EXEC)

dir:
	@mkdir -p $(OBJDIR)

$(ASSETS_DIR)/%.bin: $(ASSETS_DIR)/%.png
	ruby png2snes.rb -f $<

$(ASSETS_DIR)/%.map: $(ASSETS_DIR)/%.tmx
	ruby tmx2snes.rb -s 8 -f $<
