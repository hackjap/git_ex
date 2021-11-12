



# (libsasl2-modules sasl2-bin,libsasl2-2,sendmail).deb

dpkg-i lib*.deb
dpkg-i sendmail.deb


sudo sed -i "s/127.0.0.1 localhost/127.0.0.1 localhost.localdomain localhost/" /etc/hosts

# 보안설정
sudo bash -c "cat << 'END_HELP' >> /etc/mail/sendmail.mc
TRUST_AUTH_MECH(\`EXTERNAL DIGEST-MD5 CRAM-MD5 LOGIN PLAIN')dnl
END_HELP"
sudo bash -c "cat << 'END_HELP' >> /etc/mail/sendmail.mc
define(\`confAUTH_MECHANISMS', \`EXTERNAL GSSAPI DIGEST-MD5 CRAM-MD5 LOGIN PLAIN')dnl
END_HELP"


sudo sh -c "m4 /etc/mail/sendmail.mc > /etc/mail/sendmail.cf"

sudo sh -c "echo Connect:192.168                    RELAY >> /etc/mail/access"
sudo sh -c "makemap hash /etc/mail/access < /etc/mail/access"

cd /usr/lib/sasl2/
sudo bash -c 'cat << EOF > Sendmail.conf
pwcheck_method:saslauthd
EOF'



sudo systemctl restart saslauthd
sudo saslauthd -a pam

sudo useradd -m -s /bin/false mailsender
sudo sh -c "echo mailsender:mailsender | sudo chpasswd"

sudo systemctl stop sendmail
sudo systemctl start sendmail



# auth 인증 테스트
# $ telnet localhost 25
# $ ehlo localhost
# $ auth plain AG1haWxzZW5kZXIAbWFpbHNlbmRlcg==
# Ok Authenticated 출력되면 인증 성공