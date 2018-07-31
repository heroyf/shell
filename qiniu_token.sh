#!/usr/bin/env bash
if [ "$1" = "" ]; then
    echo 'must specify $1 eg: token xxx'
    exit 1
else
    policybase64=$(echo $1 | awk -F ":" '{print $3}')
    policy=$(base64 -D <<<$policybase64)
    echo $policy
    key=$(echo $policy | awk -F "scope" '{print $2}' | awk -F "," '{print $1}' | awk -F ":" '{print $3}')
fi

if [$key = ""]; then
    dd if=/dev/zero of=1M.file bs=1m count=1
    echo 'curl -vo /dev/null upload.qiniu.com -F"token=$token" -F"file=@$1M.file"'
    curl -v upload.qiniu.com -F"token=$1" -F"file=@1M.file"
else
    key1=$(echo $key | awk -F '"' '{print $1}')
    dd if=/dev/zero of=1M.file bs=1m count=1
    echo 'curl -vo /dev/null upload.qiniu.com -F"token=$token" -F"file=@$1M.file"'
    curl -v upload.qiniu.com -F"token=$1" -F"key=$key1" -F"file=@1M.file"
fi

rmfile=1M.file
rm $rmfile
echo ""
echo '上传策略为:'
policy=$(echo $1 | awk -F ":" '{print $3}')
date=$(echo $policy | base64 -D| sed 's/[{}]//g' | awk 'BEGIN{FS=":"} {print $3}')
echo policy字段: $policy
echo policy字段base64解码是: `base64 -D <<<$policy`
echo policy字段过期时间为： `date -r  $date`
