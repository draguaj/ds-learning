
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
array_agg(s.fare_conditions) filter (where fare_conditions != 'Business') as "класс обслуживания"
from aircrafts a 
join seats s on a.aircraft_code = s.aircraft_code
group by a.model 



-- Задание 4
-- Выведите накопительный итог количества мест в самолётах по каждому аэропорту на каждый день. 
-- Учтите только те самолеты, которые летали пустыми и только те дни, когда из одного аэропорта вылетело более одного такого самолёта.
-- Выведите в результат код аэропорта, дату вылета, количество пустых мест и накопительный итог.
  

select scheduled_departure, departure_airport, empty_seats, 
coalesce(sum(empty_seats) over (partition by scheduled_departure, departure_airport order by scheduled_departure), empty_seats) as total
from
	(select *
	from
		(select scheduled_departure, aircraft_code, flight_id, departure_airport, empty_seats, 
		count(flight_id) over (partition by scheduled_departure, departure_airport) as count_planes
		from 
			(select date_trunc('day', f.scheduled_departure) as scheduled_departure, s.aircraft_code, f.flight_id, f.departure_airport, count(s.seat_no) as empty_seats
			from flights f 
			full outer join boarding_passes bp on bp.flight_id = f.flight_id
			join seats s on s.aircraft_code = f.aircraft_code
			join airports a on f.departure_airport = a.airport_code 
			where f.scheduled_departure is not null or s.seat_no is null 
			group by scheduled_departure, f.flight_id, f.departure_airport, s.aircraft_code
			order by scheduled_departure) as first_
			) as second_
	where count_planes > 1) as third_
group by flight_id, aircraft_code, scheduled_departure, departure_airport, count_planes, empty_seats





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

select count(*) as "количество маршрутов", sum(finance) as "финансовые обороты", t.classification as классификация
from 
(
 	select sum(tf.amount) as finance, 
		case 
			when sum(amount) >= 150000000 then 'high'
			when sum(amount) between 50000000 and 150000000 then 'middle'
			when sum(amount) < 50000000 then 'low'
		end as classification
	from ticket_flights tf
	join flights f on tf.flight_id = f.flight_id
	group by amount 
) t
group by t.classification
order by count(*)  




-- Задание 8* (самостоятельное изучение)
-- Вычислите медиану стоимости билетов, медиану стоимости бронирования 
--и отношение медианы бронирования к медиане стоимости билетов, результат округлите до сотых. 

select median_tickets, median_booking, round(cast (median_tickets / median_booking as numeric), 2) as "median relations" 
from(
	select percentile_cont(0.5)
	within group (order by tf.amount) as "median_tickets",
	percentile_cont(0.5)
	within group (order by b.total_amount) as "median_booking"
	from ticket_flights tf 
	join tickets t on tf.ticket_no = t.ticket_no 
	join bookings b on t.book_ref = b.book_ref) as percentile




-- Задание 9* (самостоятельное изучение)
--Найдите значение минимальной стоимости одного километра полёта для пассажира. 
--Для этого определите расстояние между аэропортами и учтите стоимость билетов.

-- Для поиска расстояния между двумя точками на поверхности Земли используйте дополнительный модуль earthdistance. 
--Для работы данного модуля нужно установить ещё один модуль – cube.

CREATE extension cube 

CREATE extension earthdistance


select (ed.amount / ed.distance_meters) * 1000 as min_amount
from (select tf.amount,
		earth_distance(
        ll_to_earth(a.latitude, a.longitude),
        ll_to_earth(a2.latitude, a2.longitude)
    ) as distance_meters
	from flights f 
	join airports a on f.departure_airport = a.airport_code 
	join airports a2 on f.arrival_airport = a2.airport_code
	join ticket_flights tf on f.flight_id = tf.flight_id
	where f.flight_id = '30486') as ed

