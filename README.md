# Embedded-ARM-Development-ECE371-372

This program takes a incoming information packet, checks the checksum, and transfers it if appropriate. 

It's basic operation is:
 * Compute the checksum of the first 4 bytes
 * Compare it to the 5th byte
    * If not equal
      * Return to mainline with error code 1
    * If equal
      * Copy the 48 byte data block into new buffer
      * Convert from Big-Endian to Little-Endian
      * Return to mainline with error code 0

