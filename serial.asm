
/*
 * Put a character to the serial port
 */
.macro PUTC, char
    push %eax           // save
    push %edx

    mov $0x3fd, %edx    // control register for com1
    1: in (%dx), %al    // read status into AL
    test $0x20, %al     // check for ready
    je 1b               // keep trying
    mov $0x3f8, %edx    // data register for com1
    mov \char, %al      // output character
    out %al, (%dx)

    pop %edx            // restore
    pop %eax
.endm

.macro OUTSP    
   PUTC $0x20  
.endm

.macro OUTNL    
   PUTC $0x0a  
   PUTC $0x0d  
.endm

.macro OUT0    
   PUTC $0x30  
.endm

.macro OUT1    
   PUTC $0x31  
.endm

.macro OUT2    
   PUTC $0x32  
.endm

.macro OUT3    
   PUTC $0x33  
.endm

.macro OUT4    
   PUTC $0x34  
.endm

.macro OUT5    
   PUTC $0x35  
.endm

.macro OUT6    
   PUTC $0x36  
.endm

.macro OUT7
   PUTC $0x37  
.endm

.macro OUT8    
   PUTC $0x38  
.endm

.macro OUT9    
   PUTC $0x39  
.endm

.macro OUTA    
   PUTC $0x41  
.endm

.macro OUTB    
   PUTC $0x42  
.endm

.macro OUTC    
   PUTC $0x43  
.endm

.macro OUTD    
   PUTC $0x44  
.endm

.macro OUTE    
   PUTC $0x45  
.endm

.macro OUTF    
   PUTC $0x46  
.endm

.macro OUTG
   PUTC $0x47  
.endm

.macro OUTH    
   PUTC $0x48  
.endm

.macro OUTI    
   PUTC $0x49  
.endm

.macro OUTJ    
   PUTC $0x4a  
.endm

.macro OUTK    
   PUTC $0x4b  
.endm

.macro OUTL    
   PUTC $0x4c  
.endm

.macro OUTM    
   PUTC $0x4d  
.endm

.macro OUTN    
   PUTC $0x4e  
.endm

.macro OUTO
   PUTC $0x4f  
.endm

.macro OUTP    
   PUTC $0x50  
.endm

.macro OUTQ    
   PUTC $0x51  
.endm

.macro OUTR    
   PUTC $0x52  
.endm

.macro OUTS    
   PUTC $0x53  
.endm

.macro OUTT    
   PUTC $0x54  
.endm

.macro OUTU    
   PUTC $0x55  
.endm

.macro OUTV    
   PUTC $0x56  
.endm

.macro OUTW
   PUTC $0x57  
.endm

.macro OUTX    
   PUTC $0x58  
.endm

.macro OUTY    
   PUTC $0x59  
.endm

.macro OUTZ
   PUTC $0x5a  
.endm

/*
 * Convert byte in AL to ascii equivalent in AX, e.g., 0x31 -> 0x3331 which is '3' '1'
 */
.globl alto_hex
alto_hex:
    mov %al, %ah        // duplicate low byte                 0x0031 -> 0x3131
    and $0x0f, %al      // keep only low nibble of low byte   0x3131 -> 0x3101
    shr $4, %ah         // shift right to access high nibble  0x3101 -> 0x0301
    and $0x0f, %ah      // keep only low nibble               0x0301 -> 0x0301 same?
low:
    cmp $0xa, %al
    jge lowletter       //                                    0x030x, x is a-f

lowdigit:
    add $0x30, %al      // add '0'                            0x030x -> 0x033x 
    jmp high

lowletter:
    add $0x37, %al      // add 'a' - 10                      

high:
    cmp $0xa, %ah
    jge highletter

highdigit:
    add $0x30, %ah      // add '0'
    ret

highletter:
    add $0x37, %ah      // add 'a' - 10
    ret

/*
 * Write a single char in AL to the console
 */
.global outcom1_single_char
outcom1_single_char:
    push %edx
    push %eax           // save as we use AL temporarily below

    mov $0x3fd, %edx    // control register for com1

    2: in (%dx), %al    // read status into AL
    test $0x20, %al     // check for ready
    je 2b               // keep trying

    mov $0x3f8, %edx    // data register for com1
    pop %eax            // retore
    out %al, (%dx)

    pop %edx            // restore
    ret

/*
 * Put 2 chars to the serial port, describing AL the bottom byte of EAX
 */
.globl outcom1_two_chars_al
outcom1_two_chars_al:
    push %eax                       // save
    call alto_hex                  // AL value is now as ascii, so 0x30 is AH 3 AL 0
    ror $8, %ax                     // swap, so AL is now '3' and AH as '0'
    call outcom1_single_char       // put '3' 
    ror $8, %ax                     // swap back
    call outcom1_single_char       // put '0'
    pop %eax                        // restore
    ret

