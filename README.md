# Route53 Dynamic DNS

Dynamic DNS Update script for AWS Route53 Hosted Zones

## Installation

This project has some pre-requisite packages that are required for this to run properly.

### Install and configure AWS CLI

See the Documentation [here](https://docs.aws.amazon.com/cli/latest/userguide/install-cliv2-linux.html). Your IAM user must have _AmazonRoute53FullAccess_ permissions.

#### Mac

```bash
$ brew install awscli
$ aws configure
AWS Access Key ID [None]: XXXXXXXXXXXXXXX
AWS Secret Access Key [None]: ******************************
```

#### Linux

```bash
$ curl "https://awscli.amazonaws.com/awscli-exe-linux-x86_64.zip" -o "awscliv2.zip"
$ unzip awscliv2.zip
$ sudo ./aws/install
$ aws configure
AWS Access Key ID [None]: XXXXXXXXXXXXXXX
AWS Secret Access Key [None]: ******************************
```

Alternatively, you can create the credentials file yourself. By default, its location is `~/.aws/credentials`. At a minimum, the credentials file should specify the access key and secret access key. In this example, the key and secret key for the account are specified in the default profile:

```ini
[default]
aws_access_key_id = YOUR_ACCESS_KEY
aws_secret_access_key = YOUR_SECRET_KEY
```

### Install python requirements

```bash
$ pip3 install -r requirements.txt
Installing collected packages: ...
Successfully installed ...
```

### Run the script

```bash
$ python3 route53_ddns.py Z212345678902 ddns
INFO:botocore.credentials:Found credentials in shared credentials file: ~/.aws/credentials
INFO:root:IP address is 68.81.121.224
INFO:root:Querying Zone Name from ZoneID
INFO:root:Zone Name is example.com.
INFO:root:Creating record for ddns.example.com.
```

Optionally provide an interface to query the IP of:

```bash
$ python3 route53_ddns.py -i=eth0 Z212345678902 ddns
INFO:botocore.credentials:Found credentials in shared credentials file: ~/.aws/credentials
INFO:root:IP address is 10.0.1.35
INFO:root:Querying Zone Name from ZoneID
INFO:root:Zone Name is example.com.
INFO:root:Creating record for ddns.example.com.
```
