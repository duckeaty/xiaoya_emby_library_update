#!/bin/bash
Blue="\033[34m"
Green="\033[32m"
Red="\033[31m"
Yellow='\033[33m'
Font="\033[0m"
INFO="[${Green}INFO${Font}]"
ERROR="[${Red}ERROR${Font}]"
WARN="[${Yellow}WARN${Font}]"
function INFO() {
echo -e "${INFO} ${1}"
}
function ERROR() {
echo -e "${ERROR} ${1}"
}
function WARN() {
echo -e "${WARN} ${1}"
}
function main_updatepolicy(){
	clear
	echo -e "——————————————————————————————————————————————————————————————————————————————————"
    echo -e "小雅EMBY_CONFIG同步-用户策略更新"
    echo -e "——————————————————————————————————————————————————————————————————————————————————"
	if [ $1 == 0 ]; then
		get_embyurl
		get_embyapi
		EMBY_URL=$(cat /root/xiaoya_emby_url.txt)
		EMBY_API=$(cat /root/xiaoya_emby_api.txt)
		echo -e "请核对EMBY地址与EMBY的API密钥"
		echo -e "【EMBY 内网地址】 $EMBY_URL"
		echo -e "【EMBY API密钥】 $EMBY_API"
		read -ep "正确(任意键)/错误(N)" isRight
		# 验证用户输入，确保它是Y或N
		if [[ $isRight == "N" || $isRight == "n" ]]; then
			main_updatepolicy 0
		fi
	else
		EMBY_URL=$(cat /root/xiaoya_emby_url.txt)
		EMBY_API=$(cat /root/xiaoya_emby_api.txt)
	fi
	echo -e "——————————————————————————————————————————————————————————————————————————————————"
	echo -e "开始获取EMBY用户信息"
	echo -e "——————————————————————————————————————————————————————————————————————————————————"
    USER_URL="${EMBY_URL}/Users?api_key=${EMBY_API}"  
    response=$(curl -s "$USER_URL")  
    USER_COUNT=$(echo "$response" | jq '. | length')
    for((i=0;i<$USER_COUNT;i++))  
    do  
        read -r name <<< "$(echo "$response" | jq -r ".[$i].Name")"  # 使用read命令读取名字  
        read -r id <<< "$(echo "$response" | jq -r ".[$i].Id")"  # 使用read命令读取ID
        read -r policy <<< "$(echo "$response" | jq -r ".[$i].Policy | to_entries | from_entries | tojson")"
		USER_URL_2="${EMBY_URL}/Users/$id/Policy?api_key=${EMBY_API}"
		curl -i -H "Content-Type: application/json" -X POST -d "$policy" "$USER_URL_2"
		echo -e "【$name】"用户策略更新成功！
		echo -e ""
		echo -e "——————————————————————————————————————————————————————————————————————————————————"
    done
	echo -e "所有用户策略更新成功！"
	echo -e "——————————————————————————————————————————————————————————————————————————————————"
	if [ $1 == 0 ]; then
		if [[ $isRight == "N" || $isRight == "n" ]]; then
			echo echo -e "请TG群内反馈，暂不要使用该脚本"
		else
			INFO "请打开小雅EMBY测试该脚本是否有效"
			script_path=$(cd `dirname $0`; pwd)
			read -ep "有效(任意键)/无效(N)" isRight
			echo -e "确认有效，可以按以下方法添加自动计划任务"
			echo -e "——————————————————————————————————————————————————————————————————————————————————"
			echo -e "如需每天6点30分自动执行，在命令行输入："
			echo -e "crontab -e ,然后添加以下内容："
			echo -e "30 6 * * * bash -c \"\$(cat $script_path/xiaoya_emby_config_library_update.sh.sh)\" -s s"
			echo -e "——————————————————————————————————————————————————————————————————————————————————"
			echo -e "一键添加计划任务"
			INFO "强烈建议自行手动添加！"
			INFO "自动添加请一定要确认本脚本文件名未更改，为：xiaoya_emby_config_library_update.sh"
			INFO "如果已经添加过，只是更新EMBY地址或EMBY的API密钥，不要重复添加计划，直接跳过!"
			INFO "如果需要调整时间，请手动在crontab -e中删除多余的计划！"
			read -ep "手动添加或跳过(任意键)/自动添加(Y)" isRight
			if [[ $isRight == "Y" || $isRight == "y" ]]; then
				INFO "请输入计划时间，例：30 6 * * *，这个代表每天6点30分，注意，数字和*之前都有空格，格式一定要正确！"
				read -ep "请输入：" crontab_time
				[[ -z "${crontab_time}" ]] && crontab_time="30 6 * * *"
				(crontab -l 2>/dev/null; echo "$crontab_time bash -c \"\$(cat $script_path/xiaoya_emby_config_library_update.sh\" -s s") | crontab -
				INFO "添加自动计划成功，请自行crontab验证！"
				INFO "请不要更改本脚本目录地址及文件名，否则会出错或失效，如需更改，请自行crontab -e中删除该计划，然后重新运行本脚本！"
			fi
		fi
	fi
	exit 1

}

