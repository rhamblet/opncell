#!/bin/sh

version=0.10.3

display_help() {
    echo "open5gs-dbctl: Open5GS Database Configuration Tool ($version)"
    echo "FLAGS: --db_uri=mongodb://localhost"
    echo "COMMANDS:" >&2
    echo "   add {imsi key opc}: adds a user to the database with default values"
    echo "   add {imsi ip key opc}: adds a user to the database with default values and a IPv4 address for the UE"
    echo "   addT1 {imsi key opc}: adds a user to the database with 3 differents apns"
    echo "   addT1 {imsi ip key opc}: adds a user to the database with 3 differents apns and the same IPv4 address for the each apn"
    echo "   remove {imsi}: removes a user from the database"
    echo "   reset: WIPES OUT the database and restores it to an empty default"
    echo "   static_ip {imsi ip4}: adds a static IP assignment to an already-existing user"
    echo "   static_ip6 {imsi ip6}: adds a static IPv6 assignment to an already-existing user"
    echo "   type {imsi type}: changes the PDN-Type of the first PDN: 1 = IPv4, 2 = IPv6, 3 = IPv4v6"
    echo "   help: displays this message and exits"
    echo "   default values are as follows: APN \"internet\", dl_bw/ul_bw 1 Gbps, PGW address is 127.0.0.3, IPv4 only"
    echo "   add_ue_with_apn {imsi key opc apn}: adds a user to the database with a specific apn,"
    echo "   add_ue_with_slice {imsi key opc apn sst sd}: adds a user to the database with a specific apn, sst and sd"
    echo "   update_apn {imsi apn slice_num}: adds an APN to the slice number slice_num of an existent UE"
    echo "   update_slice {imsi apn sst sd}: adds an slice to an existent UE"
    echo "   showall: shows the list of subscriber in the db"
    echo "   showpretty: shows the list of subscriber in the db in a pretty json tree format"
    echo "   showfiltered: shows {imsi key opc apn ip} information of subscriber"
    echo "   ambr_speed {imsi dl_value dl_unit ul_value ul_unit}: Change AMBR speed from a specific user and the  unit values are \"[0=bps 1=Kbps 2=Mbps 3=Gbps 4=Tbps ]\""
    echo "   subscriber_status {imsi subscriber_status_val={0,1} operator_determined_barring={0..8}}: Change TS 29.272 values for Subscriber-Status (7.3.29) and Operator-Determined-Barring (7.3.30)"

}

while test $# -gt 0; do
  case "$1" in
    --db_uri*)
      DB_URI=`echo $1 | sed -e 's/^[^=]*=//g'`
      shift
      ;;
    *)
      break
      ;;
  esac
done

DB_URI="${DB_URI:-mongodb://localhost/open5gs}"

if [ "$#" -lt 1 ]; then
    display_help
    exit 1
fi

if [ "$1" = "help" ]; then
    display_help
    exit 1
fi

