Libflash Library


Introduction:

The libflash is an API which allows programs written in XC to read from and 
write to the SPI FLASH device during execution. 

 
Description:

The FLASH device on boards can be used to store both the XMOS processor code 
and user information.  

The libflash library provides functions for reading and writing data to the 
SPI flash during execution of the firmware. The SPI flash must be programmed 
as per the XMOS flash format in order to use the libflash library.  

The xflash tool is provided to allow code images to be loaded onto the SPI 
Flash during manufacture and development. The xflash tool natively supports 
a wide range of SPI flash devices. The list of devices can be found in the 
knowledge base article. 

https://www.xmos.com/support/knowledgebase/silicon/which-flash-devices-are-supported-xmos 

Devices that are not natively supported can be used by xflash by writing a 
SPI specification file for the device with characteristics such as page size, 
number of pages, etc. 

The SPI spec files for some unsupported devices can be downloaded from 
https://www.xcore.com/wiki/index.php/SPI_spec_files_for_use_with_xflash_and_flashlib


Further details of the libflash library, XMOS flash format and the xflash 
tool can be found in the Tools User Guide:
https://www.xmos.com/published/tools-user-guide 


A simple example is attached that shows how to read and write user data using 
libflash.

The example can use one of the 4 FLASH chips defined at the top of the file. 
It prints the information about the part used, erases the user data partition,
writes "Hello world!" to this partition and reads the data from it, printing 
the result to the user.



  
Required Tools:

Xmos Desktop Development Tools 11.2.2 or above.


Executing the Example Application (GUI):

To create the project:
* Create a new workspace.
* Select File -> New -> XC Project.
* In the XC project window give a name to the project and select the platform 
  on which the project would be run. Select empty project under the project 
  type table.
* Click on "Finish".
* Copy the main.xc file. Right click on the project folder under Project 
  Explorer and click paste.
     
To link the Flash library:
   * Right click on the project folder and click on "Properties".
   * Click and expand C/XC Build and click on "Settings".
   * In the Tool Settings tab click on the "Libraries" under Mapper/Linker.
   * Type "flash" (without quotes) in the "Libraries (-l)" text box.
   * Click Apply and Ok.
   
   
To build, click on the project folder in the Project Explorer window and 
click on build icon. 


Writing the Application Into Flash:

* In the Project Explorer window right click on the .xe file and click on 
  Run As -> Run Configurations.
* In the Run Configurations window, select Flash Programmer and click on 
  the "New launch Configuration" button.
* Select the Jtag adapter from the drop down list in the Main Tab.
* Specify the SPI spec filename and Boot partition size in the Xflash tab.
* Click run to flash the application into the flash.

Executing The Example Application (Command Line):

* Open the XMOS command prompt and change the directory to the location of the
  main.xc file.

* Type the following command

 xcc main.xc  -target=<boardname> -lflash -o example.xe
 
 This creates the executable binary file example.xe. 

Example:
For compiling and generating the code for XK-1 board the command would be
xcc main.xc –target=XK-1 –lflash –o example.xe
 
Writing the Application Into Flash
 
* Once the xe file is created type the following command to load the file into
  the target board.
 
 xflash --boot-partition-size <n> example.xe --spi-spec <flash_type>.spispec

Example:
For writing the application into a Ramtron FM25V10 device (not supported by 
xflash) and setting boot partition size as 139264 bytes.

xflash --boot-partition-size 139264  example.xe --spi-spec FM25V10.txt

Where FM25V10.txt is the spi spec file for the Ramtron FM25V10.txt.





