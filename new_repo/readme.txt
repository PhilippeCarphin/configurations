** NOTE: You might want to install git-completion and git-prompt before doing
this so that when you do run the new_repo script, in will take the files for
git-completion and git-prompt too.  You do this by running the git_scripts.sh
script from anywhere

To start tracking your configuration files to be able to share them across
computers easily, first, create a directory of your choice and download the two
scripts in there.

Then, from that directory, run the start_repo.sh script.  It will move your
config files from their location in the home directory to this location and
replace the home directory files with symbolic links.  Then it will do a
git itit.

You can create a repository on github (don't check the "initialise with a
readme") and then do the two commands that github says to do:
git remote add origin <a URL>
git push -u origin master

Now, when you arrive on a new system, you can clone this repo, and then run the
basic_install.sh script.  This will backup the original files on the system and
replace them with links to the files from the cloned repo.

For fancier stuff, like tracking vim plugins, and working with Vundle, have a
look at what the install.sh script does.  For these, I replace the original
files with links manually and add things to the install.sh script.
