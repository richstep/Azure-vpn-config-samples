# Thank you https://github.com/imbushuo for the basis of this script
# Thank you Daniel Mauser for your blog post: https://blogs.technet.microsoft.com/netgeeks/2017/07/11/creating-a-site-to-site-vpn-ipsec-ikev2-with-azure-and-mikrotik-routeros/

# For reference, here are the ip addresses and address spaces used in this script
# 13.211.10.144 - public IP address of the Azure VPN gateway
# 116.15.31.167 - public IP address associated with my Mikrotik router
# 192.168.88.0/24 - address space of my LAN
# 10.74.0.0/16 - address space of my Azure Vnet

#/ip firewall filter add action=accept chain=input disabled=no dst-port=8291 protocol=tcp

# Add the NAT rule
# YOU MAY NEED TO CHANGE THE PRIORITY OF THE NAT RULE (OR IT DOESN'T WORK).
/ip firewall nat add chain=srcnat action=accept src-address=192.168.88.0/24 \
dst-address=10.74.0.0/16

# Add new IPSec Proposal (Transform set)
/ip ipsec proposal add name="azure-ipsec-proposal" auth-algorithms=sha1 \
enc-algorithms=aes-256-cbc lifetime=7:30h pfs-group=modp1024

# Add new IPSec Profile
/ip ipsec profile add name=azure-ipsec-profile hash-algorithm=sha1 \
enc-algorithm=aes-256 dh-group=modp1024 lifetime=8h dpd-interval=2m

# Add new IPSec Peer
/ip ipsec peer add name=azure-ipsec-peer address=13.211.10.144/32 exchange-mode=ike2 send-initial-contact=yes profile=azure-ipsec-profile

# Add new IPSec Identitiy
# the secret is the pre-sharedkey
/ip ipsec identity add peer=azure-ipsec-peer secret=MySecretKey

# Add a new IPSec Policy
/ip ipsec policy add src-address=192.168.88.0/24 src-port=any \
dst-address=10.74.0.0/16 dst-port=any protocol=all action=encrypt \
level=require ipsec-protocol=esp tunnel=yes sa-src-address=116.15.31.167 \
sa-dst-address=13.211.10.144 proposal=azure-ipsec-proposal


# Set TCPMSS to 1360 (may vary depending Mikrotek model and LAN configuration)
/ip firewall mangle add place-before=0 action=change-mss new-mss=1360 \
dst-address=10.74.0.0/16 chain=forward protocol=tcp tcp-flags=syn  comment="Set TCPMSS to 1360"