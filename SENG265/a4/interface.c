/*
 * Code provided for SENG 265, Fall 2013 (Assignment 4)
 *
 * Quick-and-dirty ncurses-based interface for an interactive
 * calendar. The behavior when scrolling from month to month
 * may be somewhat non-standard, but shouldn't be confusing.
 * Calls routines located in schedproc.c.
 *
 * There is no need to modify the code in this file.
 *
 * Michael Zastre, University of Victoria.
 */

#include <assert.h>
#include <getopt.h>
#include <string.h>
#include <stdio.h>
#include <stdlib.h>
#include <curses.h>
#include <time.h>
#include "schedproc.h"

#define MAX_ROWS      6
#define MAX_DAY_SLOTS (MAX_ROWS * 7)
#define WINDOW_MONTH_WIDTH 21
#define WINDOW_MONTH_HEIGHT 6
#define WINDOW_EVENTS_WIDTH 79
#define WINDOW_EVENTS_HEIGHT 40

struct day_t {
    char ordinal[3];
    int  y, x;
};

static int days_in_month[] = {0, 31, 28, 31, 30, 31, 30, 31, 31, 30, 31, 30, 31};

static void advance_month(int *year, int *month)
{
    assert (year && month);
    (*month)++;
    if (*month > 12) {
        *month = 1;
        (*year)++;
    }
}


static void reverse_month(int *year, int *month)
{
    assert (year && month);
    (*month)--;
    if (*month < 1) {
        *month = 12;
        (*year)--;
    }
}


static void get_current_year_month(int *year, int *month)
{
    time_t current_time;
    struct tm *local_time;

    current_time = time(NULL);
    local_time = localtime(&current_time);

    *year = local_time->tm_year + 1900;
    *month = local_time->tm_mon + 1;

    return;
}


static void display_header(WINDOW *w, int year, int month)
{
    struct tm temp_time;
    time_t    full_time;
    char      header[100];
    int       header_l, i;

    assert(w);

    memset(&temp_time, 0, sizeof(struct tm));
    temp_time.tm_year = year - 1900;
    temp_time.tm_mon  = month - 1;
    temp_time.tm_mday = 1;
    full_time = mktime(&temp_time);
    strftime(header, 100, "%B %Y", localtime(&full_time));

    header_l = strlen(header);
    for (i = 0; i < (21 - header_l) / 2; i++) {
        mvwaddch(w, 0, i, ' ');
    }
    mvwprintw(w, 0, i, "%s", header);
    for (i = (21 - header_l)/2 + header_l; i < 21; i++) {
        mvwaddch(w, 0, i, ' ');
    }
    wrefresh(w);
}


static void display_month(WINDOW *w, int year, int month, struct day_t *slot, struct day_t **prev)
{
    struct tm temp_time;
    time_t    full_time;
    char      first_day_of_month[100];
    int       start_day;
    int       i, days;

    memset(&temp_time, 0, sizeof(struct tm));
    temp_time.tm_year = year - 1900;
    temp_time.tm_mon  = month - 1;
    temp_time.tm_mday = 1;
    full_time = mktime(&temp_time);
    strftime(first_day_of_month, 100, "%w", localtime(&full_time));
    start_day = atoi(first_day_of_month);

    for (i = 0; i < MAX_DAY_SLOTS; i++) {
        slot[i].ordinal[0] = '\0';
    }

    if (month != 2) {
        days = days_in_month[month];
    } else if (year % 400 == 0) {
        days = 29;
    } else if (year % 100 == 0) {
        days = 28;
    } else if (year % 4 == 0) {
        days = 29;
    } else {
        days = 28;
    }

    for (i = 0 ; i < days; i++) {
        sprintf(slot[i+start_day].ordinal, "%2d", i+1);
    }

    *prev = &slot[start_day];

    wattroff(w, A_REVERSE);
    wattroff(w, A_BOLD);
    for (i = 0; i < MAX_DAY_SLOTS; i++) {
        if (slot[i].ordinal[0]) {
            mvwprintw(w, i / 7, (i % 7) * 3, "%s", slot[i].ordinal);
        } else {
            mvwprintw(w, i / 7, (i % 7) * 3, "  ");
        }
        wrefresh(w);
        slot[i].y = i / 7;
        slot[i].x = (i % 7) * 3;
    }

    wrefresh(w);
}


static void display_events(WINDOW *w, int year, int month, char *day)
{
    int n_day, i;
    char **events;
    int num_events;

    assert(w);
    assert(day);

    wclear(w);
    wrefresh(w);

    if (*day == '\0') {
        return;
    }

    n_day = atoi(day);

    num_events = get_events_of_day(year, month, n_day, &events);

    for (i = 0; i < num_events; i++) {
        assert(events[i]);
        mvwprintw(w, i, 0, "%s", events[i]);
    }
    wrefresh(w);

    dispose_events_of_day(&events);
}