if [ "$1" = "add" ]; then
    if [ "$#" -eq 13 ]; then
        IMSI=$2
        KI=$3
        OPC=$4
        SST=$5
        APN=$6
        DL=$7
        UNIT=$8
        UL=$9
        QOS=${10}
        PRIORITY_LEVEL=${11}
        ARP_CAPA=${12}
        ARP_VUL=${13}

        mongo --eval "db.subscribers.insertOne(
            {
                \"_id\": new ObjectId(),
                \"schema_version\": NumberInt(1),
                \"imsi\": \"$IMSI\",
                \"msisdn\": [],
                \"imeisv\": [],
                \"mme_host\": [],
                \"mm_realm\": [],
                \"purge_flag\": [],
                \"slice\":[
                {
                    \"sst\": NumberInt($SST),
                    \"default_indicator\": true,
                    \"session\": [
                    {
                        \"name\" : \"$APN\",
                        \"type\" : NumberInt(3),
                        \"qos\" :
                        { \"index\": NumberInt($QOS),
                            \"arp\":
                            {
                                \"priority_level\" : NumberInt($PRIORITY_LEVEL),
                                \"pre_emption_capability\": NumberInt($ARP_CAPA),
                                \"pre_emption_vulnerability\": NumberInt($ARP_VUL)
                            }
                        },
                        \"ambr\":
                        {
                            \"downlink\":
                            {
                                \"value\": NumberInt($DL),
                                \"unit\": NumberInt($UNIT)
                            },
                            \"uplink\":
                            {
                                \"value\": NumberInt($UL),
                                \"unit\": NumberInt($UNIT)
                            }
                        },
                        \"pcc_rule\": [],
                        \"_id\": new ObjectId(),
                    }],
                    \"_id\": new ObjectId(),
                }],
                \"security\":
                {
                    \"k\" : \"$KI\",
                    \"op\" : null,
                    \"opc\" : \"$OPC\",
                    \"amf\" : \"8000\",
                },
                \"ambr\" :
                {
                    \"downlink\" : { \"value\": NumberInt($DL), \"unit\": NumberInt($UNIT)},
                    \"uplink\" : { \"value\": NumberInt($UL), \"unit\": NumberInt($UNIT)}
                },
                \"access_restriction_data\": 32,
                \"network_access_mode\": 0,
                \"subscriber_status\": 0,
                \"operator_determined_barring\": 0,
                \"subscribed_rau_tau_timer\": 12,
                \"__v\": 0
            }
            );" $DB_URI
        exit $?
    fi
    
    if [ "$#" -eq 14 ]; then
        IMSI=$2
        KI=$3
        OPC=$4
        SST=$5
        APN=$6
        DL=$7
        UNIT=$8
        UL=$9
        QOS=${10}
        PRIORITY_LEVEL=${11}
        ARP_CAPA=${12}
        ARP_VUL=${13}
        IP=${14}

        mongo --eval "db.subscribers.insertOne(
            {
                \"_id\": new ObjectId(),
                \"schema_version\": NumberInt(1),
                \"imsi\": \"$IMSI\",
                \"msisdn\": [],
                \"imeisv\": [],
                \"mme_host\": [],
                \"mm_realm\": [],
                \"purge_flag\": [],
                \"slice\":[
                {
                    \"sst\": NumberInt($SST),
                    \"default_indicator\": true,
                    \"session\": [
                    {
                        \"name\" : \"$APN\",
                        \"type\" : NumberInt(3),
                        \"qos\" :
                        { \"index\": NumberInt($QOS),
                            \"arp\":
                            {
                                \"priority_level\" : NumberInt($PRIORITY_LEVEL),
                                \"pre_emption_capability\": NumberInt($ARP_CAPA),
                                \"pre_emption_vulnerability\": NumberInt($ARP_VUL)
                            }
                        },
                        \"ambr\":
                        {
                            \"downlink\":
                            {
                                \"value\": NumberInt($DL),
                                \"unit\": NumberInt($UNIT)
                            },
                            \"uplink\":
                            {
                                \"value\": NumberInt($UL),
                                \"unit\": NumberInt($UNIT)
                            }
                        },
                         \"ue\":
                        {
                            \"addr\": \"$IP\"
                        },
                        \"pcc_rule\": [],
                        \"_id\": new ObjectId(),
                    }],
                    \"_id\": new ObjectId(),
                }],
                \"security\":
                {
                    \"k\" : \"$KI\",
                    \"op\" : null,
                    \"opc\" : \"$OPC\",
                    \"amf\" : \"8000\",
                },
                \"ambr\" :
                {
                    \"downlink\" : { \"value\": NumberInt($DL), \"unit\": NumberInt($UNIT)},
                    \"uplink\" : { \"value\": NumberInt($UL), \"unit\": NumberInt($UNIT)}
                },
                \"access_restriction_data\": 32,
                \"network_access_mode\": 0,
                \"subscriber_status\": 0,
                \"operator_determined_barring\": 0,
                \"subscribed_rau_tau_timer\": 12,
                \"__v\": 0
            }
            );" $DB_URI
        exit $?
    fi

    if [ "$#" -eq 5 ]; then
        IMSI=$2
        IP=$3
        KI=$4
        OPC=$5

        mongo --eval "db.subscribers.insertOne(
            {
                \"_id\": new ObjectId(),
                \"schema_version\": NumberInt(1),
                \"imsi\": \"$IMSI\",
                \"msisdn\": [],
                \"imeisv\": [],
                \"mme_host\": [],
                \"mm_realm\": [],
                \"purge_flag\": [],
                \"slice\":[
                {
                    \"sst\": NumberInt(1),
                    \"default_indicator\": true,
                    \"session\": [
                    {
                        \"name\" : \"internet\",
                        \"type\" : NumberInt(3),
                        \"qos\" :
                        { \"index\": NumberInt(9),
                            \"arp\":
                            {
                                \"priority_level\" : NumberInt(8),
                                \"pre_emption_capability\": NumberInt(1),
                                \"pre_emption_vulnerability\": NumberInt(2)
                            }
                        },
                        \"ambr\":
                        {
                            \"downlink\":
                            {
                                \"value\": NumberInt(1000000000),
                                \"unit\": NumberInt(0)
                            },
                            \"uplink\":
                            {
                                \"value\": NumberInt(1000000000),
                                \"unit\": NumberInt(0)
                            }
                        },
                        \"ue\":
                        {
                            \"addr\": \"$IP\"
                        },
                        \"pcc_rule\": [],
                        \"_id\": new ObjectId(),
                    }],
                    \"_id\": new ObjectId(),
                }],
                \"security\":
                {
                    \"k\" : \"$KI\",
                    \"op\" : null,
                    \"opc\" : \"$OPC\",
                    \"amf\" : \"8000\",
                },
                \"ambr\" :
                {
                    \"downlink\" : { \"value\": NumberInt(1000000000), \"unit\": NumberInt(0)},
                    \"uplink\" : { \"value\": NumberInt(1000000000), \"unit\": NumberInt(0)}
                },
                \"access_restriction_data\": 32,
                \"network_access_mode\": 0,
                \"subscriber_status\": 0,
                \"operator_determined_barring\": 0,
                \"subscribed_rau_tau_timer\": 12,
                \"__v\": 0
            }
            );" $DB_URI
        exit $?
    fi

    echo "open5gs-dbctl: incorrect number of args, format is \"open5gs-dbctl add imsi key opc\""
    exit 1
