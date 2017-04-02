/*
    Modifying tutorial code from github to redo the framebuffer and hopefully increasing the fps...

    Full copywrite notice from original file:
*/

/*
    Part of the Raspberry-Pi Bare Metal Tutorials
    Copyright (c) 2015, Brian Sidebotham
    All rights reserved.

    Redistribution and use in source and binary forms, with or without
    modification, are permitted provided that the following conditions are met:

    1. Redistributions of source code must retain the above copyright notice,
        this list of conditions and the following disclaimer.

    2. Redistributions in binary form must reproduce the above copyright notice,
        this list of conditions and the following disclaimer in the
        documentation and/or other materials provided with the distribution.

    THIS SOFTWARE IS PROVIDED BY THE COPYRIGHT HOLDERS AND CONTRIBUTORS "AS IS"
    AND ANY EXPRESS OR IMPLIED WARRANTIES, INCLUDING, BUT NOT LIMITED TO, THE
    IMPLIED WARRANTIES OF MERCHANTABILITY AND FITNESS FOR A PARTICULAR PURPOSE
    ARE DISCLAIMED. IN NO EVENT SHALL THE COPYRIGHT HOLDER OR CONTRIBUTORS BE
    LIABLE FOR ANY DIRECT, INDIRECT, INCIDENTAL, SPECIAL, EXEMPLARY, OR
    CONSEQUENTIAL DAMAGES (INCLUDING, BUT NOT LIMITED TO, PROCUREMENT OF
    SUBSTITUTE GOODS OR SERVICES; LOSS OF USE, DATA, OR PROFITS; OR BUSINESS
    INTERRUPTION) HOWEVER CAUSED AND ON ANY THEORY OF LIABILITY, WHETHER IN
    CONTRACT, STRICT LIABILITY, OR TORT (INCLUDING NEGLIGENCE OR OTHERWISE)
    ARISING IN ANY WAY OUT OF THE USE OF THIS SOFTWARE, EVEN IF ADVISED OF THE
    POSSIBILITY OF SUCH DAMAGE.

*/
#include <string.h>
#include <stdio.h>
#include <stdlib.h>

#include "mailboxInterface.h"

#define SCREEN_WIDTH    1024
#define SCREEN_HEIGHT   768
#define SCREEN_DEPTH    16      /* 16 or 32-bit */


// volatile unsigned char* frameBuffer = NULL;
unsigned short* frameBuffer = NULL;

rpi_mailbox_property_t* memoryPointer;

/** Main function - we'll never return from here */
void c_init_frameBuffer(){
    // int width = SCREEN_WIDTH; 
    // int height = SCREEN_HEIGHT;
    // int bytesPerPixel = SCREEN_DEPTH;
    // volatile unsigned char* frameBuffer = NULL;

    // /* Initialise the UART */
    // RPI_AuxMiniUartInit( 115200, 8 );

    // /* Print to the UART using the standard libc functions */
    // printf( "Valvers.com ARM Bare Metal Tutorials\r\n" );
    // printf( "Initialise UART console with standard libc\r\n\n" );


    /* Initialise a framebuffer... */
    RPI_PropertyInit();
    RPI_PropertyAddTag( TAG_ALLOCATE_BUFFER );
    RPI_PropertyAddTag( TAG_SET_PHYSICAL_SIZE, SCREEN_WIDTH, SCREEN_HEIGHT );
    RPI_PropertyAddTag( TAG_SET_VIRTUAL_SIZE, SCREEN_WIDTH, SCREEN_HEIGHT );
    RPI_PropertyAddTag( TAG_SET_DEPTH, SCREEN_DEPTH );
    RPI_PropertyAddTag( TAG_GET_PHYSICAL_SIZE );
    RPI_PropertyAddTag( TAG_GET_DEPTH );
    RPI_PropertyProcess();

    // if( ( memoryPointer = RPI_PropertyGet( TAG_GET_PHYSICAL_SIZE ) ) )
    // {
    //     width = memoryPointer->data.buffer_32[0];
    //     height = memoryPointer->data.buffer_32[1];
    // }

    // if( ( memoryPointer = RPI_PropertyGet( TAG_GET_DEPTH ) ) )
    // {
    //     bytesPerPixel = memoryPointer->data.buffer_32[0];
    // }

    if( ( memoryPointer = RPI_PropertyGet( TAG_ALLOCATE_BUFFER ) ) )
    {
        frameBuffer = (unsigned short*)memoryPointer->data.buffer_32[0];
    }
    // c_f_clockBoost();
}
/*
 In theory this should increase the clock speed
*/
void c_f_clockBoost(){
    /* Ensure the ARM is running at it's maximum rate */
    memoryPointer = RPI_PropertyGet( TAG_GET_MAX_CLOCK_RATE );    
    RPI_PropertyInit();
    RPI_PropertyAddTag( TAG_SET_CLOCK_RATE, TAG_CLOCK_ARM, memoryPointer->data.buffer_32[1] );
    RPI_PropertyProcess();
}

/*
 In theory this should decrease the clock speed
*/
void c_f_clockLower(){
    /* Ensure the ARM is running at it's maximum rate */
    memoryPointer = RPI_PropertyGet( TAG_GET_MIN_CLOCK_RATE );    
    RPI_PropertyInit();
    RPI_PropertyAddTag( TAG_SET_CLOCK_RATE, TAG_CLOCK_ARM, memoryPointer->data.buffer_32[1] );
    RPI_PropertyProcess();
}