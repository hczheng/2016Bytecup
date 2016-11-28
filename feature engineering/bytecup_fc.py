# -*- coding: utf-8 -*-
"""
Created on Mon Oct 10 19:52:42 2016

@author: zhenghuangcheng
"""
#       [question_ID] 0
#      ,[question_label]1
#      ,[q_word_sequence]2
#      ,[q_char_sequence]3
#      ,[zan]4
#      ,[answer]5
#      ,[sp_answer]6
#      ,[zj_ID]7
#      ,[label]8
#      ,[zj_label]9
#      ,[zj_word_sequence]10
#      ,[zj_char_sequence]11
#      ,[zj_answers]12
#      ,[zj_tuisong]13
#      ,[zj_q_label_answers]14
#      ,[zj_q_label_tuisong]15
#	   ,cast(zj_answers as float)/zj_tuisong as huidalv	16
#	  ,cast(zj_q_label_answers as float)/zj_q_label_tuisong as label_huidalv  17
#	  ,cast(zj_q_label_tuisong as float)/zj_tuisong as label_tuisongbi  18

import difflib
from sklearn.feature_extraction.text import CountVectorizer
vectorizer = CountVectorizer()
from sklearn.metrics.pairwise import euclidean_distances

features=[['qid','uid','label','zj_answer','zj_tuisong','zj_q_label_answers',
'zj_q_label_tuisong','huidalv','label_huidalv','label_tuisongbi','label_huidabi',
'qz_word_ratio','qz_char_ratio','qz_char__dist','qz_word__dist','q_word_zj_word_min']]
index=1
f= open('data/features_train.csv')
#f= open('data/features_test.csv')
context=f.readlines()
index=0
for line in context:
    print '特征构造\t第',index,'条记录'
    line=line.replace('\n','')
    array=line.split(',')
    a=array[1]
    if a=='question_label':
        continue
    #qid,uid,label
    qid=array[0]
    uid=array[7]
    label=array[8]
    zj_answer=0
    if array[12]!='NULL':
        zj_answer=float(array[12])
    zj_tuisong=0
    if array[13]!='NULL':
        zj_tuisong=array[13]
    zj_q_label_answers=0
    if array[14]!='NULL':   
        zj_q_label_answers=array[14]
    zj_q_label_tuisong=0
    if array[15]!='NULL': 
        zj_q_label_tuisong=array[15]
    huidalv=0
    if array[16]!='NULL':
        huidalv=array[16]
    label_huidalv=0
    if array[17]!='NULL':
        label_huidalv=array[17]
    label_tuisongbi=0
    if array[18]!='NULL':
        label_tuisongbi=array[18]
    label_huidabi=0
    if zj_answer!=0:
        label_huidabi=float(zj_q_label_answers)/float(zj_answer)   
    #ratio方法计算相似度:word和char 2个特征
    qz_word_ratio=0.5#缺失值处理，暂时默认为0.5
    qz_char_ratio=0.5
    if array[2]!='/' and array[10]!='/':
        qz_word_ratio=difflib.SequenceMatcher(None,array[2],array[10]).ratio()
    if array[3]!='/' and array[11]!='/':
        qz_char_ratio=difflib.SequenceMatcher(None,array[3],array[11]).ratio()
    #欧式距离计算相似度（取倒数）:word和char 2个特征  
    qz_word__dist=5#缺失值处理，暂时默认为5
    qz_char__dist=5
    if array[2]!='/' and array[10]!='/':
        corpus_word = [array[2],array[10]]
        counts_word = vectorizer.fit_transform(corpus_word).todense()
        qz_word__dist = counts_word.shape[1]/euclidean_distances(counts_word[0],counts_word[1])
        qz_word__dist=''.join(map(str,qz_word__dist[0]))#list转换成str
    if array[3]!='/' and array[11]!='/':
        corpus_char = [array[3],array[11]]
        counts_char = vectorizer.fit_transform(corpus_char).todense()
        qz_char__dist = counts_char.shape[1]/euclidean_distances(counts_char[0],counts_char[1])
        qz_char__dist=''.join(map(str,qz_char__dist[0]))
#    #字词距离计数特征 
#    q_label_temp=float(array[1])
#    zj_label_temp=array[9].split('/')
#    qlzl_min=1000
#    for zlt in zj_label_temp:
#        qlzl_temp=abs(q_label_temp-float(zlt))
#        if qlzl_temp<qlzl_min:
#            qlzl_min=qlzl_temp  
#    q_label_zj_label_min=qlzl_min#最小距离
#    qlzw_min=5000
#    if array[10]!='/':
#        zj_word_sequence_temp=array[10].split('/')
#        for zwst in zj_word_sequence_temp:
#            if zwst!='':
#                qlzw_temp=abs(q_label_temp-float(zwst))
#                if qlzw_temp<qlzw_min:
#                    qlzw_min=qlzw_temp   
#    q_label_zj_word_min=qlzw_min   
#    #问题描述与专家标签的差异距离
#    #当问题描述不为空
#    qwzl_min=5000
#    if array[2]!='/':
#        q_word_sequence_temp=array[2].split('/') 
#        for qwst in q_word_sequence_temp:
#            for zlt in zj_label_temp:
#                if qwst!='':
#                    qwzl_temp=abs(float(qwst)-float(zlt))
#                    if qwzl_temp<qwzl_min:
#                        qwzl_min=qwzl_temp
#    q_word_zj_label_min=qwzl_min
    #问题描述词向量与专家描述词向量的差异距离   
    qwzw_min=5000
    qwzw_count0=0
    qwzw_count50=0
    qwzw_count100=0
    qwzw_count200=0
    qwzw_count500=0
    qwzw_count_max=0
    if array[2]!='/'and array[10]!='/':
        q_word_sequence_temp=array[2].split('/')
        zj_word_sequence_temp=array[10].split('/')
        for qwst in q_word_sequence_temp:
            for zwst in zj_word_sequence_temp: 
                if qwst!='' and zwst!='':
                    qwzw_temp=abs(float(qwst)-float(zwst))
                    if qwzw_temp<qwzw_min:
                        qwzw_min=qwzw_temp
                    if qwzw_temp==0:
                        qwzw_count0+=1
                    elif qwzw_temp>0 and qwzw_temp<=50:
                        qwzw_count50+=1
                    elif qwzw_temp>50 and qwzw_temp<=100:
                        qwzw_count100+=1
                    elif qwzw_temp>100 and qwzw_temp<=200:
                        qwzw_count200+=1
                    elif qwzw_temp>200 and qwzw_temp<=500:
                        qwzw_count500+=1
                    else:
                       qwzw_count_max+=1                                       
    q_word_zj_word_min=qwzw_min    
        
    
    
    temp=[qid,uid,label,zj_answer,zj_tuisong,zj_q_label_answers,zj_q_label_tuisong,
    huidalv,label_huidalv,label_tuisongbi,label_huidabi,qz_word_ratio,qz_char_ratio,
    qz_char__dist,qz_word__dist,q_word_zj_word_min]
    features.append(temp)
    index=index+1

print '特征构造完毕...'
print 'features_train item number:\t',len(features)

#将特征集写入文件
fl=open('newfeatures/train.csv', 'w')
for line in features:
    for i in line:
        fl.write(str(i))
        fl.write(',')
    fl.write("\n")
fl.close()
print '写入完毕...'

        
    
    
    
    
    