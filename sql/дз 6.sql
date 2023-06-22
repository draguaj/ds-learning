--=============== МОДУЛЬ 6. POSTGRESQL =======================================
--= ПОМНИТЕ, ЧТО НЕОБХОДИМО УСТАНОВИТЬ ВЕРНОЕ СОЕДИНЕНИЕ И ВЫБРАТЬ СХЕМУ PUBLIC===========
SET search_path TO public;

--======== ОСНОВНАЯ ЧАСТЬ ==============

--ЗАДАНИЕ №1
--Напишите SQL-запрос, который выводит всю информацию о фильмах 
--со специальным атрибутом "Behind the Scenes".

select film_id, title, special_features 
from film
where 'Behind the Scenes' = any(special_features)


--ЗАДАНИЕ №2
--Напишите еще 2 варианта поиска фильмов с атрибутом "Behind the Scenes",
--используя другие функции или операторы языка SQL для поиска значения в массиве.

select film_id, title, special_features 
from film
where special_features && array['Behind the Scenes'] 


select film_id, title, special_features 
from film
where special_features @> array['Behind the Scenes'] 


select film_id, title, special_features 
from film
where array_position(special_features, 'Behind the Scenes') is not null

--ЗАДАНИЕ №3
--Для каждого покупателя посчитайте сколько он брал в аренду фильмов 
--со специальным атрибутом "Behind the Scenes.

--Обязательное условие для выполнения задания: используйте запрос из задания 1, 
--помещенный в CTE. CTE необходимо использовать для решения задания.


with cte as (
	select film_id, title, special_features 
	from film f
	where 'Behind the Scenes' = any(special_features))
select r.customer_id, count(i.film_id) as film_count
from cte
join inventory i on cte.film_id = i.film_id 
join rental r on i.inventory_id = r.inventory_id
group by customer_id
order by customer_id

			
--ЗАДАНИЕ №4
--Для каждого покупателя посчитайте сколько он брал в аренду фильмов
-- со специальным атрибутом "Behind the Scenes".

--Обязательное условие для выполнения задания: используйте запрос из задания 1,
--помещенный в подзапрос, который необходимо использовать для решения задания.

select r.customer_id, count(i.film_id) as film_count
from rental r
join inventory i on r.inventory_id = i.inventory_id 
where film_id in (
	select film_id 
		from (
			select film_id, title, special_features 
			from film f
			where 'Behind the Scenes' = any(special_features)) as k
	)
group by r.customer_id
order by r.customer_id  


--ЗАДАНИЕ №5
--Создайте материализованное представление с запросом из предыдущего задания
--и напишите запрос для обновления материализованного представления

create  materialized view films_by_attribute as
	select r.customer_id, count(i.film_id) as film_count
	from rental r
	join inventory i on r.inventory_id = i.inventory_id 
	where film_id in (
		select film_id 
			from (
				select film_id, title, special_features 
				from film f
				where 'Behind the Scenes' = any(special_features)) as k
		)
	group by r.customer_id
	order by r.customer_id 


refresh materialized view films_by_attribute

--ЗАДАНИЕ №6
--С помощью explain analyze проведите анализ стоимости выполнения запросов из предыдущих заданий и ответьте на вопросы:
--1. с каким оператором или функцией языка SQL, используемыми при выполнении домашнего задания: 
--поиск значения в массиве затрачивает меньше ресурсов системы;
--2. какой вариант вычислений затрачивает меньше ресурсов системы: 
--с использованием CTE или с использованием подзапроса.

--1. 
explain analyze -- 0.599 ms   ЗАТРАЧИВАЕТ МЕНЬШЕ РЕСУРСОВ
select film_id, title, special_features 
from film
where 'Behind the Scenes' = any(special_features)

explain analyze -- 0.8 ms
select film_id, title, special_features 
from film
where special_features && array['Behind the Scenes'] 

explain analyze -- 0.680 ms
select film_id, title, special_features 
from film
where special_features @> array['Behind the Scenes'] 

explain analyze -- 0.678 ms
select film_id, title, special_features 
from film
where array_position(special_features, 'Behind the Scenes') is not null


--2.

explain analyze -- 28.078 ms
with cte as (
  select c.customer_id, count(*) as film_count
  from customer c
  join rental r on c.customer_id = r.customer_id
  join inventory i on r.inventory_id = i.inventory_id
  join film f on i.film_id = f.film_id
  where 'Behind the Scenes' = any(special_features)
  group by c.customer_id
  order by c.customer_id 
)
select customer_id, film_count
from cte


explain analyze -- 16.311 ms    ПОДЗАПРОС ЗАТРАЧИВАЕТ МЕНЬШЕ РЕСУРСОВ
select r.customer_id, count(i.film_id) as film_count
from rental r
join inventory i on r.inventory_id = i.inventory_id 
where film_id in (
	select film_id 
		from (
			select film_id, title, special_features 
			from film f
			where 'Behind the Scenes' = any(special_features)) as k
	)
group by r.customer_id
order by r.customer_id

--======== ДОПОЛНИТЕЛЬНАЯ ЧАСТЬ ==============

--ЗАДАНИЕ №1
--Выполняйте это задание в форме ответа на сайте Нетологии

--ЗАДАНИЕ №2
--Используя оконную функцию выведите для каждого сотрудника
--сведения о самой первой продаже этого сотрудника.





--ЗАДАНИЕ №3
--Для каждого магазина определите и выведите одним SQL-запросом следующие аналитические показатели:
-- 1. день, в который арендовали больше всего фильмов (день в формате год-месяц-день)
-- 2. количество фильмов взятых в аренду в этот день
-- 3. день, в который продали фильмов на наименьшую сумму (день в формате год-месяц-день)
-- 4. сумму продажи в этот день