fi

if [ "$1" = "addT1" ]; then
    if [ "$#" -eq 4 ]; then
        IMSI=$2
        KI=$3
        OPC=$4

        mongo --eval "db.subscribers.insertOne(
            {
                \"_id\": new ObjectId(),
                \"schema_version\": NumberInt(1),
                \"imsi\": \"$IMSI\",
                \"msisdn\": [],
                \"imeisv\": [],
                \"mme_host\": [],
                \"mm_realm\": [],
                \"purge_flag\": [],
                \"slice\":[
                {
                    \"sst\": NumberInt(1),
                    \"default_indicator\": true,
                    \"session\": [
                    {
                        \"name\" : \"internet\",
                        \"type\" : NumberInt(3),
                        \"qos\" :
                        { \"index\": NumberInt(9),
                            \"arp\":
                            {
                                \"priority_level\" : NumberInt(8),
                                \"pre_emption_capability\": NumberInt(1),
                                \"pre_emption_vulnerability\": NumberInt(2)
                            }
                        },
                        \"ambr\":
                        {
                            \"downlink\":
                            {
                                \"value\": NumberInt(1000000000),
                                \"unit\": NumberInt(0)
                            },
                            \"uplink\":
                            {
                                \"value\": NumberInt(1000000000),
                                \"unit\": NumberInt(0)
                            }
                        },
                        \"pcc_rule\": [],
                        \"_id\": new ObjectId(),
                    },{
                        \"name\" : \"internet1\",
                        \"type\" : NumberInt(3),
                        \"qos\" :
                        { \"index\": NumberInt(9),
                            \"arp\":
                            {
                                \"priority_level\" : NumberInt(8),
                                \"pre_emption_capability\": NumberInt(1),
                                \"pre_emption_vulnerability\": NumberInt(2)
                            }
                        },
                        \"ambr\":
                        {
                            \"downlink\":
                            {
                                \"value\": NumberInt(1000000000),
                                \"unit\": NumberInt(0)
                            },
                            \"uplink\":
                            {
                                \"value\": NumberInt(1000000000),
                                \"unit\": NumberInt(0)
                            }
                        },
                        \"pcc_rule\": [],
                        \"_id\": new ObjectId(),
                    },{
                        \"name\" : \"internet2\",
                        \"type\" : NumberInt(3),
                        \"qos\" :
                        { \"index\": NumberInt(9),
                            \"arp\":
                            {
                                \"priority_level\" : NumberInt(8),
                                \"pre_emption_capability\": NumberInt(1),
                                \"pre_emption_vulnerability\": NumberInt(2)
                            }
                        },
                        \"ambr\":
                        {
                            \"downlink\":
                            {
                                \"value\": NumberInt(1000000000),
                                \"unit\": NumberInt(0)
                            },
                            \"uplink\":
                            {
                                \"value\": NumberInt(1000000000),
                                \"unit\": NumberInt(0)
                            }
                        },
                        \"pcc_rule\": [],
                        \"_id\": new ObjectId(),
                    }
                    ],
                    \"_id\": new ObjectId(),
                }],
                \"security\":
                {
                    \"k\" : \"$KI\",
                    \"op\" : null,
                    \"opc\" : \"$OPC\",
                    \"amf\" : \"8000\",
                },
                \"ambr\" :
                {
                    \"downlink\" : { \"value\": NumberInt(1000000000), \"unit\": NumberInt(0)},
                    \"uplink\" : { \"value\": NumberInt(1000000000), \"unit\": NumberInt(0)}
                },
                \"access_restriction_data\": 32,
                \"network_access_mode\": 0,
                \"subscriber_status\": 0,
                \"operator_determined_barring\": 0,
                \"subscribed_rau_tau_timer\": 12,
                \"__v\": 0
            }
            );" $DB_URI
        exit $?
    fi

    if [ "$#" -eq 5 ]; then
        IMSI=$2
        IP=$3
        KI=$4
        OPC=$5

        mongo --eval "db.subscribers.insertOne(
            {
                \"_id\": new ObjectId(),
                \"schema_version\": NumberInt(1),
                \"imsi\": \"$IMSI\",
                \"msisdn\": [],
                \"imeisv\": [],
                \"mme_host\": [],
                \"mm_realm\": [],
                \"purge_flag\": [],
                \"slice\":[
                {
                    \"sst\": NumberInt(1),
                    \"default_indicator\": true,
                    \"session\": [
                    {
                        \"name\" : \"internet\",
                        \"type\" : NumberInt(3),
                        \"qos\" :
                        { \"index\": NumberInt(9),
                            \"arp\":
                            {
                                \"priority_level\" : NumberInt(8),
                                \"pre_emption_capability\": NumberInt(1),
                                \"pre_emption_vulnerability\": NumberInt(2)
                            }
                        },
                        \"ambr\":
                        {
                            \"downlink\":
                            {
                                \"value\": NumberInt(1000000000),
                                \"unit\": NumberInt(0)
                            },
                            \"uplink\":
                            {
                                \"value\": NumberInt(1000000000),
                                \"unit\": NumberInt(0)
                            }
                        },
                        \"ue\":
                        {
                            \"addr\": \"$IP\"
                        },
                        \"pcc_rule\": [],
                        \"_id\": new ObjectId(),
                    },{
                        \"name\" : \"internet1\",
                        \"type\" : NumberInt(3),
                        \"qos\" :
                        { \"index\": NumberInt(9),
                            \"arp\":
                            {
                                \"priority_level\" : NumberInt(8),
                                \"pre_emption_capability\": NumberInt(1),
                                \"pre_emption_vulnerability\": NumberInt(2)
                            }
                        },
                        \"ambr\":
                        {
                            \"downlink\":
                            {
                                \"value\": NumberInt(1000000000),
                                \"unit\": NumberInt(0)
                            },
                            \"uplink\":
                            {
                                \"value\": NumberInt(1000000000),
                                \"unit\": NumberInt(0)
                            }
                        },
                        \"ue\":
                        {
                            \"addr\": \"$IP\"
                        },
                        \"pcc_rule\": [],
                        \"_id\": new ObjectId(),
                    },{
                        \"name\" : \"internet2\",
                        \"type\" : NumberInt(3),
                        \"qos\" :
                        { \"index\": NumberInt(9),
                            \"arp\":
                            {
                                \"priority_level\" : NumberInt(8),
                                \"pre_emption_capability\": NumberInt(1),
                                \"pre_emption_vulnerability\": NumberInt(2)
                            }
                        },
                        \"ambr\":
                        {
                            \"downlink\":
                            {
                                \"value\": NumberInt(1000000000),
                                \"unit\": NumberInt(0)
                            },
                            \"uplink\":
                            {
                                \"value\": NumberInt(1000000000),
                                \"unit\": NumberInt(0)
                            }
                        },
                        \"ue\":
                        {
                            \"addr\": \"$IP\"
                        },
                        \"pcc_rule\": [],
                        \"_id\": new ObjectId(),
                    }
                    ],
                    \"_id\": new ObjectId(),
                }],
                \"security\":
                {
                    \"k\" : \"$KI\",
                    \"op\" : null,
                    \"opc\" : \"$OPC\",
                    \"amf\" : \"8000\",
                },
                \"ambr\" :
                {
                    \"downlink\" : { \"value\": NumberInt(1000000000), \"unit\": NumberInt(0)},
                    \"uplink\" : { \"value\": NumberInt(1000000000), \"unit\": NumberInt(0)}
                },
                \"access_restriction_data\": 32,
                \"network_access_mode\": 0,
                \"subscriber_status\": 0,
                \"operator_determined_barring\": 0,
                \"subscribed_rau_tau_timer\": 12,
                \"__v\": 0
            }
            );" $DB_URI
        exit $?
    fi

    echo "open5gs-dbctl: incorrect number of args, format is \"open5gs-dbctl add imsi key opc\""
    exit 1
