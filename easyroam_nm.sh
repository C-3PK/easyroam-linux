#!/bin/bash

# Setup eduroam with easyroam on unsupported linux devices. 
# Developed by https://github.com/jahtz
# Modified for Fedora Atomic by https://github.com/C-3PK

# easyroam: https://www.easyroam.de/
# DFN: https://www.dfn.de/


### FUNCTIONS ###
# Function to check for dependencies
check_dependency() {
    echo -n "$1... "
    if ! type "$1" &> /dev/null; then
        echo "Not found!"
        exit 1
    fi
    echo "Ok"
}

### DEFAULT VALUES
echo
read -sp "Set password for private key: " pkpw
echo -e "\nInsert your easyroam identity (Cert S/N @ university):"
read -e cn  # Identity
homedir=$( getent passwd "$USER" | cut -d: -f6 )  # users home directory
outputdir="$homedir/Documents/easyroam/"  # default output directory
legacy="-legacy"  # legacy option

### CHECKS ###
# Check for required dependencies
echo "Checking dependencies:"
check_dependency "nmcli"

# Select network interface
interfaces=()
for iface in $(ls /sys/class/net/); do
    if iw dev "$iface" info &>/dev/null; then
        interfaces+=("$iface")
    fi
done
interface=""
echo -e "\nSelect wifi interface to configure"
PS3="Interface: "
select opt in "${interfaces[@]}" "Exit"; do
    case $opt in
        "Exit")
            exit 0
            ;;
        "")
            echo "Invalid option $REPLY"
            ;;
        *)
            interface="$opt"
            break
            ;;
    esac
done

### LOGIC ###
# Delete existing nm configurations
echo -n "Delete existing configurations... "
nmcli connection show eduroam >/dev/null 2>&1 && nmcli connection delete eduroam
nmcli connection show easyroam >/dev/null 2>&1 && nmcli connection delete easyroam

# Create new nm network profile
echo -n "Create new configurations... "
nmcli connection add type wifi ifname "$interface" con-name easyroam ssid eduroam \
    wifi-sec.key-mgmt wpa-eap 802-1x.eap tls 802-1x.identity "$cn" \
    802-1x.client-cert "$outputdir/easyroam_client_cert.pem" \
    802-1x.ca-cert "$outputdir/easyroam_root_ca.pem" \
    802-1x.private-key "$outputdir/easyroam_client_key.pem" \
    802-1x.private-key-password "$pkpw" 2>&1

if [[ $? -ne 0 ]]; then
    echo "Failed to create network configuration."
    exit 1
fi
echo -e "\nSUCCESS: You should now be able to connect to eduroam."
