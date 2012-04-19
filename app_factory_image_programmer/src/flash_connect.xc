#include <xs1.h>
#include <platform.h>
#include <flashlib.h>

fl_PortHolderStruct spi = { PORT_SPI_MISO, PORT_SPI_SS, PORT_SPI_CLK, PORT_SPI_MOSI, XS1_CLKBLK_2};

int flash_connect() {
  int res;
  res = fl_connect(spi);
  if( res != 0 ) {
    return(0);
  }
  return 1;
}



