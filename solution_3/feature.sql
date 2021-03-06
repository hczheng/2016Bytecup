/****** Script for SelectTopNRows command from SSMS  ******/
SELECT [qid]
      ,[uid]
      ,[label]
      ,[zj_answer]
      ,[zj_tuisong]
      ,[zj_q_label_answers]
      ,[zj_q_label_tuisong]
      ,[huidalv]
      ,[label_huidalv]
      ,[label_tuisongbi]
      ,[label_huidabi]
      ,[qz_word_ratio]
      ,[qz_char_ratio]
      ,[qz_char__dist]
      ,[qz_word__dist]
  FROM [Byte Cup].[dbo].[test1018]

    --2016.11.02提交测试，最优0.49128
  --select qid,uid--,(label*0.7+gl*0.15+item*0.15) as label--gl as label
  ----,(label*0.7+gl*0.15+item*0.15) as label489
  --,(label*0.6+gl*0.2+item*0.2) as label  --0.49128
  ----,(label*0.7+item*0.3) as label49002
  --into [Byte Cup].[dbo].xgb_allin1110
  --from [Byte Cup].[dbo].xgb_allin1102
  --order by label desc


  --select test.qid,test.uid,xgb.label*test.huidalv*test.label_huidalv as label
  --from [Byte Cup].[dbo].[test1018] test
  --left join [Byte Cup].[dbo].xgb_allin1110 xgb
  --on test.qid=xgb.qid and test.uid=xgb.uid
  --order by label desc

--update [Byte Cup].[dbo].[test1018] set  qz_word__dist=REPLACE(qz_word__dist,',','') 
--update [Byte Cup].[dbo].[train1018] set  qz_word__dist=REPLACE(qz_word__dist,',','') 

--2016.11.11统计分析
select *
FROM [Byte Cup].[dbo].[train1018]
--where cast(qz_word__dist as float)>5--5957/230
--where cast(qz_word__dist as float)<=5 and cast(qz_word__dist as float)>4--54555/4542
--where cast(qz_word__dist as float)<=4 and cast(qz_word__dist as float)>3.5--76493/9000
--where cast(qz_word__dist as float)<=3.5 and cast(qz_word__dist as float)>3--64768/7849
--where cast(qz_word__dist as float)<=3 and cast(qz_word__dist as float)>2.5--34887/4478
--where cast(qz_word__dist as float)<=2.5 and cast(qz_word__dist as float)>2--7441/979
--where cast(qz_word__dist as float)<=2 and cast(qz_word__dist as float)>1--1603/246
--where cast(qz_word__dist as float)<=1--48/0

select *
FROM [Byte Cup].[dbo].[train1018]
where cast(zj_answer as float)<4 and cast(zj_answer as float)>0 and cast(huidalv as float)>0.5--774
--where cast(huidalv as float)>0.8--5624/5240
and label=1--230
order by qz_word__dist desc



select *
from [Byte Cup].[dbo].[test1018]
where cast(zj_answer as float)<4 and cast(zj_answer as float)>0 and cast(huidalv as float)>0.5--199


select *FROM [Byte Cup].[dbo].[train1018]--245752
--筛选特征作为gl训练集
drop table [Byte Cup].[dbo].[train1111]
select train1018.*,train1011.question_label,train1011.zan,train1011.answer,train1011.sp_answer
into [Byte Cup].[dbo].[train1111]
from [Byte Cup].[dbo].[train1018] train1018
left join [Byte Cup].[dbo].question_info train1011
on train1018.qid=train1011.question_ID 
--order by train1018.qz_word_ratio desc--90
--order by train1018.zj_tuisong desc--110
--order by train1018.zj_answer desc--90

select qid,uid,label,cast(zj_answer as float)/90 as zj_answer,cast(zj_tuisong as float)/110 as zj_tuisong,
cast(zj_q_label_answers as float)/90 as zj_q_label_answers,cast(zj_q_label_tuisong as float)/110 as zj_q_label_tuisong,
huidalv,label_huidalv,'ql'+question_label as ql,
cast(zan as float)as zan,
cast(answer as float) as answer,
cast(sp_answer as float)/500 as sp_answer
from [Byte Cup].[dbo].[train1111] 
order by sp_answer desc

