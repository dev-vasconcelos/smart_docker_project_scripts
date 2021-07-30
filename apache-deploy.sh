#! /bin/bash
FILEPATH=$(pwd)/teste.conf

echo "#<VirtualHost *:*>" > $FILEPATH
echo "#	RequestHeader set "X-Forwarded-Proto" expr=%{REQUEST_SCHEME}" >> $FILEPATH
echo "#</VirtualHost>" >> $FILEPATH

## Default for each application##
domain="track.transp.net"
doc_root_path="/var/www/html/Track"
## view page ##
echo 	"<VirtualHost *:80>" >> $FILEPATH
echo 	"	ServerName $domain" >> $FILEPATH
echo	"	ServerAlias www.$domain" >> $FILEPATH
echo >> $FILEPATH
echo	"	DocumentRoot $doc_root_path" >> $FILEPATH
echo	"	ErrorLog ${APACHE_LOG_DIR}/error.log" >> $FILEPATH
echo	"	CustomLog ${APACHE_LOG_DIR}/access.log combined" >> $FILEPATH ## SETAR APACHE_LOG_DIR NO SISTEMA
echo	"</VirtualHost>" >> $FILEPATH

echo	"# vim: syntax=apache ts=4 sw=4 sts=4 sr noet" >> $FILEPATH

domain="gateway.transp.net"
default_path="/" #default
addr_referenced="http://127.0.0.1:5005/"
cert_relative_path="transpnet/certificado.crt"
key_relative_path="transpnet/private.key"
chain_relative_path="apps/Certificado/certificado.crt"
proxy_preserve_host="on" #default
proxy_requests="off" #default
ssl_proxy_engine="on" #default
vhost_port="80" #default
vhost_sec_port="443" #default

echo	"<VirtualHost *:$vhost_port>" >> $FILEPATH
echo	"	ProxyPreserveHost $proxy_preserve_host" >> $FILEPATH
echo	"	ProxyRequests $proxy_requests" >> $FILEPATH
echo	"	ServerName $domain" >> $FILEPATH
echo	"	ServerAlias www.$domain" >> $FILEPATH
echo	"	ProxyPass $default_path $addr_referenced" >> $FILEPATH
echo	"	ProxyPassReverse $path $addr_referenced" >> $FILEPATH
echo >> $FILEPATH	
echo	"	# ex path ProxyPass /swagger http://127.0.0.1:5010/" >> $FILEPATH
echo	"	# ex path ProxPassReverse /swagger http://127.0.0.1:5010/" >> $FILEPATH
echo	"</VirtualHost>" >> $FILEPATH
echo >> $FILEPATH
echo	"<VirtualHost *.$vhost_sec_port>" >> $FILEPATH
echo	"	ProxyPreserveHost $proxy_preserve_host" >> $FILEPATH
echo	"	ProxyRequests $proxy_requests" >> $FILEPATH
echo	"	#ServerName $domain" >> $FILEPATH
echo	"	#ServerAlias www.$domain" >> $FILEPATH
echo	"	SSLProxyEngine $ssl_proxy_engine" >> $FILEPATH
echo	"	SSLCertificatefile /etc/apache2/ssl/$cert_relative_path" >> $FILEPATH
echo	"	SSLCertificateKeyFile /etc/apache2/ssl/$key_relative_path" >> $FILEPATH
echo	"	SSLCertificateChainFile /etc/apache2/ssl/$chain_relative_path" >> $FILEPATH
echo >> $FILEPATH
echo	"	ProxyPass $default_path $addr_referenced " >> $FILEPATH
echo	"	ProxyPassReverse $default_path $addr_referenced" >> $FILEPATH
echo	"</VirtualHost>" >> $FILEPATH
