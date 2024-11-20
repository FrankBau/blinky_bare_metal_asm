// blinky for STM Nucleo-L432KC board

.syntax unified
.cpu cortex-m4
.thumb

// memory mapped IO register (MMIO) addresses, see reference manual
#define RCC_AHB2ENR  0x4002104c		// register to enable clocks of various peripherals
#define GPIOB_MODER  0x48000400		// register to set mode (input/output/…) of a pin
#define GPIOB_ODR    0x48000414		// register to set GPIOB pins high (1) or low (0)

#define GPIOB_ENA       1 << 1		        // bit pattern to switch GPIO port B clock on
#define LED_PIN         3	 	            // pin number in GPIO port B where LED is connected
#define LED_MODER       1 << (2 * LED_PIN)	// bit pattern to set output mode for pin 3
#define LED_ODR         1 << LED_PIN	    // bit pattern to set pin output value (hi/lo)

#define DELAY           0x80000

.section .isr_vector,"a",%progbits
.type	g_pfnVectors, %object
.size	g_pfnVectors, .-g_pfnVectors
g_pfnVectors:
    .word   _estack           	// initial value of sp (stack pointer)
    .word   _start          	// initial value of pc (program counter)

.section  .text
.global   _start
.type     _start, %function
_start:
    ldr     r0, =RCC_AHB2ENR    // load constant RCC_AHB2ENR to register r0
    ldr     r1, [r0]            // load value from address in r0 (RCC_AHB2ENR) to r1
    ldr     r2, =GPIOB_ENA      // load bit mask GPIOB_ENA to register r2
    orrs    r1, r2              // set bit to enable clock for GPIO port B
    str     r1, [r0]            // store modified value to address in r0 (RCC_AHB2ENR)

    ldr     r0, =GPIOB_MODER    // load constant GPIOB_MODER (GPIO Port B Mode Register address) to register r0
    ldr     r1, =LED_MODER      // load constant LED_MODER to register r0
    str     r1, [r0]            // store this value in LED_MODER. this sets pin PB3 to output mode

blink:
    ldr     r0, =GPIOB_ODR      // load constant GPIOB_ODR (GPIO Port B Output Data Register address) to register r0
    ldr     r1, =LED_ODR        // load mask value to register r1
    str     r1, [r0]            // store mask value at address GPIOB_ODR (LED on)
    bl      delay               // call the delay function below 
    eors    r1, r1              // clear r1 register to zero
    str     r1, [r0]            // store zero at address GPIOB_ODR (LED off)
    bl      delay               // call the delay function below again
    b       blink               // branch to label blink (infinite loop)

.section  .text
.global   delay
.type     delay, %function
delay:
    ldr     r2, =DELAY          // load DELAY value to register r2
L:  subs    r2, r2, #1          // subtract 1 from register r2 (count down)
    bne     L                   // branch if result of subs was not 0 (loop)
    bx      lr                  // return to caller