fi

if [ "$1" = "remove" ]; then
    if [ "$#" -ne 2 ]; then
        echo "open5gs-dbctl: incorrect number of args, format is \"open5gs-dbctl remove imsi\""
        exit 1
    fi

    IMSI=$2
    mongo --eval "db.subscribers.deleteOne({\"imsi\": \"$IMSI\"});" $DB_URI
    exit $?
fi

if [ "$1" = "reset" ]; then
    if [ "$#" -ne 1 ]; then
        echo "open5gs-dbctl: incorrect number of args, format is \"open5gs-dbctl reset\""
        exit 1
    fi

    mongo --eval "db.subscribers.deleteMany({});" $DB_URI
    exit $?
fi

if [ "$1" = "static_ip" ]; then
    if [ "$#" -ne 3 ]; then
        echo "open5gs-dbctl: incorrect number of args, format is \"open5gs-dbctl static_ip imsi ip\""
        exit 1
    fi
    IMSI=$2
    IP=$3

    mongo --eval "db.subscribers.updateOne({\"imsi\": \"$IMSI\"},{\$set: { \"slice.0.session.0.ue.addr\": \"$IP\" }});" $DB_URI
    exit $?
fi

if [ "$1" = "static_ip6" ]; then
    if [ "$#" -ne 3 ]; then
        echo "open5gs-dbctl: incorrect number of args, format is \"open5gs-dbctl static_ip6 imsi ip\""
        exit 1
    fi
    IMSI=$2
    IP=$3

    mongo --eval "db.subscribers.updateOne({\"imsi\": \"$IMSI\"},{\$set: { \"slice.0.session.0.ue.addr6\": \"$IP\" }});" $DB_URI
    exit $?
