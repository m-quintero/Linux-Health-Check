# Linux-Health-Check

LINUX-HEALTH-CHECK is a quick & dirty way to grab a full snapshot of a Linux VM. The script (health_check.sh) pulls together system details, storage layout, networking, service status, Azure info, and RPM drift into one easy to read report. It does not touch or modify the system at all. It just tells you what shape the VM is in.

The goal is to save time and give teams a clean baseline before upgrades, patching, or troubleshooting sessions.

# What This Script Does
The script collects a bunch of useful details and puts them into a single report. Here is what it checks:
- System identity and SELinux mode
- OS release and kernel
- Uptime, load, and basic performance data
- Memory and swap usage
- Filesystems and storage
- Azure disk layout and SMART health (when available)
- Azure Linux Agent status and basic Azure metadata
- Network configuration, DNS, and old ifcfg scripts
- Enabled and failed services
- Repositories and third-party RPMs
- RPM integrity (missing or modified files)
- Key config files
- Basic log errors

This makes it easier for teams to compare systems, catch problems early, and avoid upgrade failures caused by things like low disk space or broken services.

# What This Script Does Not Do
- No system changes
- No service restarts
- No package installs
- No deletions
- No LEAPP commands
- No Azure API calls that alter the VM

It’s read only. The only file it writes is the final report.

# **How to Use**

Clone the repo:

```
git clone https://github.com/your-org/LINUX-HEALTH-CHECK.git
cd LINUX-HEALTH-CHECK
```

Make the script executable:

```
chmod +x health_check.sh
```

Run it as root:

```
sudo ./health_check.sh
```

Your report will be created at:

```
/root/health_report.txt
```

---

# **Sample Output (Real Example)**

Below are small pieces of the report so you can see what the script produces. These samples were taken from an actual run.


**System Identity:**

```
Static hostname: MyTestAzureVM
Operating System: Red Hat Enterprise Linux Server 7.9 (Maipo)
Kernel: Linux 3.10.0-1160.119.1.el7.x86_64
SELinux Mode:
Permissive
```

**Uptime and Load:**

```
up 25 days, load average: 0.90, 0.62, 0.77
```

**Disk Layout:**

```
/dev/sda2 32G total, 9.1G used, 23G available
/dev/sda1 497M total
/dev/sdb1 3.9G total
```

**Azure Metadata:**

```
"location":"USGovredacted",
"name":"MyTestAzureVM",
"vmSize":"Standard_B1ms",
"publisher":"RedHat"
```

**Failed Services:**

```
kdump.service
SplunkForwarder.service
```

**RPM Integrity:**

```
missing /opt/splunkforwarder/bin/splunk
missing /opt/splunkforwarder/etc/...
```

This kind of detail makes it easy to spot problems before an upgrade.

---

# **Versioning**

* v1.0 – Initial release


# **Contributing**

If y'all want to improve the script:

* Add checks
* Add new output sections
* Improve formatting
* Report bugs
* Submit pull requests

As Nike said, "JUST DO IT!"

---
