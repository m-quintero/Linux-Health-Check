# Health Report (RHEL/AZURE), Author: michael.quintero@gmail.com, v1

#!/bin/bash

REPORT="/root/health_report.txt"
exec > "$REPORT" 2>&1

section() {
    echo
    echo "============================================================"
    echo "== $1"
    echo "============================================================"
    echo
}

echo "AZURE LINUX PRE-UPGRADE SYSTEM HEALTH REPORT"
echo "Generated on: $(date)"
echo

# ------------------------------------------------------------
section "SYSTEM IDENTITY"
hostnamectl
echo
echo "SELinux Mode:"
getenforce

# ------------------------------------------------------------
section "OS RELEASE AND KERNEL"
cat /etc/redhat-release 2>/dev/null || cat /etc/os-release
echo
uname -a

# ------------------------------------------------------------
section "UPTIME AND LOAD"
uptime
echo
vmstat 1 5

# ------------------------------------------------------------
section "MEMORY AND SWAP"
free -m
echo
swapon --show

# ------------------------------------------------------------
section "FILESYSTEMS AND STORAGE"
df -hT
echo
lsblk -f

# ------------------------------------------------------------
section "LVM STRUCTURE (if used)"
vgs 2>/dev/null
lvs 2>/dev/null
pvs 2>/dev/null

# ------------------------------------------------------------
section "DISK HEALTH (SMART IF AVAILABLE)"
for disk in /dev/sd? /dev/nvme?n1; do
    [ -e "$disk" ] || continue
    echo "Disk: $disk"
    smartctl -H "$disk" 2>/dev/null | grep -E "SMART|PASSED|FAILED"
    echo
done

# ------------------------------------------------------------
section "AZURE PLATFORM DETAILS"
echo "Azure Linux Agent Status:"
systemctl status walinuxagent 2>/dev/null | grep -E "Active:|Loaded:"
echo
echo "Azure Linux Agent Version:"
waagent --version 2>/dev/null
echo
echo "Azure Instance Metadata:"
if command -v curl >/dev/null; then
    curl -s -H "Metadata:true" \
        "http://169.254.169.254/metadata/instance?api-version=2021-02-01"
fi

# ------------------------------------------------------------
section "NETWORK CONFIGURATION"
ip addr
echo
echo "Routing Table:"
ip route
echo
echo "DNS Resolver:"
cat /etc/resolv.conf
echo
echo "Checking for Legacy ifcfg Scripts:"
ls /etc/sysconfig/network-scripts/ifcfg-* 2>/dev/null

# ------------------------------------------------------------
section "SERVICES"
echo "Enabled Services:"
systemctl list-unit-files --state=enabled
echo
echo "Failed Services:"
systemctl --failed

# ------------------------------------------------------------
section "PACKAGE SOURCES AND RPM CHECKS"
yum repolist
echo
echo "Non-RedHat or 3rd-Party RPMs:"
rpm -qa | grep -viE "redhat|rhel|kernel|grub" | sort

# ------------------------------------------------------------
section "RPM INTEGRITY (FILE VERIFY)"
echo "Modified Files (excluding config-only changes):"
echo
rpm -Va | grep -v "^..5"

# ------------------------------------------------------------
section "IMPORTANT SYSTEM LOG ERRORS"
journalctl -p 3 -xb --no-pager

# ------------------------------------------------------------
section "CRITICAL SYSTEM CONFIG SNAPSHOTS"
echo "/etc/fstab:"
cat /etc/fstab
echo
echo "/etc/hosts:"
cat /etc/hosts
echo
echo "/etc/ssh/sshd_config (non-comment lines):"
grep -vE '^(#|$)' /etc/ssh/sshd_config 2>/dev/null
echo
echo "/etc/selinux/config:"
cat /etc/selinux/config 2>/dev/null
echo
echo "/etc/sysctl.conf:"
cat /etc/sysctl.conf 2>/dev/null

# ------------------------------------------------------------
section "AZURE DISK ATTACHMENTS"
lsblk -o NAME,TYPE,SIZE,MOUNTPOINT

# ------------------------------------------------------------
section "SUMMARY OF POSSIBLE OPERATIONAL RISKS"
echo "Checking free space on critical filesystems:"
df -h / /var /usr /tmp 2>/dev/null
echo
echo "Check for core service failures:"
systemctl --failed

# ------------------------------------------------------------
echo
echo "SYSTEM HEALTH REPORT COMPLETE"
echo "Saved to: $REPORT"
echo
