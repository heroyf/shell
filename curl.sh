#!/usr/bin/env bash
echo "**********************curl 脚本**********************
1、中间源访问检测
2、边缘访问检测
3、特定cdn节点访问检测
4、客户源站访问检测(源站测试也可用)
*****************************************************
"
read -p "选择您想要的功能:" num



sourceCNAME(){
echo "中间源访问检测"
read -p "请输入访问的资源：" a1 
if [ "$a1" = "" ]; then
    echo 'must specify file path'
    exit 1
else
    read -p "请输入sourceCNAME：" b1
    if [ "$b1" = "" ]; then
    echo 'must specify sourceCNAME path'
    exit 1
    fi
fi

c1=$(echo $a1 | awk -F '://' '{print $1}')
if [ "$c1" = "http" ] || [ "$c1" = "https" ]; then
    d1=$(echo $a1 | awk -F '://' '{print $2}' )
fi
if [ "$c1" != "http" ] && [ "$c1" != "https" ]; then
    d1=$(echo $a1 )
fi

e1=$(echo $b1 | awk -F ':' '{print $2}')
if [ "$e1" == "" ]; then
    proxy=$b1:80
fi
if [ "$e1" != "" ]; then
    proxy=$b1
fi

f1=$(echo $b1 | awk -F ':' '{print $1}')
echo 中间源： `dig $f1 cname +short`
curl -I $d1 -x $proxy | head -1 
}


edge(){
echo "边缘访问检测"
read -p "请输入访问的资源：" a2
if [ "$a2" = "" ]; then
    echo 'must specify file path'
    exit 1
fi
curl  -I $a2  | head -1
}

resolve(){
echo "特定cdn节点访问检测"
read -p "请输入访问的资源：" a3 
if [ "$a3" = "" ]; then
    echo 'must specify file path'
    exit 1
else
    read -p "请输入用户提供的节点ip：" b3
    if [ "$b3" = "" ]; then
    echo 'must specify ip'
    exit 1
    else if [ "$b3" != "" ];then
            while [ `echo $b3 | awk -F '.' '$1>255||$2>255||$3>255||$4>255'` ]
            do 
            read -p "非法ip,请输入正确的节点ip：" b3
            done
        fi
    fi  
fi
scheme=$(echo $a3 | awk -F '://' '{print $1}')

if [ "$scheme" = "http" ] || [ "$scheme" = "https" ]; then
    domain=$(echo $a3 | awk -F '://' '{print $2}' | awk -F '/' '{print $1}')
    if [ "$scheme" = "http" ];then
        finaldomain=$domain:80
    else if [ "$scheme" = "https" ];then
        finaldomain=$domain:443
        fi
    fi
fi
if [ "$scheme" != "http" ] && [ "$scheme" != "https" ]; then
    finaldomain=$(echo $a3 | awk -F '/' '{print $1}'):80
fi

#echo $finaldomain,$b3
curl  -I $a3 --resolve $finaldomain:$b3  | head -1
}

sourceHOST(){
echo "客户源站访问检测(源站测试也可用)"
read -p "请输入访问的资源：" a4
if [ "$a4" = "" ]; then
    echo 'must specify file path'
    exit 1
else
    read -p "请输入客户源站(或者回源hostq)：" b4
    if [ "$b4" = "" ]; then
    echo 'must specify source path'
    exit 1
    fi
fi
c4=$(echo $b4 | awk -F '://' '{print $1}')
if [ "$c4" = "http" ] || [ "$c4" = "https" ]; then
    d4=$(echo $a4 | awk -F '://' '{print $2}' )
fi
if [ "$c4" != "http" ] && [ "$c4" != "https" ]; then
    d4=$(echo $a4 )
fi
curl -I $d4 -H  HOST:$b4 | head -1
}

choose(){
case "$num" in
1)
sourceCNAME
;;
2)
edge
;;
3)
resolve
;;
4)
sourceHOST
;;
*)
read -p "非法输入，请输入正确的数字[1-4]:" num
choose
;;
esac
}
choose
