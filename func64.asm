# -------------------------------------------------------------------------------
# author: Lukasz Glowka
# date : 09.01.2022
# description : program for decoding a BMP file containing code 128 type C
# -------------------------------------------------------------------------------

    .include "constants.inc"
    .set smallest_jump,     [rsp - 8]
    .set current_pattern,   [rsp - 16]
    .set checksum_counter,  [rsp - 24]
    .set boundary,          [rsp - 32]
    .set checksum,          [rsp - 40]


# int Decode128(unsigned char *image, char *text, int xline, int yline, int skanline);

    .global  Decode128
	.text

Decode128:
    mov r13, r8     # skanline
    mov r14, rdx    # xline
    mov r15, rcx    #  yline

    push    rbp
    mov     rbp, rsp
    sub     rsp, 40

    # clear registers
    mov r8, 0
    mov [smallest_jump],    r8
    mov [current_pattern],  r8
    mov [checksum_counter], r8
    mov [boundary],         r8
    mov [checksum],         r8

    mov rax, 0
    mov r9,  0
    mov r10, 0
    mov r11, 0
    mov r12, 0


# FIND LINE AND BOUNDARY

get_line:

    mov r8, r13     # move line to skan into r8
    imul r8, r14    # multiply by line length
    imul r8, 3      # multiply by bytes per pixel
    add rdi, r8     # line to skan

    mov rbx, rdi    # rbx - copy of rdi
    mov r8, r14     # move length of line to r9
    imul r8, 3      # r8 holds row length in bytes
    add rbx, r8

    mov [boundary], rbx # boundary holds beggining of next row
    mov rbx, rdi        # [rbx] -first pixel

# FINDING SMALLEST WIDTH

smallest_width:
    mov r10b, [rbx]
    mov r8, [boundary]
    cmp rbx, r8         # check boundary
    jge out_of_range_error

    cmp r10b, 0         # if black, count width
    je black
    cmp r11, 0
    jne white
    jmp next

black:
    add r11, 1
	jmp next


white:
    cmp r10b, 255
    je sw_exit
	jmp next

next:
    add rbx, 3
    cmp r10b, 255
	jne smallest_width
    add r12, 3          # check if 10 first white widths are present
	jmp smallest_width

sw_exit:
    sar r11, 1          # smallest width at $r11
	imul r11, 3 	    # 1 width jump at $r11
    mov [smallest_jump], r11

check_space_error:
    imul r11, 10
    cmp r12, r11
    jl wrong_space

    mov r10, 0
    mov r8, 1
    mov [current_pattern], r8
    mov r11, 1      # color counter
    mov r12, 1      # color counter
    mov r14, 2      # first black width
    mov r15, 5      # pattern widths to find
    jmp add_black

pattern_set_up:		    # set up for standard code
    mov r10, 0

    mov r11, 1
    mov r12, 1
    mov r15, 6

    mov r8, 1
    mov [current_pattern], r8

look_for_pattern:
count_black:
    cmp r15, 0
    je decode_prepare
    mov r8, [smallest_jump]
    add rbx, r8

    cmp r11, 100
    jg out_of_range_error
    mov r8, [boundary]
    cmp rbx, r8
    mov r8, 0
    jge out_of_range_error

    mov r10b, [rbx]
    cmp r10b, 0
    je add_one_black
    cmp r10b, 255
    je prepare_add_black


add_one_black:		# increment black color counter
    add r11, 1
    jmp count_black

prepare_add_black:
    mov r14, r11
    sub r15, 1
    jmp add_black


count_white:		# increment white color counter
    mov r8, [smallest_jump]
    add rbx, r8
    mov r10b, [rbx]

    cmp r12, 100
    jg out_of_range_error
    mov r8, [boundary]
    cmp rbx, r8
    mov r8, 0
    jge out_of_range_error

    cmp r10b, 255
    je add_one_white
    cmp r10b, 0
    je prepare_add_white


add_one_white:
    add r12, 1
    jmp count_white

prepare_add_white:
    mov r14, r12
    sub r15, 1
    jmp add_white





add_black:		# add black to current_pattern register in form of binary 1
	cmp r15, 5 # jump if this is start of pattern
    je pattern_beggining
    jmp pattern_black

pattern_beggining:
    sub r14, 1
    jmp pattern_black

pattern_black:
    cmp r14, 0
    je prepare_for_white_count

    mov r8, [current_pattern]
    sal r8, 1
    add r8, 1
    mov [current_pattern], r8
    mov r8, 0


    sub r14, 1
    jmp pattern_black

prepare_for_white_count:
    mov r12, 1
    jmp count_white



