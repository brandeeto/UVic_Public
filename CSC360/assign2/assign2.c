/*
 * assign2.c
 *
 * Name: Brandon Harvey
 * Student Number: V00784918
 */

#include <unistd.h>
#include <stdio.h>
#include <stdlib.h> 
#include <pthread.h>
#include "train.h"
#include <semaphore.h>

/*
 * If you uncomment the following line, some debugging
 * output will be produced.
 *
 * Be sure to comment this line out again before you submit 
 */

/* #define DEBUG	1 */

void ArriveBridge (TrainInfo *train);
void CrossBridge (TrainInfo *train);
void LeaveBridge (TrainInfo *train);

// Synchronization declaration
pthread_mutex_t bridge_crossing = PTHREAD_MUTEX_INITIALIZER;
pthread_mutex_t bridge_arrival = PTHREAD_MUTEX_INITIALIZER;
pthread_cond_t cross_the_bridge = PTHREAD_COND_INITIALIZER;
sem_t first_train;

// Direction array declaration: 0 = East, 1 = West
int *west_trains;
int *east_trains;

int turn = -1;

int east_front = -1;
int east_rear = -1;
int west_front = -1;
int west_rear = -1;

int number_of_east_trains = 0;
int number_of_west_trains = 0;
int total_trains = 0;
int number_of_east_trains_through = 0;

/*
 * This function is started for each thread created by the
 * main thread.  Each thread is given a TrainInfo structure
 * that specifies information about the train the individual 
 * thread is supposed to simulate.
 */
void * Train ( void *arguments ){
	TrainInfo	*train = (TrainInfo *)arguments;

	/* Sleep to simulate different arrival times */
	usleep (train->length*SLEEP_MULTIPLE);

	pthread_mutex_lock(&bridge_arrival);
	ArriveBridge(train);
	pthread_mutex_unlock(&bridge_arrival);

	pthread_mutex_lock(&bridge_crossing);
	while(turn != train->trainId){
		pthread_cond_wait(&cross_the_bridge, &bridge_crossing);
	}
	CrossBridge(train);
	LeaveBridge(train);
 	pthread_mutex_unlock(&bridge_crossing);

	/* I decided that the paramter structure would be malloc'd 
	 * in the main thread, but the individual threads are responsible
	 * for freeing the memory.
	 *
	 * This way I didn't have to keep an array of parameter pointers
	 * in the main thread.
	 */
	free (train);
	return NULL;
}

/*
 * You will need to add code to this function to ensure that
 * the trains cross the bridge in the correct order.
 */
void ArriveBridge ( TrainInfo *train ){
	printf ("Train %2d arrives going %s\n", train->trainId, 
			(train->direction == DIRECTION_WEST ? "West" : "East"));
	
	if((train->direction == 0) || (train->direction == 2)){
		east_rear++;
		east_trains[east_rear] = train->trainId;
		if(east_front == -1){
			east_front++;
		}
		number_of_east_trains++;
	}else if(train->direction == 1){
		west_rear++;
		west_trains[west_rear] = train->trainId;
		if(west_front == -1){
			west_front++;
		}
		number_of_west_trains++;
	}
	sem_post(&first_train);
}

/*
 * Simulate crossing the bridge.  You shouldn't have to change this
 * function.
 */
void CrossBridge ( TrainInfo *train ){
	printf ("Train %2d is ON the bridge (%s)\n", train->trainId,
			(train->direction == DIRECTION_WEST ? "West" : "East"));
	fflush(stdout);

	/* 
	 * This sleep statement simulates the time it takes to 
	 * cross the bridge.  Longer trains take more time.
	 */
	usleep (train->length*SLEEP_MULTIPLE);

	printf ("Train %2d is OFF the bridge(%s)\n", train->trainId, 
			(train->direction == DIRECTION_WEST ? "West" : "East"));
	fflush(stdout);
}

/*
 * Add code here to make the bridge available to waiting
 * trains...
 */
void LeaveBridge ( TrainInfo *train ){
	// Parse the east array
	if((train->direction == 0) || (train->direction == 2)){
		// Adjust bounds
		east_front++;
		number_of_east_trains--;
		if(number_of_west_trains > 0){
			number_of_east_trains_through++;
		}
	}else if(train->direction == 1){
		// Adjust bounds
		west_front++;
		number_of_west_trains--;
		number_of_east_trains_through = 0;
	}	
	total_trains--;
}

int main ( int argc, char *argv[] ){
	// Array instantiation
	// Array table: 0 = East, 1 = West
	east_trains = malloc(500 * sizeof(int*));
	west_trains = malloc(500 * sizeof(int*));	

	sem_init(&first_train, 0, 0);
	int		trainCount = 0;
	char 		*filename = NULL;
	pthread_t	*tids;
	int		i;

		
	/* Parse the arguments */
	if ( argc < 2 )
	{
		printf ("Usage: part1 n {filename}\n\t\tn is number of trains\n");
		printf ("\t\tfilename is input file to use (optional)\n");
		exit(0);
	}
	
	if ( argc >= 2 )
	{
		trainCount = atoi(argv[1]);
		total_trains = trainCount;
	}
	if ( argc == 3 )
	{
		filename = argv[2];
	}	
	
	initTrain(filename);
	
	/*
	 * Since the number of trains to simulate is specified on the command
	 * line, we need to malloc space to store the thread ids of each train
	 * thread.
	 */
	tids = (pthread_t *) malloc(sizeof(pthread_t)*trainCount);
	
	/*
	 * Create all the train threads pass them the information about
	 * length and direction as a TrainInfo structure
	 */
	for (i=0;i<trainCount;i++)
	{
		TrainInfo *info = createTrain();
		
		printf ("Train %2d headed %s length is %d\n", info->trainId,
			(info->direction == DIRECTION_WEST ? "West" : "East"),
			info->length );

		if ( pthread_create (&tids[i],0, Train, (void *)info) != 0 )
		{
			printf ("Failed creation of Train.\n");
			exit(0);
		}
	}

	/*
	 * This code allows trains through depending on their arrival and priority
	 */
	sem_wait(&first_train);
	while(total_trains > 0){
		pthread_mutex_lock(&bridge_crossing);
		if(((number_of_east_trains > 0) && (number_of_east_trains_through <= 1)) || ((number_of_east_trains > 0) && (number_of_west_trains == 0))){
			//send an east train
			turn = east_trains[east_front];
		} else if(((number_of_west_trains > 0) && (number_of_east_trains_through > 1)) || ((number_of_west_trains > 0 ) && (number_of_east_trains == 0))){
			//send a west train
			turn = west_trains[west_front];
		}
		pthread_cond_broadcast(&cross_the_bridge);
		pthread_mutex_unlock(&bridge_crossing);
	}

	/*
	 * This code waits for all train threads to terminate
	 */
	for (i=0;i<trainCount;i++)
	{
		pthread_join (tids[i], NULL);
	}
	free(east_trains);
	free(west_trains);	
	free(tids);
	return 0;
}

