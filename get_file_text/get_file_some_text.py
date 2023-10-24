#!/user/local/bin/python3
# 获取文本中的某些文本(eg:toast文本等)
# 定义颜色常量
NC='\033[0m' # No Color
RED='\033[31m'
GREEN='\033[32m'
YELLOW='\033[33m'
BLUE='\033[34m'
PURPLE='\033[0;35m'
CYAN='\033[0;36m'

# 获取文件中的某些文本
import subprocess
import xlsxwriter  # 使用如下命令安装: pip3 install xlsxwriter
import argparse
import os
import re
from typing import List
try:
    from git import Repo # 需要执行以下命令为python安装git: pip install gitpython
except ImportError:
    print(f"{RED}git 未安装，请先执行{BLUE} pip3 install gitpython {RED}。{NC}")
    exit(1)


# 定义颜色常量
NC = '\033[0m'  # No Color
RED = '\033[31m'
GREEN = '\033[32m'
YELLOW = '\033[33m'
BLUE = '\033[34m'
PURPLE = '\033[0;35m'
CYAN = '\033[0;36m'


# 查找 codeDirPath 所在的 Git 仓库的根目录
def findGitRepo(codeDirPath):
    repo = None
    try:
        repo = Repo(codeDirPath, search_parent_directories=True)
    except:
        print("未找到 Git 仓库")

    if repo is not None:
        git_root = repo.git.rev_parse("--show-toplevel")
        print("Git 仓库的根目录:", git_root)

    return repo

def search_toast_file_Maps(codeDirPath, codeSuffixs, toastCodePrefixSuffixs):
    if (not os.path.exists(codeDirPath)):
        print(f"{RED}Error:{BLUE} {codeDirPath} {RED}文件夹不存在，请检查。{NC}")
        return None
    
    
    # 打开仓库
    repo = findGitRepo(codeDirPath)

    toast_file_Maps = []
    # 在需要使用文件路径时，可以通过迭代生成器来逐个获取文件路径
    file_generator = (os.path.join(root, file) for root, _, files in os.walk(codeDirPath) for file in files)
    for file_path in file_generator:
        toastMap = get_toast_from_file_path(file_path, codeSuffixs, repo, toastCodePrefixSuffixs)
        if toastMap != None:
            toast_file_Maps.append(toastMap)
    if toast_file_Maps == []:
        return None
    
    return toast_file_Maps

def _checkExsitToastCode(text):
    foundToastCode = False
    for toastCodePrefixSuffix in toastCodePrefixSuffixs:
        toastCodePrefixSuffixString = toastCodePrefixSuffix.split("---dvlp---")
        toastCodePrefix = toastCodePrefixSuffixString[0]
        if toastCodePrefix in text:  # 文件是否包含关键字
            foundToastCode = True
            break
    if foundToastCode == False:  # 文件是否包含关键字
        return None

def get_toast_from_file_path(file_path, codeSuffixs, repo, toastCodePrefixSuffixs):
    # 判断文件后缀是否匹配
    is_code_file = any(file_path.endswith(suffix) for suffix in codeSuffixs)
    if is_code_file == False:
        return None
    
 
    textMapArray=[]
    try:
        with open(file_path, 'r', encoding='utf-8') as f:
            content = f.read()
            if _checkExsitToastCode(content) == False:  # 文件是否包含关键字
                return None
            
            # 从代码行中提取双引号内的文本内容
            with open(file_path, 'r', encoding='utf-8') as f:
                # 获取文件的历史记录
                log_output = repo.git.log("--follow", "--format=%an|%cn", "--", file_path)
                first_author = log_output.split("|")[0]     # 获取第一个提交的作者
                last_modifier = log_output.split("|")[-1]   # 获取最后一个提交的最后修改者
                # 打印作者和最后修改者信息
                # print(f"文件作者: {first_author}")
                # print(f"最后修改者: {last_modifier}")

                lines = f.readlines()
                for idx, line in enumerate(lines):
                    text = extract_text_from_line(line, toastCodePrefixSuffixs)
                    if text != None:
                        textMapArray.append({
                            "text": text, 
                            "isUse": True, 
                            "first_author": first_author, 
                            "last_modifier": last_modifier,
                            "lineNum": idx + 1,
                        })
                        
    except UnicodeDecodeError:
        print(f"无法使用utf-8编码读取文件: {file_path}")
        return None
    

    if textMapArray == []:
        return None
    
    print(f"{CYAN}{BLUE} {file_path} {CYAN}文件包含要查找的{BLUE} {toastCodePrefixSuffixsString} {CYAN}提取到的文本内容：《{BLUE} {textMapArray} {CYAN}》。{NC}")
    return {
            "file_path": file_path,
            "textMaps": textMapArray,
        }


