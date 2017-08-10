# orderofpi
The Re-Order of Pi Project. It's gunna be HUUUUUGE.


## Order of operations (howtosetup):
Some undetailed instructions to kinda help you set it up.
### 1. Init
  1. Create folder for project, something like OrderOfPi_Proj
  2. Clone repo in dis folder
### 2. Database
  1. If you don't already, get MySQL
  2. `mysql < dbinit.sql` to set up our database
### 3. virtualenv and virtualenvwrapper
You will need to install virtualenvwrapper for this project. We will have some python dependencies for the project and it makes it super helpful when we have 3rd party packages.
  1. Download virtualenv (https://pypi.python.org/pypi/virtualenv)
  2. `pip install virtualenvwrapper` (https://virtualenvwrapper.readthedocs.io/en/latest/)
### 4. Creating a virtualenv for the project
To help with conflicts in project dependencies we'll create a virtualenv for the project. The command reference: 
  1. `mkvirtualenv -p python3 orderofpi` *NOTE: You will need python3 for this. Also the -p python3 command may vary with your OS*
  2. `workon orderofpi` this switches to your orderofpi env. Ensure that you have `(orderofpi)` at the very most left point of your command line
  3. While in your env: `pip install -r requirements.txt`
  4. `pip freeze` will show the project dependencies
### 5. Success!
Do your party dance, you made it! I think... Your django management commands will be listed with the use of `./manage.py`.
