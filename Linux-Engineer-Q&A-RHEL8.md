**Basic Linux Engineer Interview Questions focused on RHEL8**

1. How you will check driver version & Status of NIC card?
   
   Ans:
   #ethtool -i <NIC_DEVICE_NAME>
        Example: # ethtool-i eth0
                 driver: e1000
                 version: 7.9.22-k8-NAPI
                 firmware-version: 
                 bus-info: 0000:02:01.0
                 supports-statistics: yes
        # nmcli device status
         or
        # ethtool eth0 | egrep -i "Link detected"
         or
        # lshw
   
3. How to identify driver version of PCI/HBA card in cli?
   
   Ans:
   #lspci -nn | egrep -i "hba|fiber"    --> Find HBA/Fibre Channel Card installed
  04:00.0 Fibre Channel [0c04]: Emulex Corporation Saturn-X: LightPulse Fibre Channel Host Adapter [10df:f100] (rev 03)
  04:00.1 Fibre Channel [0c04]: Emulex Corporation Saturn-X: LightPulse Fibre Channel Host Adapter [10df:f100] (rev 03)
  05:00.0 Fibre Channel [0c04]: Emulex Corporation Saturn-X: LightPulse Fibre Channel Host Adapter [10df:f100] (rev 03)
  05:00.1 Fibre Channel [0c04]: Emulex Corporation Saturn-X: LightPulse Fibre Channel Host Adapter [10df:f100] (rev 03)
  82:00.0 Fibre Channel [0c04]: Emulex Corporation Saturn-X: LightPulse Fibre Channel Host Adapter [10df:f100] (rev 03)
  82:00.1 Fibre Channel [0c04]: Emulex Corporation Saturn-X: LightPulse Fibre Channel Host Adapter [10df:f100] (rev 03)
  #lspci -v -s 04:00.0                 --> Find the Physical Port, Driver details
  04:00.0 Fibre Channel: Emulex Corporation Saturn-X: LightPulse Fibre Channel Host Adapter (rev 03)
  Subsystem: Emulex Corporation Saturn-X: LightPulse Fibre Channel Host Adapter
  Flags: bus master, fast devsel, latency 0, IRQ 84, NUMA node 0
  Memory at 92009000 (64-bit, non-prefetchable) [size=4K]
  Memory at 92004000 (64-bit, non-prefetchable) [size=16K]
  Expansion ROM at 92040000 [disabled] [size=256K]
  Capabilities: [58] Power Management version 3
  Capabilities: [60] MSI: Enable- Count=1/16 Maskable+ 64bit+
  Capabilities: [78] MSI-X: Enable+ Count=32 Masked-
  Capabilities: [84] Vital Product Data
  Capabilities: [94] Express Endpoint, MSI 00
  Capabilities: [100] Advanced Error Reporting
  Capabilities: [12c] Power Budgeting <?>
  Kernel driver in use: lpfc
  Kernel modules: lpfc
  #modinfo -d lpfc                   --> SCISI Driver info
  Emulex LightPulse Fibre Channel SCSI driver 11.2.0.6
  #modinfo lpfc|grep version        --> Driver version & Module
  version: 0:11.2.0.6
  rhelversion: 8.2
  srcversion: 72B09363B7415BF170E8W43
  vermagic: 3.10.0-693.17.1.el8.x86_64 SMP mod_unload modversions

   
4. Datacenter team has provision layed network cabling to server, How you will validate on OS level using CLI?
   
   Ans:
   #lshw -class network -short    --> List network adaptor