def contains_chinese(text):
    pattern = re.compile(r'[\u4e00-\u9fff]')  # 匹配中文字符的正则表达式
    if re.search(pattern, text):
        return True
    return False

def extract_text_from_line(line, toastCodePrefixSuffixs):
    for toastCodePrefixSuffix in toastCodePrefixSuffixs:
        toastCodePrefixSuffixString = toastCodePrefixSuffix.split("---dvlp---")
        toastCodePrefix = toastCodePrefixSuffixString[0]
        toastCodeSuffix = toastCodePrefixSuffixString[1]
        text = _extract_text_from_line(line, toastCodePrefix, toastCodeSuffix)
        if text != None:
            return text
        
    return None


def _extract_text_from_line(line, toastCodePrefix, toastCodeSuffix):
    # 使用正则表达式或其他方法从代码行中提取文本内容
    # 这里假设文本内容位于双引号内
    if toastCodePrefix not in line:
        return None

    start_index = line.find(toastCodePrefix) + len(toastCodePrefix)
    if start_index == -1:
        return None
    end_index = line.rfind(toastCodeSuffix)
    if end_index == -1:
        return None
    text = line[start_index:end_index]
    if contains_chinese(text):
        return text
    return None

# toastCodePrefix = 'ToastUtil.showMessage("'
# toastCodeSuffix = '");'
# text = extract_text_from_line('ToastUtil.showMessage("这是测试提取文本内容的方法");', toastCodePrefix, toastCodeSuffix)
# print(f"提取到的文本内容：《{text}》")
# exit(0)




# current_script_path = os.path.abspath(__file__) # 当前脚本路径
# current_script_dir = os.path.dirname(current_script_path) # 当前脚本所在目录
# codeDirPath = current_script_dir
# codeSuffixs = [".dart", ".java", ".cpp"]
# # 搜索包含关键字的文件
# matching_toastFileMaps = search_toast_file_Maps(codeDirPath, codeSuffixs, toastCodePrefix, toastCodeSuffix)
# if matching_toastFileMaps == None or len(matching_toastFileMaps) == 0:
#     print(f"{RED}未找到包含关键字的文件{NC}")
#     exit(1)
# print(f"包含关键字的文件如下：\n{matching_toastFileMaps}")
# exit(0)


# 获取具名参数的值
parser = argparse.ArgumentParser()  # 创建参数解析器
parser.add_argument("-codeDir", "--codeDir",
                    help="The value for argument 'codeDir'")
parser.add_argument("-codeSuffixsString", "--codeSuffixsString",
                    help="The value for argument 'codeSuffixsString'")
parser.add_argument("-toastCodePrefixSuffixsString", "--toastCodePrefixSuffixsString",
                    help="The value for argument 'toastCodePrefixSuffixsString'")
parser.add_argument("-toastCodeSuffix", "--toastCodeSuffix",
                    help="The value for argument 'toastCodeSuffix'")
parser.add_argument("-resultSaveToSheetFilePath", "--resultSaveToSheetFilePath",
                    help="The value for argument 'resultSaveToSheetFilePath'")
args = parser.parse_args()  # 解析命令行参数
codeDirPath = args.codeDir                      # 代码所在文件夹
codeSuffixsString = args.codeSuffixsString
codeSuffixs = codeSuffixsString.split(",")
toastCodePrefixSuffixsString = args.toastCodePrefixSuffixsString # 'ToastUtil.showMessage("---dvlp---");###dvlp###ToastUtil.showMessage('---dvlp---');'
toastCodePrefixSuffixs = toastCodePrefixSuffixsString.split("###dvlp###")
# toastCodePrefix = args.toastCodePrefix          # 'ToastUtil.showMessage("'
# toastCodeSuffix = args.toastCodeSuffix          # '");'
sheetFilePath = args.resultSaveToSheetFilePath  # "APP提示语清单表4.xlsx"

if codeDirPath is None:
    print("您要获取提示语的代码目录参数 -codeDir 不能为空，请检查！")
    exit(1)
if toastCodePrefixSuffixs is None:
    print("您要检查的提示语标识结构的参数 -toastCodePrefixSuffixs 不能为空，请检查！")
    exit(1)
if sheetFilePath is None:
    print("您检查结果要输出到哪个execl表格的参数 -sheetFilePath 不能为空，请检查！")
    exit(1)
