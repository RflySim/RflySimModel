import time
import numpy as np
import cv2
import sys
import math
import os

import UEMapServe as UEMapServe
import UE4CtrlAPI as UE4CtrlAPI
#Create a new MAVLink communication instance, UDP sending port (CopterSim’s receving port) is 20100
ue = UE4CtrlAPI.UE4CtrlAPI()

time.sleep(1)

# 开启飞机ID显示
cmd = 'RflyChangeViewKeyCmd S 1'
print(cmd)
ue.sendUE4Cmd(cmd)

# 开启轨迹显示
cmd = 'RflyChangeViewKeyCmd T 1'
print(cmd)
ue.sendUE4Cmd(cmd)

# 开启小地图
cmd = 'RflyChangeViewKeyCmd L 1'
print(cmd)
ue.sendUE4Cmd(cmd)


# 修改飞机样式，用于红蓝对抗等
#可选飞机样式
# FSJ150
# FSJ150_Orange_DBPanddles  橙色 - 两叶桨
# FSJ150_Orange_FBPanddles  橙色 - 四叶桨
# FSJ150_White_DBPanddles  白色 - 两叶桨
# FSJ150_White_FBPanddles  白色 - 四叶桨
# FSJ150_Yellow_DBPanddles 黄色 - 两叶桨
# FSJ150_Yellow_FBPanddles 黄色 - 四叶桨
CopterID=1 # 可以通过for循环，逐一设置各个飞机样式
cmd = 'RflyChange3DModel %d FSJ150_Yellow_FBPanddles' % (CopterID)
print(cmd)
ue.sendUE4Cmd(cmd)


# 放大飞机，便于观察
cmd = 'RflyChangeVehicleSize -1 4' 
print(cmd)
ue.sendUE4Cmd(cmd)

# 飞机头上显示一些必要的文字
# RflySetMsgLabel(int CopterID, FString Text, FString colorStr, float size, float time, int flag)
# RflySetIDLabel(int CopterID, FString Text, FString colorStr, float size)

# 触发特效
# RflySetActuatorPWMsExt(int CopterID, float pwm9, float pwm10, float pwm11, float pwm12, float pwm13, float pwm14, float pwm15, float pwm16, float pwm17, float pwm18, float pwm19, float pwm20, float pwm21, float pwm22, float pwm23, float pwm24)