fi

if [ "$1" = "type" ]; then
    if [ "$#" -ne 3 ]; then
        echo "open5gs-dbctl: incorrect number of args, format is \"open5gs-dbctl type imsi type\""
        exit 1
    fi
    IMSI=$2
    TYPE=$3

    mongo --eval "db.subscribers.updateOne({\"imsi\": \"$IMSI\"},{\$set: { \"slice.0.session.0.type\": NumberInt($TYPE) }});" $DB_URI
    exit $?
fi

if [ "$1" = "add_ue_with_apn" ]; then
    if [ "$#" -eq 5 ]; then
        IMSI=$2
        KI=$3
        OPC=$4
        APN=$5

        mongo --eval "db.subscribers.insertOne(
            {
                \"_id\": new ObjectId(),
                \"schema_version\": NumberInt(1),
                \"imsi\": \"$IMSI\",
                \"msisdn\": [],
                \"imeisv\": [],
                \"mme_host\": [],
                \"mm_realm\": [],
                \"purge_flag\": [],
                \"slice\":[
                {
                    \"sst\": NumberInt(1),
                    \"default_indicator\": true,
                    \"session\": [
                    {
                        \"name\" : \"$APN\",
                        \"type\" : NumberInt(3),
                        \"qos\" :
                        { \"index\": NumberInt(9),
                            \"arp\":
                            {
                                \"priority_level\" : NumberInt(8),
                                \"pre_emption_capability\": NumberInt(1),
                                \"pre_emption_vulnerability\": NumberInt(2)
                            }
                        },
                        \"ambr\":
                        {
                            \"downlink\":
                            {
                                \"value\": NumberInt(1000000000),
                                \"unit\": NumberInt(0)
                            },
                            \"uplink\":
                            {
                                \"value\": NumberInt(1000000000),
                                \"unit\": NumberInt(0)
                            }
                        },
                        \"pcc_rule\": [],
                        \"_id\": new ObjectId(),
                    }],
                    \"_id\": new ObjectId(),
                }],
                \"security\":
                {
                    \"k\" : \"$KI\",
                    \"op\" : null,
                    \"opc\" : \"$OPC\",
                    \"amf\" : \"8000\",
                },
                \"ambr\" :
                {
                    \"downlink\" : { \"value\": NumberInt(1000000000), \"unit\": NumberInt(0)},
                    \"uplink\" : { \"value\": NumberInt(1000000000), \"unit\": NumberInt(0)}
                },
                \"access_restriction_data\": 32,
                \"network_access_mode\": 0,
                \"subscriber_status\": 0,
                \"operator_determined_barring\": 0,
                \"subscribed_rau_tau_timer\": 12,
                \"__v\": 0
            }
            );" $DB_URI
        exit $?
    fi

    echo "open5gs-dbctl: incorrect number of args, format is \"open5gs-dbctl add_ue_with_apn imsi key opc apn\""
    exit 1
