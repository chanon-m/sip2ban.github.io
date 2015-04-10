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

###Unauthorized attacks

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

###RTP without registration attacks

* Add codes in opensips.cfg

Original opensips.cfg
```
if ( !(is_method("REGISTER")  ) ) {
		if (from_uri==myself)
		{
		} else {
			# if caller is not local, then called number must be local
			if (!uri==myself) {
				send_reply("403","Rely forbidden");
				exit;
			}
		}
}

```

In your opensips.cfg, you have to add:
```

if ( !(is_method("REGISTER")  ) ) {
		if (from_uri==myself)
		{
   		     if(!proxy_authorize("", "subscriber")) {
                        xlog("L_NOTICE","Auth_error for $fU@$fd from $si cause Proxy authentication required");
                        proxy_challenge("", "0");
                        exit;
                     }
                     if (!db_check_from()) {
                        xlog("L_NOTICE","Auth_error for $fU@$fd from $si cause Forbidden auth ID");
                        sl_send_reply("403", "Forbidden auth ID");
                        exit;
                     }

                     consume_credentials();

		} else {
			# if caller is not local, then called number must be local
			if (!uri==myself) {
			        xlog("L_NOTICE","Auth_error for $fU@$fd from $si cause Rely forbidden");
				send_reply("403","Rely forbidden");
				exit;
			}
		}
}

```

* Create a crontab job on your server

If you want sip2ban_opensips.pl to run every 5 minutes, you should code the time as:

```

# crontab -e 

*/5 * * * *      /etc/sip2ban_opensips.pl >> /var/log/sip2ban_opensips.log&

```

##TIP - Set QOS in CentOS

* Add new rules in iptables (Please make sure your switchhub doesn't remove dscp value)

```

#Setting DSCP
# tos_sip=cs3, tos_audio=ef, tos_video=af41
*mangle
-A OUTPUT -p udp -m udp --sport 5060 -j DSCP --set-dscp-class cs3
-A OUTPUT -p udp -m udp --dport 5060 -j DSCP --set-dscp-class cs3
-A OUTPUT -p udp -m udp --sport 10000:30000 -j DSCP --set-dscp-class ef
COMMIT

```

* Restart and monitor 

```

# service iptables restart
# iptables -t mangle -nvL

```
