#!/bin/bash

# /etc/dvsstart.sh

#==============================================================
# Function run_dvsconfig
# dvsconfig.txt에 설정한 항목을 이용하여 초기 설정을 자동으로 하는 루틴
#==============================================================
function run_dvsconfig() {

source /var/lib/dvswitch/dvs/var.txt
source /boot/firmware/dvsconfig.txt

if [ $chg = "1" ] && [ "${first_time_instl}" = "1" ]; then

sudo cp -f /var/lib/dvswitch/dvs/lan/korean.txt /var/lib/dvswitch/dvs/lan/language.txt

update_var rx_freq 430000000
update_var tx_freq 430000000
update_var call_sign ${callsign}
update_var dmr_id ${dmrid}
update_var rpt_id ${rptid}
#rpt_id_2=$(($rpt_id+10))
#rpt_id_3=$(($rpt_id+20))
#update_var rpt_id_2 ${rpt_id_2}
#update_var rpt_id_3 ${rpt_id_3}
update_var module S
#update_var nxdn_id ${nxdn_id}
update_var usrp_port ${port}

# update_var bm_master South_Korea_4501
update_var bm_address 4501.master.brandmeister.network
update_var bm_password ${bm_pswd}
update_var bm_port 62031

update_var dmrplus_address ipsc.dvham.com
update_var dmrplus_password PASSWORD
update_var dmrplus_port 55555

update_var ambe_option 2
#update_var ambe_server ${ambe_server}
#update_var ambe_rxport ${ambe_rxport}
#update_var ambe_baud ${ambe_baud}

update_var lat ${latitude}
update_var lon ${longitude}
update_var lctn "${location}"
update_var desc "DVSwitch"
update_var url https:\/\/www.qrz.com\/db\/${callsign}

sudo ${DVS}init_config.sh return > /dev/null 2>&1
# sudo ${DVS}config_main_user.sh return > /dev/null 2>&1

sudo ${DVS}temp_msg.sh -y

update_var startup_lan 73

fi
}

#==============================================================
# MAIN SCRIPT
#==============================================================

# dvswitch_upgrade + dvsmu_upgrade (로그기록은 하지 않도록)
sudo DISABLE_LOG=1 /usr/local/dvs/auto_upgrade.sh

# dvsconfig.txt에 설정한 항목을 이용하여 초기 설정을 자동으로 하는 루틴
run_dvsconfig

sudo mv /etc/dvsstart.sh /etc/dvsstart.bak > /dev/null 2>&1

exit 0


