#!/usr/bin/env bash
echo "******************cdn刷新查询 脚本*******************
1、cdn单文件刷新
2、cdn单目录刷新
3、cdn配置文件刷新
4、刷新进度查询
*****************************************************
"
read -p "选择您想要的功能:" num
ak=$1
sk=$2
if [ -f "~/.cdn_log" ];then
    touch ~/.cdn_log
fi

fresh_url(){
    read -p "请输入您要刷新的url:" url
    scheme=$(echo $url | awk -F '://' '{print $1}')
        while [ "$url" == "" ]
        do
        read -p "输入为空，请重新输入:" url
        done
        while [ "$scheme" != "http" ]&&[ "$scheme" != "https" ]
        do
        read -p "输入不合法，url需带上http或者https，请重新输入:" url
        scheme=$(echo $url | awk -F '://' '{print $1}')
        done
        without_Backslash=`echo ${url%?}`
        Backslash=`echo ${url##$without_Backslash}`
        while [ "$Backslash" == '/' ]
        do
        read -p "需输入为刷新的文件非目录，请重新输入:" url
        without_Backslash=`echo ${url%?}`
        Backslash=`echo ${url##$without_Backslash}`
        done
    token=$(echo "/v2/tune/refresh" |openssl dgst -binary -hmac "$sk" -sha1 |base64 | tr + - | tr / _ )
    final=`curl -X POST -H "Authorization: QBox $ak:$token" http://fusion.qiniuapi.com/v2/tune/refresh -d "{\"urls\":[\"$url\"]}" -H 'Content-Type: application/json'`
    code=$(echo $final| awk -F ',' '{print $1}' | awk -F ':' '{print $2}')
    requestID=$(echo $final| awk -F ',' '{print $3}' | awk -F ':' '{print $2}' )
    urlSurplusDay=$(echo $final | awk -F ',' '{print $8}' | awk -F ':' '{print $2}')
    if [ "$code" == "200" ];then
    echo 状态码: $code
    echo requestID: $requestID
    echo 刷新的url:$url
    echo 管理凭证: $token
    echo 每日文件剩余刷新次数: $urlSurplusDay
    else
    echo 错误状态: $final
    fi
    echo -e `date`:$final\ >> ~/.cdn_log
}

fresh_dir(){
    read -p "请输入您要刷新的目录:" dir
    scheme=$(echo $dir | awk -F '://' '{print $1}')
       while [ "$dir" == "" ]
        do
        read -p "输入为空，请重新输入:" dir
        done
        while [ "$scheme" != "http" ]&&[ "$scheme" != "https" ]
        do
        read -p "输入不合法，url需带上http或者https，请重新输入:" dir
        scheme=$(echo $url | awk -F '://' '{print $1}')
        done
        without_Backslash=`echo ${dir%?}`
        Backslash=`echo ${dir##$without_Backslash}`
        while [ "$Backslash" == '/' ]
        do
        read -p "需输入为刷新的目录非文件，请重新输入:" dir
        without_Backslash=`echo ${dir%?}`
        Backslash=`echo ${dir##$without_Backslash}`
        done
    token=$(echo "/v2/tune/refresh" |openssl dgst -binary -hmac "$sk" -sha1 |base64 | tr + - | tr / _ )
    final=`curl -X POST -H "Authorization: QBox $ak:$token" http://fusion.qiniuapi.com/v2/tune/refresh -d "{\"dirs\":[\"$dir\"]}" -H 'Content-Type: application/json'`
    code=$(echo $final| awk -F ',' '{print $1}' | awk -F ':' '{print $2}')
    requestID=$(echo $final| awk -F ',' '{print $3}' | awk -F ':' '{print $2}' )
    dirSurplusDay=$(echo $final | awk -F ',' '{print $10}' | awk -F ':' '{print $2}')
    if [ "$code" == "200" ];then
    echo 状态码: $code
    echo requestID: $requestID
    echo 刷新的目录:$dir
    echo 管理凭证: $token
    echo 每日目录剩余刷新次数: $dirSurplusDay
    else
    echo 错误状态: $final
    fi
    echo -e `date`:$final\ >> ~/.cdn_log
}

