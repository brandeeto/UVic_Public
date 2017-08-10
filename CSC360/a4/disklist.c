/* Brandon Harvey - V00784918
 * CSC 360 Assignment 3, Part 2
 * disklist.c - Reads the FAT
 */

#include <stdio.h>
#include <stdlib.h>
#include <string.h>
#include <stdint.h>
#include <arpa/inet.h>

int main(int argv, char *argc[]){
	uint16_t block_size = 0;
	uint32_t root_starts = 0;
	uint32_t root_size = 0;
	uint8_t status = 0;
	uint32_t starting_block = 0;
	uint32_t number_of_blocks = 0;
	uint32_t file_size = 0;
	uint16_t year = 0;
	uint16_t month = 0;
	uint16_t day = 0;
	uint16_t hour = 0;
	uint16_t minute = 0;
	uint16_t second = 0;
	char file_name[32];
	char status_char;
	int dirs_read = 0;

	if(argc[1] == NULL){
		printf("Usage: ./disklist <img file>\n");
		return 1;
	}

	FILE *fp;
	fp = fopen(argc[1], "rb+");
	
	if(fp == NULL){
		printf("Couldn't open file specified:%s\n", argc[1]);
		return 1;
	}

	fseek(fp, 8, SEEK_SET);
	fread(&block_size, 1, 2, fp);
	block_size = ntohs(block_size);

	// Get the block where the root directory starts
	fseek(fp, 22, SEEK_SET);
	fread(&root_starts, 1, 4, fp);
	root_starts = ntohl(root_starts);

	// Get the root dir size
	fseek(fp, 26, SEEK_SET);
	fread(&root_size, 1, 4, fp);
	root_size = ntohl(root_size);
	
	int offset = root_starts * block_size;

	// Continue reading the dir entries
	while(dirs_read < root_size*8){
		// Read the Status
		fseek(fp, offset, SEEK_SET);
		fread(&status, 1, 1, fp);
		offset += 1;		

		// Read the Starting Block 
		fseek(fp, offset, SEEK_SET);
		fread(&starting_block, 1, 4, fp);
		starting_block = ntohl(starting_block);
		offset += 4;

		// Read the Number of Blocks
		fseek(fp, offset, SEEK_SET);
		fread(&number_of_blocks, 1, 4, fp);
		number_of_blocks = ntohl(number_of_blocks);
		offset += 4;
		
		// Read the File Size
		fseek(fp, offset, SEEK_SET);
		fread(&file_size, 1, 4, fp);
		file_size = ntohl(file_size);
		offset += 11;

		// Read the Modify Year
		fseek(fp, offset, SEEK_SET);
		fread(&year, 1, 2, fp);
		year = ntohs(year);
		offset += 2;
		
		// Read the Modify Month
		fseek(fp, offset, SEEK_SET);
		fread(&month, 1, 1, fp);
		offset += 1;
		
		// Read the Modify Day
		fseek(fp, offset, SEEK_SET);
		fread(&day, 1, 1, fp);
		offset += 1;
	
		// Read the Modify Hour
		fseek(fp, offset, SEEK_SET);
		fread(&hour, 1, 1, fp);
		offset += 1;
	
		// Read the Modify Minute
		fseek(fp, offset, SEEK_SET);
		fread(&minute, 1, 1, fp);
		offset += 1;
	
		// Read the Modify Second 
		fseek(fp, offset, SEEK_SET);
		fread(&second, 1, 1, fp);
		offset += 1;

		// Read the filename
		fseek(fp, offset, SEEK_SET);
		fread(file_name, 1, 31, fp);
		offset += 37;

		// Determine what type of file it is and print
		if(status == 0x03){
			status_char = 'F';
		}else if(status == 0x05){
			status_char = 'D';
		}else{
			goto increment;
		}
		
		printf("%c%11d%31s %d/%02d/%02d %02d:%02d:%02d\n", status_char, file_size, file_name, year, month, day, hour, minute, second);
		
		increment: dirs_read++;
	}

	return 0;
}
