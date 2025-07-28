[BITS 16]
[ORG 0x7C00]

start:
    cli
    xor ax, ax
    mov ds, ax
    mov es, ax
    mov ss, ax
    mov sp, 0x7C00
    sti

main_loop:
    call print_prompt
    call read_input
    call handle_command
    jmp main_loop

; -------------------------------------
; PROMPT & CURSOR
; -------------------------------------
print_prompt:
    mov si, prompt
    call print_string
    ret

; Blinking cursor (underscore)
print_cursor:
    mov al, '_'
    call print_char
    ret

; -------------------------------------
; READ INPUT INTO BUFFER
; -------------------------------------
read_input:
    mov di, input_buffer
.read_loop:
    call get_char
    cmp al, 0x0D        ; Enter?
    je .done
    cmp al, 0x08        ; Backspace
    je .backspace
    call print_char
    stosb
    jmp .read_loop

.backspace:
    cmp di, input_buffer
    je .read_loop
    dec di
    mov al, 0x08
    call print_char
    mov al, ' '
    call print_char
    mov al, 0x08
    call print_char
    jmp .read_loop

.done:
    mov al, 0x0D
    call print_char
    mov al, 0x0A
    call print_char
    mov byte [di], 0
    ret

; -------------------------------------
; HANDLE COMMAND
; -------------------------------------
handle_command:
    mov si, input_buffer

    ; Empty input — skip
    cmp byte [si], 0
    je .done

    mov di, cmd_info
    call strcmp
    je do_info

    mov di, cmd_exit
    call strcmp
    je do_exit

    mov di, cmd_panic
    call strcmp
    je do_panic

    mov di, cmd_reboot
    call strcmp
    je do_reboot

    ; Unknown command
    mov si, unknown_msg
    call print_string
.done:
    ret

; -------------------------------------
; COMMANDS
; -------------------------------------
do_info:
    mov si, info_msg
    call print_string
    ret

do_exit:
    mov si, exit_msg
    call print_string
    cli
    hlt
.hang:
    jmp .hang

do_panic:
    mov si, panic_msg
    call print_string
.panic_loop:
    cli
    hlt
    jmp .panic_loop

do_reboot:
    mov si, reboot_msg
    call print_string
    cli
    mov al, 0xFE
    out 0x64, al
    jmp $

; -------------------------------------
; UTILITIES
; -------------------------------------
get_char:
    mov ah, 0x00
    int 0x16
    mov ah, 0x0E
    int 0x10
    ret

print_char:
    mov ah, 0x0E
    mov bh, 0x00
    mov bl, 0x07
    int 0x10
    ret

print_string:
    lodsb
    cmp al, 0
    je .done
    call print_char
    jmp print_string
.done:
    ret

strcmp:
.loop:
    lodsb
    mov ah, [di]
    inc di
    cmp al, ah
    jne .not_equal
    test al, al
    jne .loop
    mov ax, 1
    ret
.not_equal:
    xor ax, ax
    ret

; -------------------------------------
; STRINGS
; -------------------------------------
prompt      db '>', 0
unknown_msg db 'Unknown command.', 0x0D, 0x0A, 0
info_msg    db 'BootShell v0.1 (Real mode)', 0x0D, 0x0A, 0
exit_msg    db 'Halting system...', 0x0D, 0x0A, 0
panic_msg   db 'PANIC! System halted.', 0x0D, 0x0A, 0
reboot_msg  db 'Rebooting...', 0x0D, 0x0A, 0

cmd_info    db 'info', 0
cmd_exit    db 'exit', 0
cmd_panic   db 'panic', 0
cmd_reboot  db 'reboot', 0

; -------------------------------------
; BUFFER
; -------------------------------------
input_buffer times 64 db 0

; -------------------------------------
; BOOT SIGNATURE
; -------------------------------------
times 510-($-$$) db 0
dw 0xAA55
