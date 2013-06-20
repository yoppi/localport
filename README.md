# Local Application Package Management System
localport is an application package management system. This application just like MacPorts on Mac
OS X.
An application have some versions. But we use various version case by case.
For example Ruby application is now moving from 1.9 to 2.0.
So we must build Ruby 1.9 and Ruby 2.0 environment.
And so, we use many many middle ware, memcached, Redis, MySQL, Varnish...
localport make us build multiversion environment easyly.

## Install
Just easy. Just type,

    $ gem install localport

## How to use
There is some restrictions, following:

* When you install some application, you must specify one directory.
  This directory is called "application directory" on system.
  Like this,

        ~/local

* And, you must specify execute directory.
  This directory is called "executional directory"
  Like this,

        ~/local/bin

Ok, Let's control Ruby-2.0.0.-p195 with localport.

1.  Build, and Install Ruby-2.0.0-p195 to "application directory".

        $ tar zxvf ruby-2.0.0-p195.tar.gz
        $ cd ruby-2.0.0-p195
        $ mkdir -p ~/local/ruby/2.0.0-p195
        $ ./configure --prefix=$HOME/local/ruby/2.0.0-p195 --enable-shared
        $ make install

2.  Install that to "execution directory"

        $ localport install ~/local/ruby/2.0.0-p195

    This command make symbolic links that are Ruby applications in

        ~/local/ruby/2.0.0-p195/bin/*

3.  Then, Activate that.

        $ localport activate ruby-2.0.0-p195

    This command make installed symbolic ruby-2.0.0-p195 point symbolic link.

        $ ls -l ~/local/bin/ruby -> ~/local/bin/ruby-2.0.0-p195
        $ ls -l ~/local/bin/ruby-2.0.0-p195 -> ~/apps/ruby/2.0.0-p195/bin/ruby

4.  Deactivate that.
    If you want to execute another Ruby version with no specified version command, 'ruby'.

        $ locaport deactivate ruby-2.0.0-p195

    This command remove symbolic link 'local/bin/ruby'.

## Commands
This application provide some commands. Like MacPorts.

- install
- installed
- activate
- deactivate
- update

### install

To specify an application path.

    $ localport install {app}

### installed

To list up installed applications.

    $ localport installed [app]

### activate

To activate installed application.

    $ localport activate {app}

### deactivate

To deactivate installed application.
Delete internal symbolic link.

    $ localport deactivate {app}

### update
Rubygems will install with gem command after localport controlled. Some ${RUBY}/bin/{exec} will be installed but didn't create symbolic link.
So, update command create symbolic link for these execution files.

    $ localport update {app}
