# SIP2Ban for Asterisk
Avoided SIP attackers in Asterisk and OpenSIPS

#Licensing Information: READ LICENSE

#Project source can be downloaded from
##https://github.com/chanon-m/sip2ban.github.io.git

#Author & Contributor

Chanon Mingsuwan

Reported bugs or requested new feature can be sent to chanonm@live.com

#How to run a file
* Download files in your server

```

# git clone https://github.com/chanon-m/sip2ban.github.io.git

```

##Asterisk

* Copy sip2ban.pl to /etc

```

# cp ./sip2ban.github.io/sip2ban.pl /etc

```

* Make a file executable

```

# chmod 755 /etc/sip2ban.pl

```

* Copy whitelist file to /etc

```

# cp -r ./sip2ban.github.io/etc/sip2ban /etc

```

* Format for the whitelist

####_whitelist.ini_
```
ip1
ip2

```

* Create a crontab job on your server

If you want sip2ban.pl to run every 5 minutes, you should code the time as:

```

# crontab -e 

*/5 * * * *      /etc/sip2ban.pl >> /var/log/sip2ban.log&

```

## OpenSIPS

* Copy sip2ban_opensips.pl to /etc

```

# cp ./sip2ban.github.io/sip2ban_opensips.pl /etc

```

* Make a file executable

```

# chmod 755 /etc/sip2ban_opensips.pl

```

* Add codes in opensips.cfg

Original opensips.cfg
```

if (is_method("REGISTER"))
	{
		if (!save("location"))
			sl_reply_error();

		exit;
	}

```

In your opensips.cfg, you have to add:
```

if (is_method("REGISTER"))
	{
      		$var(auth_code) = www_authorize("", "subscriber");
      		if ($var(auth_code) == -1 || $var(auth_code) == -2) {
          		xlog("L_NOTICE","Auth_error for $fU@$fd from $si cause $var(auth_code)");
      		}
      
      		if ($var(auth_code) < 0) {
          		www_challenge("", "0");
          		exit;
      		}
      
      		if (!save("location"))
	  		sl_reply_error();

		exit;
  	}

```

* Create a crontab job on your server

If you want sip2ban.pl to run every 5 minutes, you should code the time as:

```

# crontab -e 

*/5 * * * *      /etc/sip2ban_opensips.pl >> /var/log/sip2ban_opensips.log&

```

##RTP HOTPOT

* Copy rtp.sh and rtphotpot.pl to /etc

```

# cp ./sip2ban.github.io/rtp.sh /etc
# cp ./sip2ban.github.io/rtphotpot.pl /etc

```

* Make a file executable

```

# chmod 755 /etc/rtp.sh
# chmod 755 /etc/rtphotpot.pl

```

##TIP - Set QOS in CentOS

* Edit and Add the rules in iptables (Please make sure your switchhub doesn't remove dscp value)

```

#Setting DSCP
# tos_sip=cs3, tos_audio=ef, tos_video=af41
*mangle
-A OUTPUT -p udp -m udp --sport 5060 -j DSCP --set-dscp-class cs3
-A OUTPUT -p udp -m udp --dport 5060 -j DSCP --set-dscp-class cs3
-A OUTPUT -p udp -m udp --sport 10000:30000 -j DSCP --set-dscp-class ef
COMMIT

```
