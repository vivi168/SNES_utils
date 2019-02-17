MMAP=memory.cfg
EXEC=demo.smc

AS=ca65
AS_FLAGS=--cpu 65816 -s
LD=ld65
LD_FLAGS=-C $(MMAP)

OBJDIR=obj
SRC = $(wildcard *.asm)
OBJS = $(patsubst %.asm, $(OBJDIR)/%.o, $(SRC))

all: dir $(EXEC)

$(EXEC): $(OBJS)
	$(LD) $(LD_FLAGS) -o $@ $^

$(OBJDIR)/%.o: %.asm
	$(AS) $(AS_FLAGS) -o $@ $<

.PHONY: clean
clean:
	@rm -f $(OBJDIR)/*.o
	@rm -f $(EXEC)

dir:
	@mkdir -p $(OBJDIR)
