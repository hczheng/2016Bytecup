  --统计信息
  --27324条正样本\218428条负样本\差不多1:9/10这样子
  select count(*) from [Byte Cup].[dbo].[user_info];--28763 专家总数
  select zj_ID FROM [Byte Cup].[dbo].[user_info] group by zj_ID;--28763 专家总数（没有重复ID）
  select count(*) from [Byte Cup].[dbo].[question_info];--8095  问题总数
  select question_ID from [Byte Cup].[dbo].[question_info]group by question_ID;--8095 问题总数（没有重复ID）
  select count(*) from [Byte Cup].[dbo].[invited_info_train];--245752 训练样本集
  select count(*) from [Byte Cup].[dbo].validate_nolabel;--30466 验证样本集
  select count(*) from [Byte Cup].[dbo].test_nolabel;--30167 最终测试样本集

  select count(*) from [Byte Cup].[dbo].[invited_info_train] iit
  INNER join  [Byte Cup].[dbo].[user_info] ui on
  iit.zj_ID= ui.zj_ID;--245752

   select count(iit.label) from [Byte Cup].[dbo].[invited_info_train] iit
   INNER join  [Byte Cup].[dbo].[question_info] qi on
   iit.questionID= qi.question_ID;--245752

   --去重
   select zj_ID,question_ID,max(label)as label
   into [Byte Cup].[dbo].[invited_info_train_qc]
   from [Byte Cup].[dbo].[invited_info_train]--229440
   group by zj_ID,question_ID
  --数据预处理
  --连接专家信息和question信息到train表：
  drop table [Byte Cup].[dbo].[iit_qi]
  select qi.*,iit.zj_ID,iit.label 
  into [Byte Cup].[dbo].[iit_qi]--229440
  from [Byte Cup].[dbo].[invited_info_train_qc] iit
  left  join [Byte Cup].[dbo].[question_info] qi on
  iit.question_ID=qi.question_ID;

  drop table [Byte Cup].[dbo].[iit_qi_ui_train]
  select iq.*,ui.zj_label,ui.word_sequence as zj_word_sequence,ui.char_sequence as zj_char_sequence
  into  [Byte Cup].[dbo].[iit_qi_ui_train]--229440
  from [Byte Cup].[dbo].[iit_qi] iq
  left  join [Byte Cup].[dbo].[user_info] ui on
  iq.zj_ID=ui.zj_ID

 --连接user信息和question信息到validate表：
  drop table [Byte Cup].[dbo].[validate_qi]
  select qi.*,validate.zj_ID,validate.label 
  into [Byte Cup].[dbo].[validate_qi]--30466
  from [Byte Cup].[dbo].[validate_nolabel] validate
  left  join [Byte Cup].[dbo].[question_info] qi on
  validate.question_ID=qi.question_ID;

  drop table [Byte Cup].[dbo].validate
  select vq.*,ui.zj_label,ui.word_sequence as zj_word_sequence,ui.char_sequence as zj_char_sequence
  into  [Byte Cup].[dbo].validate--30466
  from [Byte Cup].[dbo].[validate_qi] vq
  left  join [Byte Cup].[dbo].[user_info] ui on
  vq.zj_ID=ui.zj_ID

  --连接user信息和question信息到test表：(测试集的专家ID(问题ID)就是uid(qid)了...前面的懒得改了)
  drop table [Byte Cup].[dbo].[test_qi]
  select qi.*,test.uid,test.label 
  into [Byte Cup].[dbo].[test_qi]--30167
  from [Byte Cup].[dbo].[test_nolabel] test
  left  join [Byte Cup].[dbo].[question_info] qi on
  test.qid=qi.question_ID;

  drop table [Byte Cup].[dbo].[test]
  select iq.*,ui.zj_label,ui.word_sequence as zj_word_sequence,ui.char_sequence as zj_char_sequence
  into  [Byte Cup].[dbo].[test]--30167
  from [Byte Cup].[dbo].[test_qi] iq
  left  join [Byte Cup].[dbo].[user_info] ui on
  iq.uid=ui.zj_ID

  --特征构造
  --统计专家回答数（专家标签回答数）
    drop table [Byte Cup].[dbo].[zj_answers];
    select zj_ID,sum(cast(label as bigint))AS zj_answers,count(label)as zj_tuisong 
	into [Byte Cup].[dbo].[zj_answers]--27127
    from [Byte Cup].[dbo].[iit_qi_ui_train]
    group by zj_ID;

	drop table [Byte Cup].[dbo].[zj_q_label_answers];
	select zj_ID,question_label,sum(cast(label as bigint))AS zj_q_label_answers,count(label)as zj_q_label_tuisong  
	into [Byte Cup].[dbo].[zj_q_label_answers]--38972
    from [Byte Cup].[dbo].[iit_qi_ui_train]
    group by zj_ID,question_label;

  --合并专家回答信息到train表：
  --1.
  drop table [Byte Cup].[dbo].[train_add_zjanswer] ;
  select train.*,zja.zj_answers,zja.zj_tuisong 
  into [Byte Cup].[dbo].[train_add_zjanswer] --229440
  from [Byte Cup].[dbo].[iit_qi_ui_train] train
  left join [Byte Cup].[dbo].[zj_answers] zja on
  train.zj_ID=zja.zj_ID 

  select * from [Byte Cup].[dbo].[train_add_zjanswer]--这是原来未去重的245752
  --2.  
  drop table [Byte Cup].[dbo].[train_add_zj_q_label_answers] ;
  select train.*,zja.zj_q_label_answers,zja.zj_q_label_tuisong 
  into [Byte Cup].[dbo].[train_add_zj_q_label_answers] 
  from [Byte Cup].[dbo].[train_add_zjanswer]  train
  left join [Byte Cup].[dbo].[zj_q_label_answers] zja on
  train.zj_ID=zja.zj_ID and train.question_label=zja.question_label

  select * from [Byte Cup].[dbo].[train_add_zj_q_label_answers]--这是原来未去重的245752

  --合并专家信息到validate表：
  --1.
  drop table [Byte Cup].[dbo].[validate_add_zjanswer];
  select validate.*,
  (case when zja.zj_answers is null then 0 else zja.zj_answers end)as zj_answers ,
  (case when zja.zj_tuisong is null then 0 else zja.zj_tuisong end)as zj_tuisong
  into [Byte Cup].[dbo].[validate_add_zjanswer] --30466
  from [Byte Cup].[dbo].validate validate
  left join [Byte Cup].[dbo].[zj_answers] zja on
  validate.zj_ID=zja.zj_ID 

  --2.   
  drop table [Byte Cup].[dbo].[validate_add_zj_q_label_answers] ;
  select validate.*,
  (case when zja.zj_q_label_answers is null then 0 else zja.zj_q_label_answers end)as zj_q_label_answers,
  (case when zja.zj_q_label_tuisong is null then 0 else zja.zj_q_label_tuisong end)as zj_q_label_tuisong
  into [Byte Cup].[dbo].[validate_add_zj_q_label_answers] --30466
  from [Byte Cup].[dbo].[validate_add_zjanswer]  validate
  left join [Byte Cup].[dbo].[zj_q_label_answers] zja on
  validate.zj_ID=zja.zj_ID and validate.question_label=zja.question_label

  --合并专家信息到test表：
  --1.
  drop table [Byte Cup].[dbo].[test_add_zjanswer];
  select test.*,
  (case when zja.zj_answers is null then 0 else zja.zj_answers end)as zj_answers ,
  (case when zja.zj_tuisong is null then 0 else zja.zj_tuisong end)as zj_tuisong
  into [Byte Cup].[dbo].[test_add_zjanswer] --30167
  from [Byte Cup].[dbo].test test
  left join [Byte Cup].[dbo].[zj_answers] zja on
  test.uid=zja.zj_ID 

  --2.   
  drop table [Byte Cup].[dbo].[test_add_zj_q_label_answers] ;
  select test.*,
  (case when zja.zj_q_label_answers is null then 0 else zja.zj_q_label_answers end)as zj_q_label_answers,
  (case when zja.zj_q_label_tuisong is null then 0 else zja.zj_q_label_tuisong end)as zj_q_label_tuisong
  into [Byte Cup].[dbo].[test_add_zj_q_label_answers] --30167
  from [Byte Cup].[dbo].[test_add_zjanswer]  test
  left join [Byte Cup].[dbo].[zj_q_label_answers] zja on
  test.uid=zja.zj_ID and test.question_label=zja.question_label


  --构建训练集
  --select * from [Byte Cup].[dbo].[train_add_zj_q_label_answers] ;
  select question_ID as qid,zj_ID as uid,label,question_label,zj_label,zan,answer,sp_answer,
  q_word_sequence,q_char_sequence,zj_word_sequence,zj_char_sequence,
  zj_answers,zj_tuisong,zj_q_label_answers,zj_q_label_tuisong,
  (case when zj_tuisong=0 then 0 else (zj_answers+0.0)/zj_tuisong end)as huidalv,
  (case when zj_q_label_tuisong=0 then 0 else (zj_q_label_answers+0.0)/zj_q_label_tuisong end)as label_huidalv,
  (case when zj_answers=0 then 0 else (zj_q_label_answers+0.0)/zj_answers end)as huidabi
  into [Byte Cup].[dbo].train_1119--229440
  from [Byte Cup].[dbo].[train_add_zj_q_label_answers]

  --处理一下sp_answer字段，更好的归一化
  update [Byte Cup].[dbo].[train_1119]  set sp_answer=500 where cast(sp_answer as float)>500--132
  
  --根据问题的回答次数划分问题热门程度
  select * 
  from [Byte Cup].[dbo].train_1113
  where cast(answer as float)>1000--2408  极度热门
  where cast(answer as float)<=1000 and cast(answer as float)>100 --31793 超热门
  where cast(answer as float)<=100 and cast(answer as float)>50 --25281   热门
  where cast(answer as float)<=50 and cast(answer as float)>20 --56499    正常
  where cast(answer as float)<=20 and cast(answer as float)>10 --48904    一般
  where cast(answer as float)<=10 and cast(answer as float)>3 --54173     冷门
  where cast(answer as float)<=3 and cast(answer as float)>0--54173       超冷门
  where cast(answer as float)=0 --极度冷门，无意义
  order by cast(answer as float) desc

  --筛选特征集train
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
  when cast(answer as float)<=3 and cast(answer as float)>0 then 'hot6'
  else 'zero'
  end) as q_hot,
  cast(sp_answer as float)/500 as q_sp
  from [Byte Cup].[dbo].train_1119 
  order by q_sp desc

  --构建测试集
  select question_ID as qid,uid,label,question_label,zj_label,zan,answer,sp_answer,
  word_sequence as q_word_sequence,char_sequence as q_char_sequence,zj_word_sequence,zj_char_sequence,
  zj_answers,zj_tuisong,zj_q_label_answers,zj_q_label_tuisong,
  (case when zj_tuisong=0 then 0 else (zj_answers+0.0)/zj_tuisong end)as huidalv,
  (case when zj_q_label_tuisong=0 then 0 else (zj_q_label_answers+0.0)/zj_q_label_tuisong end)as label_huidalv,
  (case when zj_answers=0 then 0 else (zj_q_label_answers+0.0)/zj_answers end)as huidabi
  into [Byte Cup].[dbo].test_1119--30167
  from [Byte Cup].[dbo].[test_add_zj_q_label_answers]

  update [Byte Cup].[dbo].[test_1119]  set sp_answer=500 where cast(sp_answer as float)>500--13

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
  when cast(answer as float)<=3 and cast(answer as float)>0 then 'hot6'
  else 'zero'
  end) as q_hot,
  cast(sp_answer as float)/500 as q_sp
  from [Byte Cup].[dbo].test_1113 
  order by q_sp desc

  --筛选验证集集validate

  select question_ID as qid,zj_ID as uid,label,question_label,zj_label,zan,answer,sp_answer,
  word_sequence as q_word_sequence,char_sequence as q_char_sequence,zj_word_sequence,zj_char_sequence,
  zj_answers,zj_tuisong,zj_q_label_answers,zj_q_label_tuisong,
  (case when zj_tuisong=0 then 0 else (zj_answers+0.0)/zj_tuisong end)as huidalv,
  (case when zj_q_label_tuisong=0 then 0 else (zj_q_label_answers+0.0)/zj_q_label_tuisong end)as label_huidalv,
  (case when zj_answers=0 then 0 else (zj_q_label_answers+0.0)/zj_answers end)as huidabi
  into [Byte Cup].[dbo].validate_1119--30466
  from [Byte Cup].[dbo].[validate_add_zj_q_label_answers]

  update [Byte Cup].[dbo].validate_1119  set sp_answer=500 where cast(sp_answer as float)>500--21

  --筛选特征集validate
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
  when cast(answer as float)<=3 and cast(answer as float)>0 then 'hot6'
  else 'zero'
  end) as q_hot,
  cast(sp_answer as float)/500 as q_sp
  from [Byte Cup].[dbo].validate_1113 
  order by q_sp desc


  --对于回答率高但回答次数少的专家回答率做一下惩罚
  select * from [Byte Cup].[dbo].train_1119  --where label=1 order by question_label
  --where zj_answers< 5 and huidalv>0.5--2321
  where zj_q_label_answers<5 and label_huidalv>0.5--4896

  update [Byte Cup].[dbo].train_1119 set huidalv=huidalv/1.5 where zj_answers< 5 and huidalv>0.5--2321
  update [Byte Cup].[dbo].train_1119 set label_huidalv=label_huidalv/1.5 where zj_q_label_answers< 5 and label_huidalv>0.5--4896

  update [Byte Cup].[dbo].test_1119 set huidalv=huidalv/1.5 where zj_answers< 5 and huidalv>0.5--234
  update [Byte Cup].[dbo].test_1119 set label_huidalv=label_huidalv/1.5 where zj_q_label_answers< 5 and label_huidalv>0.5--423

  update [Byte Cup].[dbo].validate_1119 set huidalv=huidalv/1.5 where zj_answers< 5 and huidalv>0.5--258
  update [Byte Cup].[dbo].validate_1119 set label_huidalv=label_huidalv/1.5 where zj_q_label_answers< 5 and label_huidalv>0.5--460

  --1115继续惩罚，同时考虑下回答次数多但是回答率特别低的那种
  select * from [Byte Cup].[dbo].train_1120 
  --where zj_answers< 10 and huidalv>0.6--2873
  where zj_q_label_answers<8 and label_huidalv>0.6--4567

  update [Byte Cup].[dbo].train_1120 set huidalv=huidalv/1.2 where zj_answers< 10 and huidalv>0.6--2873
  update [Byte Cup].[dbo].train_1120 set label_huidalv=label_huidalv/1.2 where zj_q_label_answers< 8 and label_huidalv>0.6--4567

  update [Byte Cup].[dbo].test_1120 set huidalv=huidalv/1.2 where zj_answers< 10 and huidalv>0.6--308
  update [Byte Cup].[dbo].test_1120 set label_huidalv=label_huidalv/1.2 where zj_q_label_answers< 8 and label_huidalv>0.6--402

  update [Byte Cup].[dbo].validate_1120 set huidalv=huidalv/1.2 where zj_answers< 10 and huidalv>0.6--340
  update [Byte Cup].[dbo].validate_1120 set label_huidalv=label_huidalv/1.2 where zj_q_label_answers< 8 and label_huidalv>0.6--436

  --1115考虑下回答次数多但是回答率特别低的那种
  select * from [Byte Cup].[dbo].train_1120 
  --where zj_answers>10 and huidalv<0.3--5501
  where zj_q_label_answers>8 and label_huidalv<0.3--6249

  update [Byte Cup].[dbo].train_1120 set huidalv=huidalv*1.5 where zj_answers>10 and huidalv<0.3--5501
  update [Byte Cup].[dbo].train_1120 set label_huidalv=label_huidalv*1.5 where zj_q_label_answers>8 and label_huidalv<0.3--6249

  update [Byte Cup].[dbo].test_1120 set huidalv=huidalv*1.5 where zj_answers>10 and huidalv<0.3--651
  update [Byte Cup].[dbo].test_1120 set label_huidalv=label_huidalv*1.5 where zj_q_label_answers>8 and label_huidalv<0.3--765

  update [Byte Cup].[dbo].validate_1120 set huidalv=huidalv*1.5 where zj_answers>10 and huidalv<0.3--689
  update [Byte Cup].[dbo].validate_1120 set label_huidalv=label_huidalv*1.5 where zj_q_label_answers>8 and label_huidalv<0.3--782

  --1116 继续提升考虑下回答次数多但是回答率特别低的那种
  select * from [Byte Cup].[dbo].train_1115 
  where zj_answers>15 and huidalv<0.4--5431
  where zj_q_label_answers>15 and label_huidalv<0.5--7513

  update [Byte Cup].[dbo].train_1115 set huidalv=huidalv*1.2 where zj_answers>15 and huidalv<0.4--5431
  update [Byte Cup].[dbo].train_1115 set label_huidalv=label_huidalv*1.2 where zj_q_label_answers>15 and label_huidalv<0.5--7513

  update [Byte Cup].[dbo].test_1115 set huidalv=huidalv*1.2 where zj_answers>15 and huidalv<0.4--605
  update [Byte Cup].[dbo].test_1115 set label_huidalv=label_huidalv*1.2 where zj_q_label_answers>15 and label_huidalv<0.5--745

  update [Byte Cup].[dbo].validate_1115 set huidalv=huidalv*1.2 where zj_answers>15 and huidalv<0.4--635
  update [Byte Cup].[dbo].validate_1115 set label_huidalv=label_huidalv*1.2 where zj_q_label_answers>15 and label_huidalv<0.5--833



 --添加新特征：(把之前构造的特征：词向量相似度，词距离加上)结果表明并无软用
  drop table [Byte Cup].[dbo].train_1115 
  select new.*,old.qz_word_ratio,old.qz_char_ratio,old.qz_word__dist,old.qz_char__dist
  into [Byte Cup].[dbo].train_1120
  from [Byte Cup].[dbo].train1018 old
  left join [Byte Cup].[dbo].train_1119 new
  on old.qid=new.qid and old.uid=new.uid

  drop table [Byte Cup].[dbo].train_1120
  select *
  into [Byte Cup].[dbo].train_1120--229440
   from [Byte Cup].[dbo].train_1119

  drop table [Byte Cup].[dbo].validate_1115 
  select new.*,old.qz_word_ratio,old.qz_char_ratio,old.qz_word__dist,old.qz_char__dist
  into [Byte Cup].[dbo].validate_1115
  from [Byte Cup].[dbo].test1018 old
  left join [Byte Cup].[dbo].validate_1113 new
  on old.qid=new.qid and old.uid=new.uid

  drop table [Byte Cup].[dbo].validate_1120
  select *
  into [Byte Cup].[dbo].validate_1120
   from [Byte Cup].[dbo].validate_1119

  select *
  into [Byte Cup].[dbo].test_1120
   from [Byte Cup].[dbo].test_1119



   --2016.11.16获取专家标签（取第一位得了）
   select zj_ID as uid,zj_label,--charindex('/',zj_label),
   (case when charindex('/',zj_label)=0 then zj_label
   else substring(zj_label,0,charindex('/',zj_label)) end)as u_label
   from [Byte Cup].[dbo].user_info



  --1118继续惩罚，同时考虑下回答次数多但是回答率特别低的那种
  select qid,uid from [Byte Cup].[dbo].train_1115  --278376
  group by qid,uid--229440
  --where zj_answers< 10 and huidalv>=0.4--7152
  where zj_q_label_answers<10 and label_huidalv>=0.4--10745

  select * from [Byte Cup].[dbo].validate_1115  
  where zj_answers< 10 and huidalv>=0.4--790
  where zj_q_label_answers<10 and label_huidalv>0.4--1052

  select * from [Byte Cup].[dbo].test_1115  
  ---where zj_answers< 10 and huidalv>0.4--772
  where zj_q_label_answers<10 and label_huidalv>0.4--1025



  update [Byte Cup].[dbo].train_1115 set huidalv=huidalv/1.2 where zj_answers< 10 and huidalv>0.6--2788
  update [Byte Cup].[dbo].train_1115 set label_huidalv=label_huidalv/1.2 where zj_q_label_answers< 8 and label_huidalv>0.6--4381

  update [Byte Cup].[dbo].test_1115 set huidalv=huidalv/1.2 where zj_answers< 10 and huidalv>0.6--226
  update [Byte Cup].[dbo].test_1115 set label_huidalv=label_huidalv/1.2 where zj_q_label_answers< 8 and label_huidalv>0.6--414

  update [Byte Cup].[dbo].validate_1115 set huidalv=huidalv/1.2 where zj_answers< 10 and huidalv>0.6--317
  update [Byte Cup].[dbo].validate_1115 set label_huidalv=label_huidalv/1.2 where zj_q_label_answers< 8 and label_huidalv>0.6--414