fi

if [ "$1" = "add_ue_with_slice" ]; then
    if [ "$#" -eq 7 ]; then
        IMSI=$2
        KI=$3
        OPC=$4
        APN=$5
        SST=$6
        SD=$7

        mongo --eval "db.subscribers.insertOne(
            {
                \"_id\": new ObjectId(),
                \"schema_version\": NumberInt(1),
                \"imsi\": \"$IMSI\",
                \"msisdn\": [],
                \"imeisv\": [],
                \"mme_host\": [],
                \"mm_realm\": [],
                \"purge_flag\": [],
                \"slice\":[
                {
                    \"sst\": NumberInt($SST),
                    \"sd\": \"$SD\",
                    \"default_indicator\": true,
                    \"session\": [
                    {
                        \"name\" : \"$APN\",
                        \"type\" : NumberInt(3),
                        \"qos\" :
                        { \"index\": NumberInt(9),
                            \"arp\":
                            {
                                \"priority_level\" : NumberInt(8),
                                \"pre_emption_capability\": NumberInt(1),
                                \"pre_emption_vulnerability\": NumberInt(2)
                            }
                        },
                        \"ambr\":
                        {
                            \"downlink\":
                            {
                                \"value\": NumberInt(1000000000),
                                \"unit\": NumberInt(0)
                            },
                            \"uplink\":
                            {
                                \"value\": NumberInt(1000000000),
                                \"unit\": NumberInt(0)
                            }
                        },
                        \"pcc_rule\": [],
                        \"_id\": new ObjectId(),
                    }],
                    \"_id\": new ObjectId(),
                }],
                \"security\":
                {
                    \"k\" : \"$KI\",
                    \"op\" : null,
                    \"opc\" : \"$OPC\",
                    \"amf\" : \"8000\",
                },
                \"ambr\" :
                {
                    \"downlink\" : { \"value\": NumberInt(1000000000), \"unit\": NumberInt(0)},
                    \"uplink\" : { \"value\": NumberInt(1000000000), \"unit\": NumberInt(0)}
                },
                \"access_restriction_data\": 32,
                \"network_access_mode\": 0,
                \"subscriber_status\": 0,
                \"operator_determined_barring\": 0,
                \"subscribed_rau_tau_timer\": 12,
                \"__v\": 0
            }
            );" $DB_URI
        exit $?
    fi

    echo "open5gs-dbctl: incorrect number of args, format is \"open5gs-dbctl add_ue_with_slice imsi key opc apn sst sd\""
    exit 1
