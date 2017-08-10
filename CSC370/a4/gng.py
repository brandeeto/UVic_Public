#!/usr/bin/python


import psycopg2
import sys

# CHANGED DATA TYPE OF 'on_website' IN 'campaign' TABLE FROM BOOLEAN TO TEXT DUE TO CURSOR.EXECUTE(INSERT) ISSUES
# CHANGE DATA TYPE OF SUPPORTER IN PEOPLE TABLE FROM BOOLEAN TO TEXT DUE TO SAME ISSUES
# CAN STILL ADD VOLUNTEERS TO NON EXISTANT CAMPAIGNS (DOESNT REFERENCE CAMPAIGN OR PEOPLE TALBE) FIX LATER???
# CHANGED COLUMN NAME IN FUNDING FROM 'from_people' TO 'from_volunteer' TO MAKE MORE SENSE
# CHANGED COLUMN NAME IN RUNNING FROM 'worker_name' TO 'volunteer_name' TO MAKE MORE SENSE
# CREATED A TABLE CALLED 'history' TO MANAGE MEMBERSHIP HISTORY REQUIRMENT
# ADDED 'annotation' ATTRIBUTE TO 'campaign','event' AND 'people' TABLES

# left to do:
#	bar graph of cash flow (displaying cost attribute of expenses and funding in a bar graph) HOW?!?!
#	fix the inserts dynamically based on the where clause within the annotation section of membership history

def main():
	dbconn = psycopg2.connect(host='studentdb.csc.uvic.ca', user='c370_s17', password='tfJ4BBpE')
	cursor = dbconn.cursor()

        symbolToWord    = ["zero","one","two","three","four","five","six","seven","eight","nine","ten"]

	print("\n"+"--Main Menu--"+"\n"+"Press 1 to select an available query"+"\n"+"Press 2 to create a new campaign, assign volunteers to campaigns, add volunteers to the organization or schedule events"+"\n"+"Press 3 to view accounting information"+"\n"+"Press 4 to view membership history"+"\n"+"Press 5 to delete a campaign or a volunteer"+"\n"+"Press 6 to quit")

	var = input() #read users menu selection
	
	if(var == 1):
		queryMenu(cursor, symbolToWord)
	elif(var == 2):
		creationMenu(cursor, dbconn)
	elif(var == 3):
		accountingMenu(cursor)
	elif(var == 4):
		membershipMenu(cursor, dbconn)
	elif(var == 5):
		deletionMenu(cursor, dbconn)
	elif(var == 6):
		print("Press 1 to confirm quit"+"\n"+"Press 2 to return to main menu")
	        var = input()

	        if(var == 1):
	                print("Quitting Program")
	                cursor.close()
	                dbconn.close()

	        elif(var == 2):
	                main()

	        else:
	                print("Invalid option, returning to main menu")
	                main()

def queryMenu(cursor, symbolToWord):
		
	column_names = []
	data_rows = []
	
	#--- Prompt user and pull user selection ---
	print("\n"+"--Query Menu--"+"\n"+"-Select A Query-")
	print("Press 1 to display the names and salaries of the volunteers working on campaign 'Crude is Cruel'"+"\n"+"Press 2 to display the names of the volunteers who are working on campaign 'Start Today, Save Tomorrow' and who are being payed less than 1000"+"\n"+"Press 3 to display the names of all donors who are also organization supporters"+"\n"+"Press 4 to display the names and salaries of volunteers who are being payed the most"+"\n"+"Press 5 to display the names and costs of all events costing less than 10,000"+"\n"+"Press 6 to display the names of all events taking place in Victoria"+"\n"+"Press 7 to display the organizations funding from least to greatest"+"\n"+"Press 8 to display the names and cost of events within the campaign 'Crude is Cruel'"+"\n"+"Press 9 to display the names and starting dates of all events which start on the same day as a campaign"+"\n"+"Press 10 to display the names and salaries of all volunteers who contribute rent, and how much do they contribute to that rent"+"\n"+"Press 11 to return to main menu")
	query_selected = input()

	if(query_selected == 11):
			main()
	else:
		print("\n"+"Query Information Returned:")
		#--- Pull information from database ---
		cursor.execute(""" select * from  %s """ % symbolToWord[query_selected])	
		column_names = [desc[0] for desc in cursor.description]
		for row in cursor:
			data_rows.append(row)

		#--- Displaying Information To User ---
		print("\n"+" %s" % column_names)		
		index = 0
		for row in data_rows:
			print(data_rows[index])
			index  = index + 1

		queryMenu(cursor, symbolToWord)


