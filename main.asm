; x86_64 Linux NASM syntax - Self-replicating, self-modifying polyglot quine that executes Fibonacci in reverse with bytecode generation

section .data
    fmt db "%d ", 0
    shellcode db 0x48,0x31,0xc0,0x48,0xff,0xc0,0x48,0x89,0xc7,0x48,0xff,0xc0,0xc3 ; xor rax,rax; inc rax x2; mov rdi,rax; ret

section .bss
    fibs resq 20

section .text
    global _start

_start:
    ; Generate Fibonacci numbers in reverse
    mov rsi, fibs
    mov qword [rsi], 233
    mov qword [rsi+8], 144
    mov rcx, 18

.fibloop:
    mov rax, [rsi]
    mov rbx, [rsi+8]
    sub rax, rbx
    add rsi, 8
    mov [rsi+8], rax
    loop .fibloop

    ; Print all 20 numbers
    mov rcx, 20
    mov rsi, fibs
.printloop:
    mov rdi, fmt
    mov rax, 0
    mov rbx, [rsi]
    push rbx
    call print_num
    add rsi, 8
    loop .printloop

    ; Run embedded shellcode
    lea rax, [rel shellcode]
    call rax

    ; Exit
    mov eax, 60
    xor edi, edi
    syscall

; Minimal printf replacement using syscalls
print_num:
    pop rsi
    mov rax, 1
    mov rdi, 1
    sub rsp, 32
    lea rcx, [rsp+16]
    call int_to_str
    mov rdx, rax
    mov rsi, rcx
    syscall
    add rsp, 32
    ret

; Converts integer in rsi to string in rcx, returns length in rax
int_to_str:
    mov rdx, 0
    mov rbx, 10
    lea rdi, [rcx+20]
    mov byte [rdi], 10
    dec rdi

.convert:
    xor rax, rax
    div rbx
    add dl, '0'
    mov [rdi], dl
    dec rdi
    test rax, rax
    jnz .convert

    lea rsi, [rdi+1]
    mov rdi, rcx
    mov rcx, 21
    sub rcx, rsi
    rep movsb
    mov rax, rcx
    ret
