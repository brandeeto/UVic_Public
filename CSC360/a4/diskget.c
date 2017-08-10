/* Brandon Harvey - V00784918
 * CSC 360 Assignment 3, Part 3
 * diskget.c - Copies a file from the file system into the cwd
 */

#include <stdio.h>
#include <stdlib.h>
#include <string.h>
#include <stdint.h>
#include <arpa/inet.h>
#include <unistd.h>

int main(int argv, char *argc[]){
	uint16_t block_size = 0;
	uint32_t root_starts = 0;
	uint32_t root_size = 0;
	uint32_t starting_block = 0;
	uint32_t file_size = 0;
	char file_name[32];
	int dirs_read = 0;

	if(argc[1] == NULL || argc[2] == NULL){
		printf("Usage: ./diskget <img file> <file to pull>\n");
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
	
	uint32_t offset = root_starts * block_size;

	// Continue reading the dir entries until we find the file
	while(dirs_read < root_size*8){
		offset += 1;
		// Read the Starting Block 
		fseek(fp, offset, SEEK_SET);
		fread(&starting_block, 1, 4, fp);
		starting_block = ntohl(starting_block);
		offset += 8;
	
		// Read the File Size
		fseek(fp, offset, SEEK_SET);
		fread(&file_size, 1, 4, fp);
		file_size = ntohl(file_size);
		offset += 18;

		// Read the filename
		fseek(fp, offset, SEEK_SET);
		fread(file_name, 1, 31, fp);
		offset += 37;
		
		dirs_read++;

		if(strcmp(file_name, argc[2]) == 0){
			break;
		}else if(dirs_read == root_size*8){
			printf("File not found\n");
			return 1;
		}
	
	}

	char block_data[512];

	// Create the file to write to
	FILE *fw;
	fw = fopen(file_name, "wb");

	while(starting_block != 0xFFFFFFFF){
		offset = block_size * starting_block;
		// Read the data from the data block
		fseek(fp, offset, SEEK_SET);
		if(file_size < 512){
			fread(block_data, 1, file_size, fp);
			fwrite(block_data, 1, file_size, fw);
		}else{
			fread(block_data, 1, 512, fp);
			fwrite(block_data, 1, 512, fw);
			file_size -= 512;
		}

		// Read the FAT
		offset = starting_block * 4 + block_size;
		fseek(fp, offset, SEEK_SET);
		fread(&starting_block, 1, 4, fp);
		starting_block = ntohl(starting_block);
 	}
	
	fclose(fp);
	fclose(fw);
	return 0;
}