print(f"{PURPLE}您将要在代码目录{BLUE} {codeDirPath} {PURPLE}下排查包含{BLUE} {toastCodePrefixSuffixsString} {PURPLE}，且文案包含中文的文件.并将结果保存在{BLUE} {sheetFilePath} {PURPLE}中。{NC}")

# from . import path_util # 为了能使用远程脚本，这里的代码就不写成 from path_util import joinFullPath 了
# 路径拼接(①支持尾部及头部斜杠的处理;②支持尾部拼接../)



# 项目中使用的图片资源路径集合
print("---Analyze unused Assets----")
print(f"{CYAN}----------1.开始查找包含关键字的文件(遍历目录 {codeDirPath} ,返回获取到的文件路径数组)----------{NC}")
matching_toastFileMaps = search_toast_file_Maps(codeDirPath, codeSuffixs, toastCodePrefixSuffixs)
if matching_toastFileMaps == None or len(matching_toastFileMaps) == 0:
    print(f"{RED}未找到包含关键字的文件{NC}")
    exit(1)

print(f"----------在 {codeDirPath} 文件中找到符合条件的文件个数count:{str(len(matching_toastFileMaps))}----------")






def print_matching_toastFileMaps(toastFileMaps: List):
    resultRecordArray = []
    for toastFileMap in toastFileMaps:
        file_path = toastFileMap["file_path"]
        for textMap in toastFileMap["textMaps"]:
            resultRecordArray.append({
                "path": file_path, 
                "toast": textMap["text"], 
                "isUse": textMap["isUse"],
                "first_author": textMap["first_author"],
                "last_modifier": textMap["last_modifier"],
                "lineNum": textMap["lineNum"],
            })
    return resultRecordArray
resultRecordArray = print_matching_toastFileMaps(matching_toastFileMaps)

print(f"{GREEN}分析完成，正写入到excel中...{NC}")


#!/user/local/bin/python3
# 将本文件放在Flutter项目的根目录


# import xlsxwriter
# create a new Excel file and add a worksheet
# 创建工作薄 workbook('demo.xlsx')
# sheetFilePath="APP资源清单表4.xlsx"
# sheetFilePath=data["unuse_output"]["imageSheetFileName"]
workbook = xlsxwriter.Workbook(sheetFilePath)
# 获取默认的工作表
# worksheet = workbook.active
# 创建工作表
worksheet = workbook.add_worksheet()
# Widen the first column to make the text clearer
# 设置一列或者多列单元属性
worksheet.set_column('A:A', 20)  # 设定A列列宽为40
# Add a bold format to use to highlight cells
# 在工作表中创建一个新的格式对象来格式化单元格，实现加粗
bold = workbook.add_format({'bold': True})
# write some simple text.
# 工总表写入简单文本
worksheet.write('A1', 'hello')
# Text with formatting
# 工作表写入带有格式的文本，加粗
worksheet.write('A2', 'World', bold)
# Write some numbers, with row/column notation #按照坐标写入
# worksheet.write(2, 0, 1235)
# worksheet.write(3, 0, 123.456)


# [xlsxwriter模块add_format参数详解](https://blog.csdn.net/u013151699/article/details/122594187?spm=1001.2101.3001.6661.1&utm_medium=distribute.pc_relevant_t0.none-task-blog-2%7Edefault%7ECTRLIST%7ERate-1-122594187-blog-64443938.pc_relevant_aa_2&depth_1-utm_source=distribute.pc_relevant_t0.none-task-blog-2%7Edefault%7ECTRLIST%7ERate-1-122594187-blog-64443938.pc_relevant_aa_2&utm_relevant_index=1)
titleRowIndex = 0
worksheet.set_row(0, 30.0)  # set_row(row, height)方法，用于设定某一行单元格的行高
titleFontFormat = {
    'bold': True,  # 字体加粗
    'align': 'center',  # 水平位置设置：居中
    'valign': 'vcenter',  # 垂直位置设置，居中
    'font_size': 20,  # '字体大小设置'
}
# worksheet.write(titleRowIndex, 0, "APP提示语清单表", workbook.add_format(titleFontFormat))
worksheet.merge_range('A1:F1', "APP提示语清单表",
                      workbook.add_format(titleFontFormat))
nextRowIndex = 1

propertyRowIndex = nextRowIndex
worksheet.set_row(1, 20.0)  # set_row(row, height)方法，用于设定某一行单元格的行高
propertyFont = workbook.add_format({'bold': True, 'font_size': 12})
# set_column(first_col, last_col, width)方法，用于设置一列或多列单元格的列宽

columnIndex = 0
worksheet.write(propertyRowIndex, columnIndex, "文件(简)", propertyFont)
worksheet.set_column(columnIndex, columnIndex, 30)

