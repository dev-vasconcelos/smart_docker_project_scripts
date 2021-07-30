#! /bin/bash

#<VirtualHost *:*>
#	RequestHeader set "X-Forwarded-Proto" expr=%{REQUEST_SCHEME}
#</VirtualHost>

## Default for each application##

## view page ##
domain=track.transp.net
document_root= /var/www/html/Track
<VirtualHost *:80>
	ServerName $domain
	ServerAlias www.$domain

	DocumentRoot $document_root
	ErrorLog ${APACHE_LOG_DIR}/error.log
	CustomLog ${APACHE_LOG_DIR}/access.log combined
</VirtualHost>

# vim: syntax=apache ts=4 sw=4 sts=4 sr noet

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
<VirtualHost *:$vhost_port>
	ProxyPreserveHost $proxy_preserve_host
	ProxyRequests $proxy_requests
	ServerName $domain
	ServerAlias www.$domain
	ProxyPass $default_path $addr_referenced
	ProxyPassReverse $path #addr_referenced
	
	# ex path ProxyPass /swagger http://127.0.0.1:5010/
	# ex path ProxPassReverse /swagger http://127.0.0.1:5010/
</VirtualHost>

<VirtualHost *.$vhost_sec_port>
	ProxyPreserveHost $proxy_preserve_host
	ProxyRequests $proxy_requests
	#ServerName $domain
	$ServerAlias www.$domain
	SSLProxyEngine $ssl_proxy_engine
	SSLCertificatefile /etc/apache2/ssl/$cert_relative_path
	SSLCertificateKeyFile /etc/apache2/ssl/$key_relative_path
	SSLCertificateChainFile /etc/apache2/ssl/$chain_relative_path
	
	ProxyPass $default_path $addr_referenced 
	ProxyPassReverse $default_path $addr_references
	
</VirtualHost>
