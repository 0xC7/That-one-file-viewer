That-one-file-viewer
====================

A file viewer, written in Ruby using Sinatra, by that guy. It's intended for use with **[ShareX](http://getsharex.com/)** by [those guys](https://github.com/ShareX).

#Installing That One File Viewer
#Table of Contents
1. [Set aliases](#set-aliases)
2. [Download the required tools](#download-the-required-tools)
	1. [Windows](#windows)
	2. [Linux](#linux)
3. [Configure nginx](#configure-nginx)
4. [Configure Linux users](#configure-access)
5. [clone the repo](#clone-the-repo)
6. [Install the requirements for the file viewer](#install-the-requirements-for-the-file-viewer)
7. [configure the file viewer](#configure-the-file-viewer)
8. [Running](#running)
9. [FTP Server](#ftp-server)
10. [Autorun](#autorun)


#Set aliases
````
#Use 'apt-get' for ubuntu.
alias aptcmd='aptitude'
#replace with your own username
tuser=$USER
programs="nano sudo nginx dos2unix ruby-devel build-essential libiconv-devel libxml2-devel tmux curl git make"
````

#Download the required tools
##Windows
Install Cygwin and the following packages:

* Devel/git (Unless you have another git binary installed)
* Editors/nano
* Libs/libiconv
* Net/curl
* Utils/ruby-rails
* Utils/tmux (alternatively, Utils/screen)
* Web/nginx
* Util/dos2unix

###Nokogiri Gem

The nokogiri requires to be compiled natively.
You will need the following packages:

* Devel/g++
* Devel/make
* Interpreters/ruby-devel
* Libs/libiconv-devel
* Libs/libxml2-devel
* Libs/libxslt-devel

Run this before executing "bundle install" below

````
bundle config build.nokogiri --use-system-libraries
gem install pkg-config -v "~> 1.1.7"`
````

##Linux
````
aptcmd install ${programs}
````
**Remember to install a command-line text editor if you don't like vi(m) or nano**
####Install the GPG key
````
gpg --keyserver hkp://keys.gnupg.net --recv-keys 409B6B1796C275462A1703113804BB82D39DC0E3
````
####Install RVM and ruby
`\curl -sSL https://get.rvm.io | bash -s stable --ruby`

#Configure nginx
`nano /etc/nginx/sites-available/sharex_server`

*If you modify nginx.conf directly, remember to remove the existing server block, or adapt your configuration for your environment*
````
server {
        listen 80;
        location / {
                proxy_pass http://localhost:4567/;
                proxy_set_header Host $host;
        }
        server_name example.com;
}
````
Remember to change example.com to the domain your image viewer will use.

Enable the new configuration

`ln -s /etc/nginx/sites-available/sharex_server /etc/nginx/sites-enabled/sharex_server`

**if for some reason the directory is missing, see [#17415606](http://stackoverflow.com/a/17415606/1570096) OR just edit `/etc/nginx/nginx.conf`, see `http` block.**

*For windows/nginx, you can edit it directly with your favorite editor using the following path: `"C:\cygwin\etc\nginx\nginx.conf"`

Now, restart nginx:

Linux:
`/etc/init.d/nginx restart`

Windows:
Windows is a little silly. It does not create the proper folders.
````
#You may need to run cygwin terminal as admin
mkdir /var/log/nginx
mkdir /var/lib/nginx/tmp -p
/usr/sbin/nginx.exe
````

#Configure access

---

*Linux-only, cygwin has no equivalent*

````
#add ruby user(s) to the 'rvm' group
adduser ${tuser} rvm`
#clean up after ourselves
unset tuser && unalias apt
#login as user
su login ${tuser}
````

---

####clone the repo

Once you are logged in as user:
````
cd ${HOME}
git clone --depth=1 https://github.com/0xC7/That-one-file-viewer.git src/fileviewer/
````
####Install the requirements for the file viewer
````
cd src/fileviewer
bundle install
````
####configure the file viewer
````
cp config/examples/example_basic_cfg.yml config/basic_cfg.yml
nano config/basic_cfg.yml
````

#Running
````
dos2unix sharex_control.sh
./sharex_control.sh start
````

#FTP server
You will need to set up your own FTP server on the machine and configure your secure access to it.

# Autorun
To automatically run the script after a system reboot, edit the user's crontab file (`crontab -e`) and add something like this:
````
@reboot ~/src/fileviewer/sharex_control.sh start
````
