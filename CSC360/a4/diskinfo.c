/* Brandon Harvey - V00784918
 * CSC 360 Assignment 3, Part 1
 * diskinfo.c - Reads the superblock
 */

#include <stdio.h>
#include <stdlib.h>
#include <string.h>
#include <stdint.h>
#include <arpa/inet.h>

int main(int argv, char *argc[]){
	uint16_t block_size;
	uint32_t file_system_size;
	uint32_t fat_starts;
	uint32_t fat_size;
	uint32_t root_starts;
	uint32_t root_size;
	int offset = 8;

	if(argc[1] == NULL){
		printf("Usage: ./diskinfo <img file>\n");
		return 1;
	}

	FILE *fp;
	fp = fopen(argc[1], "rb+");
	
	if(fp == NULL){
		printf("Couldn't open file specified:%s\n", argc[1]);
		return 1;
	}

	// Print the Super Block information
	printf("Super Block Information:\n");

	// Get the Block size
	fseek(fp, offset, SEEK_SET);
	fread(&block_size, 1, 2, fp);
	block_size = ntohs(block_size);
	printf("Block size:  %d\n", block_size);
	offset += 2;

	// Get the FS Size (Block count)
	fseek(fp, offset, SEEK_SET);
	fread(&file_system_size, 1, 4, fp);
	file_system_size = ntohl(file_system_size);
	printf("Block count:  %d\n", file_system_size);
	offset += 4;

	// Get the block where the FAT starts
	fseek(fp, offset, SEEK_SET);
	fread(&fat_starts, 1, 4, fp);
	fat_starts = ntohl(fat_starts);
	printf("FAT starts:  %d\n", fat_starts);
	offset += 4;

	// Get the FAT size
	fseek(fp, offset, SEEK_SET);
	fread(&fat_size, 1, 4, fp);
	fat_size = ntohl(fat_size);
	printf("FAT blocks:  %d\n", fat_size);
	offset += 4;

	// Get the block where the root directory starts
	fseek(fp, offset, SEEK_SET);
	fread(&root_starts, 1, 4, fp);
	root_starts = ntohl(root_starts);
	printf("Root directory start:  %d\n", root_starts);
	offset += 4;

	// Get the root dir size
	fseek(fp, offset, SEEK_SET);
	fread(&root_size, 1, 4, fp);
	root_size = ntohl(root_size);
	printf("Root directory blocks:  %d\n", root_size);
	offset += 4;

	// Print the FAT information
	printf("\nFAT information:\n");


	int available = 0;
	int reserved = 0;
	int allocated = 0;
	int fat_entry = 0;
	offset = fat_starts * block_size;
	uint32_t fat_entry_value;
	while(fat_entry < fat_size * 128){
		fseek(fp, offset, SEEK_SET);
		fread(&fat_entry_value, 1, 4, fp);
		fat_entry_value = ntohl(fat_entry_value);
		offset += 4;
		fat_entry++;

		if(fat_entry_value == 0x00000000){
			available++;
		}else if(fat_entry_value == 0x00000001){
			reserved++;
		}else{
			allocated++;
		}
	}

	// Print the number of free blocks
	printf("Free Blocks: %d\n", available);

	// Print the Reserved Block count
	printf("Reserved Blocks: %d\n", reserved);

	// Print the allocated blocks
	printf("Allocated Blocks: %d\n", allocated);
	return 0;
}
