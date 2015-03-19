# SIP2Ban for Asterisk
Avoided SIP attackers in Asterisk

#Licensing Information: READ LICENSE

#Project source can be downloaded from
##https://github.com/chanon-m/sip2ban.github.io.git

#Author & Contributor

Chanon Mingsuwan

Reported bugs or requested new feature can be sent to chanonm@live.com

#How to run file

1. Upload sip2ban.pl to your Asterisk in /etc

```

# cp ./sip2ban.pl /etc

```

2. Make a file executable

```

# chmod 755 /etc/sip2ban.pl

```

3. Create a crontab job on your server

If you want sip2ban.pl to run every 5 minutes, you should code the time as:

```

# crontab -e 

*/5 * * * *      /etc/sip2ban.pl >> /var/log/sip2ban.log&

```
