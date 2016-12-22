library(data.table)
rm(list=ls())
#=====================原始数据导入===========================
train <- fread("E:/competition/BD/DATA/invited_info_train.txt",
header=F,
stringsAsFactors=F,
sep="\t",
col.names=c("qid", "uid", "label"))

question <- fread("E:/competition/BD/DATA/question_info.txt",
header=F,
stringsAsFactors=F,
sep="\t",
col.names=c("qid", "wtbq", "qci", "qzi", "dzs", "hds", "jphds"))

user <- fread("E:/competition/BD/DATA/user_info.txt",
header=F,
stringsAsFactors=F,
sep="\t",
col.names=c("uid", "yhbq", "uci", "uzi"))

validate <- fread("E:/competition/BD/DATA/validate_nolabel.txt",
header=T,
stringsAsFactors=F,
sep=",",
col.names=c("qid", "uid"))

#=========================自定义函数======================
eta <- 0.000001
getGl <- function(list_cs, list_xl, labels_cs, labels_xl, label, xs){ 
	l1 <- unlist(list_cs)
	l2 <- unlist(list_xl)
	z1 <- unlist(labels_cs)
	z2 <- unlist(labels_xl)
	names(z1) <- l1; names(z2) <- l2
	l2 <- l2[z2 == label]; z2 <- z2[z2 == label]
	gtl <- intersect(l1, l2)
	zs <- sum(z1[gtl]); fs <- length(gtl) - zs
	w <- c(zs, fs) / (length(gtl) + 1)
	value <- xs * w[1] + (1 - xs) * (1 - w[2])
	return (value)
}

df <- function(gl){
	value <- mean(gl)
	return (value)
}

#=======================规则1：专家相似===================
u <- train[,.(qlist=list(qid), labels=list(label)), uid]

upair <- merge(validate[qid %in% train$qid,.(qid, uid)], 
train[,.(qid, uid, label)], 
by="qid", 
allow.cartesian=T, 
suffixes=c("_cs", "_xl"),
all.x=T)

upair <- unique(upair, by=NULL)

upair <- merge(upair[uid_cs %in% u$uid], 
u, 
by.x="uid_cs", 
by.y="uid",
all.x=T
)

upair <- merge(upair[uid_xl %in% u$uid], 
u, 
by.x="uid_xl", 
by.y="uid",
suffixes=c("_cs", "_xl"),
all.x=T
)

upair <- upair[,
.(ugl=getGl(qlist_cs, qlist_xl, labels_cs, labels_xl, label, 0.95)),
.(qid, uid_cs, uid_xl, label)]

ugl <- upair[,
.(ugld=df(ugl)),
.(qid, uid=uid_cs)]

#=======================规则2：问题相似===================
q <- train[,.(ulist=list(uid), labels=list(label)), qid]

qpair <- merge(validate[uid %in% train$uid,.(qid, uid)], 
train[,.(qid, uid, label)], 
by="uid", 
allow.cartesian=T, 
suffixes=c("_cs", "_xl"),
all.x=T)
qpair <- unique(qpair, by=NULL)

qpair <- merge(qpair[qid_cs %in% q$qid], 
q, 
by.x="qid_cs", 
by.y="qid",
all.x=T
)

qpair <- merge(qpair[qid_xl %in% q$qid], 
q, 
by.x="qid_xl", 
by.y="qid",
suffixes=c("_cs", "_xl"),
all.x=T
)

qpair <- qpair[,
.(qgl=getGl(ulist_cs, ulist_xl, labels_cs, labels_xl, label, 0.55)),
.(uid, qid_cs, qid_xl, label)]

qgl <- qpair[,
.(qgld=df(qgl)),
.(uid, qid=qid_cs)]

#=======================预测=====================
fm <- fread("E:/competition/BD/subresult/lxfm.csv",
header=T,
stringsAsFactors=F,
sep=",")#---------------libfm预测的结果

pred <- merge(validate, ugl, by=c("qid", "uid"), all.x=T)
pred <- merge(pred, qgl, by=c("qid", "uid"), all.x=T)
pred <- merge(pred, fm, by=c("qid", "uid"), all.x=T)
pred[is.na(pred)] <- 2 * eta

combine <- function(fmyc, qgld, ugld)
{
	return (fmyc + 0.2 * qgld + 0.15 * ugld)
}

pred <- pred[,.(label=combine(fmyc, qgld, ugld)), .(qid, uid)]

#=======================写入文件====================
write.table(pred, 
"E:/competition/BD/RESULT/temp.csv", 
col.names = T, 
quote = F, 
row.names = F, 
sep = ",")