That-one-file-viewer
====================

A file viewer, written in Ruby using Sinatra, by that guy. It's intended for use with **[ShareX](http://getsharex.com/)** by [those guys](https://github.com/ShareX).

To automatically run the script after a system reboot, edit the user's crontab file (`crontab -e`) and add something like this:
````
@reboot ~/src/fileviewer/sharex_control.sh start
````
