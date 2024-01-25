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

DUCKEATY_CONFIG_DIR=/root/xiaoya_emby_library_config

function get_media_dir(){

    if [ -f $DUCKEATY_CONFIG_DIR/xiaoya_alist_media_dir.txt ]; then
        OLD_MEDIA_DIR=$(cat ${DUCKEATY_CONFIG_DIR}/xiaoya_alist_media_dir.txt)
        INFO "已读取媒体库目录：${OLD_MEDIA_DIR} (默认不更改回车继续，如果需要更改请输入新路径)"
        read -ep "MEDIA_DIR:" MEDIA_DIR
        [[ -z "${MEDIA_DIR}" ]] && MEDIA_DIR=${OLD_MEDIA_DIR}
        echo ${MEDIA_DIR} > ${DUCKEATY_CONFIG_DIR}/xiaoya_alist_media_dir.txt
		echo ${MEDIA_DIR}/config/data > ${DUCKEATY_CONFIG_DIR}/xiaoya_emby_configdata_dir.txt
		echo ${MEDIA_DIR}/config_data > ${DUCKEATY_CONFIG_DIR}/xiaoya_emby_configdata_new_dir.txt
    else
        INFO "请输入媒体库目录"
        read -ep "MEDIA_DIR:" MEDIA_DIR
        [[ -z "${MEDIA_DIR}" ]] && MEDIA_DIR="/etc/xiaoya"
		echo "${DUCKEATY_CONFIG_DIR}/xiaoya_alist_media_dir.txt"
        touch ${DUCKEATY_CONFIG_DIR}/xiaoya_alist_media_dir.txt
        echo ${MEDIA_DIR} > ${DUCKEATY_CONFIG_DIR}/xiaoya_alist_media_dir.txt
    fi

}

function get_embyurl(){
    if [ -f ${DUCKEATY_CONFIG_DIR}/xiaoya_emby_url.txt ]; then
        OLD_EMBY_URL=$(cat ${DUCKEATY_CONFIG_DIR}/xiaoya_emby_url.txt)
        INFO "已读取小雅Emby地址：${OLD_EMBY_URL} (默认不更改回车继续，如果需要更改请输入新地址)"
        read -ep "请输入: " EMBY_URL
        [[ -z "${EMBY_URL}" ]] && EMBY_URL=${OLD_EMBY_URL}
        echo ${EMBY_URL} > ${DUCKEATY_CONFIG_DIR}/xiaoya_emby_url.txt
    else
        INFO "请输入你的小雅Emby的内网访问地址，如：http://192.168.1.1:2345"
        read -ep "请输入: " EMBY_URL
        touch ${DUCKEATY_CONFIG_DIR}/xiaoya_emby_url.txt
        echo ${EMBY_URL} > ${DUCKEATY_CONFIG_DIR}/xiaoya_emby_url.txt
    fi
}

function get_embyapi(){
    if [ -f ${DUCKEATY_CONFIG_DIR}/xiaoya_emby_api.txt ]; then
        OLD_EMBY_API=$(cat ${DUCKEATY_CONFIG_DIR}/xiaoya_emby_api.txt)
        INFO "已读取小雅Emby的API密钥：${OLD_EMBY_API} (默认不更改回车继续，如果需要更改请输入新的API密钥)"
        read -ep "请输入: " EMBY_API
        [[ -z "${EMBY_API}" ]] && EMBY_API=${OLD_EMBY_API}
        echo ${EMBY_API} > ${DUCKEATY_CONFIG_DIR}/xiaoya_emby_api.txt
    else
        INFO "请输入小雅Emby的API密钥"
        read -ep "请输入: " EMBY_API
        touch ${DUCKEATY_CONFIG_DIR}/xiaoya_emby_api.txt
        echo ${EMBY_API} > ${DUCKEATY_CONFIG_DIR}/xiaoya_emby_api.txt
    fi
}

