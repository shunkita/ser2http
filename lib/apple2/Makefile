# CC65/CL65 Toolchain settings
CC = cc65
AS = ca65
AR = ar65
LIB_NAME = ser2http.lib
CFLAGS = -I ./include 
AFLAGS = -I ./include

# Source files (C and Assembly)
ASM_SOURCES = a2f_identify.s findssc.s ser_init.s ser_settings.s \
              debug.s gsssc.s ser_data.s ser_recv.s ssc.s 
C_SOURCES = httpclient.c

# Object files
ASM_OBJECTS = $(ASM_SOURCES:.s=.o)
C_ASM_FILES = $(C_SOURCES:.c=.s)
C_OBJECTS = $(C_ASM_FILES:.s=.o)
OBJECTS = $(ASM_OBJECTS) $(C_OBJECTS)

#Avoid implicit rules
.SUFFIXES:

# Default target
all: $(LIB_NAME)

# Compile assembly files into object files
%.o: %.s
	$(AS) $(AFLAGS) -o $@ $<

# Compile C files into assembly files
%.s: %.c
	$(CC) $(CFLAGS)   -o $@ $<

# Create the static library
$(LIB_NAME): $(OBJECTS)
	rm -f $(LIB_NAME)
	$(AR) r $(LIB_NAME) $(OBJECTS)

# Clean up build artifacts
clean:
	rm -f $(ASM_OBJECTS) $(C_OBJECTS) $(C_ASM_FILES) $(LIB_NAME)

# Phony targets
.PHONY: all clean
