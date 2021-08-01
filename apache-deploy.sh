#! /bin/bash
FILEPATH=$(pwd)/teste.conf

Help() {

	echo "./apache-deploy.sh -d transp.net -f / -a /swagger -c / -k /key/algo -r chain/relative/path -x on -y off -s on -p 80 -e 443 -b -w"

	echo "./apache-deploy.sh -d transp.net -o /var/html/Projeto -v -w"
}

default_values() {
	#main="gateway.transp.net"
	#addr_referenced="http://127.0.0.1:5005/"
	#cert_relative_path="transpnet/certificado.crt"
	#key_relative_path="transpnet/private.key"
	#chain_relative_path="apps/Certificado/certificado.crt"

	default_path="/" #default
	proxy_preserve_host="on" #default
	proxy_requests="off" #default
	ssl_proxy_engine="on" #default
	vhost_port="80" #default
	vhost_sec_port="443" #default
	back=0
	view=0
	new=0
}

write_header (){
    echo "#<VirtualHost *:*>" > $FILEPATH
    echo "#	RequestHeader set "X-Forwarded-Proto" expr=%{REQUEST_SCHEME}" >> $FILEPATH
    echo "#</VirtualHost>" >> $FILEPATH
    echo >> $FILEPATH
}


write_view() {
	domain="track.transp.net"
	doc_root_path="/var/www/html/Track"

	#domain=$1
	#doc_root_path=$2
	echo 	"<VirtualHost *:80>" >> $FILEPATH
	echo 	"	ServerName $domain" >> $FILEPATH
	echo	"	ServerAlias www.$domain" >> $FILEPATH
	echo >> $FILEPATH
	echo	"	DocumentRoot $doc_root_path" >> $FILEPATH
	echo	"	ErrorLog ${APACHE_LOG_DIR}/error.log" >> $FILEPATH
	echo	"	CustomLog ${APACHE_LOG_DIR}/access.log combined" >> $FILEPATH ## SETAR APACHE_LOG_DIR NO SISTEMA
	echo	"</VirtualHost>" >> $FILEPATH

	# echo	"# vim: syntax=apache ts=4 sw=4 sts=4 sr noet" >> $FILEPATH
}
write_back() {	
	#domain=$1
	#default_path=$2
	#addr_referenced=$3
	#cert_relative_path=$4
	#key_relative_path=$5
	#chain_relative_path=$6
	#proxy_preserve_host=$7 
	#proxy_requests=$8 #default
	#ssl_proxy_engine=$9 #default
	#vhost_port=${10} #default
	#vhost_sec_port=${11} #default

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
}


main() {
	
	if [ "${new}" -eq "1" ]
	then
		write_header
	fi

	if [ "${back}" -eq "1" ]
	then
		write_back
	elif [ "${view}" -eq "1" ]
	then
		write_view
	else
		echo "option not found"
		exit 1
	fi
}
	
default_values
while getopts bwvhd:f:a:c:i:r:x:y:s:e:p:s:o:k: flags
do
	case "${flags}" in
		h) Help
		   exit;;
		d) eval domain=\"${OPTARG}\";;
		f) eval default_path=\"${OPTARG}\";;
		a) eval addr_referenced=\"${OPTARG}\";;
		c) eval cert_relative_path=\"${OPTARG}\";;
		k) eval key_relative_path=\"${OPTARG}\";;
		r) eval chain_relative_path=\"${OPTARG}\";;
		x) eval proxy_preserve_host=\"${OPTARG}\";;
		y) eval proxy_requests=\"${OPTARG}\";;
		s) eval ssl_proxy_engine=\"${OPTARG}\";;
		e) eval vhost_sec_port=\"${OPTARG}\";;
		p) eval vhost_port=\"${OPTARG}\";;
		o) eval doc_root_path=\"${OPTARG}\";;
		b) eval back=1;;
		v) eval view=1;;
		w) eval new=1;;
	esac
done

main



