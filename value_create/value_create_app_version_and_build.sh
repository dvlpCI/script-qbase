#!/bin/bash
###
 # @Author: dvlproad
 # @Date: 2023-06-09 19:24:14
 # @LastEditors: dvlproad
 # @LastEditTime: 2023-11-01 16:59:26
 # @Description: 获取给app的版本号和build号
### 

cur_date_year_full=$(date "+%Y") # 小y:19  大Y:2019
cur_date_year_short=$(date "+%y") # 小y:19  大Y:2019

# 更改app信息，并返回 VERSION 和 BUILD
#VERSION="1."$(date "+%m.%d") # 1.02.21
#BUILD=$(date "+%m%d%H%M") # 02211506
cur_date_month_haszero=$(date "+%m") # 8月: 08
# 在Bash shell中，以0开头的数字表示一个八进制数。例如，08被解释为一个八进制数字，但是八进制数字中只允许出现0~7，因此会提示错误。
# 为了解决这个问题，你可以将date命令的输出的月份信息转换为十进制数，而不是八进制数。你可以通过在%m选项前添加%-来实现
cur_date_month_nozero=$(date "+%-m") # 8月: 8
# cur_date_month=$((cur_date_month_nozero+0))


cur_date_day_haszero=$(date "+%d")
cur_date_day_nozero=$(date "+%-d")

cur_date_hour_haszero=$(date "+%H")
cur_date_minute_haszero=$(date "+%M")

VERSION="${cur_date_year_short}.${cur_date_month_nozero}.${cur_date_day_nozero}"   # 18.2.21

# build 号加上年的目的是 修复Android的能否升级取决于build是否变大(iOS虽不用，但保持同步)
BUILD="${cur_date_year_short}${cur_date_month_haszero}${cur_date_day_haszero}${cur_date_hour_haszero}${cur_date_minute_haszero}" # 1802211506


# 使用 jq 添加键值对
appVersionJson='{

}'

appVersionJson=$(printf "%s" "$appVersionJson" | jq --arg version "$VERSION" '. + { "version": $version }')
appVersionJson=$(printf "%s" "$appVersionJson" | jq --arg buildNumber "$BUILD" '. + { "buildNumber": $buildNumber }')
printf "%s" "${appVersionJson}" # 必须使用 printf "%s" "$appVersionJson" ，否则当json中某个key的值有斜杠时候会出现错误













