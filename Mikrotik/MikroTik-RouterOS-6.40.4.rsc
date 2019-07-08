# Created by https://github.com/imbushuo
# Insert the source NAT rule between on-premise gateway and Azure
# Virtual Network
# YOU PROBABLY NEED TO MOVE THE NAT RULE (OR IT DOESN'T WORK).
# THE PRIORITY OF THE NAT RULE DEPENDS ON YOUR LOCAL NETWORK CONFIGURATION.

/ip firewall nat add chain=srcnat action=accept src-address=192.168.88.0/24 \
dst-address=10.74.0.0/16


# Add new IPSec Proposal (Transform set)
/ip ipsec proposal add name="azure-ipsec-proposal" auth-algorithms=sha1 \
enc-algorithms=aes-256-cbc lifetime=7:30h pfs-group=modp1024

# Add new IPSec Profile
/ip ipsec profile add name=azure-ipsec-profile hash-algorithm=sha1 \
enc-algorithm=aes-256 dh-group=modp1024 lifetime=8h dpd-interval=2m

# Add new IPSec Peer
/ip ipsec peer add name=azure-ipsec-peer address=104.211.10.144/32 exchange-mode=ike2 send-initial-contact=yes profile=azure-ipsec-profile

# Add new IPSec Identitiy
/ip ipsec identity add peer=azure-ipsec-peer secret=3oNE5BsJBUFMTjsgPbANvdEEsRfOFPEI26LAwH6nVSO9Vha8npqJbDpY7ZzOQYRq

# Add a new IPSec Policy

/ip ipsec policy add src-address=192.168.88.0/24 src-port=any \
dst-address=10.74.0.0/16 dst-port=any protocol=all action=encrypt \
level=require ipsec-protocol=esp tunnel=yes sa-src-address=216.15.31.167 \
sa-dst-address=104.211.10.144 proposal=azure-ipsec-proposal peer=azure-ipsec-peer

# Set TCPMSS to 1350 (varies depends on your local network configuration)

#/ip firewall mangle add chain=forward action=change-mss new-mss=1350 \
# passthrough=yes tcp-flags=syn protocol=tcp tcp-mss=!0-1350 log=no log-prefix="" \
# comment="Set TCPMSS to 1350"

ip firewall mangle add place-before=0 action=change-mss new-mss=1360 \
dst-address=10.74.0.0/16 chain=forward protocol=tcp tcp-flags=syn  comment="Set TCPMSS to 1360"