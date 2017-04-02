#include <stdio.h>
// #include <drawPixel.h>
extern unsigned short * frameBuffer;
void f_drawPixel(int x_int, int y_int, int colour_int){
	//calculate the offset at which to write to the frame buffer
	/*
	// offset = (y * 1024) + x = x + (y << 10)
	// add		offset,	r0, r1, lsl #10
	add		offset_r,	xValue_r, yValue_r, lsl #10
	// offset *= 2 (for 16 bits per pixel = 2 bytes per pixel)
	lsl		offset_r, #1
	*/
	unsigned int offest_int = (x_int + (y_int << 10));

    // offset by the current buffer start
    // For buffer swapping
    // offest_int += current_page * page_size;


    //Hopefully equivalent to:
    /*
    ldr		temp_r, =FrameBufferPointer
	ldr		temp_r, [temp_r]
	strh	colour_r, [temp_r, offset_r]
    */
    frameBuffer[offest_int] = colour_int;
};