def creationMenu(cursor, dbconn):

		print("\n"+"--Creation Menu--"+"\n"+"Press 1 to create a new campaign"+"\n"+"Press 2 to assign volunteers to campaigns"+"\n"+"Press 3 to create a new event within a campaign"+"\n"+"Press 4 to add a volunteer to the organization"+"\n"+"Press 5 to return to main menu")
		var = input()

		if(var == 1):
			print("--Campaign Creation--")
			print("Insert campaign information as follows: 'campaign name' (plain text), 'start date' (12/30/2014), phase (integer), cost (integer), fundraising (if any, integer), 'duration' (plain text), 'is it on the website?' ('true' or 'false'), 'annotation' (plain text)")
			user_input = input()
			print("Inserting Data")
			cursor.execute(" insert into campaign values (%s, %s, %s, %s, %s, %s, %s, %s) ", (user_input[0], user_input[1], user_input[2], user_input[3], user_input[4], user_input[5], user_input[6],  user_input[7]))
			print("Inserted")
			dbconn.commit()	
			creationMenu(cursor, dbconn)
				
		elif(var == 2):
			print("--Assign Volunteers--")
			print("Insert volunteer assignment as follows: 'campaign their assigned to' (plain text), 'volunteer name' (plain text)")
			user_input = input()
			print(user_input)
			print("Inserting Data")
			cursor.execute(" insert into running values (%s, %s) ", (user_input[0], user_input[1]))
			cursor.execute(" insert into history values (%s, %s) ", (user_input[0], user_input[1]))
			print("Inserted")
			dbconn.commit()
			creationMenu(cursor, dbconn)

		elif(var == 3):
			print("--Event Creation--")
			print("Insert event information as follows: 'name' (plain text), 'start date' (12/30/2014), 'duration' (plain text), cost (integer), 'location' (plain text), fundraising (if any, integer), 'part of which campaign' (must be part of an existing campaign, plain text), 'annotation' (plain text)")
			user_input = input()
			print("Inserting Data")
			cursor.execute(" insert into event values (%s, %s, %s, %s, %s, %s, %s, %s) ", (user_input[0], user_input[1], user_input[2], user_input[3], user_input[4], user_input[5], user_input[6], user_input[7]))
			print("Inserted")
			dbconn.commit()
			creationMenu(cursor, dbconn)
	
		elif(var == 4):
			print("--Add a Volunteer--")
			print("Insert volunteer information as follows: 'volunteer name' (plain text), tier (integer), 'are they a supporter' ('true' or 'false'), salary (integer), 'annotation' (plain text)")
			user_input = input()
			print("Inserting Data")
			cursor.execute(" insert into people values (%s, %s, %s, %s, %s) ", (user_input[0], user_input[1], user_input[2], user_input[3], user_input[4]))
			print("Inserted")
			dbconn.commit()
			creationMenu(cursor, dbconn)
		
		elif(var == 5):
			main()
		else:
			print("Invalid option, returning to main menu")
			main()

		

def accountingMenu(cursor):

		column_names = []
		data_rows = []

		print("\n"+"--Accounting Information Menu--")
		print("Press 1 to view the organizations expenses"+"\n"+"Press 2 to view the organizations funding"+"\n"+"Press 3 to return to main menu")
		var = input()
		
		if(var == 1):
			print("--Displaying Expenses--")			

	               #--- Pull information from database ---
	                cursor.execute(""" select * from  expenses """)
	       	        column_names = [desc[0] for desc in cursor.description]
	               	for row in cursor:
	                    	data_rows.append(row)

#to pull out a tuple element from a list, this pulls out the cost from the expenses table: print[x[2] for x in data_rows]
	
	                #--- Displaying Information To User ---
	                print("\n"+" %s" % column_names)
	                index = 0
	                for row in data_rows:
				print(data_rows[index])
				index = index + 1

			accountingMenu(cursor)
			
		elif(var == 2):
			print("--Displaying Funding--")
		
                       #--- Pull information from database ---
                        cursor.execute(""" select * from  funding """)
                        column_names = [desc[0] for desc in cursor.description]
                        for row in cursor:
                                data_rows.append(row)

