/*
 * Skeleton code provided for SENG 265, Fall 2013 (Assignment 4)
 *
 * Michael Zastre, University of Victoria.
 */


#ifndef _SCHEDPROC_H_
#define _SCHEDPROC_H_

int events_init(char *files, char *timezone);
int get_events_of_day(int year, int month, int day, char **event[]);
void dispose_events_of_day(char **event[]);

#endif
