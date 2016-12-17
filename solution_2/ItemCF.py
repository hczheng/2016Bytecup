# -*- coding: utf-8 -*-
"""
Created on Sat Oct 11 11:37:13 2016
By 我曾经被山河大海跨过
"""
import sys
import random
import math
import pandas as pd
from operator import itemgetter

def ReadData(file,data):
    ''' 读取评分数据
        @param file  评分数据文件
        @param data 储存评分数据的List
    '''
    for line in file :
        line = line.strip('\n')
        linelist = line.split(",")
        data.append([linelist[1],linelist[0]])
 
def SplitData(data, M, key, seed):
    ''' 将数据分为训练集和测试集
        @param data   储存训练和测试数据的List
        @param M      将数据分为M份
        @param key    选取第key份数据做为测试数据
        @param seed   随机种子
        @return train 训练数据集Dict
        @return test  测试数据集Dict
    '''
    test = dict ()
    train = dict ()
    random.seed(seed)
    for user,item in data:
        if  user in train:
            train[user].append(item)
        else:
            train[user] = []
            train[user].append(item)
        if random.randint(0,M) == key:
            if user in test:
                test[user].append(item)
            else:
                test[user] = []
#        else:
#            if  user in train:
#                train[user].append(item)
#            else:
#                train[user] = []
    return train, test
      
def UserSimilarityOld(train):
    W = dict()
    for u in train.keys():
        W[u] = dict()
        for v in train.keys():
            if u == v:
                continue
            W[u][v]  = len(list(set(train[u]) & set(train[v])))
            W[u][v] /= math.sqrt(len(train[u]) * len(train[v]) * 1.0)
    return W

def ItemSimilarity(train):
    ''' 计算物品相似度
        @param train 训练数据集Dict
        @return W    记录用户相似度的二维矩阵
    '''
    C = dict()
    N = dict()
    #计算没两个item共有的user数目
    for u, items in train.items():
        for i in items:
            if i not in N:
                N[i] = 0
            N[i] += 1
            for j in items:
                if i == j: 
                    continue
                if i not in C :
                    C[i] = dict()
                if j not in C[i]:
                    C[i][j] = 0
                C[i][j] += 1

    W = dict()
    for i, related_items in C.items():
        for j, cij in related_items.items():
            if i not in W :
                W[i] = dict()
            W[i][j] = cij / math.sqrt(N[i] * N[j])

    return W



def Coverage(train, test, W, N, K):
    ''' 获取推荐结果
        @param user  输入的用户
        @param train 训练数据集Dict
        @param W     记录用户相似度的二维矩阵
        @param N     推荐结果的数目
        @param K     选取近邻的数目
    '''
    recommned_items = set()
    all_items = set()

    for user in train.keys():
        for item in train[user]:
            all_items.add(item)

        rank = GetRecommendation(user, train, W, N, K)
        for item, pui in rank:
            recommned_items.add(item)

    print 'len: ',len(recommned_items),'\n'
    return len(recommned_items) / (len(all_items) * 1.0)


        
def GetRecommendation(user, train ,W, N, K):
    ''' 获取推荐结果
        @param user  输入的用户
        @param train 训练数据集Dict
        @param W     记录用户相似度的二维矩阵
        @param N     推荐结果的数目
        @param K     选取近邻的数目
    '''
#    print user
    rank = dict()
    ru = train[user]
    for i in  ru:
#        print i
        if i not in W :
            continue
        for j,wj in sorted(W[i].items(), key=itemgetter(1),reverse = True)[0:K]:
            if j in ru:
                continue
            if j in rank:
                rank[j] += wj
            else:
                rank[j] = 0

    rank = sorted(rank.items(), key=itemgetter(1), reverse = True)[0:N]
#    print rank
    return rank


        

def Recall(train, test, W, N, K):
    ''' 计算推荐结果的召回率
        @param train 训练数据集Dict
        @param test  测试数据集Dict
        @param W     记录用户相似度的二维矩阵
        @param N     推荐结果的数目
        @param K     选取近邻的数目
    '''
    hit = 0
    all = 0
    for user in train.keys():
        if user in test:
            tu = test[user]
            rank = GetRecommendation(user, train, W, N, K)
            for item, pui in rank:
                if item in tu:
                    hit+= 1
            all += len(tu)
    print(hit)
    print(all)
    return hit/(all * 1.0)
        
def Precision(train, test, W, N, K):
    ''' 计算推荐结果的准确率
        @param train 训练数据集Dict
        @param test  测试数据集Dict
        @param W     记录用户相似度的二维矩阵
        @param N     推荐结果的数目
        @param K     选取近邻的数目
    '''
    hit = 0
    all = 0
    for user in train.keys():
        if user in test:
            tu = test[user]
            rank = GetRecommendation(user, train, W, N, K)
            for item, pui in rank:
                if item in tu:
                    hit+= 1
            all += N
    print(hit)
    print(all)
    return hit/(all * 1.0)

def Popularity(train, test, W, N, K):
    ''' 计算推荐结果的流行度
        @param train 训练数据集Dict
        @param test  测试数据集Dict
        @param W     记录用户相似度的二维矩阵
        @param N     推荐结果的数目
        @param K     选取近邻的数目
    '''
    item_popularity = dict()
    for user, items in train.items():
        for item in items:
            if item not in item_popularity:
                item_popularity[item] = 0
            item_popularity[item] += 1

    ret = 0
    n = 0
    for user in train.keys():
        rank = GetRecommendation(user, train, W, N, K)
        for item, pui in rank:
            ret += math.log(1+ item_popularity[item])
            n += 1
    ret /= n * 1.0
    return ret


if __name__ == '__main__':
     data = []
     data1 = []
     data2 = []
     M = 8
     key = 1
     seed = 1
     N = 100
     K = 80
     W = dict()
     rank = dict()

     print("this is the main function")
     file = open('./data/sim.csv')
     file1 = open('./data/train.csv')
     file2 = open('./data/test.csv')
     
     ReadData(file,data)
     ReadData(file1,data1)
     ReadData(file2,data2)
     train1,test1 = SplitData(data1, M, key, seed)
     train2,test2 = SplitData(data2, M, key, seed)
     train,test = SplitData(data, M, key, seed)
     W = ItemSimilarity(train)
     recall = Recall(train, test, W, N, K)
     recall1 = Recall(train, train1, W, N, K)
     precision = Precision(train, test, W, N, K)
     popularity = Popularity(train, test, W, N, K)
     coverage = Coverage(train, test, W, N, K)
     print 'recall: ',recall,'\n'
     print 'precision: ',precision,'\n'
     print 'Popularity: ',popularity,'\n'
     print 'coverage: ', coverage,'\n'
     features=[['uid','qid','pui']]
     for user in train.keys():
         if user in train2:
             tu = train2[user]
             rank = GetRecommendation(user, train, W, N, K)
             for item, pui in rank:
                 print user,item,pui
                 temp=[user,item,pui]
                 features.append(temp)
     #将特征集写入文件
     fl=open('itembased_uip.csv', 'w')
     for line in features:
         for i in line:
             fl.write(str(i))
             fl.write(',')
         fl.write("\n")
     fl.close()
     print '写入完毕...' 
    
else :
     print("this is not the main function")
     
