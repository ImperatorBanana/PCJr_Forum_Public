;; Sumary: This is a starting shell for writing a PCJr IPL Cartridge
;  Note: Since we don't define the stack MASM will throw a warning
;  Build steps:
; TODO

;; BIOS System Start Call, used to hand final control to cartridge
int18_offset					EQU	018h * 004h 
int18_segment					EQU	int18_offset + 002h
int21_offset					EQU	021h * 004h ;; DOS INT 21 service
int21_segment					EQU	int21_offset + 002h

;; CART Equates
cart_rom_len					EQU	2000h

;; Memory map
;0000:00 - 0030:00 - Interrupt Vector table
interrupt_vector_table_segment	EQU	0000h
;0030:00 - 0040:00 - Stack
	val_top_of_stack			EQU 0100h
;0040:00 - 0050:00 - BIOS Data
;0050:00 - 0800:00 - System RAM
system_ram_segment				EQU	0050h
;0800:00 - 0C00:00 - Video Page 2 (Alias to 6)
;0C00:00 - 1000:00 - Video Page 3 (Alias to 7)
;------------------------------
;B800:00 - BC00:00 - Video RAM (Alias to one of the two video pages)
video_ram_segment				EQU	0B800h
;D000:00 - D800:00 - CART ROM
;E000:00 - E800:00 - CART RAM (Read)
;E800:00 - F000:00 - CART RAM (Write)
;F000:00 - 		   - BIOS
bios_rom_segment				EQU	0F000h

;; Program Equates
int_video						EQU	10h
	svc_video_mode					EQU	00h
		val_video_mode_40_25_grey		EQU	00h
		val_video_mode_40_25_16c		EQU	01h
		val_video_mode_80_25_grey		EQU	02h
		val_video_mode_80_25_16c		EQU	03h
		val_video_mode_320_200_4c		EQU	04h
		val_video_mode_320_200_4g		EQU	05h
		val_video_mode_640_200_2c		EQU	06h
		; No PCJr Mode 7				EQU 07h
		val_video_mode_160_200_16c		EQU	08h
		val_video_mode_320_200_16c		EQU	09h
		val_video_mode_640_200_4c		EQU	0Ah
	svc_video_set_cursor_pos		EQU	02h	
	svc_video_write_char_tty		EQU	0Eh
	svc_video_get_current_mode		EQU	0Fh
int_keyboard					EQU 16h
	svc_keyboard_read_next			EQU 00h
	svc_keyboard_report_ready		EQU 01h
int_bootstrap	EQU 19h
int_dos			EQU 21h
	svc_dos_print_str				EQU 09h
	svc_dos_terminate	EQU 4Ch
		val_dos_terminate_success	EQU 00h

CARTSEG segment
assume CS:CARTSEG, DS:CARTSEG
ORG	0000h
IFDEF IS_CART
HEADER: ; PC Jr Cartridge Header
	cartridgeid			dw		0AA55h
	cartridgelength		db		cart_rom_len/512	;; TODO - can the assembler calculate this 		
	jmp					INIT					;; ENTRY POINT
	headerend			db		00h
INIT PROC FAR ;; INIT Function
	; The BIOS pushes DX (the current ROM block being checked for signatures) to the stack
	; and then does a call (far) (which pushes the segment and offset before jumping)
	; Assumes your init didn't push additional data to the stack
	mov		bp,sp ; Set the base pointer
	mov		ax,bios_rom_segment ;
	mov		[bp+4],ax ; Set the "current ROM block" to be after the end of the cartridge
	; Set up the interrupt vector to boot into the cartridge
	mov		ax,interrupt_vector_table_segment
	mov		es,ax ; Set ES to 0000h (the interrupt vector segment)
	mov		ax,cs
	mov		es:int18_segment,ax ; Move the current Code Segment to the Interrupt Vector 2nd 2 bytes
	mov		ax,offset CART_SETUP
	mov		es:int18_offset,ax ; Move the Main Offset to the Interrupt Vector 1st 2 bytes
	ret
INIT ENDP
CART_SETUP PROC FAR
	call	UTIL_LOAD_DOS_INT21H
	jmp		MAIN
CART_SETUP ENDP
ELSE
	jmp		MAIN
ENDIF

ORG 100h
HOLA_MUNDO db "Hola, Mundo!$"

INCLUDE C:\SRC\UTIL.ASM 

SETUP_STACK	MACRO
	mov		ax,val_top_of_stack ; Top of the stack
	mov		sp,ax ;; Reset the stack pointer
ENDM

SETUP_DEFAULT_SEGMENTS MACRO
	mov		ax,cs 
	mov		ds,ax ;; Set DS == Cart Seg
	mov		ax,system_ram_segment
	mov		es,ax ;; Set ES == System Ram Segment
ENDM

SETUP_VIDEO_MODE MACRO ; Set video mode
	mov		ax,(svc_video_mode SHL 8) OR val_video_mode_40_25_grey
	int		int_video
ENDM


;; MAIN Function
MAIN:
	sti
SETUP:
	SETUP_STACK
	SETUP_DEFAULT_SEGMENTS
	SETUP_VIDEO_MODE
HELLO_WORLD:
	mov		ah,svc_dos_print_str
	mov		dx,offset HOLA_MUNDO
	int		int_dos
INF_LOOP:
	jmp		INF_LOOP



EXIT:
IFDEF IS_CART
	int		int_bootstrap
ELSE
	mov	ax,(svc_dos_terminate SHL 8) OR val_dos_terminate_success
	int		int_dos
ENDIF
sti		
jmp		EXIT ; In case we don't recover

ORG	cart_rom_len - 16; 15(name) + 2(chksum) ;; TODO - can the assembler calculate this
FOOTER: ; PCJr Cartridge Footer
	;;								"123456789ABCDE"
	cart_name					db	"Start Project$" ; 
	cart_chksum					dw	0000h ;; TODO - can the assembler calculate this?
CARTSEG ENDS
END ; End program
