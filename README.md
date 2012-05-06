# Local Application Port System
Local Application Management system. This application just like MacPorts on Mac
OS X.
An application has some versioned. But we use various version case by case.
For example Ruby application is now moving from 1.8 to 1.9.
So we must build Ruby 1.8 and Ruby 1.9 environment.
And so, we use many many middle ware, memcached, redis, MySQL, Varnish...
localport make us build multiversion environment easyly.

## Install
Just easy. Just type,

    $ gem install localport

## How to use
There is some restrictions, following:

* When you install some application, you must specify one directory.
  This directory is called "application directory" on system.
  Like this,

        ~/apps

* And, you must specify execute directory.
  This directory is called "executional directory"
  Like this,

        ~/local/bin

Ok, Let's control Ruby-1.8.7.-p160 with localport.

1.  Build, and Install Ruby-1.8.7-p160 to "application directory".

        $ tar zxvf ruby-1.8.7-p160.tar.gz
        $ cd ruby-1.8.7-p160
        $ ./configure --prefix=$HOME/apps/ruby/1.8.7-p160

2.  Install that to "execution directory"

        $ localport install ~/apps/ruby/1.8.7-p160

    This command make symbolic links that are Ruby applications in

        ~/apps/ruby/1.8.7-p160/bin/*

3.  Then, Activate that.

        $ localport activate ruby-1.8.7-p160

    This command make installed symbolic ruby-1.8.7-p160 point symbolic link.

        $ ls -l ~/local/bin/ruby -> ~/local/bin/ruby-1.8.7-p160
        $ ls -l ~/local/bin/ruby-1.8.7-p160 -> ~/apps/ruby/1.8.7-p160/bin/ruby

4.  Deactivate that.
    If you want to execute another Ruby version with no specified version command, 'ruby'.

        $ locaport deactivate ruby-1.8.7-p160

    This command remove symbolic link 'local/bin/ruby'.

## Commands
This application provide some commands. Like MacPorts.

- install
- installed
- activate
- deactivate

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
