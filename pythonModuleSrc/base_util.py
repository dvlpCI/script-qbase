'''
Author: dvlproad dvlproad@163.com
Date: 2023-04-16 00:10:18
LastEditors: dvlproad
LastEditTime: 2023-11-07 11:42:18
FilePath: base_util.py
Description: 打开文件、执行脚本
'''
import os
import subprocess

# 定义颜色常量
NC='\033[0m' # No Color
RED='\033[31m'
GREEN='\033[32m'
YELLOW='\033[33m'
BLUE='\033[34m'
PURPLE='\033[0;35m'
CYAN='\033[0;36m'

def openFile(file_path):
    # 在 macOS 或 Linux 上打开 file_path 文件。
    # subprocess.Popen(['open', file_path])
    subprocess.Popen(['open', file_path])
    
    
       
        
def callScriptCommond(command, sript_file_absPath, verbose=False):
    # try:
    #     subprocess.check_call(command)
    # except subprocess.CalledProcessError as e:
    #     print("Error: ", e.returncode, e.output)
    # 假设 command=["python3", sript_file_absPath, pack_input_params_file_path]
    if os.path.basename(command[0]) != "sh" and os.path.basename(command[0]) != "python3":
        # 获取脚本文件的扩展名
        ext = os.path.splitext(sript_file_absPath)[1]
        if ext == ".py":
            # 如果脚本文件是 Python 文件，则在 command 数组的第一个位置插入 python3
            command.insert(0, "python3")
        elif ext == ".sh":
            # 如果脚本文件是 Shell 文件，则在 command 数组的第一个位置插入 sh
            command.insert(0, "sh")

    
    command = [str(item) for item in command]   # 将布尔类型的元素转换为字符串，避免 ' '.join(command) 和 subprocess.run(command) 中出现不是字符串的值而出错
    try:
        cmdString=' '.join(command)
        print(cmdString)
    except TypeError as e:
        print(f"{RED}Error:将{BLUE} {command} {RED}数组拼接成字符串时出错，出错原因为:{BLUE} {str(e)} {RED}。{NC}")
        return False

    print(f"\n{BLUE}开始执行脚本，执行过程中输出内容如下：{NC}")
    if verbose==True:
        escaped_command = cmdString.replace("(", r"\(").replace(")", r"\)")
        print(f"{BLUE}正在执行选中的命令:《{YELLOW} {escaped_command} {BLUE}》{NC}")


    # 调用 subprocess.run() 函数执行 shell 命令
    try:
        # 尝试执行脚本
        # 设置了 check=True 参数，这可以使函数在命令执行失败时抛出一个 CalledProcessError 异常。
        # capture_output=True 参数可以捕获命令的标准输出和标准错误输出。
        # text=True 参数可以将输出解码为字符串。如果省略 capture_output=True 参数，则无法在 except 块中访问命令的输出
        result = subprocess.run(command) # 为了避免执行过程中，有键盘输入的需求，所以不使用 capture_output 属性
    except PermissionError:
        print(f"{CYAN}没有执行权限，正为你添加执行权限并重试{NC}")
        os.chmod(sript_file_absPath, 0o755)
        result = subprocess.run(command)
    except subprocess.CalledProcessError as error:
        # 如果脚本执行失败，输出错误信息
        print(f'{RED}脚本调用失败，错误码:{YELLOW}{error.returncode}{NC}', )
        print(f'{RED}脚本调用失败，错误信息如下:{YELLOW}{error.stderr}{NC}')
        # print(f"{RED}脚本调用失败：{error}{NC}")
        return False

    # 判断 shell 命令的返回值，并输出结果
    if result.returncode != 0:
        print(f"{RED}抱歉:您的脚本命令执行失败，returncode={result.returncode}。 请检查您所执行的命令《{YELLOW} {cmdString} {RED}》{NC}")
        exit(1)
    # elif result is not None and "exit 1" in result.stdout:
    #     print(f"{YELLOW}{sript_file_absPath}{RED} 脚本执行失败")
    #     # print(result.stdout) # 因为没有 capture_output 所以没有 stdout
    #     return False
    else:
        # print(f"{BLUE}恭喜:您的脚本命令执行成功,结果如下:\n")
        # print(f"{result.stdout.strip()}") # 因为没有 capture_output 所以没有 stdout
        return True


# sript_file_absPath = "/Users/lichaoqian/Project/CQCI/script-branch-json-file/test/test_shell.sh"
# scriptParamMaps = [
#     {"key": '-pl', "value": 'iOS'}, 
#     {"key": '-pn', "value": 'test1'}, 
#     {"key": '-pt', "value": 'formal'}, 
#     {"key": '-saveToF', "value": 'hello4.json'}
# ]
# command = ['sh', sript_file_absPath]
# for i, scriptParamMap in enumerate(scriptParamMaps):
#     param = scriptParamMap["key"]
#     value = scriptParamMap["value"]
#     command += [f"{param}", value]
    
# callScriptCommond(command, sript_file_absPath)
