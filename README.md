# Route53 Dynamic DNS

Dynamic DNS Update script for AWS Route53 Hosted Zones

## Installation

This project has some pre-requisite packages that are required for this to run properly.

### Install and configure AWS CLI

See the Documentation [here](https://docs.aws.amazon.com/cli/latest/userguide/install-cliv2-linux.html). Your IAM user must have _AmazonRoute53FullAccess_ permissions.

```bash
$ curl "https://awscli.amazonaws.com/awscli-exe-linux-x86_64.zip" -o "awscliv2.zip"
$ unzip awscliv2.zip
$ sudo ./aws/install
$ aws configure
AWS Access Key ID [None]: XXXXXXXXXXXXXXX
AWS Secret Access Key [None]: ******************************
Default region name [None]:
Default output format [None]:
```

### Install jq

#### Redhat/CentOS

```bash
yum install jq
```

#### Debian/Ubuntu

```bash
sudo apt install jq
```

### Running the Script

```bash
$ export AWS_ZONEID='XXXXXXXXXXXX'
$ chmod +x ./route53_ddns.sh 
$ ./route53_ddns.sh
Wed Feb 24 10:52:30 EST 2021 IP is still 123.234.11.22. Exiting
```

### Installing the script

```bash
$ sudo cp ./route53_ddns.sh /usr/local/bin/route53_ddns.sh
$ sudo chmod +x /usr/local/bin/route53_ddns.sh
$ sudo touch /var/log/route53_ddns.log
$ sudo chown $(whoami) /var/log/route53_ddns.log
# Create cron job to update DNS every 2 minutes
$ crontab -e
*/2 * * * * /usr/local/bin/route53_ddns.sh <route53 zone id> >> /var/log/route53_ddns.log
```
