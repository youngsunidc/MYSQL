-- ex11:  现在要查找出每个cpu中销量最好的model_name和该model_name的厚度。
--  注意: order by 的时候应当应用sum(units)。
with table_x
as(
select  cpu ,model_name_ferda , sum(2005_Sale) as units,
row_number() over(partition by `cpu`
order by convert(sum(2005_Sale),float) desc) as `rank`
from jd_guidance_2005nb
group by model_name_ferda
order by units desc)
select distinct cpu,model_name_ferda,units ,mm.`Z height(mm)`from table_x
left join learn.`model management export` mm
on table_x.model_name_ferda = mm.`Model Name`
where `rank`  = 1 and (cpu is not null);



-- ex12: 找到每一个screen_size中最便宜的产品 
-- 方法一:
select product_code ,brand_ferda , min(convert(unit_price,signed))
from jd_guidance_2005nb
group by brand_ferda ;
-- 方法二: 利用dense_rank()
with table_s 
as(
select product_code, brand_ferda, convert(unit_price,signed)as price,
dense_rank() over ( partition by  brand_ferda order by convert(unit_price,signed)) as price_ranks 
from jd_guidance_2005nb)
select * 
from table_s
where price_ranks < 2 and brand_ferda is not null ;




-- cross join 方法
-- cross join函数是指把某一张表的各行与另外一张表进行交叉的比对。 

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



