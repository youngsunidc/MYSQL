# SQL语句执行顺序 

```
1、from子句组装来自不同数据源的数据； （先join在on）
2、where子句基于指定的条件对记录行进行筛选；
3、group by子句将数据划分为多个分组；
4、使用聚集函数进行计算；
5、使用having子句筛选分组；
6、计算所有的表达式；
7、select 的字段；
8、使用order by对结果集进行排序。
```

![image](https://user-images.githubusercontent.com/65394762/114137365-a9c1bb00-993e-11eb-90e6-f601f58efbb9.png)

# SQL语句中的关键语句
## row_number()，窗口函数
```ROW_NUMBER() OVER (<partition_definition> <order_definition>)```
  - partition_definition: partition by是将子句分配成更加小的集合。可以以逗号分隔成多个表达式，这样可以进行一步的进行细分。  
  - Order by: 子句的目的是设置行的顺序， 此Order_by独立于"查询"需要的order by语句。 
 
此函数是窗口函数，常常应用于分组排名等情况，很像pivot_table有母项，然后对子项进行排序。 
每组最大的N条记录。这类问题涉及到“既要分组，又要排序”的情况，要能想到用窗口函数来实现。

### 实际例子
目的：求每一个brand下面的销量前三的model_name.

```
WITH ins_t 
AS (
select   product_code ,brand_ferda, model_name_ferda  , sum(2005_Sale),
row_number() over (  
	partition by brand_ferda
   order by  convert(2005_Sale,float) desc) as"sales"
from jd_guidance_2005nb 
where brand_ferda is not null 
group by model_name_ferda)
select * from ins_t
where sales <= 3;
```
![image](https://user-images.githubusercontent.com/65394762/114490661-cfeda080-9c47-11eb-976d-c04f19d8d112.png)

### 其他窗口函数
- row_number()： 表示顺序排列下来，并列销量也需要按照按序进行排列
- rank():  并列销量显示并列排名， 跳过并列排名
- dense_rank(): 并列销量显示并列排名， 但是不跳排名

```
select *,
   rank() over (order by 成绩 desc) as ranking,
   dense_rank() over (order by 成绩 desc) as dese_rank,
   row_number() over (order by 成绩 desc) as row_num
from 班级;
```
![image](https://user-images.githubusercontent.com/65394762/114491975-3247a080-9c4a-11eb-80c8-f580c16b0378.png)