function get_allproxy(){
    if [ -f ${DUCKEATY_CONFIG_DIR}/xiaoya_emby_allproxy.txt ]; then
        OLD_EMBY_ALLPROXY=$(cat ${DUCKEATY_CONFIG_DIR}/xiaoya_emby_allproxy.txt)
        INFO "已读取小雅Emby的ALLPROXY地址：${OLD_EMBY_ALLPROXY} (默认不更改回车继续，如果需要更改请输入新地址)"
        read -ep "请输入: " EMBY_ALLPROXY
        [[ -z "${EMBY_ALLPROXY}" ]] && EMBY_ALLPROXY=${OLD_EMBY_ALLPROXY}
        echo ${EMBY_ALLPROXY} > ${DUCKEATY_CONFIG_DIR}/xiaoya_emby_allproxy.txt
    else
        INFO "请输入你的小雅Emby的ALL_PROXY地址，如：http://192.168.1.1:7893"
        read -ep "请输入: " EMBY_ALLPROXY
        touch ${DUCKEATY_CONFIG_DIR}/xiaoya_emby_allproxy.txt
        echo ${EMBY_ALLPROXY} > ${DUCKEATY_CONFIG_DIR}/xiaoya_emby_allproxy.txt
    fi
}

function get_httpproxy(){
    if [ -f ${DUCKEATY_CONFIG_DIR}/xiaoya_emby_httpproxy.txt ]; then
        OLD_EMBY_HTTPPROXY=$(cat ${DUCKEATY_CONFIG_DIR}/xiaoya_emby_httpproxy.txt)
        INFO "已读取小雅Emby的ALLPROXY地址：${OLD_EMBY_HTTPPROXY} (默认不更改回车继续，如果需要更改请输入新地址)"
        read -ep "请输入: " EMBY_HTTPPROXY
        [[ -z "${EMBY_HTTPPROXY}" ]] && EMBY_HTTPPROXY=${OLD_EMBY_HTTPPROXY}
        echo ${EMBY_HTTPPROXY} > ${DUCKEATY_CONFIG_DIR}/xiaoya_emby_httpproxy.txt
    else
        INFO "请输入你的小雅Emby的HTTP_PROXY地址，如：http://192.168.1.1:7890"
        read -ep "请输入: " EMBY_HTTPPROXY
        touch ${DUCKEATY_CONFIG_DIR}/xiaoya_emby_httpproxy.txt
        echo ${EMBY_HTTPPROXY} > ${DUCKEATY_CONFIG_DIR}/xiaoya_emby_httpproxy.txt
    fi
}

