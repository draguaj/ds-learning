
-- Задание 1 
-- Выведите названия самолётов, которые имеют менее 50 посадочных мест

select count(seat_no) as "посадочные места", model as "самолёт" 
from aircrafts a 
join seats s on a.aircraft_code = s.aircraft_code
group by model
having count(seat_no) < 50




-- Задание 2
-- Выведите процентное изменение ежемесячной суммы бронирования билетов, округленной до сотых

select 
	sum(total_amount),
    date_trunc('month', book_date) as month,  
    round(((sum(total_amount) - lag(sum(total_amount)) over (order by date_trunc('month', book_date))) / lag(sum(total_amount)) over (order by date_trunc('month', book_date))) * 100, 2) || '%' as percentage_change 
from bookings 
group by month 
order by month

  
-- Задание 3
-- Выведите названия самолётов без бизнес-класса. Используйте в решении функцию array_agg

select a.model as "самолёт",
array_agg(s.fare_conditions) as "класс обслуживания"
from aircrafts a 
join seats s on a.aircraft_code = s.aircraft_code
group by a.model 
having not 'Business' = any(array_agg(s.fare_conditions))



-- Задание 4
-- Выведите накопительный итог количества мест в самолётах по каждому аэропорту на каждый день. 
-- Учтите только те самолеты, которые летали пустыми и только те дни, когда из одного аэропорта вылетело более одного такого самолёта.
-- Выведите в результат код аэропорта, дату вылета, количество пустых мест и накопительный итог.
  

with c as (
	select departure_airport, actual_departure, actual_departure::date ad_date, c_s
	from flights f
	join (
		select aircraft_code, count(*) c_s
		from seats
		group by aircraft_code) s on s.aircraft_code = f.aircraft_code
	left join boarding_passes bp on bp.flight_id = f.flight_id
	where actual_departure is not null and bp.flight_id is null)
select departure_airport, ad_date, c_s, sum(c_s) over (partition by departure_airport, ad_date order by actual_departure)
from c 
where (departure_airport, ad_date) in (
	select departure_airport, ad_date
	from c 
	group by 1,2 
	having count(*) > 1)




-- Задание 5
-- Найдите процентное соотношение перелётов по маршрутам от общего количества перелётов. Выведите в результат названия аэропортов и процентное отношение.
-- Используйте в решении оконную функцию.

with cte_flights as (
	select departure_airport, arrival_airport,
	count(*) as flight_count, 
	sum(count(*)) over () as total_flights
	from flights 
	group by departure_airport, arrival_airport)
select 
	a1.airport_name as departure_airport, 
  	a2.airport_name as arrival_airport, 
  	round((flight_count / total_flights) * 100, 2) as percentage
from cte_flights
join airports a1 on a1.airport_code = cte_flights.departure_airport
join airports a2 on a2.airport_code = cte_flights.arrival_airport



-- Задание 6
-- Выведите количество пассажиров по каждому коду сотового оператора. Код оператора – это три символа после +7

select count(passenger_id) as "количество пассажиров", substring(contact_data ->> 'phone', 3, 3) as "код оператора"
from tickets 
group by "код оператора"
order by "код оператора"



-- Задание 7
--Классифицируйте финансовые обороты (сумму стоимости билетов) по маршрутам:
--    до 50 млн – low
--    от 50 млн включительно до 150 млн – middle
--    от 150 млн включительно – high
--Выведите в результат количество маршрутов в каждом полученном классе.

select c, count(*)
from (
	select 
		case 
			when sum(tf.amount) < 50000000 then 'low'
			when sum(tf.amount) >= 50000000 and sum(tf.amount) < 150000000 then 'middle'
			else 'high'
		end c
	from flights f 
	join ticket_flights tf on tf.flight_id = f.flight_id 
	group by flight_no) t
group by c 



-- Задание 8* (самостоятельное изучение)
-- Вычислите медиану стоимости билетов, медиану стоимости бронирования 
--и отношение медианы бронирования к медиане стоимости билетов, результат округлите до сотых. 
	
select 
  median_tickets, 
  median_booking, 
  round(cast(median_booking / median_tickets as numeric), 2) as median_relations 
from (select 
    	(select percentile_cont(0.5) within group (order by amount) from ticket_flights) as median_tickets, 
    	(select percentile_cont(0.5) within group (order by total_amount) from bookings) as median_booking 
  	) as medians




-- Задание 9* (самостоятельное изучение)
--Найдите значение минимальной стоимости одного километра полёта для пассажира. 
--Для этого определите расстояние между аэропортами и учтите стоимость билетов.

-- Для поиска расстояния между двумя точками на поверхности Земли используйте дополнительный модуль earthdistance. 
--Для работы данного модуля нужно установить ещё один модуль – cube.

CREATE extension cube 

CREATE extension earthdistance


select min((ed.amount / ed.distance_meters) * 1000) as min_amount
from (select tf.amount,
		f.flight_id,
		earth_distance(
        ll_to_earth(a.latitude, a.longitude),
        ll_to_earth(a2.latitude, a2.longitude)
    ) as distance_meters
	from flights f 
	join airports a on f.departure_airport = a.airport_code 
	join airports a2 on f.arrival_airport = a2.airport_code
	join ticket_flights tf on f.flight_id = tf.flight_id
	) as ed