fi

if [ "$1" = "update_apn" ]; then
    if [ "$#" -eq 11 ]; then
        IMSI=$2
        APN=$3
        SLICE_NUM=$4
        DL=$5
        UNIT=$6
        UL=$7
        QOS=$8
        PRIORITY_LEVEL=$9
        ARP_CAPA=${10}
        ARP_VUL=${11}

        mongo --eval "db.subscribers.updateOne({ \"imsi\": \"$IMSI\"},
            {\$push: { \"slice.$SLICE_NUM.session\":
                           {
                            \"name\" : \"$APN\",
                            \"type\" : NumberInt(3),
                            \"_id\" : new ObjectId(),
                            \"pcc_rule\" : [],
                            \"ambr\" :
                            {
                                \"uplink\" : { \"value\": NumberInt($UL), \"unit\" : NumberInt($UNIT) },
                                \"downlink\" : { \"value\": NumberInt($DL), \"unit\" : NumberInt($UNIT) },
                            },
                            \"qos\" :
                            {
                                \"index\" : NumberInt($QOS),
                                \"arp\" :
                                {
                                    \"priority_level\" : NumberInt($PRIORITY_LEVEL),
                                    \"pre_emption_capability\" : NumberInt($ARP_CAPA),
                                    \"pre_emption_vulnerability\" : NumberInt($ARP_VUL),
                                },
                            },
                           }
                    }
            });" $DB_URI
        exit $?
    fi

    echo "open5gs-dbctl: incorrect number of args, format is \"open5gs-dbctl update_apn imsi apn num_slice\""
    exit 1
fi

if [ "$1" = "update_slice" ]; then
    if [ "$#" -eq 11 ]; then
        IMSI=$2
        APN=$3
        SST=$4
        DL=$5
        UNIT=$6
        UL=$7
        QOS=$8
        PRIORITY_LEVEL=$9
        ARP_CAPA=${10}
        ARP_VUL=${11}


        mongo --eval "db.subscribers.updateOne({ \"imsi\": \"$IMSI\"},
            {\$push: { \"slice\":

                            {
                            \"sst\" : NumberInt($SST),
                            \"default_indicator\" : false,
                            \"_id\" : new ObjectId(),
                            \"session\" :
                            [{
                                \"name\" : \"$APN\",
                                \"type\" : NumberInt(3),
                                \"_id\" : new ObjectId(),
                                \"pcc_rule\" : [],
                                \"ambr\" :
                                {
                                    \"uplink\" : { \"value\": NumberInt($UL), \"unit\" : NumberInt($UNIT) },
                                    \"downlink\" : { \"value\": NumberInt($DL), \"unit\" : NumberInt($UNIT) },
                                },
                                \"qos\" :
                                {
                                    \"index\" : NumberInt($QOS),
                                    \"arp\" :
                                    {
                                        \"priority_level\" : NumberInt($PRIORITY_LEVEL),
                                        \"pre_emption_capability\" : NumberInt($ARP_CAPA),
                                        \"pre_emption_vulnerability\" : NumberInt($ARP_VUL),
                                    },
                                },
                             }]
                            }
                    }
            });" $DB_URI
        exit $?
    fi


    echo "open5gs-dbctl: incorrect number of args, format is \"open5gs-dbctl update_slice imsi apn sst sd\""
    exit 1
fi

