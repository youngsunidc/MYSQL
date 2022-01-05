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
- 示例一：
![image](https://user-images.githubusercontent.com/65394762/114137365-a9c1bb00-993e-11eb-90e6-f601f58efbb9.png)

- 示例二： 
![image](https://user-images.githubusercontent.com/65394762/114671692-f2aab280-9d36-11eb-819e-1f40af915410.png)



# SQL语句中的应用场景
## row_number()，窗口函数  （ Pivot子项排名)
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



## if()和sum()函数的结合（条件占比）； 

- 可以算出满足条件的占比情况，即 sum(if(<条件>,1,0))。满足条件的为1，不满足条件的则为0； 

- *条件占比* 
``` python
select  brand_ferda, sum(if(is_jd ="自营",1,0) ) / count(*)as "京东自营比例"
from jd_guidance_2005nb
group by brand_ferda ;
```
![image](https://user-images.githubusercontent.com/65394762/117126991-1c06ad80-adce-11eb-891e-de819fa8b467.png)



``` python
select * ,price_group/total as "ratio" from
(select brand_ferda, unit_price ,
sum(if(unit_price >5000,1,0))as "price_group",count(*) as"total"
from jd_guidance_2004nb
group by brand_ferda) as table_b
order by ratio desc;
```

![image](https://user-images.githubusercontent.com/65394762/117125331-fc6e8580-adcb-11eb-828a-23ab8128e252.png)


## sum() over (order by) 累积求和



### 通过Groupby累计求和
![image](https://user-images.githubusercontent.com/65394762/117282230-145f0b80-ae97-11eb-836a-cca23554fb68.png)


## cross join方法
表示表1中每一行对表2中每一行进行交叉式的组合

- **表一**
![image](https://user-images.githubusercontent.com/65394762/116359576-8a2cfc80-a831-11eb-9903-5aae0b66289a.png)


- **表二**

![image](https://user-images.githubusercontent.com/65394762/116359702-ae88d900-a831-11eb-8195-1e6d54ab9269.png)

- **cross后的交叉表**
![image](https://user-images.githubusercontent.com/65394762/116359835-daa45a00-a831-11eb-9ef8-835a38739f9c.png)



```
with table_1
as (
select product_code , model_name_ferda,2005_Sale
from jd_guidance_2005nb
order by convert(2005_Sale, signed) desc 
limit 4 )
select * from table_1
cross join 
(select  `Model ID`, `Product Brand`   from learn.`model management export`
order by convert(`Model ID`,signed) desc
limit 10
) as b ;
```


![image](https://user-images.githubusercontent.com/65394762/116359084-f3604000-a830-11eb-8de4-794e8c31a5ee.png)


## count()方法
**count(*): ** 总行数，包括空行。

**count(xx): ** 某列总行数，不包括空行。 

**count(distinct xx)：某列的去重数值  **

```
select  
sum( case when is_jd is null then 0 else 1 end    ) as '非空',
sum( case when is_jd is null then 1 else 0 end    ) as '空',
count(*) as '全部数量统计',
count( is_Jd) as '非空统计',
count(distinct is_jd ) as '统计'
from test1;
```
![image](https://user-images.githubusercontent.com/65394762/148180372-713d05e9-594f-405a-b768-9b29237c48f8.png)

## case when 方法