--update [Byte Cup].[dbo].[train1111]  set sp_answer=500 where cast(sp_answer as float)>500

--test集
drop table [Byte Cup].[dbo].[test1111]
select train1018.*,train1011.question_label,train1011.zan,train1011.answer,train1011.sp_answer
into [Byte Cup].[dbo].[test1111]
from [Byte Cup].[dbo].[test1018] train1018
left join [Byte Cup].[dbo].question_info train1011
on train1018.qid=train1011.question_ID 

select qid,uid,cast(zj_answer as float)/90 as zj_answer,cast(zj_tuisong as float)/110 as zj_tuisong,
cast(zj_q_label_answers as float)/90 as zj_q_label_answers,cast(zj_q_label_tuisong as float)/110 as zj_q_label_tuisong,
huidalv,label_huidalv,'ql'+question_label as ql,
cast(zan as float)as zan,
cast(answer as float) as answer,
cast(sp_answer as float)/500 as sp_answer
from [Byte Cup].[dbo].[test1111] 
order by sp_answer desc

--update [Byte Cup].[dbo].[test1111]  set sp_answer=500 where cast(sp_answer as float)>500


--2.16.11.15

  --select * from [Byte Cup].[dbo].train_1115 
  --order by qz_word__dist --0.1867718-6.9280323
  --order by qz_char__dist --0.35149982-8.1649658
  --筛选特征集train
  select qid,uid,label,cast(zj_answers as float)/90 as zj_answers,cast(zj_tuisong as float)/110 as zj_tuisong,
  cast(zj_q_label_answers as float)/90 as zj_q_label_answers,cast(zj_q_label_tuisong as float)/110 as zj_q_label_tuisong,
  huidalv,label_huidalv,huidabi,(case when huidalv=0 then 0 else label_huidalv/huidalv end)as huidalvbi,
  'ql'+question_label as q_label,zj_label,
  (case when cast(answer as float)>1000 then 'top' when cast(answer as float)<=1000 and cast(answer as float)>100 then 'hot1'
        when cast(answer as float)<=100 and cast(answer as float)>50 then 'hot2'
		when cast(answer as float)<=50 and cast(answer as float)>20 then 'hot3'
        when cast(answer as float)<=20 and cast(answer as float)>10 then 'hot4'
        when cast(answer as float)<=10 and cast(answer as float)>0 then 'hot5' else 'zero'end) as q_hot,
  cast(sp_answer as float)/500 as q_sp,
  (case when answer=0 then 0 else cast(sp_answer as float)/cast(answer as float)end) as sp_rate,
  (case when qz_word_ratio>=0.0 and qz_word_ratio<0.1 then 'r1' when qz_word_ratio>=0.1 and qz_word_ratio<0.2 then 'r2'
        when qz_word_ratio>=0.2 and qz_word_ratio<0.3 then 'r3' when qz_word_ratio>=0.3 and qz_word_ratio<0.4 then 'r4'
        when qz_word_ratio>=0.4 and qz_word_ratio<0.5 then 'r5' when qz_word_ratio>=0.5 and qz_word_ratio<0.6 then 'r6'
        when qz_word_ratio>=0.6 and qz_word_ratio<0.7 then 'r7' when qz_word_ratio>=0.7 and qz_word_ratio<0.8 then 'r8'
        when qz_word_ratio>=0.8 and qz_word_ratio<0.9 then 'r9' else 'r10' end)as qz_word_ratio,
  (case when qz_char_ratio>=0.0 and qz_char_ratio<0.1 then 'r1' when qz_char_ratio>=0.1 and qz_char_ratio<0.2 then 'r2'
        when qz_char_ratio>=0.2 and qz_char_ratio<0.3 then 'r3' when qz_char_ratio>=0.3 and qz_char_ratio<0.4 then 'r4'
		when qz_char_ratio>=0.4 and qz_char_ratio<0.5 then 'r5' when qz_char_ratio>=0.5 and qz_char_ratio<0.6 then 'r6'
		when qz_char_ratio>=0.6 and qz_char_ratio<0.7 then 'r7' when qz_char_ratio>=0.7 and qz_char_ratio<0.8 then 'r8'
		when qz_char_ratio>=0.8 and qz_char_ratio<0.9 then 'r9' else 'r10' end)as qz_char_ratio,
  (case when cast(qz_word__dist as float)>=0.0 and cast(qz_word__dist as float)<1.0 then 'd1' when cast(qz_word__dist as float)>=1.0 and cast(qz_word__dist as float)<2.0 then 'd2'
        when cast(qz_word__dist as float)>=2.0 and cast(qz_word__dist as float)<3.0 then 'd3' when cast(qz_word__dist as float)>=3.0 and cast(qz_word__dist as float)<4.0 then 'd4'
		when cast(qz_word__dist as float)>=4.0 and cast(qz_word__dist as float)<5.0 then 'd5' when cast(qz_word__dist as float)>=5.0 and cast(qz_word__dist as float)<6.0 then 'd6' 
		else 'd7' end) as qz_word_dist,
  (case when cast(qz_char__dist as float)>=0.0 and cast(qz_char__dist as float)<1.0 then 'd1'when cast(qz_char__dist as float)>=1.0 and cast(qz_char__dist as float)<2.0 then 'd2'
        when cast(qz_char__dist as float)>=2.0 and cast(qz_char__dist as float)<3.0 then 'd3'when cast(qz_char__dist as float)>=3.0 and cast(qz_char__dist as float)<4.0 then 'd4'
		when cast(qz_char__dist as float)>=4.0 and cast(qz_char__dist as float)<5.0 then 'd5'when cast(qz_char__dist as float)>=5.0 and cast(qz_char__dist as float)<6.0 then 'd6'
		when cast(qz_char__dist as float)>=6.0 and cast(qz_char__dist as float)<7.0 then 'd7'else 'd8'end ) as qz_char_dist
  from [Byte Cup].[dbo].train_1115 
  order by qz_word_dist desc


  --筛选特征集test
  select qid,uid,label,cast(zj_answers as float)/90 as zj_answers,cast(zj_tuisong as float)/110 as zj_tuisong,
  cast(zj_q_label_answers as float)/90 as zj_q_label_answers,cast(zj_q_label_tuisong as float)/110 as zj_q_label_tuisong,
  huidalv,label_huidalv,huidabi,(case when huidalv=0 then 0 else label_huidalv/huidalv end)as huidalvbi,
  'ql'+question_label as q_label,
  (case when cast(answer as float)>1000 then 'top'
  when cast(answer as float)<=1000 and cast(answer as float)>100 then 'hot1'
  when cast(answer as float)<=100 and cast(answer as float)>50 then 'hot2'
  when cast(answer as float)<=50 and cast(answer as float)>20 then 'hot3'
  when cast(answer as float)<=20 and cast(answer as float)>10 then 'hot4'
  when cast(answer as float)<=10 and cast(answer as float)>3 then 'hot5'
  else 'zero'
  end) as q_hot,
  cast(sp_answer as float)/500 as q_sp,
 (case when answer=0 then 0 else cast(sp_answer as float)/cast(answer as float)end) as sp_rate
  from [Byte Cup].[dbo].test_1115 
  order by q_sp desc


  --筛选特征集validate
  select qid,uid,label,cast(zj_answers as float)/90 as zj_answers,cast(zj_tuisong as float)/110 as zj_tuisong,
  cast(zj_q_label_answers as float)/90 as zj_q_label_answers,cast(zj_q_label_tuisong as float)/110 as zj_q_label_tuisong,
  huidalv,label_huidalv,huidabi,(case when huidalv=0 then 0 else label_huidalv/huidalv end)as huidalvbi,
  'ql'+question_label as q_label,zj_label,
  (case when cast(answer as float)>1000 then 'top'
  when cast(answer as float)<=1000 and cast(answer as float)>100 then 'hot1'
  when cast(answer as float)<=100 and cast(answer as float)>50 then 'hot2'
  when cast(answer as float)<=50 and cast(answer as float)>20 then 'hot3'
  when cast(answer as float)<=20 and cast(answer as float)>10 then 'hot4'
  when cast(answer as float)<=10 and cast(answer as float)>0 then 'hot5'
  else 'zero'
  end) as q_hot,
  cast(sp_answer as float)/500 as q_sp,
 (case when answer=0 then 0 else cast(sp_answer as float)/cast(answer as float)end) as sp_rate,
  (case when qz_word_ratio>=0.0 and qz_word_ratio<0.1 then 'r1' when qz_word_ratio>=0.1 and qz_word_ratio<0.2 then 'r2'
        when qz_word_ratio>=0.2 and qz_word_ratio<0.3 then 'r3' when qz_word_ratio>=0.3 and qz_word_ratio<0.4 then 'r4'
        when qz_word_ratio>=0.4 and qz_word_ratio<0.5 then 'r5' when qz_word_ratio>=0.5 and qz_word_ratio<0.6 then 'r6'
        when qz_word_ratio>=0.6 and qz_word_ratio<0.7 then 'r7' when qz_word_ratio>=0.7 and qz_word_ratio<0.8 then 'r8'
        when qz_word_ratio>=0.8 and qz_word_ratio<0.9 then 'r9' else 'r10' end)as qz_word_ratio,
  (case when qz_char_ratio>=0.0 and qz_char_ratio<0.1 then 'r1' when qz_char_ratio>=0.1 and qz_char_ratio<0.2 then 'r2'
        when qz_char_ratio>=0.2 and qz_char_ratio<0.3 then 'r3' when qz_char_ratio>=0.3 and qz_char_ratio<0.4 then 'r4'
		when qz_char_ratio>=0.4 and qz_char_ratio<0.5 then 'r5' when qz_char_ratio>=0.5 and qz_char_ratio<0.6 then 'r6'
		when qz_char_ratio>=0.6 and qz_char_ratio<0.7 then 'r7' when qz_char_ratio>=0.7 and qz_char_ratio<0.8 then 'r8'
		when qz_char_ratio>=0.8 and qz_char_ratio<0.9 then 'r9' else 'r10' end)as qz_char_ratio,
  (case when cast(qz_word__dist as float)>=0.0 and cast(qz_word__dist as float)<1.0 then 'd1' when cast(qz_word__dist as float)>=1.0 and cast(qz_word__dist as float)<2.0 then 'd2'
        when cast(qz_word__dist as float)>=2.0 and cast(qz_word__dist as float)<3.0 then 'd3' when cast(qz_word__dist as float)>=3.0 and cast(qz_word__dist as float)<4.0 then 'd4'
		when cast(qz_word__dist as float)>=4.0 and cast(qz_word__dist as float)<5.0 then 'd5' when cast(qz_word__dist as float)>=5.0 and cast(qz_word__dist as float)<6.0 then 'd6' 
		else 'd7' end) as qz_word_dist,
  (case when cast(qz_char__dist as float)>=0.0 and cast(qz_char__dist as float)<1.0 then 'd1'when cast(qz_char__dist as float)>=1.0 and cast(qz_char__dist as float)<2.0 then 'd2'
        when cast(qz_char__dist as float)>=2.0 and cast(qz_char__dist as float)<3.0 then 'd3'when cast(qz_char__dist as float)>=3.0 and cast(qz_char__dist as float)<4.0 then 'd4'
		when cast(qz_char__dist as float)>=4.0 and cast(qz_char__dist as float)<5.0 then 'd5'when cast(qz_char__dist as float)>=5.0 and cast(qz_char__dist as float)<6.0 then 'd6'
		when cast(qz_char__dist as float)>=6.0 and cast(qz_char__dist as float)<7.0 then 'd7'else 'd8'end ) as qz_char_dist
  from [Byte Cup].[dbo].validate_1115 
  order by q_sp desc


   --2016.11.16获取专家标签（取第一位得了）
   select zj_ID as uid,zj_label,--charindex('/',zj_label),
   (case when charindex('/',zj_label)=0 then 'ul'+zj_label
   else 'ul'+substring(zj_label,0,charindex('/',zj_label)) end)as u_label
   from [Byte Cup].[dbo].user_info
   order by u_label


  --筛选特征集train1120
  select qid,uid,label,cast(zj_answers as float) as zj_answers,cast(zj_tuisong as float)/110 as zj_tuisong,
  cast(zj_q_label_answers as float)/90 as zj_q_label_answers,cast(zj_q_label_tuisong as float)/110 as zj_q_label_tuisong,
  huidalv,label_huidalv,huidabi,(case when huidalv=0 then 0 else label_huidalv/huidalv end)as huidalvbi,
  'ql'+question_label as q_label,zj_label,
    (case when cast(answer as float)>1000 then 'top' when cast(answer as float)<=1000 and cast(answer as float)>100 then 'hot1'
        when cast(answer as float)<=100 and cast(answer as float)>50 then 'hot2'
		when cast(answer as float)<=50 and cast(answer as float)>20 then 'hot3'
        when cast(answer as float)<=20 and cast(answer as float)>10 then 'hot4'
        when cast(answer as float)<=10 and cast(answer as float)>0 then 'hot5' else 'zero'end) as q_hot,
  cast(sp_answer as float)/500 as q_sp,
  (case when answer=0 then 0 else cast(sp_answer as float)/cast(answer as float)end) as sp_rate
  from [Byte Cup].[dbo].train_1120


  --筛选特征集test
  select qid,uid,label,cast(zj_answers as float)/90 as zj_answers,cast(zj_tuisong as float)/110 as zj_tuisong,
  cast(zj_q_label_answers as float)/90 as zj_q_label_answers,cast(zj_q_label_tuisong as float)/110 as zj_q_label_tuisong,
  huidalv,label_huidalv,huidabi,(case when huidalv=0 then 0 else label_huidalv/huidalv end)as huidalvbi,
  'ql'+question_label as q_label,
  cast(sp_answer as float)/500 as q_sp,
 (case when answer=0 then 0 else cast(sp_answer as float)/cast(answer as float)end) as sp_rate
  from [Byte Cup].[dbo].test_1120 
  order by q_sp desc


  --筛选特征集validate
  select qid,uid,label,cast(zj_answers as float)/90 as zj_answers,cast(zj_tuisong as float)/110 as zj_tuisong,
  cast(zj_q_label_answers as float)/90 as zj_q_label_answers,cast(zj_q_label_tuisong as float)/110 as zj_q_label_tuisong,
  huidalv,label_huidalv,huidabi,(case when huidalv=0 then 0 else label_huidalv/huidalv end)as huidalvbi,
  'ql'+question_label as q_label,zj_label,
  (case when cast(answer as float)>1000 then 'top'
  when cast(answer as float)<=1000 and cast(answer as float)>100 then 'hot1'
  when cast(answer as float)<=100 and cast(answer as float)>50 then 'hot2'
  when cast(answer as float)<=50 and cast(answer as float)>20 then 'hot3'
  when cast(answer as float)<=20 and cast(answer as float)>10 then 'hot4'
  when cast(answer as float)<=10 and cast(answer as float)>0 then 'hot5'
  else 'zero'
  end) as q_hot,
  cast(sp_answer as float)/500 as q_sp,
 (case when answer=0 then 0 else cast(sp_answer as float)/cast(answer as float)end) as sp_rate
  from [Byte Cup].[dbo].validate_1120
  order by q_sp desc


   --2016.11.16获取专家标签（取第一位得了）
   select zj_ID as uid,zj_label,--charindex('/',zj_label),
   (case when charindex('/',zj_label)=0 then 'ul'+zj_label
   else 'ul'+substring(zj_label,0,charindex('/',zj_label)) end)as u_label
   from [Byte Cup].[dbo].user_info
   order by u_label