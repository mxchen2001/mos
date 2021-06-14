# -*- makefile -*-

build: build/kernel.flp

run: qemu

# run if source file changed
build/bin/x86_64/bootloader.bin: src/x86_64/bootloader.S src/x86_64/lib/*.S
	mkdir -p build/bin/x86_64 && \
	nasm -fbin $< -o $@

build/bin/x86_64/main.o: src/x86_64/main.S src/x86_64/lib/*.S
	mkdir -p build/bin/x86_64 && \
	nasm -f elf64 $< -o $@

build/bin/kernel/kernel.o: src/kernel/kernel.c
	mkdir -p build/bin/kernel && \
	x86_64-elf-gcc -c -I src/intf -Ttext 0x8000 -ffreestanding -mno-red-zone -m64 -c $< -o $@

build/bin/kernel.bin: build/bin/x86_64/main.o build/bin/kernel/kernel.o 
	x86_64-elf-ld -n -o $@ -T link.ld $^

build/kernel.flp: build/bin/x86_64/bootloader.bin build/bin/kernel.bin
	cat $^ > $@

qemu:
	qemu-system-x86_64 build/kernel.flp

clean:
	rm  -rf build





# default:
# 	nasm src/bootloader.S -fbin -o bootloader.bin
# 	nasm src/main.S -f elf64 -o main.o
# 	x86_64-elf-gcc -Ttext 0x8000 -ffreestanding -mno-red-zone -m64 -c src/kernel.c -o kernel.o
# 	x86_64-elf-ld -n -o kernel.bin -T link.ld main.o kernel.o
# 	cat bootloader.bin kernel.bin > kernel.flp

# qemu:
# 	qemu-system-x86_64 kernel.flp

# clean:
# 	rm  *.bin *.o *.flp