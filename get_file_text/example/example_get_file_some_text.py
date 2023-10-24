'''
Author: dvlproad
Date: 2022-10-10 18:46:08
LastEditors: dvlproad dvlproad@163.com
LastEditTime: 2023-10-24 23:15:04
Description: 
'''
#!/user/local/bin/python3
import os
import subprocess

current_script_path = os.path.abspath(__file__) # 当前脚本路径
current_script_dir = os.path.dirname(current_script_path) # 当前脚本所在目录
parent_script_dir = os.path.dirname(current_script_dir) # 当前脚本所在目录
test_script_path = f"{parent_script_dir}/get_file_some_text.py"

codeProjectAbsPath = current_script_dir
projectAbsRootPath = current_script_dir
# codeProjectAbsPath = "/Users/qian/Project/XXX/mobile_flutter_wish/wish"
# projectAbsRootPath = os.path.dirname(codeProjectAbsPath)


codeDir = f"{codeProjectAbsPath}/lib"
codeSuffixs = [".dart", ".java", ".cpp"]
codeSuffixsString = ",".join(codeSuffixs)    # 将 codeSuffixs 转换为字符串形式，以逗号分隔后传递给脚本
toastCodePrefixSuffixs=['ToastUtil.showMessage("---dvlp---");', 'ToastUtil.showMessage(\'---dvlp---\');']
toastCodePrefixSuffixsString = "###dvlp###".join(toastCodePrefixSuffixs)    # 将 toastCodePrefixSuffixs 转换为字符串形式，以逗号分隔后传递给脚本
resultSaveToSheetFilePath=f"{projectAbsRootPath}/APP提示语清单表.xlsx"

# 注意这里要用 python3.9 (请现在终端执行安装python3.9的命令: brew install python@3.9)
subprocess.run(["python3.9", test_script_path, "-codeDir", codeDir, "-codeSuffixsString", codeSuffixsString, "-toastCodePrefixSuffixsString", toastCodePrefixSuffixsString, "-resultSaveToSheetFilePath", resultSaveToSheetFilePath])
