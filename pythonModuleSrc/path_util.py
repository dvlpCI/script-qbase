'''
Author: dvlproad dvlproad@163.com
Date: 2023-04-16 00:10:18
LastEditors: dvlproad dvlproad@163.com
LastEditTime: 2026-04-22 11:42:23
FilePath: path_util.py
Description: 路径的计算方法
'''
import os

# 定义颜色常量
NC='\033[0m' # No Color
RED='\033[31m'
GREEN='\033[32m'
YELLOW='\033[33m'
BLUE='\033[34m'
PURPLE='\033[0;35m'
CYAN='\033[0;36m'

# 获取相对于指定文件的相对目录的绝对路径
def getAbsPathByRelativePath(firlOrDir_path, rel_path, createIfNoExsit=False, is_file=None):
    fileOrDir_abspath=os.path.abspath(firlOrDir_path)
    if not os.path.exists(fileOrDir_abspath):
        return None # 拼接前的路径就不存在了，没必要拼接了
    
    # 如果是文件，取所在目录；如果是目录，直接使用
    # 如果 fileOrDir_abspath 是文件：基于该文件所在目录拼接；如果 fileOrDir_abspath 是目录：基于该目录拼接
    if os.path.isfile(fileOrDir_abspath):
        base_dir = os.path.dirname(fileOrDir_abspath)
    else:
        base_dir = fileOrDir_abspath
    
    return joinFullPath_checkExsit(base_dir, rel_path, createIfNoExsit, is_file)


def joinFullPath_noCheck(host_dir, rel_path):
    # 在 Unix 和 Linux 系统中，以斜杠开头的路径被视为绝对路径。所以需要去掉头部结尾的斜杠或者尾部开头的斜杠
    if host_dir.endswith("/"):
        host_dir = host_dir[:-1]
    if rel_path.startswith("/"):
        rel_path = rel_path[1:]
    full_path = os.path.join(host_dir, rel_path)
    full_abspath = os.path.abspath(full_path)
    return full_abspath




# 路径拼接(①支持尾部及头部斜杠的处理;②支持尾部拼接../)
"""
拼接路径并检查是否存在，可选择创建目录或文件

参数:
    host_dir: 主机目录路径
    rel_path: 相对路径
    createIfNoExsit: 不存在时是否创建
    is_file: 创建类型（createIfNoExsit为True的时候该值才有用）
                True: 创建文件
                False: 创建目录
                None: 不根据路径特征自动判断，而是报你必须自己指定
"""
def joinFullPath_checkExsit(host_dir, rel_path, createIfNoExsit=False, is_file=None):
    # 在 Unix 和 Linux 系统中，以斜杠开头的路径被视为绝对路径。所以需要去掉头部结尾的斜杠或者尾部开头的斜杠
    if host_dir.endswith("/"):
        host_dir = host_dir[:-1]
    if rel_path.startswith("/"):
        rel_path = rel_path[1:]
    full_path = os.path.join(host_dir, rel_path)
    full_abspath = os.path.abspath(full_path)
    if os.path.exists(full_abspath):
        return full_abspath
    else:
        if createIfNoExsit==True:
            print(f"{RED}路径拼接后的目标文件'{YELLOW} {full_abspath} {RED}'不存在，正在尝试创建该路径{BLUE} {full_abspath} {RED}...{NC}")

            # 如果is_file未指定，尝试自动判断
            if is_file is None:
                # # 有扩展名认为是文件，否则是目录
                # import re
                # basename = os.path.basename(full_abspath)
                # is_file = bool(re.search(r'\.[a-zA-Z0-9]{1,5}$', basename))
                print(f"{RED}拼接路径必须主动指明是什么类型，不进行自动判断，因为不一定准，比如qbase执行文件没有扩展名，但却是文件{NC}")
                return None
            try:
                if is_file:
                    # 创建文件：先确保父目录存在
                    parent_dir = os.path.dirname(full_abspath)
                    if parent_dir:
                        os.makedirs(parent_dir, exist_ok=True)
                    # 创建空文件
                    open(full_abspath, 'a').close()
                    print(f"已创建文件: {full_abspath}")
                else:
                    # 创建目录
                    os.makedirs(full_abspath, exist_ok=True)
                    print(f"已创建目录: {full_abspath}")
                return full_abspath
            except OSError as e:
                print(f"创建失败: {e}")
                return None
        else:
            print(f"{RED}路径拼接后的目标文件'{YELLOW} {full_abspath} {RED}'不存在，请检查其拼接参数{BLUE} {host_dir} {RED}和{BLUE} {rel_path} {RED}.{NC}")
            return None
        


# Url路径拼接
def joinFullUrl(host_url, rel_url):
    # rstrip() 方法删除字符串末尾的斜杠，lstrip() 方法删除字符串开头的斜杠，然后拼接字符串
    full_url = host_url.rstrip("/") + "/" + rel_url.lstrip("/")

    # print(f"full_url: {YELLOW}{full_url}{NC}")
    return full_url

# a = '/Users/qian/Project/CQCI/script-branch-json-file/test/tool_input.json'
# b = '../../'
# c = os.path.abspath(os.path.join(os.path.dirname(a), b))
# print("===0====envValue: \033[1;31m{}\033[0m".format(c))
# print(f"===0====envValue: {RED}{c}{NC}")
# print("===1====envValue: \033[1;31m{}\033[0m".format(joinFullPath_checkExsit(os.path.dirname(a), "./")))
# print("===2====envValue: \033[1;31m{}\033[0m".format(joinFullPath_checkExsit(os.path.dirname(a), "../")))
# print("===3====envValue: \033[1;31m{}\033[0m".format(joinFullPath_checkExsit(os.path.dirname(a), "../../")))

# aUrl = "http://acd/dfd/cdfd.com/"
# print("===2.1====envValue: \033[1;31m{}\033[0m".format(joinFullUrl(aUrl, "/de/")))