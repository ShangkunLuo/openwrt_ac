SOURCES=$(wildcard *.c)
OBJS=$(patsubst %.c,%.o,$(SOURCES))
EXEC=ac-discovery-server

CFLAGS += -DDEBUG

all: $(EXEC)

$(EXEC):$(OBJS)
	$(CC) $(CFLAGS) $(LDFLAGS) -o $@ $^

clean:
	-rm -f $(EXEC) *.elf *.gdb *.o
