-- 1. Вывести к каждому самолету класс обслуживания и количество мест этого класса
SELECT a.aircraft_code, s.fare_conditions, COUNT(s.seat_no) AS total_seats
FROM aircrafts a
         JOIN seats s ON a.aircraft_code = s.aircraft_code
GROUP BY a.aircraft_code, s.fare_conditions;

-- 2. Найти 3 самых вместительных самолета (модель + кол-во мест)
SELECT a.model, COUNT(s.seat_no) AS total_seats
FROM aircrafts a
         JOIN seats s ON a.aircraft_code = s.aircraft_code
GROUP BY a.model
ORDER BY total_seats DESC LIMIT 3

-- 3. Найти все рейсы, которые задерживались более 2 часов
SELECT flights.flight_no
FROM flights
WHERE actual_departure IS NOT NULL -- исключаем незадержанные рейсы
  AND actual_arrival IS NOT NULL   -- исключаем незавершенные рейсы
  AND (actual_departure - scheduled_departure) > INTERVAL '2 hours';

-- 4. Найти последние 10 билетов, купленные в бизнес-классе (fare_conditions = 'Business'), с указанием имени пассажира и контактных данных
SELECT t.passenger_name, t.contact_data
FROM tickets t
         JOIN ticket_flights tf ON t.ticket_no = tf.ticket_no
WHERE tf.fare_conditions = 'Business'
ORDER BY t.ticket_no DESC LIMIT 10

-- 5. Найти все рейсы, у которых нет забронированных мест в бизнес-классе (fare_conditions = 'Business')
SELECT f.flight_no
FROM flights f
         JOIN ticket_flights tf ON f.flight_id = tf.flight_id
WHERE tf.fare_conditions IS NULL
   OR tf.fare_conditions <> 'Business';

-- 6. Получить список аэропортов (airport_name) и городов (city), в которых есть рейсы с задержкой по вылету
SELECT DISTINCT a.airport_name, a.city
FROM airports a
         INNER JOIN flights f ON a.airport_code = f.departure_airport
WHERE f.actual_departure IS NOT NULL
  AND f.actual_departure > f.scheduled_departure;

-- 7. Получить список аэропортов (airport_name) и количество рейсов, вылетающих из каждого аэропорта, отсортированный по убыванию количества рейсов
SELECT a.airport_name, COUNT(*) AS flight_count
FROM airports a
         INNER JOIN flights f ON a.airport_code = f.departure_airport
GROUP BY a.airport_name
ORDER BY flight_count DESC;

-- 8. Найти все рейсы, у которых запланированное время прибытия (scheduled_arrival) было изменено и новое время прибытия ( actual_arrival) не совпадает с запланированным
SELECT *
FROM flights
WHERE actual_arrival IS NOT NULL -- исключаем незавершенные рейсы
  AND actual_arrival <> scheduled_arrival

-- 9. Вывести код, модель самолета и места не эконом класса для самолета "Аэробус A321-200" с сортировкой по местам
SELECT a.aircraft_code, a.model, s.fare_conditions, s.seat_no
FROM aircrafts a
         JOIN seats s ON a.aircraft_code = s.aircraft_code
WHERE s.fare_conditions <> 'Economy'
  AND a.model = 'Аэробус A321-200'
GROUP BY a.aircraft_code, a.model, s.fare_conditions, s.seat_no
ORDER BY s.seat_no

-- 10. Вывести города, в которых больше 1 аэропорта (код аэропорта, аэропорт, город)
SELECT a.airport_code, a.airport_name, a.city
FROM airports a
         INNER JOIN (SELECT city
                     FROM airports
                     GROUP BY city
                     HAVING COUNT(*) > 1) sub
                    ON a.city = sub.city
ORDER BY a.city;

-- 11. Найти пассажиров, у которых суммарная стоимость бронирований превышает среднюю сумму всех бронирований
SELECT t.passenger_name, SUM(b.total_amount) AS total_booking_amount
FROM tickets t
         JOIN bookings b ON t.book_ref = b.book_ref
GROUP BY t.passenger_name
HAVING SUM(b.total_amount) > (SELECT AVG(total_amount) FROM bookings);