columnIndex = 1
worksheet.write(propertyRowIndex, columnIndex, "行号", propertyFont)
worksheet.set_column(columnIndex, columnIndex, 10)

columnIndex = 2
worksheet.write(propertyRowIndex, columnIndex, "提示文案", propertyFont)
worksheet.set_column(columnIndex, columnIndex, 40)

columnIndex = 3
worksheet.write(propertyRowIndex, columnIndex, "文案类型", propertyFont)
worksheet.set_column(columnIndex, columnIndex, 40)
#  # 定义下拉选项的值 + 定义下拉选项的范围
# options = ["失败", "成功", "提示", "未确定"]
# start_row = propertyRowIndex+1
# end_row = 30
# # 创建下拉选项数据验证对象，并将下拉选项应用到指定的单元格范围
# validation = {
#     'validate': 'list',
#     'source': options
# }
# worksheet.write_column(start_row, columnIndex, options)
# worksheet.data_validation(start_row, columnIndex, end_row, columnIndex, validation)

columnIndex = 4
worksheet.write(propertyRowIndex, columnIndex, "触发路径及条件", propertyFont)
worksheet.set_column(columnIndex, columnIndex, 60)

columnIndex = 5
worksheet.write(propertyRowIndex, columnIndex, "提示方式", propertyFont)
worksheet.set_column(columnIndex, columnIndex, 10)

columnIndex = 6
worksheet.write(propertyRowIndex, columnIndex, "isUse 是否使用中", propertyFont)
worksheet.set_column(columnIndex, columnIndex, 20)

columnIndex = 7
worksheet.write(propertyRowIndex, columnIndex, "创建者", propertyFont)
worksheet.set_column(columnIndex, columnIndex, 10)

columnIndex = 8
worksheet.write(propertyRowIndex, columnIndex, "修改者", propertyFont)
worksheet.set_column(columnIndex, columnIndex, 10)

columnIndex = 9
worksheet.write(propertyRowIndex, columnIndex, "useInFile", propertyFont)
worksheet.set_column(columnIndex, columnIndex, 100)


nextRowIndex += 1


resultRecordCount = len(resultRecordArray)
# for iResultRecord in resultRecordArray:
for i in range(0, resultRecordCount, 1):
    iResultRecord = resultRecordArray[i]

    currentRowIndex = nextRowIndex+i
    worksheet.write(currentRowIndex, 0, os.path.basename(iResultRecord["path"])) # 文件(简)
    worksheet.write(currentRowIndex, 1, iResultRecord["lineNum"]) # 所在文件行号

    toastString = iResultRecord["toast"]
    resourceSizeFont = workbook.add_format({'bg_color': 'orange', 'font_size': 12})
    worksheet.write(currentRowIndex, 2, toastString, resourceSizeFont) # 提示文案
    if "失败" in toastString:
        toastTypeString = "失败"
        toastTypeBGColor = '#{:02x}{:02x}{:02x}'.format(250, 222, 220)
        toastTypeFormat = workbook.add_format({'bg_color': toastTypeBGColor, 'font_size': 12})
    elif "成功" in toastString:
        toastTypeString = "成功"
        toastTypeBGColor = '#{:02x}{:02x}{:02x}'.format(217, 242, 227)
        toastTypeFormat = workbook.add_format({'bg_color': toastTypeBGColor, 'font_size': 12})
    elif "请" in toastString:
        toastTypeString = "提示"
        toastTypeBGColor = '#{:02x}{:02x}{:02x}'.format(221, 223, 227)
        toastTypeFormat = workbook.add_format({'bg_color': toastTypeBGColor, 'font_size': 12})
    else:
        toastTypeString = "未确定"
        toastTypeFormat = workbook.add_format({'bg_color': 'white', 'font_size': 12})
    worksheet.write(currentRowIndex, 3, toastTypeString, toastTypeFormat) # 文案类型

    worksheet.write(currentRowIndex, 6, iResultRecord["isUse"]) # isUse 是否使用中

    worksheet.write(currentRowIndex, 7, iResultRecord["first_author"]) # 创建者
    worksheet.write(currentRowIndex, 8, iResultRecord["last_modifier"]) # 修改者

    worksheet.write(currentRowIndex, 9, iResultRecord["path"]) # useInFile


# 关闭工作薄
workbook.close()

print(f"{GREEN}恭喜{BLUE} {sheetFilePath} {GREEN}已生成，并为你自动打开. {NC}")

# 在 macOS 或 Linux 上打开 file_path 文件。
subprocess.Popen(['open', sheetFilePath])
