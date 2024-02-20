bits 32

section .data
    name_msg db "Please enter your name:", 0x0a, 0x00
    code_msg db "Please enter your code:", 0x0a, 0x00
    success_msg db "Success!", 0x0a, 0x00
    failed_msg db "Access Denied", 0x0a, 0x00
    
section .bss
    user_name resb 0x14
    name_eol resb 0x02
    user_code resb 0x14
    code_eol resb 0x02
    name_len resb 0x01
    result resb 0x10

section .text
    global main

failed:
    push failed_msg
    call print
    add esp, 0x04
    jmp exit

print:
    push ebp
    mov ebp, esp

    call len_check

    ; ;print message
    mov edx, eax
    mov ecx, [ebp + 8]
    mov ebx, 0x01
    mov eax, 0x04
    int 0x80

    leave
    ret

get_input:
    push ebp
    mov ebp, esp

    mov eax, [ebp + 0x08]
    push eax
    call print
    add esp, 0x04

    ;get user information
    mov edx, [ebp + 0x0c]
    mov ecx, [ebp + 0x10]
    mov ebx, 0x00
    mov eax, 0x03
    int 0x80

newtest: 
    xor edx, edx

eol_insert_loop:
    cmp byte [ecx + edx], 0x0a
    je eol_found
    inc edx
    jne eol_insert_loop

eol_found:
    mov byte [ecx + edx], 0x00

    leave
    ret

len_check:
    push ebp
    mov ebp, esp
    
    xor eax, eax
    mov ecx, [ebp + 0x10]
    
len_check_loop:
    cmp byte [ecx + eax], 0x00
    jz len_check_done
    inc eax
    jnz len_check_loop

len_check_done:
    leave 
    ret

calc:
    push ebp
    mov ebp, esp

    xor eax, eax
    mov al, byte [ebp + 0x08]
    imul eax, eax
    sub eax, 0x2000

    leave
    ret

residual_test:
    push ebp
    mov ebp, esp

    mov eax, [ebp+8]
    mov ecx, 0x03
    xor edx, edx
    div ecx
    cmp edx, 0x00
    jnz failed

    leave
    ret

main:
    mov [name_eol], word 0x0000
    mov [code_eol], word 0x0000

    push dword user_name
    push dword 0x14
    push dword name_msg
    call get_input
    add esp, 0x0c

    push dword user_code
    push dword 0x14
    push dword code_msg
    call get_input
    add esp, 0x0c

    push user_name
    push user_name
    push user_name
    call len_check
    mov [name_len], eax
    add esp, 0x0c

    ; check user name length
    movzx ecx, byte [name_len]
    cmp ecx, 12
    jb failed
    cmp ecx, 20
    ja failed

    ; calculate result
    push name_len
    call residual_test
    add esp, 0x04

    ; calc
    push name_len
    call calc
    add esp, 0x4
    mov [result], eax

    mov eax, [result]
    mov ebx, [user_code]
    or al, 0x30
    cmp al, bl
    jne failed

    ; print success message
    push success_msg
    call print
    add esp, 0x04
    
    jmp exit

exit:
    ;exit
    mov eax, 0x01
    int 0x80