function get_embyurl(){
    if [ -f /root/xiaoya_emby_url.txt ]; then
        OLD_EMBY_URL=$(cat /root/xiaoya_emby_url.txt)
        INFO "已读取小雅EMBY地址：${OLD_EMBY_URL} (默认不更改回车继续，如果需要更改请输入新地址)"
        read -ep "请输入: " EMBY_URL
        [[ -z "${EMBY_URL}" ]] && EMBY_URL=${OLD_EMBY_URL}
        echo ${EMBY_URL} > /root/xiaoya_emby_url.txt
    else
        INFO "请输入你的小雅EMBY的内网访问地址，如：http://192.168.1.1:2345"
        read -ep "请输入: " EMBY_URL
        touch /root/xiaoya_emby_url.txt
        echo ${EMBY_URL} > /root/xiaoya_emby_url.txt
    fi
}

function get_embyapi(){
    if [ -f /root/xiaoya_emby_api.txt ]; then
        OLD_EMBY_API=$(cat /root/xiaoya_emby_api.txt)
        INFO "已读取小雅EMBY的API密钥：${OLD_EMBY_API} (默认不更改回车继续，如果需要更改请输入新的API密钥)"
        read -ep "请输入: " EMBY_API
        [[ -z "${EMBY_API}" ]] && EMBY_API=${OLD_EMBY_API}
        echo ${EMBY_API} > /root/xiaoya_emby_api.txt
    else
        INFO "请输入小雅EMBY的API密钥"
        read -ep "请输入: " EMBY_API
        touch /root/xiaoya_emby_api.txt
        echo ${EMBY_API} > /root/xiaoya_emby_api.txt
    fi
}

