#include <stdio.h>
#include <stdlib.h>
#include <stdint.h>
#include <flashlib.h>

#define FILE_BUF_SIZE 4096
char file_buf[FILE_BUF_SIZE];

// Callback for supplying page data
unsigned int supplyData(void* userPtr,
		                unsigned int numBytes,
		                unsigned char* dstBuf)
{
  return( fread( dstBuf, 1, numBytes, (FILE*)userPtr ) );
}

// Flash connection function
extern int flash_connect();

void flash_erase() {
  fl_eraseAll();
}

// Factory image programming
#pragma stackfunction 2048
int flash_addFactoryImage(unsigned address,
					      unsigned imageSize,
                          unsigned (*getData)(void*,unsigned,unsigned char*),
                          void* userPtr)
{
  if (imageSize == 0)
    return 0;

  unsigned pageSize = fl_getPageSize();

  /* Write data. */
  unsigned char buf[256];
  int finalPage = 0;

  while (!finalPage) {
    unsigned pageBytes = pageSize;
    if (pageBytes >= imageSize) {
      pageBytes = imageSize;
      finalPage = 1;
    }
    unsigned pageRead = 0;

    /* Get a page of data. */
    do {
      unsigned read = (*getData)(userPtr, pageBytes - pageRead, &buf[pageRead]);
      if (read == 0)
        return 1;
      else if (read > (pageBytes - pageRead))
        return 1;
      pageRead += read;
    } while (pageBytes - pageRead);

    /* Write the page. */
    printf("Writing page at [0x%x]\n", address);
    if (fl_writePage(address, buf) != 0)
      return 1;
    imageSize -= pageBytes;
    address += pageSize;
  }
  fl_endWriteImage();
  return 0;
}

int main()
{
  FILE* inFile = NULL;
  int imageSize;

  inFile = fopen("upgrade.bin", "rb");
  if(inFile == NULL) {
    fprintf(stderr,"Error: Failed to open input data file.\n");
    exit(1);
  }
  setvbuf(inFile, file_buf, _IOFBF, FILE_BUF_SIZE);

  if(0 != fseek(inFile, 0, SEEK_END)) {
    fprintf(stderr,"Error: Failed to discover input data file size.\n");
    exit(1);
  }
  imageSize = (int)ftell(inFile);
  if(0 != fseek(inFile, 0, SEEK_SET)) {
    fprintf(stderr,"Error: Failed to input file pointer.\n");
    exit(1);
  }

  if( 0 == flash_connect() ) {
    fprintf(stderr,"Error: failed to recognise attached flash device.\n");
    fclose(inFile);
    exit(1);
  }

  fl_BootImageInfo bii;
  if(0 != fl_getFirstBootImage(&bii)) {
    printf("%s\n", "No factory image found, erase not required");
  } else {
	printf("%s\n", "Factory image found");
	printf("%s\n", "Erasing flash");
	flash_erase();
  }

  // Disable flash protection
  fl_setProtection(0);

  if(0 != flash_addFactoryImage( 0, imageSize, &supplyData, (void*)inFile)) {
    fprintf(stderr,"Error: failed to add new boot image.\n");
    fclose(inFile);
    fl_disconnect();
    exit(1);
  }

  printf("Factory boot image added.\n");

  // Verify programming step

  if(0 != fseek(inFile, 0, SEEK_SET)) {
    fprintf(stderr,"Error: Failed to input file pointer.\n");
    exit(1);
  }

  if(0 != fl_getFirstBootImage(&bii)) {
    fprintf(stderr,"Error: failed to locate factory boot image.\n");
    fclose(inFile);
    fl_disconnect();
    exit(1);
  }

  unsigned int imageAddr = 0;

  unsigned char checkBuf[256];
  unsigned char fileBuf[256];
  unsigned int checkPos = 0;
  int gotError = 0;
  while(checkPos < imageSize) {
    int thisSize = ((imageSize-checkPos)>256) ? 256 : (imageSize-checkPos);
    fl_readPage(checkPos+imageAddr, checkBuf);
    fread(fileBuf, 1, 256, inFile);
    int i;
    for(i=0; i<thisSize; i++) {
      if(checkBuf[i] != fileBuf[i]) {
        printf("Error: verification mismatch at offset 0x%08x (file:0x%02x, flash:0x%02x).\n",checkPos+i,fileBuf[i],checkBuf[i]);
        gotError = 1;
      }
    }
    checkPos += 256;
    if(gotError) {
      exit(1);
    }
  }

  fclose(inFile);
  inFile = NULL;

  fl_setProtection(1);
  fl_disconnect();

  printf("Verification complete.\n");

  return( 0 );
}

