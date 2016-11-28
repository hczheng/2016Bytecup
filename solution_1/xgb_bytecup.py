# -*- coding: utf-8 -*-
"""
Created on Sat Oct 11 11:37:13 2016
By 我曾经被山河大海跨过
"""
import numpy as np
import pandas as pd
import time 
import xgboost as xgb
from sklearn.cross_validation import train_test_split

import os

#os.mkdir('featurescore')
#os.mkdir('model')
#os.mkdir('preds')

#from xgboost.sklearn import XGBClassifier
#from sklearn import cross_validation, metrics   #Additional scklearn functions
#from sklearn.grid_search import GridSearchCV   #Perforing grid search
#
#import matplotlib.pylab as plt
#from matplotlib.pylab import rcParams

start_time = time.time()

trains = pd.read_csv("newfeatures/train.csv") # 注意自己数据路径
train=trains.iloc[:,0:15]
#train = dataset.iloc[:,:].values#第一列为label
#labels = dataset.iloc[:,:1].values#第一列为label

tests = pd.read_csv("newfeatures/test.csv") # 注意自己数据路径
#test_id = range(len(tests))
test_f = tests.iloc[:,:15]
test_qid=tests.qid
test_uid=tests.uid

params={
'booster':'gbtree',
'objective': 'binary:logistic',
'scale_pos_weight': 1/9.5,
#27324条正样本
#218428条负样本
#差不多1:9/10这样子
'gamma':0.2,  # 用于控制是否后剪枝的参数,越大越保守，一般0.1、0.2这样子。
'max_depth':6, # 构建树的深度，越大越容易过拟合
'lambda':3,  # 控制模型复杂度的权重值的L2正则化项参数，参数越大，模型越不容易过拟合。
'subsample':0.7, # 随机采样训练样本
#'colsample_bytree':0.7, # 生成树时进行的列采样
'min_child_weight':3, 
# 这个参数默认是 1，是每个叶子里面 h 的和至少是多少，对正负样本不均衡时的 0-1 分类而言
#，假设 h 在 0.01 附近，min_child_weight 为 1 意味着叶子节点中最少需要包含 100 个样本。
#这个参数非常影响结果，控制叶子节点中二阶导的和的最小值，该参数值越小，越容易 overfitting。 
'silent':0 ,#设置成1则没有运行信息输出，最好是设置为0.
'eta': 0.01, # 如同学习率
'seed':1000,
'nthread':16,# cpu 线程数
'eval_metric': 'auc'
}

plst = list(params.items())
num_rounds = 5000 # 迭代次数

train_xy,val = train_test_split(train, test_size = 0.15,random_state=1)
#random_state is of big influence for val-auc
y = train_xy.label
X = train_xy.drop(['qid','uid','label','zj_answer','zj_q_label_answers','zj_q_label_tuisong','zj_tuisong'],axis=1)

val_y = val.label
val_X = val.drop(['qid','uid','label','zj_answer','zj_q_label_answers','zj_q_label_tuisong','zj_tuisong'],axis=1)

test=test_f.drop(['qid','uid','label','zj_answer','zj_q_label_answers','zj_q_label_tuisong','zj_tuisong'],axis=1)

xgb_val = xgb.DMatrix(val_X,label=val_y)
xgb_train = xgb.DMatrix(X, label=y)
xgb_test = xgb.DMatrix(test)


# return 训练和验证的错误率
watchlist = [(xgb_train, 'train'),(xgb_val, 'val')]

print "跑到这里了xgb.train"
# training model 
# early_stopping_rounds 当设置的迭代次数较大时，early_stopping_rounds 可在一定的迭代次数内准确率没有提升就停止训练
model = xgb.train(plst, xgb_train, num_rounds, watchlist,early_stopping_rounds=500)
print "跑到这里了save_model"
model.save_model('model/xgb.model') # 用于存储训练出的模型
print "best best_ntree_limit",model.best_ntree_limit   #did not save the best,why?
print "best best_iteration",model.best_iteration   #get it?

print "跑到这里了model.predict"
#preds = model.predict(xgb_test,ntree_limit=model.best_iteration)#
test_y = model.predict(xgb_test,ntree_limit=model.best_iteration)
test_result = pd.DataFrame(columns=["qid","uid","label"])
test_result.qid = test_qid
test_result.uid = test_uid
test_result.label = test_y
test_result.to_csv("output/xgb_bytecup_output.csv",index=None,encoding='utf-8')  #remember to edit xgb.csv , add ""

cost_time = time.time()-start_time
print "",'\n',"cost time:",cost_time,"(s)"

#save feature score and feature information:  feature,score,min,max,n_null,n_gt1w
feature_score = model.get_fscore()
feature_score = sorted(feature_score.items(), key=lambda x:x[1],reverse=True)
fs = []
for (key,value) in feature_score:
    fs.append("{0},{1}\n".format(key,value))
    
with open('newfeatures/feature_score_{0}.csv'.format(6),'w') as f:
        f.writelines("feature,score\n")
        f.writelines(fs)

#逻辑回归
#X=X['label_huidalv']
#test=test['label_huidalv']
from sklearn.linear_model import LogisticRegression
model1 = LogisticRegression()
model1.fit(X,y)
lr_y1=model1.predict_log_proba(test)
lr_y2=model1.predict(test)
lr_y3=model1.predict_proba(test)
lr_result = pd.DataFrame(columns=["qid","uid","label"])
lr_result.qid = test_qid
lr_result.uid = test_uid
lr_result.label = lr_y3
lr_result.to_csv("output/lr_bytecup1010_1.csv",index=None,encoding='utf-8')  #remember to edit xgb.csv , add ""
    