static void display_loop(int year, int month) 
{
    struct day_t slot[MAX_DAY_SLOTS];
    int i;
    int ch;
    int y, x;
    struct day_t *prev = NULL, *next = NULL;
    int display_new_month = 0;
    int highlight_last_day = 0;

    WINDOW *header_window;
    WINDOW *weekday_window;
    WINDOW *month_window;
    WINDOW *events_window;

    header_window = newwin (1, 50, 0, 5);
    display_header(header_window, year, month);

    weekday_window = newwin (1, 50, 2, 5);
    mvwprintw(weekday_window, 0, 0, "%s", "Su Mo Tu We Th Fr Sa");
    wrefresh(weekday_window);

    month_window = newwin(WINDOW_MONTH_HEIGHT, WINDOW_MONTH_WIDTH, 3, 5);

    wrefresh(month_window);
    display_month(month_window, year, month, slot, &prev);
    wrefresh(month_window);
    
    wattron(month_window, A_REVERSE);
    wattron(month_window, A_BOLD);
    mvwprintw(month_window, prev->y, prev->x, "%s", prev->ordinal);
    wmove(month_window, prev->y, prev->x);
    wattroff(month_window, A_REVERSE);
    wattroff(month_window, A_BOLD);
    wrefresh(month_window);

    events_window = newwin(WINDOW_EVENTS_HEIGHT, WINDOW_EVENTS_WIDTH, WINDOW_MONTH_HEIGHT + 4, 0);
    display_events(events_window, year, month, prev->ordinal);
    wrefresh(events_window);

    while ((ch = getch()) != 'X') {
        getyx(month_window, y, x);

        switch (ch) {
            case KEY_LEFT:
                x = x - 3; 
                break;
            case KEY_RIGHT:
                x = x + 3;
                break;
            case KEY_UP:
                y--;
                break;
            case KEY_DOWN:
                y++;
                break;
            case '>':
            case '+':
                display_new_month = 1;
                highlight_last_day = 0;
                y = WINDOW_MONTH_HEIGHT;
                break;
            case '<':
            case '-':
                display_new_month = 1;
                highlight_last_day = 1;
                y = -1;
                break;
            case 'q':
            case 'Q':
            case 'x':
            case 'X':
                return;
            default:
                break;
        }

        if (x < 0) {
            y--;
            x = 19;
        } else if (x > 19) {
            y++;
            x = 0;
        }

        if (y < 0) {
            y = WINDOW_MONTH_HEIGHT - 1;
            reverse_month(&year, &month);
            display_new_month = 1;
            highlight_last_day = 1;
            prev = NULL;
        } else if (y >= WINDOW_MONTH_HEIGHT) {
            y = 0;
            advance_month(&year, &month);
            display_new_month = 1;
            highlight_last_day = 0;
            prev = NULL;
        }

        for (i = 0; i < MAX_DAY_SLOTS; i++) {
            if (slot[i].y != y) {
                continue;
            }
            if (slot[i].x == x || slot[i].x+1 == x) {
                next = &slot[i];
                break;
            }
        }

        if (prev != NULL) {
            wattroff(month_window, A_REVERSE);
            wattroff(month_window, A_BOLD);
            mvwprintw(month_window, prev->y, prev->x, "%s", prev->ordinal);
        }

        if (next != NULL) {
            wattron(month_window, A_REVERSE);
            wattron(month_window, A_BOLD);
            mvwprintw(month_window, next->y, next->x, "%s", next->ordinal);
            wmove(month_window, next->y, next->x);
        }

        if (display_new_month) {
            display_header(header_window, year, month);
            wrefresh(header_window);
            display_month(month_window, year, month, slot, &next);
            wrefresh(month_window);

            if (highlight_last_day) {
                for (prev = next; prev->ordinal[0] != '\0'; prev++) {
                    next = prev;
                }
            }
    
            wattron(month_window, A_REVERSE);
            wattron(month_window, A_BOLD);
            mvwprintw(month_window, next->y, next->x, "%s", next->ordinal);
            wmove(month_window, next->y, next->x);
            wrefresh(month_window);

            display_new_month = 0;
        }

        display_events(events_window, year, month, next->ordinal);

        prev = next;
        next = NULL;

        wrefresh(month_window);
    }
}


int main(int argc, char *argv[])
{
    char *files = NULL;
    char *timezone = NULL;
    int  option_index = 0;
    int  index;
    int  year, month;

    struct option long_options[] = {
        {"files", required_argument, 0, 'f'},
        {"tz",    required_argument, 0, 't'},
        {0, 0, 0, 0}
    };    

    for(;;) {
        index = getopt_long(argc, argv, "f:t:", long_options, &option_index);

        if (index == -1) {
            break;
        }

        switch(index) {
            case 'f':
                files = strdup(optarg);
                break;
            case 't':
                timezone = strdup(optarg);
                break;
            default:
                break;
        }
    }

    if (files == NULL || timezone == NULL) {
        fprintf(stderr, "usage: %s --file=<ics files> --tz=<UTC offset>\n",
            argv[0]);
        exit(1);
    }

    events_init(files, timezone);

    initscr();
    clear();
    keypad(stdscr, TRUE);
    noecho();
    cbreak();
    refresh();

    get_current_year_month(&year, &month);
    display_loop(year, month);

    refresh();
    endwin();

    return 0;
}
