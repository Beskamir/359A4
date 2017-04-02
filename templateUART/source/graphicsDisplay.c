#include <stdio.h>
// #include <string.h>
// #include <drawPixel.h>
#define screenArraySize 786431

extern unsigned short * FrameBufferPointer;


int screenCurrent[ screenArraySize ];
int screenOld[ screenArraySize ];

void c_f_refreshScreen(){
	int screenCurrent[ screenArraySize ];
	int screenOld[ screenArraySize ];
	int i = 0;

	// for (int i = 0; i < screenArraySize; ++i)
	while (i<screenArraySize)
	{
		screenCurrent[i] = 0;
		screenOld[i] = 0;
		i++;
	}
}
// 
// 
void c_f_storePixel(int x_int, int y_int, int colour_int){
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
    screenCurrent[offest_int] = colour_int;
};


void c_f_displaceFrame(){
	int colourNew;
	int colourOld;
	int i = 0;
	// for (int i = 0; i < screenArraySize; ++i)
	while (i<screenArraySize)
	{
		colourNew = screenCurrent[i];
		colourOld = screenOld[i];
		if (colourNew!=colourOld)
		{
    		FrameBufferPointer[i] = colourNew;
    		screenOld[i] = colourNew;
		}
		i++;
	}
}