**  H/W path       Device      Class          Description
  =====================================================**
  /0/100/1c/0    wlp1s0      network        Wireless 8265 / 8275
  /0/100/1f.6    eno1        network        Ethernet Connection I219-LM
  /2             virbr0-nic  network        Ethernet interface
  /3             virbr0      network        Ethernet interface

  #ethtool eno1
  Settings for eno1:
	Supported ports: [ TP ]
	Supported link modes:   10baseT/Half 10baseT/Full 
	                        100baseT/Half 100baseT/Full 
	                        1000baseT/Full 
	Supported pause frame use: No
	Supports auto-negotiation: Yes
	Supported FEC modes: Not reported
	Advertised link modes:  10baseT/Half 10baseT/Full 
	                        100baseT/Half 100baseT/Full 
	                        1000baseT/Full 
	Advertised pause frame use: No
	Advertised auto-negotiation: Yes
	Advertised FEC modes: Not reported
	Speed: 1000Mb/s
	Duplex: Full
	Port: Twisted Pair
	PHYAD: 1
	Transceiver: internal
	Auto-negotiation: on
	MDI-X: on (auto)
	Supports Wake-on: pumbg
	Wake-on: g
	Current message level: 0x00000007 (7)
			       drv probe link
	**Link detected: yes**        --> Make sure "Link detected: yes" else engadge DC/Netowrk team to Lay the cabling

 or 
 #nmcli device status

   
5. Server has config Raid 1+0 and hardware disk failure notfication has receive, How will you validate in Linux CLI?
   WARNING: Your hard drive is failing
   Device: /dev/sdb [SAT], unable to open device
   
     Ans:
     #dmsg | grep sdb
   
     #smartctl --all /dev/sdb
      smartctl 6.2 2013-07-26 r3841 [x86_64-linux-3.10.0-514.2.2.el7.x86_64] (local build)
      Copyright (C) 2002-13, Bruce Allen, Christian Franke, www.smartmontools.org

      Smartctl open device: /dev/sdb failed: No such device        --> Confirm disk sdb failed
   
     #fdisk -l 2>/dev/null | egrep -i '^disk /dev+.' | sort
     Disk /dev/sda: 3000.6 GB, 3000592982016 bytes, 5860533168 sectors
     Disk /dev/sdc: 3000.6 GB, 3000592982016 bytes, 5860533168 sectors
     Disk /dev/sdd: 3000.6 GB, 3000592982016 bytes, 5860533168 sectors

   In this case engadge hardware vendor to replace **sdb** disk with right hardware part number online

7. What is initramfs and explain its functionalities?
   
   Ans:
   Initramfs is a root filesystem that is embedded into the kernel and loaded at an early stage of the boot process. It is the successor of initrd.     It provides early userspace which can do things the kernel can't easily do by itself during the boot process. Using initramfs is optional.

9. What are the log files you will validate in RHEL8 on routine basis?
    
   Ans:
   #journelctl --> Talking on RHEL8 prefer to use journelctl with required options based on use cases

   The following subdirectories under the /var/log directory store syslog messages.

    /var/log/messages - all syslog messages except the following
    /var/log/secure - security and authentication-related messages and errors
    /var/log/maillog - mail server-related messages and errors
    /var/log/cron - log files related to periodically executed tasks
    /var/log/boot.log - log files related to system startup

   Reference: https://access.redhat.com/documentation/en-us/red_hat_enterprise_linux/8/html/configuring_basic_system_settings/assembly_troubleshooting-problems-using-log-files_configuring-basic-system-settings
   
11. How you will identify status of WWN ID on RHEL8?
    
   Ans:
   #systool -c fc_host -v
       (output trimmed for clarity)
    
      Class Device path = "/sys/class/fc_host/host8"  (kernel assigned host name/number)
        node_name           = "0x20000024ff2254bf"    (hba wwnn       )
        port_name           = "0x21000024ff2254bf"    (hba wwpn       )
        port_id             = "0x030b00"              (fabric port id assigned by the san to this HBA)

      Class Device path = "/sys/class/fc_host/host9"
        node_name           = "0x20000024ff2254be"
        port_name           = "0x21000024ff2254be"
        port_id             = "0x010c00"

   
   Reference: https://access.redhat.com/articles/17054#NR2
   
