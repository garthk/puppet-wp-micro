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

## TODO

* Finish replicating Ewan's work (current step: "Run a blitz.io test to see how we’re doing")

## Installation

#### Sign up for EC2

* [Sign up for EC2]

* On the [Security Credentials] page, hit [Access Credentials] and the X.509 Certificates tab. Click Create a new Certificate.

* Click Download Private Key File. **This will be your only chance to do so.**

* Click Download  X.509 Certificate. 

* `mkdir ~/.ec2`

* Move the certificates. As a one-liner, it's:

     `find ~/Downloads -type f | egrep ".*/(cert|pk)-[A-Z0-9]{32}.pem" | xargs -I{} mv {} ~/.ec2/`

### Install EC2 API tools

* [Install Homebrew]. If you're not on a Mac, you can't do this. Find another way to install the EC2 API tools and skip a few steps.

* `brew install ec2-api-tools`

* `brew unlink ec2-api-tools` to remove 284 scripts from your `PATH` unless you need them

* Do the variables per [RS2008], but with an adjusted `EC2_HOME` that suits Homebrew.

        export EC2_PRIVATE_KEY=`ls $EC2_HOME/pk-*.pem`
        export EC2_CERT=`ls $EC2_HOME/cert-*.pem`
        export EC2_HOME=/usr/local/Cellar/ec2-api-tools/1.5.2.5/jars
        export JAVA_HOME=/System/Library/Frameworks/JavaVM.framework/Home/
        export PATH=$EC2_HOME/bin

  Note that the `EC2_PRIVATE_KEY` and `EC2_CERT` lines will cause commands to fail if you have more than one matching file. Tip: don't. 

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

* Still as `root`, install the module:

        cd /etc/puppet/modules
        git clone git://github.com/garthk/puppet-wp-micro.git
        ln -s puppet-wp-micro wp_micro

* Secure your clone by changing the shipped passwords and other keys:

        curl https://api.wordpress.org/secret-key/1.1/salt/ > templates/wp-config-keys.php.erb
        vim manifests/passwords.pp

* Finally, apply the configuration. Puppet will install and build everything else:

        puppet apply manifests/self.pp

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

