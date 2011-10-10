/*****************************************************************************/
/* COPYRIGHT                                                                 */
/* The copyrights, all other intellectual and industrial property rights are */
/* retained by XMOS and/or its licensors. Terms and conditions covering the  */
/* use of this code can be found in the Xmos End User License Agreement.     */
/*****************************************************************************/
/* File name : main.xc                                                       */
/* ------------------------------------------------------------------------- */
/* Component version: 1v0                                                    */
/* ------------------------------------------------------------------------- */
/* Description : Application for testing the Flashlib library                */
/*****************************************************************************/


#ifndef _MAIN_XC_
#define _MAIN_XC_
/*****************************************************************************/
/*                                 Includes                                  */
/*****************************************************************************/
#include <xs1.h>
#include <flashlib.h>
#include <platform.h>
#include <print.h>
#include <stdio.h>
#include <stdlib.h>

/*****************************************************************************/
/*                             Port Declaration                              */
/*****************************************************************************/
on stdcore[0] : fl_SPIPorts flash_ports = { PORT_SPI_MISO,
											PORT_SPI_SS,
											PORT_SPI_CLK,
											PORT_SPI_MOSI,
											XS1_CLKBLK_1 };


/*****************************************************************************
*                              Global Variables                              *
*****************************************************************************/

// Array of allowed flash devices from "SpecMacros.h"
fl_DeviceSpec myFlashDevices[] = {	FL_DEVICE_ATMEL_AT25FS010,
									FL_DEVICE_ATMEL_AT25DF041A,
									FL_DEVICE_WINBOND_W25X10,
									FL_DEVICE_WINBOND_W25X20 };

/*****************************************************************************
*                          Local function Prototypes                         *
*****************************************************************************/

void test_flash( void );

/*****************************************************************************
*                                  Functions                                 *
*****************************************************************************/




/**
 * Execution of the example function starts here.
 * \return int
 */

int main(void)
{
  par{
    // XCore 0
    on stdcore[0] : test_flash( );
}

  return 0;
}


/**
 * This function tests the flash by reading the device
 * signature, performing write and read on the flash device.
 * \return none.
 */


void test_flash( void )
{
  /*Array to store the data to be written to the flash*/
  unsigned char my_page[256];

  /*Variables forbuffering, counting iterations,etc*/
  unsigned int temp, i;


  /*Initialise the my_page array*/
  for ( i = 0; i < 256; i++ ){
    my_page[i] = 0x00;
  }

  /* Write "Hello World" to the my_page data array*/

  my_page[0] = 'H';
  my_page[1] = 'e';
  my_page[2] = 'l';
  my_page[3] = 'l';
  my_page[4] = 'o';
  my_page[5] = ' ';
  my_page[6] = 'W';
  my_page[7] = 'o';
  my_page[8] = 'r';
  my_page[9] = 'l';
  my_page[10] = 'd';
  my_page[11] = '!';
  my_page[12] = '\0';

  /* Connect to the FLASH */
  if ( 0 != fl_connectToDevice(flash_ports, myFlashDevices, 4) ){
    printstrln( "Could not connect to FLASH" );
    exit(-1);
  }

  /*Get the FLASH type*/
  switch ( fl_getFlashType() ){
    case 0 :
      printstrln( "FLASH fitted : Unknown!" );
      break;

    case ATMEL_AT25FS010 :
      printstrln( "FLASH fitted : ATMEL AT25FS010." );
      break;

    case ATMEL_AT25DF041A :
      printstrln( "FLASH fitted : ATMEL AT25DF041A." );
      break;

    case WINBOND_W25X10 :
      printstrln( "FLASH fitted : WINBOND W25X10." );
      break;

    case WINBOND_W25X20 :
      printstrln( "FLASH fitted : WINBOND W25X20." );
      break;

    default :
      printstrln( "FLASH fitted : Unexpected!" );
      break;
  }

  // Get the FLASH size
  temp = fl_getFlashSize();
  printstr( "FLASH size: " );
  printuint(temp);
  printstrln( " bytes." );

  // Get the FLASH page size
  temp = fl_getPageSize();
  printstr( "FLASH page size: " );
  printuint(temp);
  printstrln( " bytes." );

  // Get the FLASH data partition size
  temp = fl_getDataPartitionSize();
  printstr( "FLASH data partition size: " );
  printuint(temp);
  printstrln( " bytes." );

  // Get the FLASH data pages
  temp = fl_getNumDataPages();
  printstr( "FLASH number of pages in data partition: " );
  printuintln( temp );

  // Get the FLASH data sectors
  temp = fl_getNumDataSectors();
  printstr( "FLASH number of sectors in data partition: " );
  printuintln( temp );

  // Get the FLASH data sector size
  temp = fl_getDataSectorSize(0);
  printstr( "FLASH data sector size: " );
  printuint(temp);
  printstrln( " bytes." );

  // Wipe the data partition
  if ( 0 != fl_eraseAllDataSectors() ){
    printstrln( "Could not erase the data partition" );
    exit(-1);
  }

  printstrln( "Data partition erased!" );

  // Write to the data partition
  if ( 0 !=  fl_writeDataPage(0, my_page) ){
    printstrln( "Could not write the data partition" );
    exit(-1);
  }

  printstrln( "Data partition written!" );

  // Wipe the my_page data array
  for ( i = 0; i < 256; i++ )
    my_page[i] = 0x00;


  // Read from the data partition
  if ( 0 !=  fl_readDataPage(0, my_page) ){
    printstrln( "Could not read the data partition" );
    exit(-1);
  }

  // Return the contents of the data partition to the user
  printstr( "Data partition read! Data: " );
  printstrln( my_page );

  // Disconnect from the flash
  if ( 0 != fl_disconnect() ){
    printstrln( "Could not disconnect from FLASH" );
    exit(-1);
  }

  // Tell the user that it completed successfully
  printstrln( "FLASH tested successfully!" );
}

#endif
