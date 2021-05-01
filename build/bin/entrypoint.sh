#!/bin/bash

case ${role} in
        management)
           	gearmand_bad=0
                nagios_bad=0

                #infinite loop
                while [ 0 -eq 0 ]; do
                        #gearmand server
                        gearmand_pid=`pgrep gearmand`

                        #determine status of gearmand
                        if [ -z "${gearmand_pid}" ]; then
                                echo gearmand stopped, starting\($gearmand_bad}\)
                                gearmand --log-file=/var/log/gearmand.log -d
                                ((gearmand_bad++))
                        else
                            	echo gearmand\(${gearmand_pid}\) running
                                gearmand_bad=0
                        fi

                        ##nagios
                        nagios_pid=`pgrep nagios`

                        #determine status of gearman worker
                        if [ -z "${nagios_pid}" ]; then
                                echo nagios stopped, validating config
                                /usr/sbin/nagios -v /etc/nagios/nagios.cfg > /dev/null
                                nagios_preflight=${?}
                                if [ ${nagios_preflight} -eq 0 ]; then
                                        echo nagios stopped, starting\(${nagios_bad}\)
                                        nagios -d /etc/nagios/nagios.cfg
                                else
                                    	echo nagios preflight failed, exiting
                                        exit
                                fi
                                ((nagios_bad++))
                        else
                            	echo nagios\(${nagios_pid}\) running
                                nagios_bad=0
                        fi

                        #exit container bad count exceeds 4
                        if [ ${gearmand_bad} -gt 5 ] || [ ${nagios_bad} -gt 5 ]; then exit; fi

                        sleep 30
                done
	;;
	trap)
             	snmptrapd_bad=0
                snmptt_bad=0

                #infinite loop
                while [ 0 -eq 0 ]; do

                        #snmptrapd server
                        snmptrapd_pid=`pgrep snmptrapd`

                        #determine status of snmptrapd
                        if [ -z "${snmptrapd_pid}" ]; then
				if [ -f /var/run/snmptt.pid ]; then rm -rf /var/run/snmptt.pid; fi

                                echo snmptrapd stopped, starting\(${snmptrapd_bad}\)
                                snmptrapd 1> /dev/null 2> /dev/null 3> /dev/null
                                ((snmptrapd_bad++))
                        else
                            	echo snmptrapd\(${snmptrapd_pid}\) running
                                snmptrapd_bad=0
                        fi

                        #snmptt server
                        snmptt_pid=`pgrep snmptt`

                        #determine status of snmptt
                        if [ -z "${snmptt_pid}" ]; then
                                echo snmptt stopped, starting\(${snmptt_bad}\)
                                snmptt --daemon
                                ((snmptt_bad++))
                        else
                                echo snmptt\(${snmptt_pid}\) running
                                snmptt_bad=0
                        fi

                        #exit container bad count exceeds 4
                        if [ ${snmptrapd_bad} -gt 5 ] || [ ${snmptt_bad} -gt 5 ]; then exit; fi

                        sleep 30
                done
	;;
	web)
                apache_bad=0
                thruk_bad=0

                #infinite loop
                while [ 0 -eq 0 ]; do

                        #apache server
                        apache_pid=`pgrep httpd`

                        #determine status of apache
                        if [ -z "${apache_pid}" ]; then
                                echo apache stopped, starting\(${apache_bad}\)
                                apachectl 1> /dev/null 2> /dev/null 3> /dev/null
                                ((apache_bad++))
                        else
                            	echo apache\(${apache_pid}\) running
                                apache_bad=0
                        fi

                        #thruk server
                        thruk_pid=`pgrep thruk`

                        #determine status of thruk
                        if [ -z "${apache_pid}" ]; then
                                echo thruk stopped, starting\(${thruk_bad}\)

                                #delete pid file
                                if [ -f /var/cache/thruk/thruk.pid ]; then
                                        rm -rf /var/cache/thruk/thruk.pid
                                fi

                                /etc/init.d/thruk start > /dev/null
                                ((thruk_bad++))
                        else
                                echo thruk\(${thruk_pid}\) running
                                thruk_bad=0
                        fi

                        #exit container bad count exceeds 4
                        if [ ${apache_bad} -gt 5 ] || [ ${thruk_bad} -gt 5 ]; then exit; fi

                        sleep 30
                done
	;;
	worker)
            	gearman_bad=0

                #infinite loop
                while [ 0 -eq 0 ]; do

                        #gearman worker
                        gearman_pid=`pgrep mod_gearman`

                        #determine status of gearman worker
                        if [ -z "${gearman_pid}" ]; then
                                echo gearman worker stopped, starting\(${gearman_bad}\)
                                mod_gearman_worker -d --config=/etc/mod_gearman/worker.conf
                                ((gearman_bad++))
                        else
                                echo gearman worker\(${gearman_pid}\) running
                                apache_bad=0
                        fi

                        #exit container bad count exceeds 4
                        if [ ${gearman_bad} -gt 5 ]; then exit; fi

                        sleep 30
                done
	;;
esac
