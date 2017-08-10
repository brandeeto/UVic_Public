/*
 * train.c
 */

#include <string.h> 
#include <unistd.h>
#include <stdlib.h>
#include <stdio.h>
#include "train.h"
 
/* A global to assign IDs to our trains */ 
int idNumber = 0;
int *length_of_train;
char **direction_of_train;
int train_number = 0;

/* If this value is set to 1, trains lengths
 * etc will be generated randomly.
 * 
 * If it is set to 0, the lengths etc will be
 * input from a file.
 */
int doRandom = 0;

/* The file to input train data from */
FILE *inputFile;

/* You can assume that no more than 80 characters
 * will be on any line in the input file
 */
#define MAXLINE		80

void	initTrain ( char *filename )
{
	length_of_train = malloc(200 * sizeof(int*));
	direction_of_train = malloc(200 * sizeof(char*));
	doRandom = 0;
	
	/* If no filename is specified, generate randomly */
	if ( !filename ){
		doRandom = 1;
		srandom(getpid());
	}
	// Read the file
	else{
		FILE *fp;
		char *line = NULL;
		size_t len = 0;
		ssize_t read;

		fp = fopen(filename, "r");
		if(fp == NULL){
			exit(EXIT_FAILURE);
		}
		
		while((read = getline(&line, &len, fp)) != -1){
			direction_of_train[train_number] = malloc((sizeof(char)+1 * sizeof(char)));

			if(direction_of_train[train_number] == NULL){
				printf("ERROR");
			}			

			strncpy(direction_of_train[train_number], line, 1);

			line += 1;
			length_of_train[train_number] = atoi(line);
			train_number++;
		}
	}
}
 
/*
 * Allocate a new train structure with a new trainId, trainIds are
 * assigned consecutively, starting at 0
 *
 * Either randomly create the train structures or read them from a file
 *
 * This function malloc's space for the TrainInfo structure.  
 * The caller is responsible for freeing it.
 */
TrainInfo *createTrain ( void ){
	TrainInfo *info = (TrainInfo *)malloc(sizeof(TrainInfo));

	/* I'm assigning the random values here in case
	 * there is a problem with the input file.  Then
	 * at least we know all the fields are initialized.
	 */	 
	info->trainId = idNumber;
	info->arrival = 0;
	info->direction = (random() % 2 + 1);
	info->length = (random() % MAX_LENGTH) + MIN_LENGTH;

	if (!doRandom){
		if((strcmp(direction_of_train[idNumber], "e") == 0) || (strcmp(direction_of_train[idNumber], "E") == 0)){
			info->direction = 0;
}		else{
			info->direction = 1;
		}
		info->length = length_of_train[idNumber];
	}
	idNumber++;
	return info;
}
