import argparse
import json
import sys

# 定义颜色常量
NC='\033[0m' # No Color
RED='\033[31m'
GREEN='\033[32m'
YELLOW='\033[33m'
BLUE='\033[34m'
PURPLE='\033[0;35m'
CYAN='\033[0;36m'

# 创建命令行参数解析器
parser = argparse.ArgumentParser()
parser.add_argument('-jsonF', dest='json_file', help='JSON文件路径')
parser.add_argument('-k', dest='key_name', help='要更新的键名')
parser.add_argument('-v', dest='value', help='要更新的值')
parser.add_argument('-change-type', dest='changeType', help='修改方式覆盖cover或添加add')
args = parser.parse_args(sys.argv[1:])  # 解析命令行参数

# 从命令行参数获取相应的值
json_file = args.json_file
key_name = args.key_name
value = args.value
changeType = args.changeType


def get_json_data(json_file):
    # 加载JSON文件
    try:
        with open(json_file, 'r') as file:
            json_data = json.load(file)
            return json_data
    except FileNotFoundError:
        print("找不到指定的JSON文件。")
        exit(1)
    except json.JSONDecodeError:
        print("JSON文件格式错误。")
        exit(1)

def update_json_file_with_json_data(json_file, json_data):
    # 将更新后的JSON保存回原始文件
    try:
        with open(json_file, 'w') as file:
            json.dump(json_data, file, indent=4, ensure_ascii=False)
        # print("JSON文件更新成功。")
    except Exception as e:
        print("更新JSON文件时出错：", str(e))


def add_values_to_array(json_data, key_name, new_values):
    if key_name in json_data and isinstance(json_data[key_name], list):
        json_data[key_name].extend(new_values)
    else:
        json_data[key_name] = new_values
    return json_data



def add_value_to_array(json_data, key_name, new_value):
    if key_name in json_data and isinstance(json_data[key_name], list):
        json_data[key_name].append(new_value)
    else:
        json_data[key_name] = [new_value]
    return json_data

# # 根据嵌套的 nested_key 获取你要操作的具体的json和key
# def get_operate_json_by_nested_key(json_data, nested_key):
#     keys = nested_key.split('.')
#     current = json_data
#     for key in keys[:-1]:
#         if key in current and isinstance(current[key], dict):
#             current = current[key]
#         else:
#             return json_data

#     last_key = keys[-1]
#     operate_json=current[last_key]

#     return {
#         "operate_json":  operate_json,
#         "operate_key":  last_key,
#     }

# 调用添加新值到嵌套数组的函数
def add_value_to_nested_array(json_data, nested_key, new_value, changeType="add"):
    keys = nested_key.split('.')
    current = json_data
    # 在嵌套结构中逐级查找键名
    # for key in keys[:-1]:遍历了 keys 列表中除了最后一个元素之外的所有元素。也就是说，它遍历了嵌套键名的每个层级。
    for key in keys[:-1]:
        # isinstance(current[key], dict) 检查 current[key] 对应的值是否是一个字典。isinstance() 函数用于检查一个对象是否属于指定的类型或类的子类。如果值是字典类型，则条件为真；如果不是字典类型，则条件为假。
        if key in current and isinstance(current[key], dict):
            current = current[key]
        else:
            print(f"{RED}出错了1,在{BLUE}{current}{RED}中不存在{BLUE}{key}{RED}的值，请检查.{NC}")
            return None
    
    last_key = keys[-1]
    if last_key not in current:
        print(f"{RED}出错了2,在{BLUE}{current}{RED}中不存在{BLUE}{last_key}{RED}的值，请检查.{NC}")
        return None
    
    update_json=current[last_key]
    if changeType == "cover":   # 覆盖
        update_json = [new_value]
        return json_data
    else:                       # 添加
        if last_key in current and isinstance(update_json, list):
            update_json.append(new_value)
        else:
            update_json = [new_value]

        return json_data

def update_json(json_file, key_name, value):
    json_data=get_json_data(json_file)
    
    # print(f"哈哈哈1:{json_data[key_name]}")
    # 调用添加新值的函数
    # json_data[key_name]=value
    new_json_data = add_value_to_nested_array(json_data, key_name, value, changeType)
    # print(f"哈哈哈2:{json_data[key_name]}")

    # 如果修改失败的话
    if new_json_data == None:
        return json_data
    
     # 如果修改成功的话
    update_json_file_with_json_data(json_file, new_json_data)
    return new_json_data





# 调用更新函数
updated_json = update_json(json_file, key_name, value)