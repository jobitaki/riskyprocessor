strncopy:
    # a0 = char *dst (where to store new string)
    # a1 = const char *src (start of string)
    # a2 = unsigned long n (length of string)
    # t0 = i (index)
	  li      a1, 4
    li      a2, 4
    li      t0, 0        # i = 0
1:  # first for loop
    bge     t0, a2, 2f   # break if i >= n
    add     t1, a1, t0   # t1 = src + i
    lb      t1, 0(t1)    # t1 = src[i]
    beqz    t1, 2f       # break if src[i] == '\0'
    add     t2, a0, t0   # t2 = dst + i
    sb      t1, 0(t2)    # dst[i] = src[i]
    addi    t0, t0, 1    # i++
    j       1b           # back to beginning of loop

2:  # second for loop
    bge     t0, a2, 3f   # break if i >= n
    add     t1, a0, t0   # t1 = dst + i
    sb      zero, 0(t1)  # dst[i] = 0
    addi    t0, t0, 1    # i++
    j       2b           # back to beginning of loop

3:
    lw      t6, 0(x0)
    ret                  # return