add_white:		# add white to current_pattern register in form of binary 0
pattern_white:
    cmp r14, 0
    je prepare_for_black_count

    mov r8, [current_pattern]
    sal r8, 1
    mov [current_pattern], r8
    mov r8, 0

    sub r14, 1
    jmp pattern_white

prepare_for_black_count:
    mov r11, 1
    jmp count_black


decode_prepare:
    mov r10, 0      # counter also serves purpose as decoder

    mov r12, 0

decode:
    mov r12w, [table + 2 * r10]     # 2 * r10 jumps by one word in table
    cmp r12w, [current_pattern]
    je match

next_code:
    add r10, 1
    cmp r10, 106
    je possible_stop    # possible stop since there were no matches, else error
    jmp decode

check_set_up:
    mov r8, 105
    add [checksum], r8
    cmp r10, 105    # check start code, happens one time
    jne wrong_pattern
    jmp match_continue


match:
    mov r8b, [checksum_counter]
    cmp r8b, 0
    je check_set_up

match_continue:
    # CODE A, CODE B, FNC1, START A, START B

    cmp r10, 100
    je wrong_pattern
    cmp r10, 101
    je wrong_pattern
    cmp r10, 102
    je wrong_pattern
    cmp r10, 103
    je wrong_pattern
    cmp r10, 104
    je wrong_pattern


    mov r8, [checksum_counter]  # count word
    mov r9, r10                 # move current word to r9
    imul r9, r8                 # multiply word by counter
    add [checksum], r9          # add word to checksum

	mov r8, 1
    add [checksum_counter], r8b

    cmp r10, 105
    je pattern_set_up


    cmp r10, 10
    jl less_than_10

    mov rdx, 0
    mov rax, r10
    mov r8, 10
	div r8

    add rax, '0'    # convert to ASCII digit
    add rdx, '0'    # convert to ASCII digit
    mov BYTE PTR[rsi], al
    inc rsi
    mov BYTE PTR[rsi], dl
    inc rsi
    jmp pattern_set_up

    less_than_10:
        mov BYTE PTR[rsi], '0'  # convert to ASCII digit
        inc rsi
        add r10, '0'            # convert to ASCII digit
        mov BYTE PTR[rsi], r10b
        inc rsi
		jmp pattern_set_up

possible_stop:
    mov r8, [current_pattern]
    cmp r8, 0x63A
    jne stop_error

    mov r11, 1

count_stop:
    mov r8, [smallest_jump]
    add rbx, r8
    mov r10b, [rbx]
    mov r8, [boundary]
    cmp rbx, r8
    mov r8, 0
    jge out_of_range_error

    cmp r10b, 0
    je increment_count_stop
    cmp r10b, 255
    je check_stop

increment_count_stop:
    add r11, 1
    jmp count_stop

check_stop:
    cmp r11, 2
    jne stop_error

jmp check_space


check_space:
    mov r12, 9

loop_check_space:
    mov r8, [smallest_jump]
    add rbx, r8
    mov r10b, [rbx]
    mov r8, [boundary]
    cmp rbx, r8
    mov r8, 0
    jge out_of_range_error

    cmp r10b, 0
    je wrong_space
    sub r12, 1
    cmp r12, 0
    je count_checksum
    jmp loop_check_space

count_checksum:
    mov r10, 0
    mov r11, 0

    mov r8, [checksum_counter] # count word
    mov r13, [checksum] # checksum + checksum read in r13

    mov r10b, BYTE PTR[rsi-2]
    mov r11b, BYTE PTR[rsi-1]
    sub r10b, 48
    sub r11b, 48
    imul r10, 10
    add r10b, r11b # checksum read in r10b

    mov r11b, r10b
    sub r8, 1
    imul r11, r8
    sub r13, r11

    xor rdx, rdx
    xor rax, rax
    mov al, r13b
    mov r8, 103
	div r8

    cmp dl, r10b
    je write
    jne wrong_checksum

write:
    mov BYTE PTR[rsi-2], ' '
    mov BYTE PTR[rsi-1], ' '
    mov rsp, rbp
    pop rbp
    mov rax, 0
    ret


out_of_range_error:
    mov    rsp, rbp
    pop    rbp
    mov rax, 1
	ret   # out of range error

wrong_space:
    mov    rsp, rbp
    pop    rbp
    mov rax, 2
	ret   # wrong space error

wrong_checksum:
    mov    rsp, rbp
    pop    rbp
    mov rax, 3
	ret   # wrong checksum error

stop_error:
    mov    rsp, rbp
    pop    rbp
    mov rax, 4
	ret   # stop error

wrong_pattern:
    mov    rsp, rbp
    pop    rbp
    mov rax, 5
	ret   # wrong pattern error