function install_emby_library(){

    get_media_dir

    get_embyapi

    get_embyurl
	
    INFO "请输入小雅Emby的容器名（默认 $(cat ${DUCKEATY_CONFIG_DIR}/xiaoya_emby_name.txt) ）"
    read -ep "EMBY_NAME:" EMBY_NAME
    [[ -z "${EMBY_NAME}" ]] && EMBY_NAME="$(cat ${DUCKEATY_CONFIG_DIR}/xiaoya_emby_name.txt)"

    INFO "请输入计划时间，例：30 6 * * *，这个代表每天6点30分，注意，数字和*之前都有空格，格式一定要正确！（默认 30 6 * * * ）"
    read -ep "CRON:" CRON
    [[ -z "${CRON}" ]] && CRON="30 6 * * *"

    INFO "是否自动删除旧Emby容器重新配置 [Y/n]（默认 n）"
    read -ep "REMOVE:" REMOVE
    [[ -z "${REMOVE}" ]] && REMOVE="n"
    if [[ ${REMOVE} == [Yy] ]]; then
        docker stop ${EMBY_NAME}
        docker rm ${EMBY_NAME}
        if [ ! -d ${MEDIA_DIR}/config_data ]; then
            mkdir -p ${MEDIA_DIR}/config_data
			cp -rf ${MEDIA_DIR}/config/data/* ${MEDIA_DIR}/config_data/
        fi
        #cp -rf ${MEDIA_DIR}/config/data/* ${MEDIA_DIR}/config_data/
        #MOUNT="-v ${MEDIA_DIR}/config_data:/config/data"
        emby_reinstall
    else
        INFO "请手动删除Emby容器，并添加一个目录映射：-v ${MEDIA_DIR}/config_data:/config/data"
        read -ep "按任意键继续..." abcdefg
    fi

    INFO "开始安装xiaoya-emby-library-update..."
	if docker ps -a | grep -q xiaoya-emby-library-update; then  
		docker stop xiaoya-emby-library-update 2>/dev/null
		docker rm xiaoya-emby-library-update 2>/dev/null
	fi

    docker run -itd \
        --name=xiaoya-emby-library-update \
        -v ${MEDIA_DIR}:/data \
        -v /var/run/docker.sock:/var/run/docker.sock:ro \
        --net=host \
        -e EMBY_NAME=${EMBY_NAME} \
        -e EMBY_API=${EMBY_API} \
        -e EMBY_URL=${EMBY_URL} \
        -e "CRON=${CRON}" \
        --restart=always \
        duckeaty/xiaoya-emby-library:latest

    INFO "安装完成！"
	INFO "正在更新library.db"
	echo -e "——————————————————————————————————————————————————————————————————————————————————"
	INFO "正在更新，时间可能较长，请等待..."
	library_logs
	echo -e "——————————————————————————————————————————————————————————————————————————————————"
	INFO "已新增DOCKER容器xiaoya-emby-library-update"
	WARN "请不要停止该容器，如需要及时更新library.db，重启此容器即可！"
	main_emby_library

}

function library_logs() {
	# 容器名称或ID  
	CONTAINER_NAME="xiaoya-emby-library-update"  
	SINCE_TIME=$(date +"%Y-%m-%dT%H:%M:%S")
	# 实时输出日志
	while true; do
		line=$(docker logs --since "$SINCE_TIME" "$CONTAINER_NAME" | tail -n 1)
		if [[ "$line" == *"crond (busybox 1.36.1) started, log level 8"* ]]; then
			INFO "更新完成，并已添加计划任务！"
			break
		fi
		sleep 3
	done
	#INFO "更新完成，并已添加计划任务！" 
}

function emby_reinstall(){
	#CONFIG_DIR=$(cat ${DUCKEATY_CONFIG_DIR}/xiaoya_alist_config_dir.txt)
	MEDIA_DIR=$(cat ${DUCKEATY_CONFIG_DIR}/xiaoya_alist_media_dir.txt)
	EMBY_NAME=$(cat ${DUCKEATY_CONFIG_DIR}/xiaoya_emby_name.txt)
	cpu_arch=$(uname -m)
	WARN "即将重新安装EMBY，将删除DOCKER中的名为${EMBY_NAME}的容器（小雅全家桶默认），如果你的容器名不是${EMBY_NAME},请输入你的小雅EMBY的容器名"
	read -ep "默认emby(任意键)/或重新输入：" emby_name
	[[ -z "${emby_name}" ]] && emby_name="emby"
	echo $emby_name > ${DUCKEATY_CONFIG_DIR}/xiaoya_emby_name.txt
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
	emby_proxy=""
	WARN "是否添加代理 [Y/N]"
	read -ep "默认NO(任意键)：" emby_isproxy
	[[ -z "${emby_isproxy}" ]] && emby_isproxy="n"
	if [[ $emby_isproxy == [Yy] ]]; then
		get_allproxy
		get_httpproxy
		EMBY_ALLPROXY=$(cat ${DUCKEATY_CONFIG_DIR}/xiaoya_emby_allproxy.txt)
		EMBY_HTTPPROXY=$(cat ${DUCKEATY_CONFIG_DIR}/xiaoya_emby_httpproxy.txt)
		EMBY_NOPORXY="127.0.0.1,localhost"
		emby_proxy=" -e ALL_PROXY=${EMBY_ALLPROXY} -e HTTP_PROXY=${EMBY_HTTPPROXY} -e NO_PROXY=${EMBY_NOPORXY} "
	fi
	emby_dri=""
	WARN "是否添加显卡直通，如需添加，请确认你已经做好显卡直通 [Y/N]"
	read -ep "默认NO(任意键)：" emby_isdri
	[[ -z "${emby_isdri}" ]] && emby_isdri="n"
	if [[ $emby_isdri == [Yy] ]]; then
		emby_dri=" --device=/dev/dri"
	fi
	
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
			docker run -d --name $emby_name -v /etc/nsswitch.conf:/etc/nsswitch.conf ${emby_dri} -v ${MEDIA_DIR}/config:/config -v ${MEDIA_DIR}/config_data:/config/data -v ${MEDIA_DIR}/xiaoya:/media ${emby_proxy} --net=host --user 0:0 --restart always emby/embyserver:$emby_ver
			echo "EMBY增加CONFIG映射目录及更新完成"
			;;
		"aarch64" | *"arm64"* | *"armv8"* | *"arm/v8"*)
		    docker run -d --name $emby_name -v /etc/nsswitch.conf:/etc/nsswitch.conf ${emby_dri} -v ${MEDIA_DIR}/config:/config -v ${MEDIA_DIR}/config_data:/config/data -v ${MEDIA_DIR}/xiaoya:/media ${emby_proxy} --net=host  --user 0:0 --restart always emby/embyserver_arm64v8:$emby_ver
			echo "EMBY增加CONFIG映射目录及更新完成"
            ;;
		*)
			echo "目前只支持intel64和amd64架构，你的架构是：$cpu_arch"
			exit 1
			;;
	esac
	INFO "请等待EMBY启动"
	CONTAINER_NAME=$emby_name
	SINCE_TIME=$(date +"%Y-%m-%dT%H:%M:%S")
	TARGET_LOG_LINE_OK="All entry points have started"
	while true; do
        line=$(docker logs --since "$SINCE_TIME" "$CONTAINER_NAME" | tail -n 1)
        echo $line
		if [[ "$line" == *"$TARGET_LOG_LINE_OK"* ]]; then
			INFO "emby启动完成！"
			break
		fi
		sleep 3
	done
}

function uninstall_emby_library(){

    for i in `seq -w 3 -1 0`
    do
        echo -en "即将开始卸载自动同步Emby数据库${Blue} $i ${Font}\r"  
    sleep 1;
    done
    docker stop xiaoya-emby-library-update
    docker rm xiaoya-emby-library-update
    docker rmi duckeaty/xiaoya-emby-library:latest
	WARN "是否删除脚本配置文件 [Y/N]"
	read -ep "默认NO(任意键)：" isrm
	[[ -z "${isrm}" ]] && isrm="n"
	if [[ $isrm == [Yy] ]]; then
		if [ -d ${DUCKEATY_CONFIG_DIR} ]; then
			rm -rf ${DUCKEATY_CONFIG_DIR}
		fi
	fi
    INFO "卸载成功！"

}

function root_need(){
    if [[ $EUID -ne 0 ]]; then
        ERROR '此脚本必须以 root 身份运行！'
        exit 1
    fi
}

function main_emby_library(){
	root_need
	#echo ${DUCKEATY_CONFIG_DIR}
	if [ ! -d ${DUCKEATY_CONFIG_DIR} ]; then
        mkdir -p ${DUCKEATY_CONFIG_DIR}
		chmod +w ${DUCKEATY_CONFIG_DIR}
    fi
	if [ -f ${DUCKEATY_CONFIG_DIR}/xiaoya_emby_name.txt ]; then
		emby_name=$(cat ${DUCKEATY_CONFIG_DIR}/xiaoya_emby_name.txt)
	else
		echo "emby" > ${DUCKEATY_CONFIG_DIR}/xiaoya_emby_name.txt
		emby_name="emby"
	fi
	
    echo -e "——————————————————————————————————————————————————————————————————————————————————"
    echo -e "${Blue}自动同步Emby数据库${Font}\n"
    echo -e "1、安装"
    echo -e "2、卸载"
	echo -e "3、退出"
    echo -e "——————————————————————————————————————————————————————————————————————————————————"
    read -ep "请输入数字 [1-3]:" num
    case "$num" in
        1)
        clear
        install_emby_library
        ;;
        2)
        clear
        uninstall_emby_library
        ;;
		3)
        echo "正在退出脚本..."
        exit 0
        ;;
        *)
        clear
        ERROR '请输入正确数字 [1-3]'
        main_emby_library
        ;;
        esac

}
clear
main_emby_library
