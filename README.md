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
## row_number()
```ROW_NUMBER() OVER (<partition_definition> <order_definition>)```




