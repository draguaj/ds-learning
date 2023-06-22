--=============== МОДУЛЬ 3. ОСНОВЫ SQL =======================================
--= ПОМНИТЕ, ЧТО НЕОБХОДИМО УСТАНОВИТЬ ВЕРНОЕ СОЕДИНЕНИЕ И ВЫБРАТЬ СХЕМУ PUBLIC===========
SET search_path TO public;

--======== ОСНОВНАЯ ЧАСТЬ ==============

--ЗАДАНИЕ №1
--Выведите для каждого покупателя его адрес проживания, 
--город и страну проживания.

select concat(last_name, ' ', first_name) as "Customer name", a.address, c.city, co.country
from customer cu
join address a  on cu.address_id = a.address_id
join city c  on a.city_id = c.city_id 
join country co on co.country_id = c.country_id






--ЗАДАНИЕ №2
--С помощью SQL-запроса посчитайте для каждого магазина количество его покупателей.

select s.store_id as "ID магазина", count(c.customer_id)
from customer c
join store s on c.store_id = s.store_id  
group by s.store_id  






--Доработайте запрос и выведите только те магазины, 
--у которых количество покупателей больше 300-от.
--Для решения используйте фильтрацию по сгруппированным строкам 
--с использованием функции агрегации.


select s.store_id as "ID магазина", count(c.customer_id) as "Количество покупателей"
from customer c
join store s on c.store_id = s.store_id 
group by s.store_id 
having count(c.customer_id) > 300 




-- Доработайте запрос, добавив в него информацию о городе магазина, 
--а также фамилию и имя продавца, который работает в этом магазине.

select s.store_id as "ID магазина", count(c.customer_id) as "Количество покупателей", ci.city as "Город", concat(st.last_name, ' ', st.first_name) as "Имя сотрудника" 
from customer c
join store s on c.store_id = s.store_id 
join address a on s.address_id = a.address_id 
join city ci on a.city_id = ci.city_id 
join staff st on s.manager_staff_id = st.staff_id  
group by s.store_id, st.staff_id, ci.city
having count(c.customer_id) > 300





--ЗАДАНИЕ №3
--Выведите ТОП-5 покупателей, 
--которые взяли в аренду за всё время наибольшее количество фильмов
select concat(last_name, ' ', first_name) as "Фамилия и имя покупателя", count(c.customer_id) as "Количество фильмов"
from rental r 
join customer c on c.customer_id = r.customer_id 
group by c.customer_id 
order by count(c.customer_id) desc
limit 5






--ЗАДАНИЕ №4
--Посчитайте для каждого покупателя 4 аналитических показателя:
--  1. количество фильмов, которые он взял в аренду
--  2. общую стоимость платежей за аренду всех фильмов (значение округлите до целого числа)
--  3. минимальное значение платежа за аренду фильма
--  4. максимальное значение платежа за аренду фильма


select concat(last_name, ' ', first_name) as "Фамилия и имя покупателя", count(c.customer_id) as "Количество фильмов", round(sum(p.amount)) as "Общая стоимость платежей", min(p.amount) as "Минимальная стоимость платежа", max(p.amount) as "Максимальная стоимость платежа" 
from rental r 
join customer c on c.customer_id = r.customer_id 
join payment p on r.rental_id = p.payment_id 
group by c.customer_id
order by c.customer_id
 




--ЗАДАНИЕ №5
--Используя данные из таблицы городов составьте одним запросом всевозможные пары городов таким образом,
 --чтобы в результате не было пар с одинаковыми названиями городов. 
 --Для решения необходимо использовать декартово произведение.

select t1.city as "Город 1", t2.city as "Город 2"
from  city t1
cross join city t2 
where t1.city < t2.city
 




--ЗАДАНИЕ №6
--Используя данные из таблицы rental о дате выдачи фильма в аренду (поле rental_date)
--и дате возврата фильма (поле return_date), 
--вычислите для каждого покупателя среднее количество дней, за которые покупатель возвращает фильмы.

select customer_id as "ID покупателя", round(EXTRACT(epoch FROM avg(return_date - rental_date))/60/60/24, 2) as "Среднее количество дней на возврат"
from rental r 
group by customer_id 
order by customer_id

(extract(day from avg(return_date - rental_date)))



--======== ДОПОЛНИТЕЛЬНАЯ ЧАСТЬ ==============

--ЗАДАНИЕ №1
--Посчитайте для каждого фильма сколько раз его брали в аренду и значение общей стоимости аренды фильма за всё время.





--ЗАДАНИЕ №2
--Доработайте запрос из предыдущего задания и выведите с помощью запроса фильмы, которые ни разу не брали в аренду.





--ЗАДАНИЕ №3
--Посчитайте количество продаж, выполненных каждым продавцом. Добавьте вычисляемую колонку "Премия".
--Если количество продаж превышает 7300, то значение в колонке будет "Да", иначе должно быть значение "Нет".








