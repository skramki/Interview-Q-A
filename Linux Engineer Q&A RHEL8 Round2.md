
**Senior Linux Consultant Role Focus on RHEL8**
**2nd Round Scenarios:**

Troubleshooting Steps

1. How you will boot kernel panic system in RHEL8? Linux rescue mode in RHEL8?
   > Ans:
	> Identified from console Image not found
	> After reboot /initramfs-3.10-el8.img not found
	> Boot in Linux Rescue mode with limited option with root password
	> uname -r
	> dracut initramfs-3.10.0-1062.el8.x86_64.img 3.10.0-1062.el8.x86_64
	> dracut —force initramfs-3.10.0-1062.el8.x86_64.img 3.10.0-1062.el8.x86_64

2. How you boot with Single user mode in RHEL8?
   > Ans:
	> Kernel Press e to edit —> linux ($root)/vmlinuz- rw init=/sysroot/bin/bash —> Crtl X
	> Kernel Press e to edit —> linux ($root)/vmlinuz- rd.break init=/bin/sh —> Crtl X
	> #Now we are in Emergency mode
	> chroot /sysroot
	> mount —bind /prod /sysroot/proc/
	> mount —bind /sys /sysroot/sys
	> mount —bind /dev /sysroot/dev
	> chroot /sysroot
	sh-4.2 # mount -o remount,rw /
	sh-4.2 # lvs
	sh-4.2 # vgchange -ay
	sh-4.2# mount -a
	sh-4.2# passwd root
	sh-4.2# touch ./autorelabel

3. How to extend lv in RHEL8?
   Ans:
	> lvextend -r -L +1G /dev/vgname/lvname		--> ( -r Resize underlying filesystem together with the logical volume using )
 	> 	
	> ( or )
	> lvextend -L +1G /dev/vgname/lvname
 	> xfs_growfs /dev/vgname/lvname			--> ( Traditional method )

4. Explain Selinux policy for RHEL8?
   Ans:
	> get enforce
	> set enforce 0
	  Premissive
 	> set enforce 1
	  Enforcing
 
	> getsebool -a | grep “http”
	> setsebool -P httpd_enable_ftp_server on
	> getsebook -a | grep http_enable
	> semanage port -a -t http_port_t -p tcp 82
	> ls -lZ /var/www/html
	> semanage fcontext -a -t httpd_sys_content_t /var/www/html/index.html “/var/www/html/(*)?”
	> restore con -Rv /var/www/html
	> ls -lZ /var/www/html
 
5. Explain detail about /etc/fstab entry and how will you make sure Filesystem order is correct?
   Ans:
   	Your Linux system's filesystem table, /etc/fstab, is a configuration table designed to ease the burden of mounting and unmounting file systems to a 		machine by hard coded configuration.

   	**Device**		**Mount Point**		**FS Type**	**Options of MountPoint**	**Backup Operation**	**Filesystem Check Order**
	/dev/mapper/rhel-root   /                       xfs     	defaults        		0 			0
	UUID=64351209-b3d4-421d-8900-7d940ca56fea /boot xfs     	defaults        		0 			0
	/dev/mapper/rhel-swap   swap                    swap    	defaults        		0 			0

7. Linux CIS hardening standards for module change?
   Ans:
   Refer --> https://access.redhat.com/documentation/en-us/red_hat_enterprise_linux/7/html/security_guide/sec-hardening_tls_configuration#sec-Working_with_Cipher_Suites_in_OpenSSL

8. Have you used default Redhat tools to upgrade OS from RHEL7 to RHEL8?
   Ans:
   Yes, Using Leapp utility I've upgraded RHEL7 to RHEL8 with pre-requesties given below.
   
   Reference https://access.redhat.com/documentation/en-us/red_hat_enterprise_linux/8/html-single/upgrading_from_rhel_7_to_rhel_8/index
   
9. Explain rhel8 patching procedure using Ansible playbook?
   Ans:
   Yes, Using below reference can explain patching procedure using ansible playbook.
   
   Reference https://stackoverflow.com/questions/44019836/install-multiple-yum-packages-on-centosnode-via-ansible

**2nd Round Scenarios:**

1. User has reported intermittent network issue on application level, they are reaching you to analyse network traffic at this time. What step will you take 
   place & what CLI used to conclude?
  Ans: 
  This answer will explain deep troubleshoot skills by answering, collect more inputs from Application stack holders like source & destination IP/Port which they are trying to hit.
  Next perform basic troubleshoot on traceroute of destination IP from source server IP to make sure connection establish and server is healthy.
  Since no issue noticed on Server Layer, reach Network team to make sure no packet drop from source to destination IP.

	Next option in OS layer we can identify network traffic use tcpdump utility by using CLI below

  > tcpdump -i bond0 -c 20 host/src <HOST_IP_bond0> and port 80 -p udp -w /tmp/tcpdump_outputfile.log -v
  > Syntax#  tcpdump -i <Interface_name> -c <NO_of_Packet_count> src <HOST_IP>.<PORT> and des <DEST_IP>.<PORT> -w <OUTPUT_FILE>

  > To Read tcpdump output file
  > tcpdump -r <OUTPUT_FILE>/tmp/tcpdump_outputfile.log

  Analyse the log file and identify packet drop on which subnet IP refers too.
  Then engage network team to clear the network traffic on subnet IP having issue.
  Ask Application stack holders to perform testing which could isolate the issue.

2. How you will make sure crash dump has enable, if not what’s your steps?
  Ans:

  **CLI to generate a memory usage report**
	> makedumpfile --mem-usage /proc/kcore
	> grubby --update-kernel=ALL --args="crashkernel=512M-2G:64M,2G-:128M@16M”
	> grep -v ^# /etc/kdump.conf | grep -v ^$
		ext4 /dev/mapper/vg00-varcrashvol
		path /var/crash
		core_collector makedumpfile -c --message-level 1 -d 31
	> core_collector makedumpfile -l --message-level 1 -d 31           —> Manual Configuration CLI
	> systemctl is-active kdump
		active
	
	To Force Linux Kernel to Crash 
	> echo 1 > /proc/sys/kernel/sysrq
