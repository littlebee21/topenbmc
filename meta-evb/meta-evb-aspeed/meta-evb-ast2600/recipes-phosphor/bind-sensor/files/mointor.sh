#!/bin/bash

BUSCTL="busctl  set-property xyz.openbmc_project.Settings /xyz/openbmc_project/control/host0/mointor/"
BUSCTLS="xyz.openbmc_project.Control.Mointor"
server_array=('snmpd.service' 'snmptrapd.service' 'nslcd' 'xyz.openbmc_project.User.Manager.service' 'systemd-timedated.service' 'obmc-console@ttyS0.service' 'obmc-console@ttyVUART0.service' 'xyz.openbmc_project.Network.service' 'start-ipkvm.service')
mointor_array=('Snmpconf' 'Snmpconf' 'Ldapconf' 'Usraddconf' 'Datetimeconf' 'Virtualconf' 'Virtualconf' 'Netconf' 'Kvmconf')

function mointorl()
{
#busctl set-property xyz.openbmc_project.Settings  /xyz/openbmc_project/control/host0/mointor xyz.openbmc_project.Control.Mointor Status s "open"
    activate=/etc/checksum
    i=0
    for ser in "${server_array[@]}"
    do
        if systemctl is-active $ser &>/dev/null ;then
            $BUSCTL${mointor_array[i]} $BUSCTLS  Status s "open"
        else
            $BUSCTL${mointor_array[i]} $BUSCTLS Status s "close"
        fi
        i=$((i + 1))
    done

    POWER_STATUS=$(busctl get-property  xyz.openbmc_project.State.Chassis0  /xyz/openbmc_project/state/chassis0 xyz.openbmc_project.State.Chassis RequestedPowerTransition)
    POWER_STATUS=${POWER_STATUS:0-4:3}   #使用busctl命令获取状态，并且截取字符串比较
    if [ "$POWER_STATUS" == "Off" ];
    then
            $BUSCTL"Powerconf" $BUSCTLS  Status s "open"
    else
            $BUSCTL"Powerconf" $BUSCTLS Status s  "close"
    fi

    if [ ! -e $activate ];
    then
        $BUSCTL"Activaconf" $BUSCTLS Status s "close"
    else
        $BUSCTL"Activaconf" $BUSCTLS Status s "open"
    fi
}


while [ -n "$1" ]; do
        case "$1" in
                mointor) mointorl ;;
        esac
        shift
done
