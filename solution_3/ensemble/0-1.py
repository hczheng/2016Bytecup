import pandas as pd
import numpy as np
import sys

file_name = sys.argv[1][:-4]
column_name='qid'
label_name='label'
result=pd.read_csv(file_name+'.csv')
keys = result.groupby(column_name).groups

for key in keys:
    pred=result[result[column_name]==key][label_name]
    index=pred.sort_values(ascending=True).index
    s=1
    all_s=sum(range(len(pred)+1))
    for i in index:
        result.ix[i,label_name]=s/all_s
        s=s+1
result.to_csv(file_name+'_processed.csv',index=False)