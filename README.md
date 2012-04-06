## Disclaimer

This is a work in progress. All help appreciated. 

## Goal

To install an EC2 micro server configured to serve [10 Million hits per day with WordPress on a $15 virtual server][EL2012] but without quite as much manual work.

* Sign up for EC2
* Install EC2 API tools
* Create your Micro server
* Log in and update
* Install Puppet and Git
* Configure your puppet

For more detail, see Installation below. (Sadly, GitHub's Markdown lacks internal anchors.)

## Testing in Vagrant

* Install [Vagrant](http://vagrantup.com)

* Edit your `/etc/hosts` file (`%WINDOWS%\system32\drivers\etc\hosts` on Windows) to include:

    `192.168.31.43   fortythree.local fortythree`

* Build the virtual machine:

    `make vm` -- on Linux or Mac OS X   
    `vagrant up` -- on Windows, Linux, or Mac OS X

* Browse to `http://fortythree.local/`
* Configure and play with WordPress

## TODO

* Finish replicating Ewan's work (current step: "Run a blitz.io test to see how we’re doing")
* Fix the security again. 
* Fix the CSS when not on the admin page when `port` is set. 

## Installation

### Sign up for EC2

* [Sign up for EC2]

* On the [Security Credentials] page, hit [Access Credentials] and the X.509 Certificates tab. Click Create a new Certificate.

* Click Download Private Key File. **This will be your only chance to do so.**

* Click Download  X.509 Certificate. 

* `mkdir ~/.ec2`

* Move the certificates. As a one-liner, it's:

     `find ~/Downloads -type f | egrep ".*/(cert|pk)-[A-Z0-9]{32}.pem" | xargs -I{} mv {} ~/.ec2/`

### Install EC2 API tools

#### Windows:

* Good luck!

#### Linux:

* Try these instructions on [Installing the Amazon EC2 Command Line Tools] from Bottomless, Inc.

[Installing the Amazon EC2 Command Line Tools]: http://blog.bottomlessinc.com/2010/12/installing-the-amazon-ec2-command-line-tools-to-launch-persistent-instances/

#### Mac:

* [Install Homebrew].

* `brew install ec2-api-tools`

* `brew unlink ec2-api-tools` to remove 284 scripts from your `PATH` unless you need them

* Do the variables per [RS2008], but with an adjusted `EC2_HOME` that suits Homebrew.

        export EC2_PRIVATE_KEY=`ls $EC2_HOME/pk-*.pem`
        export EC2_CERT=`ls $EC2_HOME/cert-*.pem`
        export EC2_HOME=/usr/local/Cellar/ec2-api-tools/1.5.2.5/jars
        export JAVA_HOME=/System/Library/Frameworks/JavaVM.framework/Home/
        export PATH=$EC2_HOME/bin

    **WARNING:** the `EC2_PRIVATE_KEY` and `EC2_CERT` lines will cause commands to fail if you have more than one matching file. If so, pick one key pair and set the variables to their file names.

### Create your Micro server

* look for a 32-bit t1.micro [oneirc image] in your preferred region, and note its AMI, e.g. `ami-ac05889c` for `us-west-2`. 

* Create a key pair for the region and set its permissions so that `ssh` will trust it: 

        REGION=us-west-2
        ec2-add-keypair --region $REGION $REGION | tee $REGION.pem
        chmod 600 $REGION.pem

* Run the instance:

        AMI=ami-ac05889c
        ec2-run-instances $AMI --instance-type t1.micro --region $REGION --key $REGION

* If you're sick of specifying `--region` all the time, set `EC2_URL` to `https://` plus the region's API address:

        export EC2_URL=https://$(ec2-describe-regions | grep $REGION | cut -f 3)
        
    I'll assume you've done so from now on. 

* Use `ec2-describe-instances` to watch your instance boot. The output format is diabolical: a run of tab-separated values. Look for `running`, which for me turned up in column 6. Then note the group (probably `default`, perhaps in column 30) and hostname (`ec2-$DASHED_IP-$REGION.compute.amazonaws.com`, perhaps in column 4).

    Assuming your columns match:
  
        export $HOSTNAME=`ec2-describe-instances|grep $AMI|grep $INSTANCE|cut -f 4`

* Enable SSH and HTTP traffic to its group, which by default will be conveniently named `default`:

        ec2-authorize default -p 22
        ec2-authorize default -p 80

    The default Ubuntu instance lacks anything on port 80, so that second line is safe — especially as we're about to…
  
### Log in and update

* SSH in and apply updates right away. First, connect:

        ssh -i $REGION.pem ubuntu@$HOSTNAME
        
    Then, on the host: 
  
        sudo -i
        set -o emacs # else go insane
        apt-get update
        apt-get dist-upgrade

### Install Puppet and Git

* Still as `root`, install [Puppet], which is like CSS but which describes server configuration rather than element rendering:

        apt-get install puppet git-core
        
### Configure your puppet

* Still as `root`, install the module and change its cookie keys:

        cd /etc/puppet/modules
        git clone git://github.com/garthk/puppet-wp-micro.git wp_micro
        curl https://api.wordpress.org/secret-key/1.1/salt/ > wp_micro/templates/wp-config-keys.php.erb

* Write your own `self.pp` file based on `tests/vagrant.pp`.

* `puppet apply self.pp`

[EL2012]: http://www.ewanleith.com/blog/900/10-million-hits-a-day-with-wordpress-using-a-15-server
[Install Homebrew]: https://github.com/mxcl/homebrew/wiki/installation
[AWS console]: https://console.aws.amazon.com/
[Sign up for EC2]: https://aws-portal.amazon.com/gp/aws/developer/registration/index.html
[Security Credentials]: https://aws-portal.amazon.com/gp/aws/securityCredentials
[Access Credentials]: https://aws-portal.amazon.com/gp/aws/securityCredentials#access_credentials
[oneirc image]: http://cloud-images.ubuntu.com/releases/oneiric/release/
[RS2008]: http://www.robertsosinski.com/2008/01/26/starting-amazon-ec2-with-mac-os-x/
[Puppet]: http://projects.puppetlabs.com/projects/1/wiki

References:

* Robert Sosinski's [Starting Amazon EC2 with Mac OS X][RS2008]
* Ewan Leith's [10 Million hits per day with WordPress on a $15 virtual server][EL2012]
