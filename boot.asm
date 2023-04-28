;bootloader, should also demonstrate printing from visual memory as opposed to bios interrupt

[ORG 0x7c00]   ; memory offset
xor ax, ax     ; set to zero
mov ds, ax     ; same as below but for the data segment
mov ss, ax     ; stack segment register, not the pointer, just shows where the stack starts
mov sp, 0x9c00

cld            ; auto increment esi/edi with string operation

mov ax, 0xb800 ; video memory address
mov es, ax     ; es = extra segment

mov si, msg    ; loads location of msg into general register si
call sprint

mov ax, 0xb800
mov gs, ax     ; gs is just general purpose
mov bx, 0x0000
mov ax, [gs:bx]; some offset for video mem

mov word [reg16], ax
call printreg16

hang:
    jmp hang

;------printing functions

dochar: call cprint ; print one char

sprint: lodsb  ; load string from address at DS:SI into al 
    cmp al, 0
    jne dochar ; jump if not equal
    add byte [ypos], 1 ; down one
    mov byte [xpos], 0 ; back to left side
    ret 

cprint: mov ah, 0x0f ; white on black for printing
    mov cx, ax ; saves char and white on black, one is in lower bytes other is in higher
    movzx ax, byte [ypos] ; move contents of ypos into ax and extend with 0's
    mov dx, 160
    mul dx     ; multiplies ax by dx
    movzx bx, byte [xpos]
    shl bx, 1  ; shift left by 1, fills lowest bit with 0

    mov di, 0  ; video memory
    add di, ax ; add y offset
    add di, bx ; add x offset

    mov ax, cx ; restore char/attribute
    stosw      ; stores word from ax into destination operand es:di
    add byte [xpos], 1 ; advance right

    ret

;------hex stuff

printreg16:
    mov di, outstr16
    mov ax, [reg16]
    mov si, hexstr
    mov cx, 4
hexloop:
    rol ax, 4  ; rotate left by 4
    mov bx, ax ; leftmost become rightmost
    and bx, 0x0f
    mov bl, [si + bx] ; index into hexstr
    mov [di], bl
    inc di
    dec cx
    jnz hexloop

    mov si, outstr16
    call sprint

    ret

;=============variables=============
msg db "printable text goes here", 0
reg16 dw    0  ; pass values to printreg16
outstr16 db '0000', 0
hexstr db '0123456789ABCDEF'
xpos db 0
ypos db 0


times 510-($-$$) db 0
dw 0xaa55