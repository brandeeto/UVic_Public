Each of the parameter below produces output which is seen in the
test file.  When evaluating your A#4 submission, we'll look at the
date selected in the program and compare that with what is expected
for that date in the test file.

For example, if test 21 is used during evaluation, then a date from
the range of 1/1/2013 to 31/12/2013 will be selected along with a
timezone setting of -8.  The output that appears from the program
for a date on the calendar must match what appears in that date
in test21.txt.

--start=11/10/2013 --end=12/10/2013 --tz=-8 --file=deborah_developer.ics : test01.txt
--start=5/11/2013 --end=11/11/2013 --tz=-8 --file=deborah_developer.ics : test02.txt
--start=30/10/2013 --end=30/10/2013 --tz=-8 --file=deborah_developer.ics : test03.txt
--start=01/01/2013 --end=31/12/2013 --tz=-8 --file=deborah_developer.ics : test04.txt
--start=01/01/2013 --end=31/12/2013 --tz=-8 --file=deborah_developer.ics : test05.txt
--start=31/10/2013 --end=31/10/2013 --tz=-8 --file=deborah_developer.ics : test06.txt
--start=1/11/2013 --end=30/11/2013 --tz=-8 --file=deborah_developer.ics : test07.txt
--start=1/12/2013 --end=31/12/2013 --tz=-8 --file=deborah_developer.ics : test08.txt
--start=8/9/2013 --end=3/12/2013 --tz=-8 --file=deborah_developer.ics : test09.txt
--start=28/9/2013 --end=25/9/2013 --tz=-8 --file=deborah_developer.ics : test10.txt
--start=11/10/2013 --end=12/10/2013 --tz=-8 --file=nhl_canada.ics : test11.txt
--start=5/11/2013 --end=11/11/2013 --tz=-8 --file=nhl_canada.ics : test12.txt
--start=30/10/2013 --end=30/10/2013 --tz=-8 --file=nhl_canada.ics : test13.txt
--start=01/01/2013 --end=31/12/2013 --tz=-8 --file=nhl_canada.ics : test14.txt
--start=01/01/2013 --end=31/12/2013 --tz=-8 --file=nhl_canada.ics : test15.txt
--start=31/10/2013 --end=31/10/2013 --tz=-8 --file=nhl_canada.ics : test16.txt
--start=1/11/2013 --end=30/11/2013 --tz=-8 --file=nhl_canada.ics : test17.txt
--start=1/12/2013 --end=31/12/2013 --tz=-8 --file=nhl_canada.ics : test18.txt
--start=8/9/2013 --end=3/4/2014 --tz=-8 --file=nhl_canada.ics : test19.txt
--start=28/9/2013 --end=25/9/2013 --tz=-8 --file=nhl_canada.ics : test20.txt
--start=1/1/2013 --end=31/12/2013 --tz=-8 --file=one.ics,many.ics : test21.txt
--start=1/1/2013 --end=31/12/2013 --tz=-4 --file=one.ics,many.ics : test22.txt
--start=1/1/2013 --end=31/12/2013 --tz=-3 --file=one.ics,many.ics : test23.txt
--start=1/11/2013 --end=12/12/2013 --tz=-5 --file=nhl_canada.ics : test24.txt
--start=1/11/2013 --end=12/12/2013 --tz=1 --file=nhl_canada.ics : test25.txt
--start=1/9/2013 --end=15/12/2013 --tz=-5 --file=deborah_developer.ics : test26.txt
--start=1/9/2013 --end=15/12/2013 --tz=1 --file=deborah_developer.ics : test27.txt
--start=1/1/2013 --end=31/12/2013 --tz=-8 --file=deborah_developer.ics,one.ics : test28.txt
--start=1/1/2013 --end=31/12/2013 --tz=1 --file=deborah_developer.ics,one.ics,nhl_canada.ics : test29.txt
--start=1/1/2013 --end=31/12/2013 --tz=-5 --file=deborah_developer.ics,one.ics,nhl_canada.ics : test30.txt