function update_config(){
	MEDIA_DIR=$(cat /root/xiaoya_alist_media_dir.txt)
	emby_config_data=$(cat /root/xiaoya_emby_configdata_dir.txt)
	emby_config_data_new=$(cat /root/xiaoya_emby_configdata_new_dir.txt)
	clear
	echo -e "——————————————————————————————————————————————————————————————————————————————————"
    echo -e "小雅EMBY_CONFIG同步"
    echo -e "——————————————————————————————————————————————————————————————————————————————————"
	echo -e "本脚本解决小雅EMBY的config中library.db数据库同步与同步后非管理员帐户进入EMBY空白问题"
	WARN "请确保你已经安装好resilio同步工具，并已设置好config的选择性更新：cache目录，metadata目录，data/library.db文件"
	INFO "建议将小雅的EMBY容器增加一个目录映射，重新指定一个目录映射为/config/data(脚本默认方案)"
	echo -e "——————————————————————————————————————————————————————————————————————————————————"
	INFO "请输入小雅EMBY的config/data目录地址，已读取默认为$MEDIA_DIR/config/data"
	read -ep "请输入（回车默认）：" emby_config_data
	[[ -z "${emby_config_data}" ]] && emby_config_data=${MEDIA_DIR}/config/data
	echo ${emby_config_data} > /root/xiaoya_emby_configdata_dir.txt
	INFO "请输入小雅EMBY的同步备份config/data目录地址，默认为$MEDIA_DIR/config_data"
	read -ep "请输入（回车默认）：" emby_config_data_new
	[[ -z "${emby_config_data_new}" ]] && emby_config_data_new=${MEDIA_DIR}/config_data
	echo ${emby_config_data_new} > /root/xiaoya_emby_configdata_new_dir.txt
	
	INFO "请选择是否需要更新EMBY及EMBY映射目录（默认为不更新,代表你已经手动设置完成）"
	read -ep "更新(Y)/自行已经设置好（N）" isRight
	if [[ $isRight == "Y" || $isRight == "y" ]]; then
	
		echo -e "——————————————————————————————————————————————————————————————————————————————————"
		INFO "开始更新EMBY配置"
		echo -e "——————————————————————————————————————————————————————————————————————————————————"
		cp -rf ${emby_config_data}/* ${emby_config_data_new}/
		emby_reinstall
	else
		echo -e "——————————————————————————————————————————————————————————————————————————————————"
		WARN "跳过更新EMBY配置，请确认你已经按要求配置好"
		read -ep "按任意键继续..." abcdefg
		echo -e "——————————————————————————————————————————————————————————————————————————————————"
	fi
	echo -e "——————————————————————————————————————————————————————————————————————————————————"
	INFO "开始更新CONFIG"
	
	docker stop $emby_name
	rm -f /root/xiaoya_emby_library_user.sql
	sqlite3 ${emby_config_data_new}/library.db ".dump UserDatas" > /root/xiaoya_emby_library_user.sql
	rm -f ${emby_config_data_new}/library.db*
	cp -f ${emby_config_data}/library.db ${emby_config_data_new}/
	sqlite3 ${emby_config_data_new}/library.db "DROP TABLE IF EXISTS UserDatas;"
	sqlite3 ${emby_config_data_new}/library.db ".read /root/xiaoya_emby_library_user.sql"
	chmod 777 ${emby_config_data_new}/library.db*
	docker start $emby_name
	echo -e "——————————————————————————————————————————————————————————————————————————————————"
	echo -e "正在重启EMBY..."
	check_emby_started $1
	
}
  
# 检查emby容器是否已启动的函数  
function check_emby_started() {
	SINCE_TIME=$(date +"%Y-%m-%dT%H:%M:%S")
	# 定义容器名称
	CONTAINER_NAME=$emby_name
	# 定义要查找的日志行
	TARGET_LOG_LINE_OK="All entry points have started"
	TARGET_LOG_LINE_FAIL="sending all processes the KILL signal and exiting"
    while true; do
        line=$(docker logs --since "$SINCE_TIME" "$CONTAINER_NAME" | tail -n 1)
        echo $line
		if [[ "$line" == *"$TARGET_LOG_LINE_OK"* ]]; then
			echo -e "——————————————————————————————————————————————————————————————————————————————————"
			INFO "更新CONFIG完成，请确认emby已经正常启动（根据机器性能启动可能需要一点时间）"
			if [ $1 == 0 ]; then
				read -ep "请确认已经正常启动,按回车继续"
			fi
			echo -e "——————————————————————————————————————————————————————————————————————————————————"
            main_updatepolicy $1
            break  # 跳出循环
		elif [[ "$line" == *"$TARGET_LOG_LINE_FAIL"* ]]; then
			echo -e "——————————————————————————————————————————————————————————————————————————————————"
			WARN "EMBY启动失败，可能你安装的sqlite3存在问题，导致数据库出错，不能启动EMBY,请选择："
			echo -e "1.尝试重启EMBY"
			echo -e "2.恢复EMBY数据库，并退出"
			read -ep "请选择（1-2）：" uchoice
			case $uchoice in
				1)
					docker start $emby_name
					check_emby_started $1
					break  # 跳出循环
					;;
				2)
					INFO "正在恢复数据库并重启EMBY"
					docker stop $emby_name
					rm -f ${emby_config_data_new}/library.db*
					cp -f ${emby_config_data}/library.db ${emby_config_data_new}/
					docker start $emby_name
					INFO "已恢复数据库，请确认sqlite3版本，不懂可搜索Sqlite3版本问题，解决后再使用本脚本"
					exit 1
					;;
				*)
					docker start $emby_name
					check_emby_started $1
					break  # 跳出循环
					;;
			esac
			echo -e "——————————————————————————————————————————————————————————————————————————————————"
            break  # 跳出循环
        fi
		sleep 3  # 每3秒检查一次日志文件
    done
}

function emby_reinstall(){
	#CONFIG_DIR=$(cat /root/xiaoya_alist_config_dir.txt)
	MEDIA_DIR=$(cat /root/xiaoya_alist_media_dir.txt)
	cpu_arch=$(uname -m)
	WARN "即将重新安装EMBY，将删除DOCKER中的名为emby的容器（小雅全家桶默认），如果你的容器名不是emby,请输入你的小雅EMBY的容器名"
	read -ep "默认emby(任意键)/或重新输入：" emby_name
	[[ -z "${emby_name}" ]] && emby_name="emby"
	echo $emby_name > /root/xiaoya_emby_name.txt
	INFO "请输入需要更新的EMBY版本(不能从高版本降到低版本)："
	echo -e "1.小雅默认4.8.0.56(默认)"
	echo -e "2.更新为4.8.0.63"
	echo -e "3.更新为4.8.0.67"
	echo -e "4.更新为最新版本"
	echo -e "5.自行输入版本号"
	read -ep "请选择（1-5）" ver_sel
	emby_ver="4.8.0.56"
	case $ver_sel in
		1)
			emby_ver="4.8.0.56"
			;;
		2)
			emby_ver="4.8.0.63"
			;;
		3)
			emby_ver="4.8.0.67"
			;;
		4)
			emby_ver="latest"
			;;
		5)
			read -ep "请输入版本号：" ver_other
			emby_ver=$ver_other
			;;
		*)
			emby_ver="4.8.0.56"
			;;
	esac
	INFO "选择安装的EMBY版本为：$emby_ver"
	case $cpu_arch in
        "x86_64" | *"amd64"*)
			docker pull emby/embyserver:$emby_ver
			;;
        "aarch64" | *"arm64"* | *"armv8"* | *"arm/v8"*)
            docker pull emby/embyserver_arm64v8:$emby_ver
            ;;
        *)
            echo "目前只支持intel64和amd64架构，你的架构是：$cpu_arch"
            exit 1
            ;;
    esac
	echo -e "——————————————————————————————————————————————————————————————————————————————————"
	echo "开始安装Emby容器....."
	docker stop $emby_name 2>/dev/null
    docker rm $emby_name 2>/dev/null
	docker_exist=$(docker images |grep emby/embyserver |grep $emby_ver)
	if [ -z "$docker_exist" ]; then
		echo "拉取镜像失败，请检查网络，或者翻墙后再试"
		exit 1
	fi
	case $cpu_arch in
		"x86_64" | *"amd64"*)
			docker run -d --name $emby_name -v ${MEDIA_DIR}/config:/config -v ${MEDIA_DIR}/config_data:/config/data -v ${MEDIA_DIR}/xiaoya:/media --net=host --user 0:0 --restart always emby/embyserver:$emby_ver
			echo "EMBY增加CONFIG映射目录及更新完成"
			;;
		"aarch64" | *"arm64"* | *"armv8"* | *"arm/v8"*)
		    docker run -d --name $emby_name -v ${MEDIA_DIR}/config:/config -v ${MEDIA_DIR}/config_data:/config/data -v ${MEDIA_DIR}/xiaoya:/media --net=host  --user 0:0 --restart always emby/embyserver_arm64v8:$emby_ver
			echo "EMBY增加CONFIG映射目录及更新完成"
            ;;
		*)
			echo "目前只支持intel64和amd64架构，你的架构是：$cpu_arch"
			exit 1
			;;
	esac
}

function get_config_dir(){

    if [ -f /root/xiaoya_alist_config_dir.txt ]; then
        OLD_CONFIG_DIR=$(cat /root/xiaoya_alist_config_dir.txt)
        INFO "已读取小雅Alist配置文件路径：${OLD_CONFIG_DIR} (默认不更改回车继续，如果需要更改请输入新路径)"
        read -ep "CONFIG_DIR:" CONFIG_DIR
        [[ -z "${CONFIG_DIR}" ]] && CONFIG_DIR=${OLD_CONFIG_DIR}
        echo ${CONFIG_DIR} > /root/xiaoya_alist_config_dir.txt
    else
        INFO "请输入配置文件目录（默认 /etc/xiaoya ）"
        read -ep "CONFIG_DIR:" CONFIG_DIR
        [[ -z "${CONFIG_DIR}" ]] && CONFIG_DIR="/etc/xiaoya"
        touch /root/xiaoya_alist_config_dir.txt
        echo ${CONFIG_DIR} > /root/xiaoya_alist_config_dir.txt
    fi

}

function get_media_dir(){

    if [ -f /root/xiaoya_alist_media_dir.txt ]; then
        OLD_MEDIA_DIR=$(cat /root/xiaoya_alist_media_dir.txt)
        INFO "已读取媒体库目录：${OLD_MEDIA_DIR} (默认不更改回车继续，如果需要更改请输入新路径)"
        read -ep "MEDIA_DIR:" MEDIA_DIR
        [[ -z "${MEDIA_DIR}" ]] && MEDIA_DIR=${OLD_MEDIA_DIR}
        echo ${MEDIA_DIR} > /root/xiaoya_alist_media_dir.txt
		echo ${MEDIA_DIR}/config/data > /root/xiaoya_emby_configdata_dir.txt
		echo ${MEDIA_DIR}/config_data > /root/xiaoya_emby_configdata_new_dir.txt
    else
        INFO "请输入媒体库目录（默认 /opt/media ）"
        read -ep "MEDIA_DIR:" MEDIA_DIR
        [[ -z "${MEDIA_DIR}" ]] && MEDIA_DIR="/etc/xiaoya"
        touch /root/xiaoya_alist_media_dir.txt
        echo ${MEDIA_DIR} > /root/xiaoya_alist_media_dir.txt
    fi

}


function root_need(){
    if [[ $EUID -ne 0 ]]; then
        ERROR '此脚本必须以 root 身份运行！'
        exit 1
    fi
}
function sqlite_need() {  
    # 检查SQLite3是否已安装  
    if ! command -v sqlite3 &> /dev/null; then  
        ERROR "sqlite3未安装。请安装sqlite3后再次运行此脚本。"
		INFO "安装方式请自行搜索"
		WARN "目前用yum方式安装的sqlite3有问题（至少在Centos上），请Centos用户采用编译方式安装"
		INFO "如果脚本执行后EMBY打开有问题，多半是sqlite3的问题"	
        exit 1  
    fi  
}  
function jq_need(){
	# 判断是否安装了jq  
	if ! command -v jq &> /dev/null; then  
		ERROR "jq未安装，请运行以下命令进行安装："  
		echo -e "apt-get install jq"  # Ubuntu/Debian系统  
		echo -e "yum install jq"      # CentOS/RedHat系统  
		echo -e "dnf install jq"      # Fedora系统  
		exit 1
	fi
}
function main(){
	root_need
	jq_need
	sqlite_need
	emby_name=$(cat /root/xiaoya_emby_name.txt)
	clear
	if [ $1 == 1 ]; then
		INFO "后台模式"
		emby_config_data=$(cat /root/xiaoya_emby_configdata_dir.txt)
		emby_config_data_new=$(cat /root/xiaoya_emby_configdata_new_dir.txt)
		INFO "停止EMBY"
		docker stop $emby_name
		INFO "同步library.db并保留用户播放记录"
		rm -f /root/xiaoya_emby_library_user.sql
		sqlite3 ${emby_config_data_new}/library.db ".dump UserDatas" > /root/xiaoya_emby_library_user.sql
		rm -f ${emby_config_data_new}/library.db*
		cp -f ${emby_config_data}/library.db ${emby_config_data_new}/
		sqlite3 ${emby_config_data_new}/library.db "DROP TABLE IF EXISTS UserDatas;"
		sqlite3 ${emby_config_data_new}/library.db ".read /root/xiaoya_emby_library_user.sql"
		chmod 777 ${emby_config_data_new}/library.db*
		INFO "启动EMBY"
		docker start $emby_name
		check_emby_started 1
	else
		#get_config_dir
		get_media_dir
		update_config 0
	fi
}

if [ $# -eq 0 ] || [ "$1" != "s" ]; then
	main 0
else
	main 1
fi
