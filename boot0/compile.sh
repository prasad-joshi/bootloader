#!/bin/bash

nasm -f bin -o simple.bin simple.asm

dd if=mikeos.flp of=simple.flp

dd status=noxfer conv=notrunc if=simple.bin of=simple.flp
