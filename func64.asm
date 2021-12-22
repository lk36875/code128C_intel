    .include "constants.inc"
    .set data, 2
    .set s0, 0
    .set s1, 0
    .set s2, 0
    .set s3, 0
    .set s4, 0
    .set s5, 0
    .set s6, 0






li $s0, 0	# smallest width counter, will hold smallest width
	# s1 will hold current pixel address
	li $s2, 0	# current pattern
	la $s3, 0	# output counter
	la $s4, 0	# stack word multiplication counter
	# s5 will hold boundary of considered pixels
	la $s6, 0	# s6 hold flag to check if proper start code occured

	li $t0, 25	# y value






	.global  Decode128
	.text


#=====================================================================
# int Decode128(char *a)#
#
# Description: Function changes chars to '*' between first and second
# char of string
# Return value: none
#=====================================================================
# int Decode128(unsigned char *image, char *text, int xline, int yline, int skanline);
# define image [ebp+8]
# define text [ebp+12]
# define xline [ebp+16]
# define yline [ebp+20]
# define skanline [ebp+24]




Decode128:










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

    mov rax, code_06

	ret

