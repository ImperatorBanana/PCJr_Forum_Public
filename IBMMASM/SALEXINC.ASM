;THIS STRUC DEFINES THE	AREA USED AS BUFFER TO RECEIVE INPUT FROM KEYBOARD.
BUFS	EQU	25			;SET SIZE OF BUFFER AREA
PARMLST	STRUC
BUFSIZE	DB	BUFS			;LIMIT OF NUMBER OF CHARACTERS
RESIZE	DB	?			;RESPONSE SIZE
BUFFER	DB	BUFS DUP(" ")		;BUFFER	AREA
BUFEND	DB	EOM			;TERMINATOR TO BUFFER AREA
PARMLST	ENDS
RESIZE	DB	?			;RESPONSE SIZE
BUFFER	DB	BUFS DUP(" ")		;BUFFER	AREA
BUFEN