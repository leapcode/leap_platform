@title = 'Development'
@summary = "Getting started with making changes to the LEAP platform"

Installing leap_cli
------------------------------------------------

### From gem, for a single user

Install the latest:

    gem install leap_cli --install-dir ~/leap
    export PATH=$PATH:~/leap/bin

Install a particular version:

    gem install leap_cli --version 1.8 --install-dir ~/leap
    export PATH=$PATH:~/leap/bin

### From gem, system wide

Install the latest:

    sudo gem install leap_cli

Install a particular version:

    sudo gem install leap_cli --version 1.8

### As a gem, built from source

    sudo apt-get install ruby ruby-dev rake
    git clone https://leap.se/git/leap_cli.git
    cd leap_cli
    git checkout develop
    rake build
    sudo rake install

### The "develop" branch from source, for a single user

    sudo apt-get install ruby ruby-dev rake
    git clone https://leap.se/git/leap_cli.git
    cd leap_cli
    git checkout develop

Then do one of the following to be able to run `leap` command:

    cd leap_cli
    export PATH=$PATH:`pwd`/bin
    alias leap="`pwd`/bin/leap"
    ln -s `pwd`/bin/leap ~/bin/leap

In practice, of course, you would put aliases or PATH modifications in a shell startup file.

You can also clone from https://github.com/leap/leap_cli

Running different leap_cli versions
---------------------------------------------

### If installed as a gem

With rubygems, you can always specify the gem version as the first argument to any executable installed by rubygems. For example:

    sudo gem install leap_cli --version 1.7.2
    sudo gem install leap_cli --version 1.8
    leap _1.7.2_ --version
    => leap 1.7.2, ruby 2.1.2
    leap _1.8_ --version
    => leap 1.8, ruby 2.1.2

### If running from source

Alternately, if you are running from source, you can alias different commands:

    git clone https://leap.se/git/leap_cli.git
    cd leap_cli
    git checkout develop
    alias leap_develop="`pwd`/bin/leap`

