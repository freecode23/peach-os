# 0. 
FILES = kernelstuff

# 1. all rule, will run if just type 'make' with no arguments
# depends on bootsuff and the files listed in Files which is kernelstuff
# if bootstuff anr kernelstuff are not up to date, it will run those command/rule
# to update them
# remove os.bin everytime we make
all: bootstuff $(FILES)
	rm -rf .bin/os.bin
	dd if=./bin/boot.bin >> ./bin/os.bin

# 2. "./bin/boot.bin" RULE:
# Assemble boot.asm into a binary file
# depends on boot.asm
bootstuff: ./src/boot/boot.asm
	nasm -f bin ./src/boot/boot.asm -o ./bin/boot.bin

# 3. "./build/kernel.asm.o" RULE: 
# Assemble kernel.asm into an object file
# enable debugging with -g
kernelstuff: ./src/kernel.asm
	nasm -f elf -g ./src/kernel.asm -o ./build/kernel.asm.o

clean:
	rm -rf .bin/boot.bin