if [ "$1" = "set_apn" ]; then
    if [ "$#" -eq 11 ]; then
        IMSI=$2
        APN=$3
        SST=$4
        DL=$5
        UNIT=$6
        UL=$7
        QOS=$8
        PRIORITY_LEVEL=$9
        ARP_CAPA=${10}
        ARP_VUL=${11}


        mongo --eval "db.subscribers.updateOne({ \"imsi\": \"$IMSI\"},
            {\$set: { \"slice\":

                            {
                            \"sst\" : NumberInt($SST),
                            \"default_indicator\" : false,
                            \"_id\" : new ObjectId(),
                            \"session\" :
                            [{
                                \"name\" : \"$APN\",
                                \"type\" : NumberInt(3),
                                \"_id\" : new ObjectId(),
                                \"pcc_rule\" : [],
                                \"ambr\" :
                                {
                                    \"uplink\" : { \"value\": NumberInt($UL), \"unit\" : NumberInt($UNIT) },
                                    \"downlink\" : { \"value\": NumberInt($DL), \"unit\" : NumberInt($UNIT) },
                                },
                                \"qos\" :
                                {
                                    \"index\" : NumberInt($QOS),
                                    \"arp\" :
                                    {
                                        \"priority_level\" : NumberInt($PRIORITY_LEVEL),
                                        \"pre_emption_capability\" : NumberInt($ARP_CAPA),
                                        \"pre_emption_vulnerability\" : NumberInt($ARP_VUL),
                                    },
                                },
                             }]
                            }
                    }
            });" $DB_URI
        exit $?
    fi

    echo "open5gs-dbctl: incorrect number of args, format is \"open5gs-dbctl update_slice imsi apn sst sd\""
    exit 1
fi

if [ "$1" = "subscriber_status" ]; then
    if [ "$#" -eq 4 ]; then
        IMSI=$2
        SUB_STATUS=$3
        OP_DET_BARRING=$4
        mongo --eval "db.subscribers.updateOne({ \"imsi\": \"$IMSI\"},
            {\$set: { \"subscriber_status\": $SUB_STATUS,
                      \"operator_determined_barring\": $OP_DET_BARRING
                    }
            });" $DB_URI
        exit $?
    fi
    echo "open5gs-dbctl: incorrect number of args, format is \"open5gs-dbctl subscriber_status imsi subscriber_status_val={0,1} operator_determined_barring={0..8}"
    exit 1
fi
if [ "$1" = "showall" ]; then
   mongo --eval "db.subscribers.find()" $DB_URI
        exit $?
fi
if [ "$1" = "showone" ]; then
    if [ "$#" -eq 2 ]; then
        IMSI=$2
        mongo --eval "db.subscribers.find({ \"imsi\": \"$IMSI\"},{'_id':0,'imsi':1,'security.k':1, 'security.opc':1,'slice.session.name':1,'slice.session.ue.addr':1})" $DB_URI
        exit $?
    fi
fi
if [ "$1" = "showpretty" ]; then
   mongo --eval "db.subscribers.find().pretty()" $DB_URI
        exit $?
fi
if [ "$1" = "showfiltered" ]; then
   mongo --eval "db.subscribers.find({},{'_id':0,'imsi':1,'security.k':1, 'security.opc':1,'slice.session.name':1,'slice.session.ue.addr':1})" $DB_URI
        exit $?
fi

if [ "$1" = "ambr_speed" ]; then
    if [ "$#" -eq 6 ]; then
        IMSI=$2
        DL_VALUE=$3
        DL_UNIT=$4
        UL_VALUE=$5
        UL_UNIT=$6
        mongo --eval "db.subscribers.updateOne({\"imsi\": \"$IMSI\"},
            {\$set: {
                \"ambr\" : {
                    \"downlink\" : {
                        \"value\" : NumberInt($DL_VALUE),
                        \"unit\"  : NumberInt($DL_UNIT)
                    },
                    \"uplink\" :{
                        \"value\": NumberInt($UL_VALUE),
                        \"unit\" : NumberInt($UL_UNIT)
                    }
                },
                \"slice.0.session.0.ambr\": {
                    \"downlink\" : {
                        \"value\" : NumberInt($DL_VALUE),
                        \"unit\"  : NumberInt($DL_UNIT)
                    },
                    \"uplink\" :{
                        \"value\": NumberInt($UL_VALUE),
                        \"unit\" : NumberInt($UL_UNIT)
                    }
                }
                     }
            });" $DB_URI


        exit $?
    fi
    echo "open5gs-dbctl: incorrect number of args, format is \"open5gs-dbctl ambr_speed imsi dl_value dl_unit ul_value ul_unit dl is for download and ul is for upload and the  unit values are[0=bps 1=Kbps 2=Mbps 3=Gbps 4=Tbps ] \""
    exit 1
fi


display_help
