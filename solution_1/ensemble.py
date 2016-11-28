# -*- coding: utf-8 -*-
"""
Created on Tue Oct 11 22:45:13 2016

@author: zhenghuangcheng
"""

import pandas as pd

xgb0480 = pd.read_csv("output/xgb_bytecup1010_1_0.48.csv")
svm0479 = pd.read_csv('output/svm_bytecup1011_1.csv')
xgb04799 = pd.read_csv('output/xgb_bytecup1010_3_0.4799.csv')

qid=xgb0480.qid
uid = xgb0480.uid

label = 0.4*xgb0480.label+0.25*svm0479.label+0.35*xgb04799.label
test_result = pd.DataFrame(columns=["qid","uid","label"])
test_result.qid = qid
test_result.uid = uid
test_result.label = label

test_result.to_csv('output/ensembel_1011_1.csv',index=None,encoding='utf-8')