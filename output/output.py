# -*- coding: utf-8 -*-
"""
Created on Sun Oct 09 19:48:51 2016
@author: zhenghuangcheng
"""
output=[['qid','uid','label']]
f= open('output_1.csv')
context=f.readlines()
index=0
for line in context:
    print '特征构造\t第',index,'条记录'
    line=line.replace('\n','')
    array=line.split(',')
    a=array[1]
    if a=='uid':
        continue
    qid=array[0]
    uid=array[1]
    label=float(array[2])
    temp=[qid,uid,label]
    output.append(temp)
    index=index+1
print '完毕...'
print ' output number:\t',len(output)

 #将结果写入文件
fl=open('output_2.csv', 'w')
for line in output:
    for i in line:
        fl.write(str(i))
        fl.write(',')
    fl.write("\n")
fl.close()
print '写入完毕...'
    






