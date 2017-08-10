/*
 * Brandon Harvey
 * V00784918
 * January 19, 2016
 * 
 * assign1.c: A simple shell displaying the use of fork and background process handling
 */

#include <stdio.h>
#include <stdlib.h>
#include <readline/readline.h>
#include <readline/history.h>
#include <unistd.h>
#include <sys/wait.h>
#include <sys/types.h>
#include <errno.h>
#include <string.h>
#include <signal.h>

// stop the requested currently running background job
void stop_background_processes(char ** args, int * background_pids, char ** background_status){
	int job_to_stop = atoi(args[2]);
	if(strcmp(background_status[job_to_stop], "S") == 0){
		printf("Error: Cannot stop a job which is already stopped\n");
	}else{ 
		if(kill(background_pids[job_to_stop], SIGSTOP) != 0){
			perror("suspend");
		}
		sprintf(background_status[job_to_stop], "%s", "S");
	}
}

// start the requested currently stopped background job
void start_background_processes(char ** args, int * background_pids, char ** background_status){
	int job_to_start = atoi(args[2]);
	if(strcmp(background_status[job_to_start], "R") == 0){
		printf("Error: Cannot start a job which is already started\n");
	}else{
		if(kill(background_pids[job_to_start], SIGCONT) != 0){
			perror("start");
		}
		sprintf(background_status[job_to_start], "%s", "R");
	}
}

// Print the list of currently running background jobs
void print_background_processes(int number_of_background_pids, char ** background_command, char ** background_status){
	int i = 0;
	for(i = 0; i < number_of_background_pids; i++){
		printf("%d[%s]: %s\n", i, background_status[i], background_command[i]);
	}
	printf("Total background jobs: %d\n", number_of_background_pids);
}

// Kill the user specified process
void kill_background_process(char ** args, int * background_pids){
	int job_to_kill = atoi(args[2]);
	if(kill(background_pids[job_to_kill], SIGTERM) == -1){
		perror("kill");
	}
}

/* Once a background process completes enter this function
	- Decrement the number of background jobs value
	- Remove the pid and the command of the completed background job  
*/
int background_complete(int completed_pid, int * background_pids, int number_of_background_pids, char ** background_command, char ** background_status){
	int i = 0;
	for(i = 0; i < number_of_background_pids; i++){
		// If we've found the process in the array
		if(completed_pid == background_pids[i]){
			printf("%d[%s]: %s	Done\n\n", i, background_status[i], background_command[i]);
			number_of_background_pids--;
			return number_of_background_pids;
		}
	}
	printf("Error occured during completion of a background process. Aborting\n");
	exit(-1);
}

// Execute the requested command in the background
int background_execute(char ** args, int * background_pids, int number_of_background_pids, char ** background_command, char ** background_status){
	pid_t child_pid = fork();
	if(child_pid == 0){
		execvp(args[0], args);
		perror("execvp");
		exit(-1);
	}else{
		// Add the currently executing background PID to the list
		background_pids[number_of_background_pids] = child_pid;
		
		// Allocate space to store the command within the background command storage array
		if((background_command[number_of_background_pids] = malloc((sizeof(args[2])+1 * sizeof(char)))) == NULL){
	perror("malloc");
	exit(-1);
}
		// Add the currently running command to the list
		sprintf(background_command[number_of_background_pids], "%s", args[2]);

		// Allocate space to store the background status
		if((background_status[number_of_background_pids] = malloc((1*sizeof(char)))) == NULL){
			perror("malloc");
			exit(-1);
		}

		// Add the status to the status array
		sprintf(background_status[number_of_background_pids], "%s", "R");
		
		// Increment the background job counter
		number_of_background_pids += 1;
		return number_of_background_pids;
	}
}

int basic_execute(char ** args){
	pid_t child_pid = fork();

	// If its the child, execute the process, else its the parent so wait
	if(child_pid == 0){
		execvp(args[0], args);
		perror("execvp");
		exit(-1);
	}else{
		int status;
		pid_t term_pid;
		term_pid = wait(&status);
		if(term_pid == -1){
			perror("wait");
			exit(-1);
		}
	}
	return 0;
}

int main( void ){	
	// Create the array, counter, and command array, tasked with tracking the background PIDs
	int *background_pids = malloc(5 * sizeof(int*));
	char **background_command = malloc(5 * sizeof(char*));
	char **background_status = malloc(5 * sizeof(char*));
	int number_of_background_pids = 0;

	// Variables for the waitpid call
	int status;
	int pid_returned;

	// Main variable declaration complete, enter main loop
	while(1){
		// Variable declaration
		char *cmd;
		char cwd[256];

		if(getcwd(cwd, sizeof(cwd)) == NULL){
			perror("getcwd()");
			exit(-1);
		}
		// Shell formatting
		strcat(cwd, "> ");

		// Read in the user input
		cmd = readline(cwd);
		
		// Notify the user that a background process has completed
		pid_returned = waitpid(-1, &status, WNOHANG);
		if(pid_returned != 0 && pid_returned != -1){
			number_of_background_pids = background_complete(pid_returned, background_pids, number_of_background_pids, background_command, background_status);
		}
		
		// Fill out the args to be later passed into execvp
		char **args = malloc(4 * sizeof(char*));
		args[0] = "/bin/bash";
		args[1] = "-c";
		args[2] = malloc((sizeof(cmd)+1 * sizeof(char)));
		sprintf(args[2], "%s", cmd);
		args[3] = NULL;
		
		if(strstr(args[2], "cd")){
			char *token;
			token = strtok(args[2], " ");
			while(token != NULL){
				if(strcmp(token, "cd") != 0){
					chdir(token);
				}
				token = strtok(NULL, " ");
			}	
		}else if(strcmp(args[2], "pwd") == 0){
			printf("%s", cwd);
		}else if(strncmp(args[2], "bglist", 6) == 0){
			print_background_processes(number_of_background_pids, background_command, background_status);
		}else if(strncmp(args[2], "bgkill", 6) == 0){
			args[2] += 7;
			int cmd_length = strlen(args[2]);
			if(cmd_length == 1){
				kill_background_process(args, background_pids);
			}
		}else if(strncmp(args[2], "bg", 2) == 0){
			args[2] += 3;
			int cmd_length = strlen(args[2]);
			if(cmd_length > 3){
				number_of_background_pids = background_execute(args, background_pids, number_of_background_pids, background_command, background_status);
			}
		}else if(strncmp(args[2], "start", 5) == 0){
			args[2] +=  6;
			start_background_processes(args, background_pids, background_status);
		}else if(strncmp(args[2], "stop", 4) == 0){
			args[2] += 5;
			stop_background_processes(args, background_pids, background_status);
		}else if(args[2] != NULL){
			basic_execute(args);
		}

		// free up allocated memory
		free(args);
		free(cmd);
	}
	
	// free up allocated memory
	free(background_pids);
	free(background_status);

	return 0;
}
