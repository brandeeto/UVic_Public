/*
 * Skeleton code provided for SENG 265, Fall 2013 (Assignment 4)
 *
 * Michael Zastre, University of Victoria.
 */

#include "schedproc.h"
#include <assert.h>
#include <ctype.h>
#include <getopt.h>
#include <stdio.h>
#include <stdlib.h>
#include <string.h>
#include <unistd.h>

#define MESSAGE "Your messages to appear here someplace."


int events_init(char *files, char *timezone)
{   
    assert(files);
    assert(timezone);

    printf("DEBUGGING: Entered 'events_init()'\n");
    return 0;
}


int get_events_of_day(int year, int month, int day, char ***events)
{
    char **temp_events;
    char *temp_event;

    assert(events != NULL);

    temp_events = (char **)malloc(sizeof(char *) * 3);
    if (temp_events == NULL) {
        fprintf(stderr, "Error allocating memory in get_events_of_day\n");
        exit(1);
    }

    temp_event = (char *)malloc((strlen(MESSAGE)+1) * sizeof(char));
    if (temp_event == NULL) {
        fprintf(stderr, "Error allocating memory in get_events_of_day\n");
        exit(1);
    }
    strncpy(temp_event, MESSAGE, strlen(MESSAGE)+1);
    temp_events[0] = temp_event;


    temp_event = (char *)malloc(sizeof(char)*40);
    if (temp_event == NULL) {
        fprintf(stderr, "Error allocating memory in get_events_of_day\n");
        exit(1);
    }
    sprintf(temp_event, "%d %d %d", year, month, day);
    temp_events[1] = temp_event;

    temp_events[2] = NULL;

    *events = temp_events; 
    return 2;
}


void dispose_events_of_day(char **events[])
{
    assert(events != NULL);

    char **temp_events;
    char *temp_event;

    for (temp_events = *events; *temp_events; temp_events++) {
        temp_event = *temp_events;
        free(temp_event);
    }

    free(*events);
}
