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

* Copy sip2ban.pl to /etc

```

# cp ./sip2ban.github.io/sip2ban.pl /etc

```

* Make a file executable

```

# chmod 755 /etc/sip2ban.pl

```

* Create a crontab job on your server

If you want sip2ban.pl to run every 5 minutes, you should code the time as:

```

# crontab -e 

*/5 * * * *      /etc/sip2ban.pl >> /var/log/sip2ban.log&

```

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
