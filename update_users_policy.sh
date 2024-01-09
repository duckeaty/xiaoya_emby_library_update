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
    echo -e "小雅EMBY同步-用户策略更新"
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
	INFO "请打开小雅EMBY测试该脚本是否有效"
	read -ep "有效(任意键)/无效(N)" isRight
	if [[ $isRight == "N" || $isRight == "n" ]]; then
		echo echo -e "请TG群内反馈，暂不要使用该脚本"
	else
		echo -e "确认有效，可以按以下方法添加自动计划任务"
		echo -e "——————————————————————————————————————————————————————————————————————————————————"
		echo -e "如需每天6点30分自动执行，在命令行输入："
		echo -e "crontab -e ,然后添加以下内容："
		echo -e "30 6 * * * bash -c \"\$(cat 本脚本的绝对地址)\" -s s"
		echo -e "——————————————————————————————————————————————————————————————————————————————————"
		echo -e "一键添加计划任务"
		INFO "强烈建议自行手动添加！"
		read -ep "手动添加(任意键)/自动添加(Y)" isRight
		if [[ $isRight == "Y" || $isRight == "y" ]]; then
			INFO "请输入计划时间，例：30 6 * * *，这个代表每天6点30分，注意，数字和*之前都有空格，格式一定要正确！"
			read -ep "请输入：" crontab_time
			script_path=$(cd `dirname $0`; pwd)
			script_filename=$(basename $0)
			(crontab -l 2>/dev/null; echo "$crontab_time bash -c \"\$(cat $script_path/$script_filename)\" -s s") | crontab -
			INFO "添加自动计划成功，请自行crontab验证！"
			INFO "请不要更改本脚本目录地址及文件名，否则会出错或失效，如需更改，请自行crontab -e中删除该计划，然后重新运行本脚本！"
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

function root_need(){
    if [[ $EUID -ne 0 ]]; then
        ERROR '此脚本必须以 root 身份运行！'
        exit 1
    fi
}
function jq_need(){
	# 判断是否安装了jq  
	if ! command -v jq &> /dev/null; then  
		echo "jq未安装，请运行以下命令进行安装："  
		echo "sudo apt-get install jq"  # Ubuntu/Debian系统  
		echo "sudo yum install jq"      # CentOS/RedHat系统  
		echo "sudo dnf install jq"      # Fedora系统  
		exit 1  
	fi
}
function main(){
	root_need
	jq_need
	curl -sLo /root/update_users_policy.sh https://github.com/duckeaty/main.sh
	clear
	main_updatepolicy $1
}

if [ $# -eq 0 ] || [ "$1" != "s" ]; then
	main 0
else
	main 1
fi