11. What’s the CLI use to validate HBA card port status?
    
   Ans:
   #lspci
   #systool -c fc_host -v    from sysfsutils package
  Class = "fc_host"

  Class Device = "host10"
  Class Device path = "/sys/class/fc_host/host10"
    fabric_name         = "0x200000e08b8068ae"
    issue_lip           = 
    node_name           = "0x200000e08b8068ae"
    port_id             = "0x000000"
    port_name           = "0x210000e08b8068ae"
    port_state          = "Linkdown"
    port_type           = "Unknown"
    speed               = "unknown"
    supported_classes   = "Class 3"
    supported_speeds    = "1 Gbit, 2 Gbit, 4 Gbit"
    symbolic_name       = "QLE2460 FW:v5.06.03 DVR:v8.03.07.15.05.09-k"
    system_hostname     = ""
    tgtid_bind_type     = "wwpn (World Wide Port Name)"
    uevent              = 

    Device = "host10"
    Device path = "/sys/devices/pci0000:00/0000:00:04.0/0000:08:00.0/host10"
      optrom_ctl          = 
      reset               = 
      uevent              = 

      (or)
    # grep -v "zZzZ" -H /sys/class/fc_host/host*/port_state
    sys/class/fc_host/host10/port_state:Linkdown    --> **host10 has identified Linkdown**
    sys/class/fc_host/host11/port_state:Online
    sys/class/fc_host/host12/port_state:Online
    sys/class/fc_host/host8/port_state:Online
    sys/class/fc_host/host9/port_state:Online

Refer: https://access.redhat.com/solutions/528683


10. There is request to change NIC duplex/speed value to half, What could be your steps you follow?
    
    Ans:
    #ethtool eth0
    #ethtool -s eth0 speed 100 duplex half autoneg off
    To make a speed change permanent for eth0, set or add the ETHTOOL_OPT environment variable in /etc/sysconfig/network-scripts/ifcfg-eth0:
    ETHTOOL_OPTS="speed 1000 duplex full autoneg off"

Refer: https://access.redhat.com/documentation/en-us/red_hat_enterprise_linux/5/html/tuning_and_optimizing_red_hat_enterprise_linux_for_oracle_9i_and_10g_databases/chap-oracle_9i_and_10g_tuning_guide-adjusting_network_settings#sect-Oracle_9i_and_10g_Tuning_Guide-Adjusting_Network_Settings-Changing_Network_Adapter_Settings
    
12. What are the ansible modules you have been worked and explain your experience?
    
    Ans:
    Explain interviewer use case which you are more familier, which will ensure your confidence level on Ansible automation.

    We had many reference documents and here is default module https://docs.ansible.com/ansible/latest/playbook_guide/playbooks_module_defaults.html
    
14. Which programming languages you are comfortable with?
    
    Ans:
    Tell top 3 comfortable language you are familier with, here it depends on individual have to answer.

**1st Round Scenarios:**
1. App user can’t access SSH terminal. How do you take this call?
2. Users has raised complain on intermittent performance issue and it has escalated to give Top priority. What are the action items you will take & your approach?
3. Incident has reported portal is accessible, also Web layer team confirms services are running fine. Now they reach you to fix the issue. At this time what are the tools look into and your approach to resolve?
4. Peer team user don’t have access to some of config files, they request you to create pipeline using Jenkins. Now explain how would you achieve this?

**2nd Round Scenarios:**

1. User has reported intermittent network issue on application level, they are reaching you to analyse network traffic at this time. What step will you take place & what CLI used to conclude?
	Ans: 
	To identify network traffic use tcpdump utility like below

#tcpdump -i bond0 -c 20 host/src <HOST_IP_bond0> and port 80 -p udp -w /tmp/tcpdump_outputfile.log -v
#Syntax#  tcpdump -i <Interface_name> -c <NO_of_Packet_count> src <HOST_IP>.<PORT> and des <DEST_IP>.<PORT> -w <OUTPUT_FILE>

#To Read tcpdump output file
#tcpdump -r <OUTPUT_FILE>

2. How you will make sure crash dump has enable, if not what’s your steps?

#CLI to generate a memory usage report
	#makedumpfile --mem-usage /proc/kcore
	# grubby --update-kernel=ALL --args="crashkernel=512M-2G:64M,2G-:128M@16M”
	# grep -v ^# /etc/kdump.conf | grep -v ^$
		ext4 /dev/mapper/vg00-varcrashvol
		path /var/crash
		core_collector makedumpfile -c --message-level 1 -d 31
	# core_collector makedumpfile -l --message-level 1 -d 31           —> Manual Configuration CLI
	# systemctl is-active kdump
		active
	
	Force Linux Kernel to Crash 
	# echo 1 > /proc/sys/kernel/sysrq
