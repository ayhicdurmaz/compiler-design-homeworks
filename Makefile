# MiniGo Parser Makefile

CC = gcc
CFLAGS = -Wall -Wextra -std=c99 -g
LDFLAGS = -lm

# Target executable
TARGET = minigo_parser

# Source files
SOURCES = ast.c parser.tab.c lex.yy.c
HEADERS = ast.h parser.tab.h

# Generated files
GENERATED = parser.tab.c parser.tab.h lex.yy.c

# Default target
all: $(TARGET)

# Generate parser from Bison grammar
parser.tab.c parser.tab.h: parser.y
	bison -d parser.y

# Generate lexer from Flex specification
lex.yy.c: lexer.l parser.tab.h
	flex lexer.l

# Build the main executable
$(TARGET): $(SOURCES) $(HEADERS)
	$(CC) $(CFLAGS) -o $(TARGET) $(SOURCES) $(LDFLAGS)

# Test target - run parser on test file
test: $(TARGET)
	./$(TARGET) test1.mg

# Clean generated files
clean:
	rm -f $(TARGET) $(GENERATED)

# Install required tools (Ubuntu/Debian)
install-deps:
	sudo apt-get update
	sudo apt-get install flex bison build-essential

# Show help
help:
	@echo "MiniGo Parser Build System"
	@echo "========================="
	@echo "Available targets:"
	@echo "  all          - Build the parser (default)"
	@echo "  test         - Build and run parser on test1.mg"
	@echo "  clean        - Remove generated files"
	@echo "  install-deps - Install flex and bison (Ubuntu/Debian)"
	@echo "  help         - Show this help message"
	@echo ""
	@echo "Usage examples:"
	@echo "  make                    # Build the parser"
	@echo "  make test               # Test with test1.mg"
	@echo "  ./minigo_parser file.mg # Parse a specific file"

.PHONY: all test clean install-deps help
