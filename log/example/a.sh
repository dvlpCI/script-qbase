#!/bin/bash

# 写入日志信息到标准错误流
echo "This is a log message" >&2

# 模拟成功的结果信息
echo "Success: This is the successful result"

# 模拟失败的结果信息
echo "Error: This is the error result" >&2