-- 12. Найти ближайший вылетающий рейс из Екатеринбурга в Москву, на который еще не завершилась регистрация
SELECT f.flight_no, f.scheduled_departure
FROM flights f
         JOIN airports dep_airport ON f.departure_airport = dep_airport.airport_code
         JOIN airports arr_airport ON f.arrival_airport = arr_airport.airport_code
         LEFT JOIN ticket_flights tf ON f.flight_id = tf.flight_id
WHERE dep_airport.city = 'Екатеринбург'
  AND arr_airport.city = 'Москва'
ORDER BY f.scheduled_departure LIMIT 1;

-- 13. Вывести самый дешевый и дорогой билет и стоимость (в одном результирующем ответе)
SELECT MIN(amount) AS min_price, MAX(amount) AS max_price
FROM ticket_flights;

-- 14. Написать DDL таблицы Customers, должны быть поля id, firstName, LastName, email, phone. Добавить ограничения на поля (constraints)
CREATE TABLE customer
(
    id         SERIAL PRIMARY KEY,
    first_name VARCHAR(50) NOT NULL,
    last_name  VARCHAR(50) NOT NULL,
    email      VARCHAR(100) UNIQUE,
    phone      VARCHAR(20) UNIQUE
);

-- 15. Написать DDL таблицы Orders, должен быть id, customerId, quantity. Должен быть внешний ключ на таблицу customers + constraints
CREATE TABLE orders
(
    id          SERIAL PRIMARY KEY,
    customer_id INTEGER NOT NULL,
    quantity    INTEGER,
    FOREIGN KEY (customer_id) REFERENCES customer (id)
);

-- 16. Написать 5 insert в эти таблицы
INSERT INTO customer (first_name, last_name, email, phone)
VALUES ('Joh', 'Doea', 'johdoea@example.com', '1265467892'),
       ('Jana', 'Loka', 'janaloka@example.com', '09878764321'),
       ('Sofi', 'Sad', 'sofisad@example.com', '0987654445'),
       ('Ada', 'Adams', 'adaadams@example.com', '0934554321'),
       ('Kim', 'Loki', 'kimloki@example.com', '7657654321')
    INSERT
INTO orders (customer_id, quantity)
VALUES (1, 5), (2, 4), (3, 7), (4, 8), (5, 2)

-- 17. Удалить таблицы
DROP TABLE IF EXISTS orders
DROP TABLE IF EXISTS customer

-- 18. Вывести информацию о вылете с наибольшей суммарной стоимостью билетов
SELECT f."flight_id",
       f."flight_no",
       f."scheduled_departure",
       f."scheduled_arrival",
       SUM(tf."amount") AS total_ticket_value
FROM "bookings"."ticket_flights" tf
         JOIN "bookings"."flights" f ON tf."flight_id" = f."flight_id"
GROUP BY f."flight_id", f."flight_no", f."scheduled_departure", f."scheduled_arrival"
ORDER BY total_ticket_value DESC LIMIT 1;

-- 19. Найти модель самолета, принесшую наибольшую прибыль (наибольшая суммарная стоимость билетов). Вывести код модели, информацию о модели и общую стоимость
SELECT ac."model", ac."aircraft_code", SUM(tf."amount") AS total_revenue
FROM "bookings"."ticket_flights" tf
         JOIN "bookings"."flights" f ON tf."flight_id" = f."flight_id"
         JOIN "aircrafts" ac ON f."aircraft_code" = ac."aircraft_code"
GROUP BY ac."aircraft_code", ac."model"
ORDER BY total_revenue DESC LIMIT 1;

-- 20. Найти самый частый аэропорт назначения для каждой модели самолета. Вывести количество вылетов, информацию о модели самолета, аэропорт назначения, город
WITH flight_counts AS (SELECT ac."aircraft_code",
                              ac."model",
                              f."arrival_airport",
                              a."airport_name",
                              a."city",
                              COUNT(f."flight_id") AS flight_count,
                              ROW_NUMBER()            OVER (PARTITION BY ac."aircraft_code" ORDER BY COUNT(f."flight_id") DESC) AS rn
                       FROM "bookings"."flights" f
                                JOIN "aircrafts" ac ON f."aircraft_code" = ac."aircraft_code"
                                JOIN "airports" a ON f."arrival_airport" = a."airport_code"
                       GROUP BY ac."aircraft_code", ac."model", f."arrival_airport", a."airport_name", a."city")

SELECT "aircraft_code", "model", "arrival_airport", "airport_name", "city", "flight_count"
FROM flight_counts
WHERE rn = 1;