/*
 * Put 4 chars to the serial port, describing AX the bottom word of EAX
 */
.globl outcom1_ax
outcom1_ax:
    push %eax           // save
    ror $8, %ax         // rotate bytes so the order on the console is correct
    call outcom1_two_chars_al
    ror $8, %ax         // rotate bytes so the order on the console is correct
    call outcom1_two_chars_al
    pop %eax            // restore
    ret

/*
 * Put 8 chars to the serial port, describing AL the bottom long of RAX
 */
.globl outcom1_eax_8_chars
outcom1_eax_8_chars:
    push %eax           // save
    ror $16, %eax       // rotate words so chars appear in the expected ordef
    call outcom1_ax
    ror $16, %eax       // rotate words so chars appear in the expected ordef
    call outcom1_ax
    pop %eax            // restore
    ret

.globl outcom1_eax
outcom1_eax:
    push %eax           // save
    OUTE
    OUTA
    OUTX
    OUTSP
    call outcom1_eax_8_chars
    OUTSP
    pop %eax            // restore
    ret

.globl outcom1_ebx
outcom1_ebx:
    push %eax           // save
    OUTE
    OUTB
    OUTX
    OUTSP
    mov %ebx, %eax
    call outcom1_eax_8_chars
    OUTSP
    pop %eax            // restore
    ret

.globl outcom1_ecx
outcom1_ecx:
    push %eax           // save
    OUTE
    OUTC
    OUTX
    OUTSP
    mov %ecx, %eax
    call outcom1_eax_8_chars
    OUTSP
    pop %eax            // restore
    ret

.globl outcom1_edx
outcom1_edx:
    push %eax           // save
    OUTE
    OUTD
    OUTX
    OUTSP
    mov %edx, %eax
    call outcom1_eax_8_chars
    OUTSP
    pop %eax            // restore
    ret

.globl geteip
geteip: 
    mov (%esp), %eax
    ret

.globl outcom1_eip
outcom1_eip:
    push %eax           // save
    OUTE
    OUTI
    OUTP
    OUTSP
    call geteip
    call outcom1_eax_8_chars
    OUTSP
    pop %eax            // restore
    ret

.globl outcom1_ebp
outcom1_ebp:
    push %eax           // save
    OUTE
    OUTB
    OUTP
    OUTSP
    mov %ebp, %eax
    call outcom1_eax_8_chars
    OUTSP
    pop %eax            // restore
    ret

.globl outcom1_esp
outcom1_esp:
    push %eax           // save
    OUTE
    OUTS
    OUTP
    OUTSP
    mov %esp, %eax
    call outcom1_eax_8_chars
    OUTSP
    pop %eax            // restore
    ret

.globl outcom1_regs
outcom1_regs:
    OUTR
    OUTE
    OUTG
    OUTS
    OUTSP
    call outcom1_eax
    call outcom1_ebx
    call outcom1_ecx
    call outcom1_edx
    call outcom1_eip
    call outcom1_esp
    call outcom1_ebp
    OUTNL
    ret

.globl putaxtest
putaxtest:
    push %eax           // save

    mov $0x12345678, %eax
    call outcom1_eax_8_chars
    OUTSP

    mov $0x00000011, %eax
    call outcom1_eax_8_chars
    OUTSP

    mov $0x00001100, %eax
    call outcom1_eax_8_chars
    OUTSP

    mov $0x00110000, %eax
    call outcom1_eax_8_chars
    OUTSP

    mov $0x11000000, %eax
    call outcom1_eax_8_chars
    OUTSP

    mov $0x000000aa, %eax
    call outcom1_eax_8_chars
    OUTSP

    mov $0x0000aa00, %eax
    call outcom1_eax_8_chars
    OUTSP

    mov $0x00aa0000, %eax
    call outcom1_eax_8_chars
    OUTSP

    mov $0xaa000000, %eax
    call outcom1_eax_8_chars
    OUTSP

    mov $0x123456aa, %eax
    call outcom1_eax_8_chars
    OUTSP

    mov $0x1234aa56, %eax
    call outcom1_eax_8_chars
    OUTSP

    mov $0x12aa3456, %eax
    call outcom1_eax_8_chars
    OUTSP

    mov $0xaa123456, %eax
    call outcom1_eax_8_chars
    OUTSP

    pop %eax            // restore
    ret

.globl neiltest
neiltest:
    OUTN
    OUTE
    OUTI
    OUTL
    OUTSP
    call putaxtest
    OUTNL
    call outcom1_regs
    OUTNL
    ret

