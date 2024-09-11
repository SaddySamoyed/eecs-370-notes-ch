	beq	1	2	done	// beq by label
	beq	1	2	1	// beq by num
	beq	1	1	-32768	// beq must
	beq	1	1	32767	// beq most
done	halt