#to pull out a tuple element from a list, this pulls out the cost from the expenses table: print[x[2] for x in data_rows]

                        #--- Displaying Information To User ---
                        print("\n"+" %s" % column_names)
                        index = 0
                        for row in data_rows:
                                print(data_rows[index])
                                index  = index + 1
			
			accountingMenu(cursor)

		elif(var == 3):
			main()

		else:
			print("Invalid option, returning to main menu")
			main()

def membershipMenu(cursor, dbconn):
	
		column_name = []
		data_rows = []

		print("\n"+"--Membership History Menu--")
		print("Press 1 to view membership history information"+"\n"+"Press 2 to add an annotation to a campaign"+"\n"+"Press 3 to add an annotation to a volunteer"+"\n"+"Press 4 to add an annotation to a volunteer and campaign within membership history"+"\n"+"Press 5 to return to main menu")
		var = input()
		
		if(var == 1):
			print("--Viewing Membership History--")
			cursor.execute(" select * from history ")
			column_names = [desc[0] for desc in cursor.description]
                        for row in cursor:
                                data_rows.append(row)

#to pull out a tuple element from a list, this pulls out the cost from the expenses table: print[x[2] for x in data_rows]

                        #--- Displaying Information To User ---
                        print("\n"+" %s" % column_names)
                        index = 0
                        for row in data_rows:
                                print(data_rows[index])
                                index  = index + 1

			membershipMenu(cursor, dbconn)

		elif(var == 2):
			print("--Add An Annotation To A Campaign--")
			print("insert annotation information as follows: 'name of campaign' (plain text), 'annotation' (plain text)")
			user_input = input()
# not working		cursor.execute(" insert into campaign (annotation) values (%s) where name = %s" % user_input[0], (user_input[1]))
			dbconn.commit()
			print("data inserted successfully")

			membershipMenu(cursor, dbconn)

		elif(var == 3):
			print("--Add An Annotation To A Volunteer--")
			print("insert annotation information as follows: 'name of volunteer' (plain text), 'annotation' (plain text)")
			user_input = input()
# not working		cursor.execute(" insert into people (annotation) values (%s) where name= '(%s)'", (user_input[1], user_input[0]))
			dbconn.commit()
			print("data inserted successfully")

			membershipMenu(cursor, dbconn)

		elif(var == 4):
			print("--Add An Annotation To Both A Campaign And Volunteer--")
			print("insert annotation information as follows:'name of campaign' (plain text), 'name of volunteer' (plain text), 'annotation' (plain text)")
			user_input = input()
# not working			cursor.execute(" insert into history (annotation) values (%s) where campaign_name= '(%s)' and volunteer_name= '(%s)'", (user_input[2], user_input[0], user_input[1]))
			dbconn.commit()
			print("data inserted successfully")

			membershipMenu(cursor, dbconn)

		elif(var == 5):
			main()		
			
		else:
			print("Invalid option, returning to main menu")
			main()

def deletionMenu(cursor, dbconn):

		print("--Deletion Menu--")
		print("Press 1 to delete a campaign by name"+"\n"+"Press 2 to delete a volunteer by name"+"\n"+"Press 3 to return to main menu")
		var = input()
		
		if(var == 1):		
			print("--Delete A Campaign--")
			print("Type the name of the campaign you would like to delete as follows: 'campaign name' (plain text)")
			user_input = input()
			cursor.execute(" delete from funding where from_campaign = '%s'" % user_input)
			cursor.execute(" delete from expenses where paid_to_campaign = '%s'" % user_input)
			cursor.execute(" delete from event where part_of = '%s'" % user_input)
			cursor.execute(" delete from running where campaign_name = '%s'" % user_input)
			cursor.execute(" delete from campaign where name = '%s'" % user_input)
			dbconn.commit()
			deletionMenu(cursor, dbconn)

		elif(var == 2):
			print("--Delete A Volunteer--")
			print("Type the name of the volunteer you would like to delete as follows: 'volunteer name' (plain text)")
			user_input = input()
			cursor.execute(" delete from expenses where paid_to_volunteer = '%s'" % user_input)
            cursor.execute(" delete from funding where from_volunteer = '%s'" % user_input)
            cursor.execute(" delete from running where volunteer_name = '%s'" % user_input)
			cursor.execute(" delete from people where name = '%s'" % user_input)
			dbconn.commit()
			deletionMenu(cursor, dbconn)			

		elif(var == 3):
			main()
		else:
			print("Invalid option, returning to main menu")
			main()

if __name__ == "__main__": main()
