# MYSQL与Python的API
- 数据读取
``` python
import pandas as pd
import sqlalchemy 
import pymysql

engine = sqlalchemy.create_engine('mysql+pymysql://root:root@127.0.0.1:3306/jd_guidance') 

# mysql的代码。  
sql='''
select pageurl,title,is_jd,model_name_ferda,Q1_sales
from jd_guidance_2003nb
where model_name_ferda is not null and Q1_sales> 1000
order by convert(Q1_sales,signed) desc
'''
df = pd.read_sql(sql,engine)

```

- 数据录入
``` python

"""
name:需要操作的表的名称
con:与数据库的连接器
if_exists:如果数据库中已经存在该表,则执行那些操作(1. fail:抛出错误,中断执行 2. replace 替换掉目前的表 
3. append:向目前已存在的表中插入数据) 默认为fail
index:是否将DataFrame的索引列作为一列数据插入到数据库的表中.默认为True
index_label:索引列的列标签,默认为None
chunksize:每次插入多少行数据,默认为None,一次性批量写入所有数据
dtype :字典格式,key是字段名称,value是字段对应的数据格式.可以在插入数据时指定每个字段的数据格式.默认为None
"""

engine = sqlalchemy.create_engine('mysql+pymysql://root:root@127.0.0.1:3306/jd_guidance') 
df.to_sql("sqlpy_test",con=engine)
```
