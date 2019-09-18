export KERNEL_MODULE  := harfbuzz

obj-m                 := ${KERNEL_MODULE}.o
${KERNEL_MODULE}-objs := module.o main.o

all: main.o
	make -C /lib/modules/$(shell uname -r)/build M=$(PWD) modules

clean:
	make -C /lib/modules/$(shell uname -r)/build M=$(PWD) clean

insmod:
	sudo insmod "${KERNEL_MODULE}.ko"; sleep 1; dmesg | tail

rmmod:
	sudo modprobe -r "${KERNEL_MODULE}"; sleep 1; sudo rmmod "${KERNEL_MODULE}"; dmesg | tail

test: ${KERNEL_MODULE}.ko
	sudo insmod "${KERNEL_MODULE}.ko"; sudo rmmod  "${KERNEL_MODULE}"; dmesg | tail -3

main.o: main.cc harfbuzz
	clang main.cc -c -DHB_USE_INTERNAL_QSORT -DHB_TINY -fno-exceptions -fno-rtti -fno-stack-protector -nostdlib

#TODO: Merge some of the flags below, make it work on armv7 kernels, use GCC instead clang
#clang ../harfbuzz/src/harfbuzz.cc -c -fno-exceptions -fno-rtti -fno-stack-protector \
#  -nostdlib -nostdinc -I../libc/include \
#  -DHB_USE_INTERNAL_QSORT -DHB_TINY \
#  -Xclang -target-feature -Xclang "-mmx,-sse,-sse2,-sse3,-ssse3,-sse4.1,-sse4.2,-3dnow,-3dnowa,-avx,-avx2,+soft-float" \
#  -msoft-float ../libc/zephyr-string.c a.c \
#  -I../harfbuzz/src

harfbuzz:
	[ -d harfbuzz/src ] || git clone --depth=1 https://github.com/harfbuzz/harfbuzz
	(cd harfbuzz; git pull)
