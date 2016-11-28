# -*- coding: utf-8 -*-
"""
Created on Tue Oct 11 21:15:16 2016

@author: zhenghuangcheng
"""
import numpy as np
import pandas as pd
import time 
from sklearn.cross_validation import train_test_split

import os

from sklearn import  svm   #导入所需要的库
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

train_xy,val = train_test_split(train, test_size = 0.2,random_state=1)
#random_state is of big influence for val-auc
y = train_xy.label
X = train_xy.drop(['qid','uid','label','qz_word_ratio','qz_char_ratio','qz_char__dist','qz_word__dist'],axis=1)

val_y = val.label
val_X = val.drop(['qid','uid','label','qz_word_ratio','qz_char_ratio','qz_char__dist','qz_word__dist'],axis=1)

test=test_f.drop(['qid','uid','label','qz_word_ratio','qz_char_ratio','qz_char__dist','qz_word__dist'],axis=1)

svc = svm.SVC(C=1, kernel='linear')  #初始化svm分类器

#from sklearn import cross_validation   #导入交叉验证模块
#kfold = cross_validation.KFold(len(X), n_folds=10) #初始化交叉验证对象，len(X_digits)指明有多少个样本；n_folds指代kfolds中的参数k,表示把训练集分成k份（n_folds份），本例中为3份
#[svc.fit(X[ctrain], y[ctrain]).score(X[cval],y[cval]) for ctrain, cval in kfold]   #此处train、test里有交叉验证对象中已经初始化好的3组训练样本和测试样本所需的位置标号

C = 1.0  # SVM regularization parameter
lin_svc = svm.LinearSVC(C=C).fit(X, y)
test_y=lin_svc.predict(test)
test_y=lin_svc._predict_proba_lr(test)

test_result = pd.DataFrame(columns=["qid","uid","label"])
test_result.qid = test_qid
test_result.uid = test_uid
test_result.label = 1-test_y
test_result.to_csv("output/svm_bytecup1011_1.csv",index=None,encoding='utf-8')  #remember to edit xgb.csv , add ""
#

