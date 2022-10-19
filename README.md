![](images/mirovoy_logo.png)

# **Launching A Flurdy Email Server on AWS with CloudFormation**

### Version 0.99.6
(ref [Flurdy 14th edition][flurdy edition], [Jon Jerome])

---

This reference architecture provides a set of YAML templates for
deploying primary and backup [Flurdy email servers][flurdy] (as
extended by [Jon Jerome] for Dovecot support) on AWS using [AWS
CloudFormation].

- [Introduction](#introduction)
  - [Description](#description)
  - [Rationale](#rationale)
  - [TL;DR](#tldr--launch-the-stack)
  - [Overview](#overview)
- [Usage](#usage)
  - General Instructions
    - [Populate CloudFormation Helpers](#populate-cloudformation-helpers)
    - [Create an AWS SSL Certificate](#create-an-aws-ssl-certificate)
    - [Run The Templates](#run-the-templates)
    - [Populate Your Database](#populate-your-database)
    - [Migration](#migrating-an-existing-flurdyjeremy-server)
  - Migrating an Existing Flurdy/Jeremy Server
- [Testing](#testing)
- [Version History](#version-history)
- [Parameters](#parameters)
- [Variances from Flurdy](#variances-from-flurdy)
  - [Significant Variances](#significant-variances)
  - [Minor Variances](#minor-variances)
    - [Encrypted Passwords](#encrypted-passwords)
    - [Firewall](#firewall)
    - [SASL](#sasl)
    - [Alternative Admin User Shell](#alternative-admin-user-shell)
    - [Linux Distribution](#linux-distribution)
    - [UID and GID](#gid-and-uid)
    - [Dovecot SSL](#dovecot-ssl)
    - [Dovecot User Query](#dovecot-user-query)
    - [SSL Certificates](#ssl-certificates)
    - [Session Cache](#session-cache)
    - [Amavis and SpamAssassin](#amavis-and-spamassassin)
    - [ClamAV](#clamav)
    - [Postgrey](#postgrey)
    - [RoundCube](#roundcube)
    - [SPF Verification](#extend---spf-verificaiton)
    - [DKIM](#extend---dkim)
- [To Do](#to-do)
- [Notes](#notes)
- [Useful Links](#useful-links)

# Introduction

## Description

This reference architecture provides a set of YAML templates for
deploying primary and backup [Flurdy email servers][flurdy] (as
extended by [Jon Jerome] for Dovecot support) on AWS using [AWS
CloudFormation]. The servers run [Amazon Linux 2], [Postfix],
[Dovecot] IMAP, [Amazon RDS MySQL], [Amavis] (amavisd with
SpamAssassin Perl module), [ClamAV], SASL, TLS (with [LetsEncrypt]
certs), and [Postgrey] with optional additional servers deployed
for [Roundcube], and [phpMyAdmin], behind [Elastic Load Balancing].

The dedicated Flurdy fan will already notice several, minor variations
from the default Flurdy deployment (the use of Amazon Linux 2 instead
of Ubuntu (Flurdy) or Debian (Jon Jerome); moving MySQL off the
server and onto RDS; the upgrade to Amavis which no longer runs
spamd; and the migration of Roundcube and phpMyAdmin to standalone
servers). These and other variations are discussed in [Variances
from Flurdy](#variances-from-flurdy).

**NB**: This is pre-release (pre-beta even) software. It works for
me, but that's about all I can say. Please try it, break it, and
report any problems (or, better, submit patches).

## Rationale

I've been using Ivar Abrahamsen's [excellent Flurdy guide][flurdy]
for setting up my personal email servers for ... I don't know how
long. Maybe nine years. Maybe longer. If this is the first time
you're setting up an email server (or at least, the first time in
a long time), I _highly_ recommend you go read his guide. However,
even with his guide, email is a giant PITA.

Web servers are easy. DNS is (relatively) easy. But every time I
go to touch something on an email server (never mind install a new
one from scratch), it takes _days_ for me to figure it out and get
things working. Enter CloudFormation. Now, with near-enough the
click of a button, I can have a fully-functional testing environment
set up where I can poke around with whatever changes I want to make,
without disrupting my production servers.  Then I can do something
like a blue-green swap, and _voilà_.

Plus, this was a good excuse to learn CloudFormation.

Plus, this was an opportunity to give back to the community. I've
been a user of open-source projects for decades, but I haven't
really contributed anything since I moved to Europe in 2011. To
wit, this is my first project on GitHub, so if I'm doing something
wrong, don't hesitate to let me know. And hopefully others find
these templates useful, and hopefully you contribute back patches
to make them better (see [To Do](#to-do)).

_**[Chris Richardson]**_

## TL;DR — Launch the Stack

To launch the entire stack and deploy a Flurdy primary (and,
optionally, backup) email server on AWS, copy the directory structure
and files from mirovoy-cf-helpers to a private S3 bucket. click on
one of the **Launch Stack** links below and enter the necessary
parameters. In about 20 minutes, you should have everything up and
running, and you can go update your DNS entries.

*Caveat emptor*, you should not do this unless you're familiar both
with the Flurdy email server setup, and [AWS CloudFormation].

*NB*: You must have a [Route53] Hosted Zone for the domain in which the
mail servers will be put.

*NB*: If you enable phpMyAdmin or Roundcube support, you *must*
create a certificate in [AWS Certificate Manager]. The certificate
must include the relevant DNS names.

| AWS Region Code | Name | Launch |
| --- | --- | --- 
| us-east-1 |US East (N. Virginia)| [![cloudformation-launch-stack](images/launch.png)](https://console.aws.amazon.com/cloudformation/home?region=us-east-1#/stacks/new?stackName=FlurdyMail&templateURL=https://mirovoy-public.s3.eu-central-1.amazonaws.com/mirovoy-refarch/infrastructure/latest/aws-mirovoy-ref-arch-master.yaml) |
| us-east-2 |US East (Ohio)| [![cloudformation-launch-stack](images/launch.png)](https://console.aws.amazon.com/cloudformation/home?region=us-east-2#/stacks/new?stackName=FlurdyMail&templateURL=https://mirovoy-public.s3.eu-central-1.amazonaws.com/mirovoy-refarch/infrastructure/latest/aws-mirovoy-ref-arch-master.yaml) |
| us-west-1 |US West (N. California)| [![cloudformation-launch-stack](images/launch.png)](https://console.aws.amazon.com/cloudformation/home?region=us-west-1#/stacks/new?stackName=FlurdyMail&templateURL=https://mirovoy-public.s3.eu-central-1.amazonaws.com/mirovoy-refarch/infrastructure/latest/aws-mirovoy-ref-arch-master.yaml) |
| us-west-2 |US West (Oregon)| [![cloudformation-launch-stack](images/launch.png)](https://console.aws.amazon.com/cloudformation/home?region=us-west-2#/stacks/new?stackName=FlurdyMail&templateURL=https://mirovoy-public.s3.eu-central-1.amazonaws.com/mirovoy-refarch/infrastructure/latest/aws-mirovoy-ref-arch-master.yaml) |
| ap-east-1 |Asia Pacific (Hong Kong)| [![cloudformation-launch-stack](images/launch.png)](https://console.aws.amazon.com/cloudformation/home?region=ap-east-1#/stacks/new?stackName=FlurdyMail&templateURL=https://mirovoy-public.s3.eu-central-1.amazonaws.com/mirovoy-refarch/infrastructure/latest/aws-mirovoy-ref-arch-master.yaml) |
| ap-south-1 |Asia Pacific (Mumbai)| [![cloudformation-launch-stack](images/launch.png)](https://console.aws.amazon.com/cloudformation/home?region=ap-south-1#/stacks/new?stackName=FlurdyMail&templateURL=https://mirovoy-public.s3.eu-central-1.amazonaws.com/mirovoy-refarch/infrastructure/latest/aws-mirovoy-ref-arch-master.yaml) |
| ap-northeast-2 |Asia Pacific (Seoul)| [![cloudformation-launch-stack](images/launch.png)](https://console.aws.amazon.com/cloudformation/home?region=ap-northeast-2#/stacks/new?stackName=FlurdyMail&templateURL=https://mirovoy-public.s3.eu-central-1.amazonaws.com/mirovoy-refarch/infrastructure/latest/aws-mirovoy-ref-arch-master.yaml) |
| ap-southeast-1 |Asia Pacific (Singapore)| [![cloudformation-launch-stack](images/launch.png)](https://console.aws.amazon.com/cloudformation/home?region=ap-southeast-1#/stacks/new?stackName=FlurdyMail&templateURL=https://mirovoy-public.s3.eu-central-1.amazonaws.com/mirovoy-refarch/infrastructure/latest/aws-mirovoy-ref-arch-master.yaml) |
| ap-southeast-2 |Asia Pacific (Sydney)| [![cloudformation-launch-stack](images/launch.png)](https://console.aws.amazon.com/cloudformation/home?region=ap-southeast-2#/stacks/new?stackName=FlurdyMail&templateURL=https://mirovoy-public.s3.eu-central-1.amazonaws.com/mirovoy-refarch/infrastructure/latest/aws-mirovoy-ref-arch-master.yaml) |
| ap-northeast-1 |Asia Pacific (Tokyo)| [![cloudformation-launch-stack](images/launch.png)](https://console.aws.amazon.com/cloudformation/home?region=ap-northeast-1#/stacks/new?stackName=FlurdyMail&templateURL=https://mirovoy-public.s3.eu-central-1.amazonaws.com/mirovoy-refarch/infrastructure/latest/aws-mirovoy-ref-arch-master.yaml) |
| ca-central-1 |Canada (Central)| [![cloudformation-launch-stack](images/launch.png)](https://console.aws.amazon.com/cloudformation/home?region=ca-central-1#/stacks/new?stackName=FlurdyMail&templateURL=https://mirovoy-public.s3.eu-central-1.amazonaws.com/mirovoy-refarch/infrastructure/latest/aws-mirovoy-ref-arch-master.yaml) |
| eu-central-1 |Europe (Frankfurt)| [![cloudformation-launch-stack](images/launch.png)](https://console.aws.amazon.com/cloudformation/home?region=eu-central-1#/stacks/new?stackName=FlurdyMail&templateURL=https://mirovoy-public.s3.eu-central-1.amazonaws.com/mirovoy-refarch/infrastructure/latest/aws-mirovoy-ref-arch-master.yaml) |
| eu-west-1 |Europe (Ireland)| [![cloudformation-launch-stack](images/launch.png)](https://console.aws.amazon.com/cloudformation/home?region=eu-west-1#/stacks/new?stackName=FlurdyMail&templateURL=https://mirovoy-public.s3.eu-central-1.amazonaws.com/mirovoy-refarch/infrastructure/latest/aws-mirovoy-ref-arch-master.yaml) |
| eu-west-2 |Europe (London)| [![cloudformation-launch-stack](images/launch.png)](https://console.aws.amazon.com/cloudformation/home?region=eu-west-2#/stacks/new?stackName=FlurdyMail&templateURL=https://mirovoy-public.s3.eu-central-1.amazonaws.com/mirovoy-refarch/infrastructure/latest/aws-mirovoy-ref-arch-master.yaml) |
| eu-west-3 |Europe (Paris)| [![cloudformation-launch-stack](images/launch.png)](https://console.aws.amazon.com/cloudformation/home?region=eu-west-3#/stacks/new?stackName=FlurdyMail&templateURL=https://mirovoy-public.s3.eu-central-1.amazonaws.com/mirovoy-refarch/infrastructure/latest/aws-mirovoy-ref-arch-master.yaml) |
| eu-north-1 |Europe (Stockholm)| [![cloudformation-launch-stack](images/launch.png)](https://console.aws.amazon.com/cloudformation/home?region=eu-north-1#/stacks/new?stackName=FlurdyMail&templateURL=https://mirovoy-public.s3.eu-central-1.amazonaws.com/mirovoy-refarch/infrastructure/latest/aws-mirovoy-ref-arch-master.yaml) |
| me-south-1 |Middle East (Bahrain)| [![cloudformation-launch-stack](images/launch.png)](https://console.aws.amazon.com/cloudformation/home?region=me-south-1#/stacks/new?stackName=FlurdyMail&templateURL=https://mirovoy-public.s3.eu-central-1.amazonaws.com/mirovoy-refarch/infrastructure/latest/aws-mirovoy-ref-arch-master.yaml) |
| sa-east-1 |South America (São Paulo)| [![cloudformation-launch-stack](images/launch.png)](https://console.aws.amazon.com/cloudformation/home?region=sa-east-1#/stacks/new?stackName=FlurdyMail&templateURL=https://mirovoy-public.s3.eu-central-1.amazonaws.com/mirovoy-refarch/infrastructure/latest/aws-mirovoy-ref-arch-master.yaml) |

## Overview

![architecture-overview](images/Mirovoy-AWS-Architecture-Light-190609a.png)

The repository consists of a set of nested templates. The master
template nests two sub-templates: one for general infrastructure,
one for mail services.  Each of these, in turn, nest a series of
templates which are run in order. Nested templates can be run
individually in order, entering the appropriate input parameters
for each stack. Additionally, when run as individual templates,
there are more configuration options (CloudFormation has a limit
of 60 parameters); however, to just get things running as quickly
as possible, go ahead and [run the master
template](#tldr--launch-the-stack).

In actual practice, I tend to run the first-level stacks
(infrastructure, and flurdy-mail-master) separately.  Even (especially)
when making minor changes, I do this because the databases take a
long time to set up (it's only a few minutes, but if you have to
take them down and set them back up every time you make a change
and get a typo in YAML, it becomes annoying).

The infrastructure template sets up the [Amazon Virtual Private
Cloud], with three subnets — one public subnet (a DMZ in classic
networking parlance), one private subnet for applications, and one
private subnet for the data layer — in each of two availability
zones; two [Auto Scaling] groups (one for [NAT Instances], which
by default spin up one instance per AZ, and one for [Bastion Hosts],
which by default spin up none); and an Amazon RDS MySQL server in
the data subnet in one availability zone.

Additionally, it creates an [Application Load Balancer](ALB), which
splits traffic across the Webmail servers and phpMyAdminServers. A
single ALB is used for both web and phpMyAdmin, and traffic routing
is accomplished with [host-based routing]. To do this, you must
know the DNS name you want to use for each service, which you will
manually assign to the ALB, later. If you run your own DNS somewhere
other than AWS, you can do this as a CNAME, or if you use Route53,
you can create an alias.

The mail template sets up an [Amazon EC2] (Amazon Elastic Compute
Cloud) instance running a Flurdy server in one of the public subnets,
and optionally a Flurdy backup server in the other public subnet;
and [Elastic Block Store] volumes for spool and log for each of the
primary and backup mail servers. The Flurdy server runs Postfix,
Dovecot, SpamAssassin, ClamAV, and PostGrey. The system uses SASL
Authentication, and TLS encryption. The certificates are automatically
generated from LetsEncrypt.

The optional phpMyAdmin template configures an autoscaling group.
By default zero instances are enabled. Much like the Bastion
autoscaling group, when you need to perform database management
with phpMyAdmin, you go to the EC2 console and change the minimum
and desired number of instances to 1. See the notes on the
infrastructure template (above) for mandatory requirements if you're
going to enable this feature. Both phpMyAdmin and Roundcube rely
on [Amazon Certificate Manager] for SSL.

The optional webmail template configures an autoscaling group, which
defaults to 1 EC2 instance running [Apache] and Roundcube. See the
notes on the infrastructure template (above) for mandatory requirements
if you're going to enable this feature. Both phpMyAdmin and Roundcube
rely on [Amazon Certificate Manager] for SSL.

In addition to these general resources, if you have configured at
least one Amazon [Key Management Service] key, then you can configure
either or both your RDS instances and EBS storage to be encrypted.

Finally, you have the option to populate the databases with Flurdy
test data, and to turn services on/off incrementally to aid in
testing.

# Usage

There are only a few simple steps in order to get your email
environment up and running:

1. Populate CloudFormation Helpers
2. Create an AWS SSL Certificate for the ALB
3. Run the templates
4. Populate your database
5. Update/Add DNS entries

That's it!

## General Instructions

### Populate CloudFormation Helpers

In the AWS Region where you want to deploy the environment, create
the following bucket structure:

```
mirovoy-cf-assets/bastion/scripts
mirovoy-cf-assets/bastion/var/skel
mirovoy-cf-assets/mail/var/skel
mirovoy-cf-assets/nat/scripts
mirovoy-cf-assets/nat/var/skel
mirovoy-cf-assets/phpmyadmin/scripts
mirovoy-cf-assets/phpmyadmin/var/skel
mirovoy-cf-assets/roundcube/scripts
mirovoy-cf-assets/roundcube/var/skel
```

The `mirovoy-cf-assets` bucket need not (indeed, should not) be
publicly accessible.

Clone or download this repository.

Populate your new S3 buckets with the files from `mirovoy-cf-assets`.

### Create an AWS SSL Certificate

1. Go to `Security, Identity, & Compliance -> Certificate Manager`
   in the AWS management console.
2. Click `Request a certificate`.
3. Select `Request a public certificate` and click `Request a
certificate`.
4. Add domain names.
5. Choose your validation method and issue the certificate.

This is the single certificate used for HTTPS access to the ALB.
The domain names you add should include both the fully-qualified
domain name for your phpMyAdmin service (e.g., `phpmyadmin.example.com`)
and your roundcube service (e.g., `webmail.example.com`). If you're
going to run other services on this same infrastructure, you can
include those as well (e.g., `www.example.com`); however, *NB*: if
you're going to use CloudFront for your other services, that
certificate _must_ be created in the us-east-1 region.

### Run the templates

The simplest way to run this is to just [execute the master
template](#tldr--launch-the-stack) from the AWS Region in which you
want to deploy the environment. If you're here for the first time,
this is probably what you should do, just to see it work. However,
there are a few reasons you may not want to do this.

First, time. If you're experimenting with the configuration, and
something goes wrong, the whole nest will roll back. By executing
the master, you can get a Flurdy email server environment up and
running in about 20 minutes, but if something goes wrong
because, for example, you made a simple typo or didn't change a
parameter that you really meant to change, you don't want to have
to wait 20 minutes to fix this. This is worse when you're experimenting,
as you may have to play around with things several times to get
them to work. Waiting 20 minutes every time you make a change gets
very annoying, very quickly.

Second, modularity. You may run this stack and find you really
like it.  Great! Since you like it, you decide to run other services
on the infrastructure (e.g., your web servers). Also great! (In
fact, that's what I do). But if you've deployed this from the highest
level, then deployed a web server, and then decide you need to
reprovision your mail servers for some reason, you're stuck taking
down the whole nest, which means you also have to take down your
web servers. This is not ideal.

Third, configurability. CloudFormation is limited to 60 configurable
parameters. That may sound like a lot, but one uses them up
surprisingly quickly. As a result, running the `flurdy-mail-master`
template gives you less configurability than running the templates
one by one, and running the `master` template gives you even less.

For these reasons, the way I actually use this in practice is to
spin up the `infrastructure` nest, then `flurdy-mail-master` nest.
YMMV, and you'll figure out what works best for you.

### Populate your database

In order to access the database, you can either ssh through a bastion
host, or use the phpMyAdmin web interface. In either case, you'll
need to spin up an auto-scaling instance. Go to `EC2 -> Auto Scaling
-> Auto Scaling Groups`. Depending on your preference, select either
the bastion or the phpmyadmin Launch Configuration. Under Actions,
select Edit, and then change your Desired and Min number of instances
to 1.

Once you have access to your database, you can follow the [Flurdy
data](https://flurdy.com/docs/postfix/index.html#data) instructions.
However, see [Minor variances: encrypted passwords](#encrypted-passwords)
before you attempt to do so.

### Update DNS entries

* Add the SPF, DMARC, and DKIM DNS entries.
* Add a DNS entry for your new backup mail server at a lower priority
than your main server, but a higher priority than your existing
backup server (if you have one)
* Confirm your new backup server is queuing mail
* Add DNS entry for `<phpmyadmin>.<example>.com` (it should point
to your new load balancer).
* Replace your old primary MX record to point to your new primary server
* Add DNS entry for `<webmail>.<example>.com` (it should point to
your new load balancer).

## Migrating an Existing Flurdy/Jeremy Server

* Make sure you've run through a new install of the above a few
times, and everything works as expected.
* Stop postfix and dovecot on your current mail server
* Backup /var/spool on your existing mail server
* Backup your existing mail database
* Launch this template
* Update DNS entries
* Make sure everything works
* Shut down your old server

### Backup /var/spool

If you're already running on AWS and /var/spool is a separate volume,
the easiest thing to do is just create a snapshot of said volume
and use it as an input to this configuration.

If you're running on AWS, but /var/spool isn't it's own volume, the
easiest thing to do is create a new EBS, attach it to your existing
instance, copy /var/spool to the new volume, and then create a
snapshot of that (and delete the EBS so you're not paying for extra
storage you don't need).

If you're not on AWS, you'll have to figure out some way to get the
data from your existing server to the new server. Probably spin up
one of these first, launch a bastion instance from your new autoscaling
group, and then rsync over an ssh tunnel to the new server.

### Backup your database

Backup your existing database

`mysqldump --add-drop-table -h mysql_hostserver -u mysql_username`
    `-p mysql_databasename`

Put that backup in your S3 bucket under `mirovoy-cf-assets/mail`,
and use it as input to this configuration template.

# Testing

In addition to the excellent [testing guidelines][flurdy test]
provided by Flurdy, I found the following resources extremely useful:

* [Test SASL]
	* Note: the method for creating the Base64 encoded username and 
	  password described in this article no longer works for me. 
	  Instead, use `echo -ne '\000user@domain.com\000password' | 
	  openssl base64`
* [Testing IMAP with openssl]
* [Certificate testing with openssl]
* [Test spamassassin]
* [Test POP3]

Also, when using LetsEncrypt, I could never get it to completely work 
with test certifictes (as opposed to real). At a minimum, on whatever 
machine you're running `openssl` you'll need to download the intermediate
and root certificates from the [LetsEncrypt staging 
environment](https://letsencrypt.org/docs/staging-environment/). Then,
you'll need to tell `openssl` about them with one of `openssl certhash`,
`openssl rehash`, or `c_rehash`, depending on your OpenSSL installation.
But, like I said, I still couldn't get that to work. Connection testing
works fine, but I couldn't send test emails from an external box.

# Version History

* 0.99.6
	* Upgrade Roundcube to 1.6.0
		* This also necessitated an upgrade to PHP 8.0 on
		  the webmail server
* 0.99.5
	* Fix issue with API-based LetsEncrypt SSL verification, so 
	  phpMyAdmin works [LetsEncrypt X3 expiry explanation]
	* Have amavis do sql lookups
	* Update the NAT security groups to allow mail (so servers in the
	  app subnets can email status and alerts and whatnot)
	* Set system hostname so Postfix doesn't use the default which is
          the AWS hostname for the private IP address
	* Disable ConcurrentDatabaseReload on ClamD
	* Install fail2ban on primary mail server
* 0.99.4
	* Change policyd-spf to install with yum
	* No longer prefetch clamav virus databases
	* Update Roundcube to 1.4.11
	* Include php-xml for phpmyadmin builds
	* Update inline documentation to indicate that the snapshot restore
	  parameter for Mail storqge takes a snapshot ID, not a name
	* Fix bug in restore database from snapshot.
	* Fix bug in postgrey configuration
* 0.99.3
	* Initial release to GitHub

# Parameters

Almost all configuration that is described in the Flurdy documentation
defaults to that setting, and you should read the docs. This section
covers the required parameters used in the top level template. For
full details on all parameters, including the nested templates, see
[the parameter documentaiton][ParameterDoc].

## Mandatory Parameters

**Deployment Type**: which services to deploy? Can be "Primary",
which just deploys a standard Flurdy server, or any combination of
"Primary" along with "phpMyAdmin", "webmail", or "backup". "backup"
deploys a secondary Flurdy server with the backup configuration
specified in his docs, otherwise identical to the primary server,
in the second Availability Zone selected. "webmail" deploys an Auto
Scaling group with 1 instance activated, which runs Roundcube behind
the ALB. "phpMyAdmin" likewise deploys an Auto Scaling group, but
with zero instances activated. In both cases, the web servers deploy
the service at the root of the URL, and you should point your DNS
entry to the ALB. So, for example, create an Alias A record for
`webmail.example.com` that points to the ALB created by the
`infrastructure` stack. Then, to log into Roundcube, navigate to
`https://webmail.example.com/". Ditto for phpMyAdmin. As with bastion
instances, the phpMyAdmin Auto Scaling group should be set back to
a minimum and target number of instances of zero, once you're done
using it, to avoid security vulnerabilities.

**AMI ID for Servers**: the Amazon Machine Image that will be used for
all EC2 instances in the stack. You are welcome to use something other than
the default, but if you don't use an Amazon Linux 2 image, everything will
almost certainly break.

Ivar recommends creating an AMI for all your future server uses. I
used to do that, but maintaining your own images is hard, and they
don't stay current. This is part of the reason I selected Amazon
Linux 2 — I'm pretty sure Amazon's engineers are better than me at
keeping the OS up to date and stable. They may not be as good as
the broader Linux community that you get with Ubuntu or Debian,
but, then again, we're not doing anything fancy in userland, except
for AWS specific stuff, so that's what we most care about being
current. Ergo, I use Amazon Linux 2. This field is a URL to an
[Amazon SSM parameter store] for the AMI you want to use. If you
go look at other CloudFormation templates, they will often use a
mapping to get a per-region AMI. When I initially wrote this, I
used that same paradigm, but put in my own AMIs. I changed to this
method because it seems cleaner. However, this URL resolves to a
value of type `'AWS::SSM::Parameter::Value<AWS::EC2::Image::Id>'`.
If you're using one of the sub-templates diredtly, you can use any
AMI ID that way. However, at the top level, it must be a URL, which
is interpreted as a string and passed to the subtemplates. So, if
you want to use a custom AMI, you have to get an SSM Parameter Store
ID for it.

**Domain Names**: a comma-separated list of the fully-qualified domain names
that correspond to the publically accessible servers to be deployed.
Depending on Deployment Type, above, this may include the FQDNs for your
primary and backup mail servers, your phpMyAdmin, or your Roundcube servers.
The list should not include spaces, and order matters. If your Deployment
Type doesn't deploy one of the servers, just leave the relevant field blank.
For example, if you are deploying a primary server plus phpMyAdmin, but no 
backup or webmail, you would put something like

`mx1.example.com,,,phpmyadmin.example.com`

leaving the backup and webmail fields blank.

**Existing Key Pair**: This is the EC2 key pair that you want to
use to set up the machines (i.e., the key pair for ec2-user). You
may not want to use this key yourself, but you'll need to keep it
installed so the stack can still be managed (there's probably some
way to allow you to upload your own private key to manage the stack,
but that seems ... silly.  If Amazon has your key, why not just use
their key?).

You can set up an alternative root user by specifying an alternative
superuser account to create, later in the configuration.

**Number of Availability Zones**: The number of availability zones across
which to spread the infrastructure. Right now, this is limited to exactly
two, because one is not possible with MySQL on RDS (you have to specify at
least two AZs), and I haven't yet put in the effort to allow selection of
more than two.

**Availability Zones**: The availability zones in which to deploy the
infrastructure. You must pick exactly two (see above).

**RDS Database Master Password**: the password for the "root" user of the
database. You can change the name of the user in the optional parameters.

**Mail Database Password**: the password for the "mail" database user.
As in the Flurdy documentation, this user is "mail", but you can change
it in the optional configuration.

**DNS Zone for SSL cert verification**: right now, SSL certificates are
automatically generated using LetsEncrypt, and validation is done through
DNS. You must specify the DNS Hosted Zone in which the servers will
reside in order for authentication to work properly.

**Mirovoy CloudFormation Assets S3 bucket name**: the "bucket" where
you'll put your helper scripts. This should not be a public bucket.
S3 URLs look like

`https://<asset-bucket>.s3-<region>.amazonaws.com/<key/prefix/to/stuff>/<stuff>`

Also see [AWS S3 Configuration](#aws-s3-configuration).

### Mandatory when either phpMyAdmin or Webmail are enabled

**ALB Certificate ARN**: if you have either or both phpMyAdmin or
Webmail set to be enabled, you need to provide an SSL certificate
for the ALB. This certificate should be generated in the same region
in which you're deploying.

### Mandatory when Webmail is enabled

**Roundcube Database Password**: the password for the webmail database user.

### Recommended Parameters

**Alternative superuser account to create**

The Linux username for your alternative to the default ec2-user
that is created. This user will be created on all instances, whether
the standalone mail servers, or the auto-scaling groups.

**SSH public key for the AdminUser**

The SSH public key for the above user. It's the **public** key, so
there's no danger in sharing it widely.

# Variances from Flurdy

## Significant Variances

There are no significant variances in the current release.

## Minor Variances

### Encrypted Passwords

Flurdy uses the following MySQL syntax to enter passwords into the
database:

encrypt('apassword', CONCAT('$5$', MD5(RAND())))

Unfortunately, the `encrypt` function was depricated in MySQL 5.7.6,
and removed in MySQL 8.0.3. We're using a more recent version (8.0.15
as of this writing); therefore, we can no longer use this syntax
for injection of new passwords.

In fact, there does not appear to be any way to perform SHA256-CRYPT
natively in MySQL anymore, so to manually enter passwords in the
database, you'll need to generate the hash on the command line

`doveadm pw -s SHA256-CRYPT -p <apassword>`

The result will be something like

`{SHA256-CRYPT}$5$9m8G1.WomxSJUu8K$uu3Ky9Lsoa9XHtmyaNtV./MjAc3GP45Ucxrg5i1PEI8`

You can then take everything after `{SHA256-CRYPT}` (\<the hash\>)
and add it to the database using the Flurdy syntax:

`INSERT INTO users (id,name,maildir,crypt) VALUES
	('xandros@blobber.org','xandros','xandros/','<the hash>');`

You actually could, and probably should, also include the
`{SHA256-CRYPT}` as well (i.e., just put the whole output of `dovadm`
into the database.  For more details, see
[Password Storage](#password-storage), below.

### Firewall

This does not install the Shorewall firewall. Instead, it relies
on the VPC Public/Private architecture and AWS EC2 Security Groups
to provide that functionality, so the entire Firewall section of
the Flurdy docs can be ignored. As they say, "not essential for an
EC2 image."

Additionally, it installs fail2ban, and configures it to block some
common attacks on mail servers.

To view the status of fail2ban jails, you can either

`iptables -nvL`

or

`fail2ban-client status [mailserver|postfix|dovecot]`

### SASL

The entire SASL (Authentication) section of the Flurdy docs can be
ignored, as the current versions of Postfix and Dovecot support
SASL via Dovecot.

### Alternative Admin User shell

When setting up on EC2, the Flurdy docs describe the creation of a
[Simple Server] as the basis for all future servers.  Part of that
description includes uploading your public SSH keys, creating a new
user, and adding that user to certain groups. Finally, it optionally
suggests removing the default user used by AWS to launch the
instances. While this last part is good practice in general, it
doesn't really work with CloudFormation, as you need the AWS system
to continue to be able to access the server. I do provide the ability
to add an additional admin user, and to add login files for that
user (.profile .shrc). However, because I'm old and grumpy, I use
ksh, not bash. That should probably be fine for most people, but
if you're approximately equally old and grumpy and want bash (or
something else), you're out of luck for the moment (though, adding
the ability to support other shells is on the To Do list).

### Linux distribution

Flurdy uses Ubuntu. Jon Jerome uses Debian. These templates use
Amazon Linux 2 (probably for [no good reason]).

### GID and UID

Flurdy sets the GID and UID for virtual to 5000 in both cases. The
UID is configurable in these templates, and defaults to 5000 (in
general, I default to the Flurdy defaults ... that's kind of the
point). However, there's no good way to set the GID with CloudFormation,
so it gets set automatically.

### Dovecot SSL

Jon Jerome sets it to "yes". I set it to "required". (It's optional
for server-server SNMP communication, but why let it be optional
for IMAP?)

### Dovecot user query

Jon Jerome uses prefetch to get all of the information in one go.
Mostly this just works, but in the event you have Roundcube enabled,
and a user in the database, but that user has not yet received any
mail, Dovecot gets confused about the directory structure. To fix
this (and prevent errors in Roundcube) we modify the password_query
to prefix "maildir:" to the maildir path.

### SSL Certificates

#### SSL for Email: LetsEncrypt

These templates default to getting "fake" SSL certificates for the
email servers from [LetsEncrypt], using [acme.sh]. This is
approximately equivalent to creating your own CA. The benefit is,
once everything is working, you can switch the configuration option,
and get real SSL certificates that will be accepted by people's
IMAP clients. The downside is, it only works if the primary domain
for the mail server has DNS hosted in [Route53].

SSL certificates are in /etc/pki/dovecot and there are only two in
the default letsencrypt style, but the names are slightly different
than Dovecot instructions specify.

.chain.pem includes the cert, intermediate certs, and CA cert. We no longer
use a separate setting for the CAcert.

#### SSL for Web

The SSL certificate for HTTPS is put on an Amazon Application Load
Balancer (ALB). This certificate comes from [AWS Certificate Manager],
and must be manually generated. Changing this to allow manual
creation is on the To Do list, but for now, the process is manual.
The reason is, if you generate new ones via a CloudFormation stack,
template execution will pause in the middle, while you validate the
new certificates (which can be done either by email or DNS).  Further,
if you're using [AWS CloudFront], you **must** generate or
import the certificate in the US East (N. Virginia) Region (us-east-1).
The first problem is minor, but the second one is significant. If
and when CloudFront supports creation of certificates in other
regions, I'll likely update the templates to support certificate
creation. In the meantime, you must manually create a single
certificate in your region of choice which covers all of the relevant
hosts which will be proxied by the ALB (probably something like
`www.example.com`, `phpmyadmin.example.com`, and `webmail.example.com`).

### Session Cache

Flurdy has the session cache file locations commented out, but sets
the cache timeout variable. I’m not sure what the intent here is,
but according to current postfix documentation, the default values
for those commented out file locations is “blank”. So, we set them.
Also, as we’re using postfix > 2.3, we set the lmtp cache database
location.

### Amavis and SpamAssassin

AmavisD is no longer amavisd-new, and is now amavisd (again?). Additionally,
the [IJS home for amavisd](https://www.ijs.si/software/amavisd/) no longer
seems to be authoritative; having now moved to
[GitLab](https://gitlab.com/amavis/amavis).

The amavisd config files are not broken out under a conf.d
directory in the version that Amazon Linux 2 installs. Instead,
they’re all in one file /etc/amavisd/amavisd.conf. Additionally
amavisd installs SpamAssasin on its own, including setting up
/etc/cron.d/sa-update.  Additionally additionally, amavisd-new now
calls the SpamAssassin perl library directly, so spamd is no longer
launched.

### ClamAV

For ClamAV, the only package installed is clamd, which pulls in the
other requirements. We now grab the virus databases early with freshclam
(see [ClamAV's blog post](https://blog.clamav.net/2021/03/)  from
February 2021).

Also, we disable ConcurrentDatabaseReload. It's on the [TODO
list](#to-do) to make this configurable, as there's no reason to
disable it if you have sufficient memory; however, with the 1GB of
RAM on the micro instance and a 2GB swap, you run out of memory
when the dstabase is updated, and the server can get into a hung
state. I haven't experimented with larger swap, but that might also
be a solution.

### Postgrey

Connect postfix and postgrey via unix socket instead of TCP.

### Roundcube

I install Roundcube from the github source rather than the distribution
because the distributed version is ancient.

Also, you have the option to enable the Roundcube password plugin,
which allows users to change their own passwords.

### Extend - SPF Verification

The package system for Amazon Linux uses slightly different packages.
I install python3, and then use pip to install pypolicyd-spf, pyspf,
and py3dns.  The configuration is in /etc/python-policyd-spf.

### Extend - DKIM

The version of OpenDKIM we install has slightly different configuration
than the one on Flurdy, and the configuration file is
`/etc/opendkim.conf`, not `/etc/default/opendkim`.

In the configuration, we don't configure the `Domains` line, as that
is not required if we use SigningTable, which Flurdy does (I'm not sure
why he includes the Domain parameter in the config; maybe a difference
in OpendDKIM versions).

I'm not actually sure this matters, but the configuration syntax
for the version of OpenDKIM that gets installed by yum appears to
have slightly different syntax. Instead of

`SOCKET="local:/var/spool/postfix/var/run/opendkim/opendkim.sock"`

it is

`Socket local:/var/spool/postfix/var/run/opendkim/opendkim.sock`

## To Do

Make turning off of ConcurrentDatabaseReload in ClamD a configurable
option.

Make fail2ban a config option.

Add ability to configure separate DB user and password for amavisd, as
it can operate with read-only privileges. Probably doesn't matter for now,
but can't hurt in preparation for allowing for amavisd to operate on 
a separate instance.

Add backup to S3/Glacier.

Do a better job of checking if Roundcube is a fresh install or needs
to be updated.

Add LDAP support to Roundcube.

Fix cfn-init.log.

Should have better handling for altadminuser — different shell
types, ability to add multiple groups (e.g., Flurdy’s japanese-inspired
groups).

Add ability to create self-signed certs.

Add ability to do Let’s Encrypt validation via Cloudflare in addition
to Route53.

Allow per-user bayesian filtering (https://wiki.mattrude.com/SpamAssassin)

Allow enabling plus-addressing for spam and viruses (requires setting
local_domains_maps, presumably pulled from the database)

Allow 3 AZs.

Allow multi-AZ deployments.

Would be nice to get some groupware working. Either add support for
Kolab, or replace Roundcube with HORDE, so we have calendaring,
etc….

~~Have AmavisD do lookups for local domain through the SQL database~~
(added in 0.99.5)

## Notes

### Password Storage

The Dovecot recommendation for hashed passwords is to "choose the
strongest crypt scheme that’s supported by your system" (see [dovecot
password schemes]). In this case, that's SHA512-CRYPT. The package
manager is currently installing Dovecot 2.2.36.  As of Dovecot
2.3.0, Dovecot natively supports BLF-CRYPT (Blowfish crypt), which
is considered stronger, and we'll likely move to it once the package
distribution moves to that version.

Dovecot allows you to store passwords with a hint to tell it which
encryption scheme to use if the default scheme doesn't work, by
prepending the encryption type in braces (see [dovecot sql
authentication]). So, for example,

`$5$PgdnNT4KA8Y2djhO$DFV4eHO7U/6SWucFE0PjgsA7ce9PeS4.uCCUVeta717`

becomes

`{SHA256-CRYPT}$5$PgdnNT4KA8Y2djhO$DFV4eHO7U/6SWucFE0PjgsA7ce9PeS4.uCCUVeta717`

Mostly, you probably don't _need_ to do this, as the Jeremy Dovecot
instructions set the default_pass_scheme to `CRYPT` instead of, for
example, `SHA256-CRYPT`. According to the doc's, "Dovecot uses
libc’s `crypt()` function, which means that `CRYPT` is usually able
to recognize `MD5-CRYPT` and possibly also other password schemes.
See all of the `*-CRYPT` ...". In practice, this seems to be true,
and we can leave `CRYPT` as the default passwrod scheme, and it
works fine with `SHA256-CRYPT` and `SHA512-CRYPT` without prepending
the hint. However, it's probably good practice to start prepending
the hint, as at some future point it's likely you'll want to migrate
to a better scheme (e.g., when Blowfish becomes available), and
there's no guarantee that the default `CRYPT` will work at that
point.

#### SHA256 vs SHA256-CRYPT and salt

This is here mostly to help people avoid rabbit holes I've already
navigated.

SHA256 (also SHA512) is a strong hash; however, attackers are clever.
Because people don't generally use strong passwords, and because
they often use the same passwords in multiple places, many passwords
can be gleaned from a rainbow table (a table that takes known hashes
and maps them to known passwords). To prevent this, it is recommended
to always "salt" your passwords. The idea is that by adding a unique,
per-user string to their password at the time the hash is computed,
the hash won't be the same on any two systems and rainbow tables
will become useless.

For this reason, you should not use SHA-256 (or SHA-512) without a
per-user salt. The salt can be stored in a separate column in the
database, or as part of the hash string, as long as your systems
all know which part of the stored string is the hash. It doesn't
matter if an attacker learns the salt, so there's no need to obfuscate
it.

The Flurdy instructions use the MySQL `encrypt` function to store
a salted hash of each user's password. The `encrypt` function
actually relies on the underlying Unix `crypt()` system call, and
the behavior may vary depending on your system's verions of `crypt()`.
For example, on Windows, where no `crypt()` is available, the
`encrypt` function always returns `null`. On older *nix systems,
it may only return the DES hash of the first 8 characters of the
password. However, on most systems running Flurdy mail servers,
there almost certainly exists a glibc2, which supports extensions
to the original `crypt()` functionality, and this is what is used.
The way these versions of `glibc` work is to store password hashes
in the format

`$id$salt$encrypted`

The `id` is used to specify which encryption method is used. In the
case of Flurdy, this is `5`, which tells glibc to use SHA-256. The
salt is the per-user plain-text salt added into the hash to prevent
rainbow attacks.  The "enrypted" part, then, is the SHA-256 hash
of the plain-text password combined with a unique per-user salt.
So far, so good.

For better or worse, the crypt library's SHA256 implementation does
not trivially append the salt to the plaintext password, instead
it needs to know which parts are the salt and which parts are the
password (see [crypt description] by one of the glibc maintainers),
and uses them in a moderately complicated way, which (amongst other
things) does not appear to be replicable with MySQL 8 functions.

After googling around for this for quite a while, I found several
people on ServerFault and StackOverflow using SHA512 without the
salt. This seems like a bad idea, so I gave up on doing this with
MySQL functions and use the `doveadm-pw` utility when I need to
manually generate paswwords.

### AWS S3 Configuration

This is probably needlessly complex. It's not that complex. But it
could probably be simpler.

S3 URLs look like

`https://<asset-bucket>.s3-<region>.amazonaws.com/<key/prefix/to/stuff>/<stuff>`

I keep Bastion and NAT scripts in

`https://mirovoy-public.s3-eu-central-1.amazonaws.com/mirovoy-refarch/cf-helpers/latest/[bastion|nat]/[scripts|var]`

So, if you've checked out this repository, but modified the scripts,
you can put them in your own S3 bucket, and then replace "mirovoy-public"
with your bucket name, and "mirovoy-refarch/cf-helpers/latest/"
with your prefix. Then, underneath that, create

* bastion/scripts/bastion_bootstrap.sh
* bastion/var/banner_message.txt
* bastion/var/skel/profile
* bastion/var/skel/shrc
* nat/scripts/configure-pat.sh
* nat/scripts/nat_bootstrap.sh

and play 'till your heart's content.

## Useful Links

In addition to the original documentation from Flurdy and Jon Jerome, and
the testing links in the Testing section, these other links may be useful:

* configuring amavisd to use SQL [HowtoForge](https://www.howtoforge.com/virtual-users-and-domains-with-postfix-courier-mysql-and-squirrelmail-centos-6.3-x86_64-p4)

[acme.sh]:https://github.com/Neilpang/acme.sh
[ALB]: https://aws.amazon.com/elasticloadbalancing/application-load-balancer/
[Amavis]: https://www.amavis.org
[Amazon Certificate Manager]: http://docs.aws.amazon.com/acm/latest/userguide/acm-overview.html
[Amazon EC2]: http://docs.aws.amazon.com/AWSEC2/latest/UserGuide/concepts.html
[Amazon Linux 2]: https://aws.amazon.com/amazon-linux-2/
[Amazon RDS MySQL]:https://aws.amazon.com/rds/mysql/
[Amazon SSM parameter store]:https://aws.amazon.com/blogs/compute/query-for-the-latest-amazon-linux-ami-ids-using-aws-systems-manager-parameter-store/
[Amazon Virtual Private Cloud]:http://docs.aws.amazon.com/AmazonVPC/latest/UserGuide/VPC_Introduction.html
[Apache]:https://httpd.apache.org
[Auto Scaling]:http://docs.aws.amazon.com/autoscaling/latest/userguide/WhatIsAutoScaling.html
[AWS Certificate Manager]: https://aws.amazon.com/certificate-manager/
[AWS CloudFront]: https://aws.amazon.com/cloudfront/
[AWS CloudFormation]: http://docs.aws.amazon.com/AWSCloudFormation/latest/UserGuide/Welcome.html
[AWS KMS Best Practices]:https://d0.awsstatic.com/whitepapers/aws-kms-best-practices.pdf
[AWS VPC subnetting]:https://docs.aws.amazon.com/vpc/latest/userguide/working-with-vpcs.html
[Bastion Hosts]:https://docs.aws.amazon.com/quickstart/latest/linux-bastion/architecture.html
[Chris Richardson]: https://chrisrichardson.info
[ClamAV]: https://www.clamav.net
[Certificate testing with openssl]:https://support.plesk.com/hc/en-us/articles/213961665-How-to-verify-that-SSL-for-IMAP-POP3-SMTP-works-and-a-proper-SSL-certificate-is-in-use
[crypt description]: https://akkadia.org/drepper/SHA-crypt.txt
[Elastic Block Store]: https://aws.amazon.com/ebs/
[Elastic Load Balancing]: https://aws.amazon.com/elasticloadbalancing/
[Dovecot]: https://www.dovecot.org
[dovecot password schemes]:https://doc.dovecot.org/configuration_manual/authentication/password_schemes/
[dovecot sql authentication]:https://doc.dovecot.org/configuration_manual/authentication/sql/#authentication-sql
[flurdy]: http://flurdy.com/docs/postfix/
[flurdy edition]: https://flurdy.com/docs/postfix/edition14.html
[flurdy test]: https://flurdy.com/docs/postfix/index.html#test
[Jon Jerome]: https://xec.net/dovecot-migration/
[host-basedd routing]: https://aws.amazon.com/blogs/aws/new-host-based-routing-support-for-aws-application-load-balancers/
[Key Management Service]:https://aws.amazon.com/kms/
[launch-use2]: https://console.aws.amazon.com/cloudformation/home?region=us-east-2#/stacks/new?stackName=FlurdyEmail&templateURL=https://mirovoy-public.s3.eu-central-1.amazonaws.com/mirovoy-refarch/mail-and-web/latest/aws-mirovoy-ref-arch-mail-master.yaml
[launch-usw2]: https://console.aws.amazon.com/cloudformation/home?region=us-west-2#/stacks/new?stackName=FlurdyEmail&templateURL=https://mirovoy-public.s3.eu-central-1.amazonaws.com/mirovoy-refarch/mail-and-web/latest/aws-mirovoy-ref-arch-mail-master.yaml
[launch-euw1]: https://console.aws.amazon.com/cloudformation/home?region=eu-west-1#/stacks/new?stackName=FlurdyEmail&templateURL=https://mirovoy-public.s3.eu-central-1.amazonaws.com/mirovoy-refarch/mail-and-web/latest/aws-mirovoy-ref-arch-mail-master.yaml
[launch-euc1]: https://console.aws.amazon.com/cloudformation/home?region=eu-central-1#/stacks/new?stackName=FlurdyEmail&templateURL=https://mirovoy-public.s3.eu-central-1.amazonaws.com/mirovoy-refarch/mail-and-web/latest/aws-mirovoy-ref-arch-mail-master.yaml
[launch-apse2]: https://console.aws.amazon.com/cloudformation/home?region=ap-southeast-2#/stacks/new?stackName=FlurdyEmail&templateURL=https://mirovoy-public.s3.eu-central-1.amazonaws.com/mirovoy-refarch/mail-and-web/latest/aws-mirovoy-ref-arch-mail-master.yaml
[LetsEncrypt]:https://letsencrypt.org
[LetsEncrypt X3 expiry explanation]:https://letsencrypt.org/docs/dst-root-ca-x3-expiration-september-2021/
[NAT Instances]:https://docs.aws.amazon.com/vpc/latest/userguide/VPC_NAT_Instance.html
[Network Load Balancer]:https://docs.aws.amazon.com/elasticloadbalancing/latest/application/introduction.html
[no good reason]:https://www.juliandunn.net/2018/01/05/whats-amazon-linux-might-use/
[ParameterDoc]:docs/index.md
[phpMyAdmin]:https://www.phpmyadmin.net
[Postfix]: http://www.postfix.org
[Postgrey]: https://postgrey.schweikert.ch
[Roundcube]:https://roundcube.net
[Route53]:https://aws.amazon.com/route53/
[Simple Server]:http://flurdy.com/docs/ec2/ubuntu/index.html
[t2vt3]:https://www.cloudsqueeze.ai/amazons-t3-who-should-use-it-when-how-and-the-why/index.html
[Test POP3]: https://blog.yimingliu.com/2009/01/23/testing-a-pop3-server-via-telnet-or-openssl/
[Test SASL]: https://www.cs.ait.ac.th/~on/postfix/SASL_README.html#server_test
[Test spamassassin]:https://spamassassin.apache.org/gtube/gtube.txt
[Testing IMAP with openssl]:https://tewarid.github.io/2011/05/10/access-imap-server-from-the-command-line-using-openssl.html
[WordPress]:https://wordpress.org
