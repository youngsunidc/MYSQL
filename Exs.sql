-- excise1 (查找重复数值), 
-- having 是因为 select中的counts没有生成， 因此用Where的时候会出现错误。
-- 通过groupby函数是跟having函数一起书写。 

use jd_guidance;
select model_name_ferda,2003_sales ,count(*) as counts
from jd_guidance_2003nb
group by model_name_ferda
having counts >10 and (2003_sales is not null) and (model_name_ferda is not null);



-- excise2
-- 真实要求： 寻找带core i5处理器中的， sale_unit中第二名的数值。如果不存在就返回Null值。 
-- 知识点： limit 1,1; 即limit (x,y); x表示miss数据， y表示输出数据的条数。 
select model_name_ferda,cpu , 
ifnull( (select 2003_sales 
from  jd_guidance_2003nb 
order by convert(2003_sales ,signed) desc
limit 1,1
),"null") as units
from jd_guidance_2003nb
order by convert(2003_sales,signed) desc
limit 1;



-- ex3 
-- 知识要点：需要从左表中的key id连接右表的key id; 
-- 当关联的sheet不在同一个库里面的时候... 需要加上<库名><表名>
select distinct model_id , model_name_ferda,m1.`Model Name (Client View)`
from jd_guidance_2003nb s1
LEFT JOIN learn.`model management export` m1
on s1.model_id = m1.`Model ID`
where model_name_ferda is not null  and model_id is not null;


-- ex4 目的：同一个model name的core i7比core i5贵多少钱？ 
-- 两个不同的shipment经给某些过滤筛选做减值。
select m.model_name_ferda,m.unit_price_i5,n.unit_price_i7, (n.unit_price_i7-m.unit_price_i5) as"差值"
from (select model_name_ferda, unit_price as "unit_price_i5"
from jd_guidance_2003nb where cpu = "Core i5"
group by model_name_ferda) as m
left join 
(select model_name_ferda, unit_price as "unit_price_i7"
from jd_guidance_2003nb  where cpu ="Core i7" group by model_name_ferda ) as n
on m.model_name_ferda = n.model_name_ferda 
order by `差值` desc;




-- ex5 目的：在同一个model中，查找product_code大于的时候,unit_price也高的场景。 
-- 知识点： cross join
select * from (
select * , (unit_p1 -unit_p2) as price_gap,(code1-code2) as code_gap
from (select product_code as "code1", model_name_ferda as"model1",cpu as"cpu1", unit_price as"unit_p1"
from jd_guidance_2004nb
order by  convert(product_code,signed)) as table_a
cross join  (select product_code as "code2", model_name_ferda as "model2" ,cpu as"cpu2", unit_price as"unit_p2"
from jd_guidance_2004nb
order by  convert(product_code,signedsqlpy_test)) as table_b
where model1=model2 
order by model2  ) as table_comb
where price_gap > 0 and code_gap >0;


-- ex6 目的： 提取每一个brand里面价格在5K以上的产品，及其产品所占品牌的比例。 
-- 知识点： group by& count(*)，可以自动查出group by的数目。 
select unit_price,brand_ferda, 5K_counts,total_count, (5k_counts/total_count) as "5k_ratio"
from 
(select unit_price, brand_ferda,count(*) as "5K_counts" 
from jd_guidance_2004nb
where unit_price> 5000
group by  brand_ferda ) as table_a
left join 
(select brand_ferda as "brand2",count(*) as "total_count"
from jd_guidance_2004nb
group by brand_ferda) as table_b
on table_a.brand_ferda = table_b.brand2 
order by 5k_ratio desc;

-- 方法二
select * ,price_group/total as "ratio" from
(select brand_ferda, unit_price ,
sum(if(unit_price >5000,1,0))as "price_group",count(*) as"total"
from jd_guidance_2004nb
group by brand_ferda) as table_b
order by ratio desc;


-- ex7 目的： 找出连续出现3次的model name
-- 如何自动插入标识列 ； 如何对不同的表格进行自关联。 
ALTER TABLE jd_guidance_2005nb
ADD COLUMN `key` int(255)  primary key AUTO_INCREMENT FIRST;

select a.key,a.model_name_ferda
from jd_guidance_2005nb as a,
jd_guidance_2005nb as b,
jd_guidance_2005nb as c
where (a.`key` = b.`key` -1) 
and (b.`key` = c.`key`-1)
and a.model_name_ferda = b.model_name_ferda
and b.model_name_ferda = c.model_name_ferda ;

-- ex8 : 计算每一个brand,自营的比例是多少
-- 类似于拉出pivot求占比 
select  brand_ferda, sum(if(is_jd ="自营",1,0) ) / count(*)as "京东自营比例"
from jd_guidance_2005nb
group by brand_ferda ;



-- ex9, 剔除前20%的销量后， brand中每个model的平均销量。
with this_ as
(select product_code ,model_name_ferda,  avg(unit_price) as average , sum(2005_Sale) as sum_units,
row_number() over(order by convert( sum(2005_Sale), float )  desc) as `rank`
from jd_guidance_2005nb 
where model_name_ferda is not null
group by model_name_ferda) 
select * from this_
where `rank` > (select max(`rank`) from this_)*0.2 ;


-- ex10 如何查找每个品牌前3高的model;
-- row_number()
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


-- row_number的具体用法，即分组聚合。 
select model_name_ferda , cpu, unit_price,
row_number() over 
( partition by model_name_ferda
order by  convert(unit_price,signed) desc) as ranks
from jd_guidance_2003nb
where ( model_name_ferda is not null) and (cpu is not null)  
group by model_name_ferda,cpu;



set @limits := 0;
select model_name_ferda,unit_price, 2003_sales ,@limits := @limits+ 2003_sales as `累计`
from jd_guidance_2003nb
where 2003_sales is not null
order by convert(2003_sales,signed);


with table_s 
as (
select model_name_ferda, sum(2003_sales) as units,sum( sum(2003_sales) ) over (order by convert(sum(2003_sales),signed) desc) as sums
from jd_guidance_2003nb
where 2003_sales is not null  and  (model_name_ferda is not null)
group by model_name_ferda )
select * from  table_s 
where sums >  (select max(sums) from table_s) * 0.4
