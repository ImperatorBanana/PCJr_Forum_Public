TITLE Skeleton for building COM OR ROM Program

cart_rom_len EQU 2000h ; 8K

CODESEG SEGMENT
	assume CS:CODESEG, DS:CODESEG, SS:CODESEG
	
IFDEF ROM
	ORG 000h
HEADER: ; PC Jr Cartridge Header
	cartridgeid			dw		0AA55h
	cartridgelength		db		cart_rom_len/512	
	jmp					START_FUNCTION					;; ENTRY POINT
	headerend			db		00h
ENDIF

	ORG 100h
PROGRAM: ; Needed for COM to later terminate the program
START_FUNCTION PROC NEAR
	mov		al,'S' ; S for success!
	mov		ah,0Eh ; BIOS Print TTY Character
	int		10h ; BIOS Video Interrupt
IFDEF ROM
	INF_LOOP: jmp INF_LOOP
ELSE ;; COM
	ret ; Return to DOS
ENDIF
START_FUNCTION ENDP

ORG	cart_rom_len - 16; 14(name) + 2(chksum) ;; TODO - can the assembler calculate this
FOOTER: ; PCJr Cartridge Footer
	;;								"0123456789ABCD"
	cart_name					db	"Start Project$" ; 
	cart_chksum					dw	0000h ;; TODO - can the assembler calculate this?
CODESEG ENDS

;; Workaround to build the program differently if ROM or COM
	; If ROM, we don't want EXE2BIN to destroy 0000h -> 0100h
	; If COM, we do want EXE2BIN to destroy 0000h -> 0100h
IFDEF ROM
	INCLUDE C:\SRC\ROM_END.ASM
ELSE
	INCLUDE C:\SRC\COM_END.ASM
ENDIF
