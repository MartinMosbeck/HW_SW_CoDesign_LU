
#include "display.h"
#include "system.h"
#include "io.h"

void display_init()
{
    // wait while textmode controller is busy
    while (IORD_32DIRECT(TEXTMODE_CONTROLLER_BASE,0) == 0x01);
    // INSTR_CFG (0x04) cursor blink, auto scroll, auto increment cursor, cursor color 3
    IOWR_32DIRECT(TEXTMODE_CONTROLLER_BASE,0,0x00033304);
    // wait while textmode controller is busy
    while (IORD_32DIRECT(TEXTMODE_CONTROLLER_BASE,0) == 0x01);
}

void display_clear()
{
    // wait while textmode controller is busy
    while (IORD_32DIRECT(TEXTMODE_CONTROLLER_BASE,0) == 0x01);
    // set cursor to (0,0)
    IOWR_32DIRECT(TEXTMODE_CONTROLLER_BASE,0,0x00000003);
    // wait while textmode controller is busy
    while (IORD_32DIRECT(TEXTMODE_CONTROLLER_BASE,0) == 0x01);
    IOWR_32DIRECT(TEXTMODE_CONTROLLER_BASE,0,0x00000002|(' '<<8));
}

void display_print(char* txt)
{
    int i;
    char s;
    
    i = 0;
    s = txt[i++];
    while (s != '\0')
    {
	 // wait while textmode controller is busy
	while (IORD_32DIRECT(TEXTMODE_CONTROLLER_BASE,0) == 0x01);
	
	if (s == '\n')
	{
	    IOWR_32DIRECT(TEXTMODE_CONTROLLER_BASE,0,0x00300007);
	}
	else
	{
	    IOWR_32DIRECT(TEXTMODE_CONTROLLER_BASE,0,0x00300001|(s<<8));
	}
	
	s = txt[i++];
    }
}
