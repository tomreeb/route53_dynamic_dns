#!/bin/bash

if [ -z "$1" ]; then 
  echo "ZONEID Parameter is not defined. Exiting"
  exit 1
else 
  ZONEID="$1"
fi

DOMAIN="$(
  /usr/local/bin/aws route53 list-resource-record-sets \
     --hosted-zone-id "$ZONEID" \
     --query "ResourceRecordSets[?Type=='NS']" | \
     jq -r .[0].Name
)"

HOSTNAME="$(
  hostname | awk -F. '{ print $1 }'
)"

RECORDSET="$HOSTNAME.$DOMAIN"

if [ -z "$2" ]; then 
  # Get the external IP if no interface is provided
  IP=$(curl -s http://checkip.amazonaws.com/)
else
  # Get IP of interface provided by second argument
  IP=$(ip -4 addr show "$2" | grep -oP '(?<=inet\s)\d+(\.\d+){3}')
fi

# The Time-To-Live of this recordset
TTL=300

# Change this if you want
COMMENT="$(date) Updated by Route53 Dynamic DNS Script"

# Change to AAAA if using an IPv6 address.
TYPE="A"

# Get Record set IP from Route 53
DNSIP="$(
   /usr/local/bin/aws route53 list-resource-record-sets \
      --hosted-zone-id "$ZONEID" \
      --query "ResourceRecordSets[?Name=='$RECORDSET']" | \
      jq -r .[0].ResourceRecords[].Value
)"

# Check that IP is valid
function valid_ip()
{
    local  ip=$1
    local  stat=1

    if [[ $ip =~ ^[0-9]{1,3}\.[0-9]{1,3}\.[0-9]{1,3}\.[0-9]{1,3}$ ]]; then
        OIFS=$IFS
        IFS='.'
        ip=($ip)
        IFS=$OIFS
        [[ ${ip[0]} -le 255 && ${ip[1]} -le 255 \
            && ${ip[2]} -le 255 && ${ip[3]} -le 255 ]]
        stat=$?
    fi
    return $stat
}

if ! valid_ip "$IP" ; then
    echo "$(date) Invalid IP address $IP."
    exit 1
fi

# Check if the IP has changed and if so create JSON string for updating.
if [ "$IP" == "$DNSIP" ] ; then
    echo "$(date) IP is still $IP. Exiting"
    exit 0
else
    LOGMESSAGE="$(date) Updating record for $RECORDSET to $IP, changed from $DNSIP"
    echo "$LOGMESSAGE"
    TMPFILE=$(mktemp /tmp/temporary-file.XXXXXXXX)
    cat > "${TMPFILE}" << EOF
    {
      "Comment":"$COMMENT",
      "Changes":[
        {
          "Action":"UPSERT",
          "ResourceRecordSet":{
            "ResourceRecords":[
              {
                "Value":"$IP"
              }
            ],
            "Name":"$RECORDSET",
            "Type":"$TYPE",
            "TTL":$TTL
          }
        }
      ]
    }
EOF

    # Update the Hosted Zone record
    /usr/local/bin/aws route53 change-resource-record-sets \
        --hosted-zone-id $ZONEID \
        --change-batch file://"$TMPFILE" \
		--query '[ChangeInfo.Comment, ChangeInfo.Id, ChangeInfo.Status, ChangeInfo.SubmittedAt]' \
		--output text

    # Clean up
    rm "$TMPFILE"
fi