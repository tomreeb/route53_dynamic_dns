#!/usr/bin/env python3

import logging
import argparse
import botocore
import boto3
import requests
import netifaces as ni


def ext_ip_lookup():

    check_ip = "http://checkip.amazonaws.com/"
    try:
        response = requests.get(check_ip)
        body = response.text
        ip = body.split("\n")[0]
    except requests.ConnectionError:
        print("Error checking IP")

    return ip


def update_r53(record, value, zone_id):
    logging.basicConfig(level=logging.INFO)
    logger = logging.getLogger()

    client = boto3.client("route53")

    logger.info(f"IP address is {value}")

    try:
        logger.info("Querying Zone Name from ZoneID")
        response = client.get_hosted_zone(Id=zone_id)
        zone_name = response["HostedZone"]["Name"]
        logger.info(f"Zone Name is {zone_name}")
    except botocore.exceptions.ClientError as error:
        if error.response["Error"]["Code"] == "LimitExceededException":
            logger.warning("API call limit exceeded; backing off and retrying...")
        else:
            raise error

    record_set = f"{record}.{zone_name}"

    try:
        logger.info(f"Creating record for {record_set}")
        response = client.change_resource_record_sets(
            HostedZoneId=zone_id,
            ChangeBatch={
                "Comment": "Updated by reoute53_ddns.py script",
                "Changes": [
                    {
                        "Action": "UPSERT",
                        "ResourceRecordSet": {
                            "Name": record_set,
                            "Type": "A",
                            "TTL": 60,
                            "ResourceRecords": [
                                {"Value": value},
                            ],
                        },
                    },
                ],
            },
        )
    except botocore.exceptions.ClientError as error:
        if error.response["Error"]["Code"] == "LimitExceededException":
            logger.warning("API call limit exceeded; backing off and retrying...")
        else:
            raise error

    return response


parser = argparse.ArgumentParser()
parser.add_argument("zone_id", help="Route53 Zone ID eg. 'Z12345678927'", type=str)
parser.add_argument("host_record", help="Host Record to create/modify", type=str)
parser.add_argument(
    "-i", "--interface", help="Optionally specify an interface to get IP"
)
args = parser.parse_args()

if args.interface:
    ip = ni.ifaddresses(args.interface)[ni.AF_INET][0]["addr"]
else:
    ip = ext_ip_lookup()

update = update_r53(args.host_record, ip, args.zone_id)
