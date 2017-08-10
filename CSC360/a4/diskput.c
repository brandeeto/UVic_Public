/* Brandon Harvey - V00784918
 * CSC 360 Assignment 3, Part 4
 * diskput.c - Copies a file from the local system to the file system
 */

#include <stdio.h>
#include <stdlib.h>
#include <string.h>
#include <stdint.h>
#include <arpa/inet.h>
#include <math.h>
#include <time.h>

int main(int argv, char *argc[]){
	uint16_t block_size = 0;
	uint32_t root_starts = 0;
	uint32_t root_size = 0;
	uint32_t fat_block = 0;
	uint32_t selected_block = 0;
	uint32_t starting_block = 0;
	uint32_t file_size = 0;
	uint32_t fat_starts;
	uint32_t fat_size;
	uint32_t number_of_req_blocks;
	uint8_t status;
	char file_name[31];
	int dirs_read = 0;
	int offset = 8;
	uint32_t terminate = 0xFFFFFFFF;

	if(argc[1] == NULL || argc[2] == NULL){
		printf("Usage: ./diskput <img file> <file to put>\n");
		return 1;
	}

	// Locate and open the image file
	FILE *fp;
	fp = fopen(argc[1], "rb+");
	if(fp == NULL){
		printf("Couldn't open file specified:%s\n", argc[1]);
		return 1;
	}

	// Locate and open the local file
	FILE *local_file;
	local_file = fopen(argc[2], "rb+");
	if(local_file == NULL){
		printf("Couldn't open file specified:%s\n", argc[2]);
		return 1;
	}

	// Get the Block size
	fseek(fp, offset, SEEK_SET);
	fread(&block_size, 1, 2, fp);
	block_size = ntohs(block_size);
	offset += 6;

	// Get the block where the FAT starts
	fseek(fp, offset, SEEK_SET);
	fread(&fat_starts, 1, 4, fp);
	fat_starts = ntohl(fat_starts);
	offset += 4;

	// Get the FAT size
	fseek(fp, offset, SEEK_SET);
	fread(&fat_size, 1, 4, fp);
	fat_size = ntohl(fat_size);
	offset += 4;

	// Get the block where the root directory starts
	fseek(fp, offset, SEEK_SET);
	fread(&root_starts, 1, 4, fp);
	root_starts = ntohl(root_starts);
	offset += 4;

	// Get the root dir size
	fseek(fp, offset, SEEK_SET);
	fread(&root_size, 1, 4, fp);
	root_size = ntohl(root_size);
	offset += 4;

	// Find an available block in the FAT, take that as our starting block
	int fat_entry = 0;
	offset = fat_starts * block_size;
	while(fat_entry < fat_size * 128){
		fseek(fp, offset, SEEK_SET);
		fread(&fat_block, 1, 4, fp);
		fat_block = ntohl(fat_block);
		
		if(fat_block == 0x00000000){
			selected_block = fat_entry * block_size;
			starting_block = selected_block;
			fat_entry = (fat_entry*4) + (fat_starts * block_size);
			break;	
		}else{
			fat_entry++;
		}
		
		if(fat_entry >= fat_size * 128){
			printf("File System Full!\n");
			return 1;
		}
		offset += 4;
	}
	
	// Read the binary data from the file and write it to the available block
	char file_data[512];
	while(1){
		bzero(file_data, 512);
		file_size += fread(file_data, 1, 512, local_file);

		// Move the file pointer to our available block
		fseek(fp, selected_block, SEEK_SET);
		if(feof(local_file)){
			// Write the buffer to the available block and modify the current block as 0xFF in FAT
			fwrite(file_data, 1, 512, fp);	
			fseek(fp, fat_entry, SEEK_SET);
			terminate = htonl(terminate);
			fwrite(&terminate, 4, 1, fp);
			break;
		}else{
			fwrite(file_data, 1, 512, fp);

			int old_fat_entry = fat_entry;

			// Write the next block in our previously selected FAT entry
			fseek(fp, old_fat_entry, SEEK_SET);
			fat_entry = selected_block / block_size;
			fat_entry++;

			fat_entry = htonl(fat_entry);
			fwrite(&fat_entry, 4, 1, fp);
			fat_entry = ntohl(fat_entry);
			
			offset = fat_starts * block_size;
			fat_entry = 0;
			while(fat_entry < fat_size * 128){
				fseek(fp, offset, SEEK_SET);
				fread(&fat_block, 1, 4, fp);
				fat_block = ntohl(fat_block);

				if(fat_block == 0x00000000){
					selected_block = fat_entry * block_size;
					fat_entry = (fat_entry*4) + (fat_starts * block_size);	
					break;
				}else{
					fat_entry++;
				}
		
				if(fat_entry >= fat_size * 128){
					printf("File System Full!\n");
					return 1;
				}
				offset += 4;
			}
		}
	}

	// Finally, modify the directory entry with what we know
	offset = root_starts * block_size;
	// Continue reading the dir entries until we find an empty space
	while(dirs_read < root_size*8){
		// Read the directory entry availability
		fseek(fp, offset, SEEK_SET);
		fread(&status, 1, 1, fp);
		// We've found an available directory entry, use it
		if(status == 0){
			// Write the status
			status = 3;
			fseek(fp, offset, SEEK_SET);
			fwrite(&status, 1, 1, fp);
	
			// Write the starting block
			starting_block = starting_block / block_size;
			starting_block = htonl(starting_block);
			fwrite(&starting_block, 4, 1, fp);

			// Write the number of blocks
			number_of_req_blocks = file_size / block_size;
			if(file_size % 512 != 0){
				number_of_req_blocks++;
			}
			number_of_req_blocks = htonl(number_of_req_blocks);
			fwrite(&number_of_req_blocks, 4, 1, fp);

			// Write the file size
			file_size = htonl(file_size);
			fwrite(&file_size, 4, 1, fp);
		
			// Write the Creation time
			time_t rawtime;
			struct tm *current_time;
			time(&rawtime);
			current_time = localtime(&rawtime);

			// Write year
			uint16_t year = current_time->tm_year;
			year += 1900;
			year = htons(year);			
			fwrite(&year, 2, 1, fp);

			// Write month
			uint8_t month = current_time->tm_mon;
			month++;
			fwrite(&month, 1, 1, fp);

			// Write day
			uint8_t day = current_time->tm_mday;
			fwrite(&day, 1, 1, fp);

			// Write hour
			uint8_t hour = current_time->tm_hour;
			fwrite(&hour, 1, 1, fp);
	
			// Write minute
			uint8_t minute = current_time->tm_min;
			fwrite(&minute, 1, 1, fp);

			// Write second
			uint8_t second = current_time->tm_sec;
			fwrite(&second, 1, 1, fp);


			// Write the Modified time
			fwrite(&year, 2, 1, fp);
			fwrite(&month, 1, 1, fp);
			fwrite(&day, 1, 1, fp);
			fwrite(&hour, 1, 1, fp);
			fwrite(&minute, 1, 1, fp);
			fwrite(&second, 1, 1, fp);			

			bzero(file_name, 31);
			strcpy(file_name, argc[2]);
			fwrite(file_name, 31, 1, fp);

			break;
		}else{
			offset += 64;
		}

		dirs_read++;
		if(dirs_read >= root_size*8){
			printf("No more directory entries available!\n");
			return 1;
		}
	}
	
	fclose(local_file);
	fclose(fp);
	return 0;
}