fresh_conf(){
    read -p "请输入您的配置文件绝对地址:" local_file
        while [ "$local_file" == "" ]|| [ ! -f "$local_file" ] 
        do
        read -p "输入的本地配置文件为空或不存在,请重新输入:" local_file
        done
        while [ -d "$local_file" ]
        do 
        read -p "输入的不是文件,请重新输入:" local_file
        done
    final_file=$(cat $local_file | awk -F ',' '{print $1}' | xargs echo )
    without_Backslash=`echo ${final_file%?}`
    Backslash=`echo ${final_file##$without_Backslash}`
    echo $Backslash
    token=$(echo "/v2/tune/refresh" |openssl dgst -binary -hmac "$sk" -sha1 |base64 | tr + - | tr / _ )
    if [ "$Backslash" != '/' ];then
    final=`curl -X POST -H "Authorization: QBox $ak:$token" http://fusion.qiniuapi.com/v2/tune/refresh -d "{\"urls\":[$(cat $local_file)]}" -H 'Content-Type: application/json'`
    code=$(echo $final| awk -F ',' '{print $1}' | awk -F ':' '{print $2}')
    requestID=$(echo $final| awk -F ',' '{print $3}' | awk -F ':' '{print $2}' )
    urlSurplusDay=$(echo $final | awk -F '}' '{print $2}' | awk -F ':' '{print $5}'| awk -F ',' '{print $1}')
    if [ "$code" == "200" ];then
    echo 状态码: $code
    echo requestID: $requestID
    echo 刷新的文件：`cat $local_file`
    echo 管理凭证: $token
    echo 每日文件剩余刷新次数: $urlSurplusDay
    else  
    echo 错误状态: $final 
    fi
    echo -e `date`:$final\ >> ~/.cdn_log
    else
    final=`curl -X POST -H "Authorization: QBox $ak:$token" http://fusion.qiniuapi.com/v2/tune/refresh -d "{\"dirs\":[$(cat $local_file)]}" -H 'Content-Type: application/json'`
    code=$(echo $final| awk -F ',' '{print $1}' | awk -F ':' '{print $2}')
    requestID=$(echo $final| awk -F ',' '{print $3}' | awk -F ':' '{print $2}' )
    dirSurplusDay=$(echo $final | awk -F '}' '{print $2}' | awk -F ':' '{print $7}'| awk -F '}' '{print $1}')
    if [ "$code" == "200" ];then
    echo 状态码: $code
    echo requestID: $requestID
    echo 刷新的目录：`cat $local_file`
    echo 管理凭证: $token
    echo 每日目录剩余刷新次数: $dirSurplusDay
    else 
    echo 错误状态: $final
    fi
    echo -e `date`:$final\ >> ~/.cdn_log
    fi
}

get_fresh(){
    read -p "请输入您的配置文件绝对地址:" local_file
        while [ "$local_file" == "" ]|| [ ! -f "$local_file" ] 
        do
        read -p "输入的本地配置文件为空或不存在,请重新输入:" local_file
        done
        while [ -d "$local_file" ]
        do 
        read -p "输入的不是文件,请重新输入:" local_file
        done
    token=$(echo "/v2/tune/refresh/list" |openssl dgst -binary -hmac "$sk" -sha1 |base64 | tr + - | tr / _ )
    final=`curl -X POST -H "Authorization: QBox $ak:$token" http://fusion.qiniuapi.com/v2/tune/refresh/list -d "{$(cat $local_file)}" -H 'Content-Type: application/json'`
    echo 返回状态: $final
}


choose(){
case "$num" in
1)
fresh_url
;;
2)
fresh_dir
;;
3)
fresh_conf
;;
4)
get_fresh
;;
*)
read -p "非法输入，请输入正确的数字[1-4]:" num
choose
;;
esac
}
choose
