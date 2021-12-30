












#=====================================================================
# int Decode128(char *a)#
#
# Description: Function changes chars to '*' between first and second
# char of string
# Return value: none
#=====================================================================

# 4.3 Register Usage
# There are sixteen 64-bit registers in x86-64: %rax, %rbx, %rcx, %rdx, %rdi, %rsi, %rbp,
# %rsp, and %r8-r15.

# Of these, %rax, %rcx, %rdx, %rdi, %rsi, %rsp, and %r8-r11 are
# considered caller-save registers, meaning that they are not necessarily saved across function
# calls. By convention, %rax is used to store a function’s return value, if it exists and is no more
# than 64 bits long. (Larger return types like structs are returned using the stack.) Registers %rbx,
# %rbp, and %r12-r15 are callee-save registers, meaning that they are saved across function
# calls. Register %rsp is used as the stack pointer, a pointer to the topmost element in the stack.
# Additionally, %rdi, %rsi, %rdx, %rcx, %r8, and %r9 are used to pass the first six integer
# or pointer parameters to called functions. Additional parameters (or large parameters such as
# structs passed by value) are passed on the stack.


    .include "constants.inc"
    .set data, 2
    .set s0, 0
    .set s1, 0
    .set s2, 0
    .set s3, 0
    .set s4, 0
    .set s5, 0
    .set s6, 0
# int Decode128(unsigned char *image, char *text, int xline, int yline, int skanline);
    # .set image, [rdi]
    # .set text, [rsi]
    .set xline, [rdx]
    .set yline, [rcx]
    .set skanline, 0
    lea skanline, r8





    .global  Decode128
	.text

Decode128:

    mov rax, 0
    mov r8, 0
    mov r9, 0
    mov r10, 0
    mov r11, 0
    mov r12, 0
    mov r13, 0
    mov r14, 0
    mov r15, 0

    # li $s0, 0	# smallest width counter, will hold smallest width      s0
    # 	# s1 will hold current pixel address                            rdi, s1 is iterator
    # 	li $s2, 0	# current pattern                                    s2
    # 	la $s3, 0	# output counter                                       rsi
    # 	la $s4, 0	# stack word multiplication counter                 s4
    # 	# s5 will hold boundary of considered pixels                    s5
    # 	la $s6, 0	# s6 hold flag to check if proper start code occured    s6

    # FILE READ

get_middle:
# arguments:
#	x = 0
#	$a1 - y coordinate - (0,0) - bottom left corner

    mov rbx, rdi # rbx - copy of rdi
    add r8, xline
    imul r8, 3  # r8 holds row length in bytes
    add rbx, r8
    .set s5, rbx # s5 holds beggining of next row

# ????????????????????????????????
# ????????????????????????????????
    mov rax, skanline
    ret
# ????????????????????????????????
# ????????????????????????????????


# t0 - r10, s1 - rbx, s0 - bedzie z r11, t3 = r12

smallest_width:
    mov rbx, rdi # [rbx] -first pixel
    mov r10, [rbx]
# ????????????????????????????????
    cmp rbx, s5
    jge error2

    cmp r10, 0x00000000 # if black, count width
    je black
    cmp r11, 0
    jne white
    jmp next

black:
    add r11, 1
	jmp next


white:
    cmp r10, 0x000000ff
    je sw_exit
	jmp next

next:
    add rbx, 3
    cmp r10, 0x000000ff
	jne smallest_width
    add r12, 3
	jmp smallest_width

sw_exit:
    sar r11, 1 # smallest width at $r11
	imul r11, 3 	# 1 width jump at $r11
    .set s0, r11

check_space_error:
    imul r11, 10
    cmp r11, r12
    jl error3






 #   mov rax, [rbx + r8]
    mov rax, 12312312
	ret


condition0:
    mov rax, 0
	ret


condition1:
    mov rax, 1
	ret


error2:
    mov rax, 2222
	ret   # out of range error

error3:
    mov rax, 3333
	ret   # space error








	#address of *a in rdi
	#return value in rax



	mov rax, 0			# count=0
    mov rsi, rdi

read_first_second:

    mov al, [rdi] # first char
    cmp al, 0 # end of string
	jz exit
    mov BYTE PTR[rdi], ' ' # change first char to space
    inc rdi # increment string and temp string
    inc rsi
    mov bl, [rdi] # second char
    cmp al, 0 # end of string
	jz exit
    mov BYTE PTR[rdi], ' '
    inc rdi
    inc rsi
    mov cl, [rdi]
    cmp cl, 0
    mov BYTE PTR[rdi], ' '

first_loop:
    mov cl, [rdi]
    cmp cl, 0
	jz exit # no char found
    cmp cl, al
    je check_if_second_exists # if first char found check if second char exists
    inc rdi # increment rdi if char not found
    inc rsi
    jmp first_loop # and look

check_if_second_exists:
    # incrementing temp string rsi to find second char
    mov cl, [rsi]
    cmp cl, bl
	je convert_to_stars_and_look # char found, convert
    cmp cl, 0
    je exit # char not found, abort
    inc rsi
    jmp check_if_second_exists



convert_to_stars_and_look:
    # iterate and convert
    inc rdi
    mov cl, [rdi]
    cmp cl, bl
    je exit # if second char found, stop converting and end fucntion
    mov BYTE PTR[rdi], '*'     # else if not second char , put star, *a = '*'
    jmp convert_to_stars_and_look
    ; inc rax


exit:

    movq rax, 2

	ret

