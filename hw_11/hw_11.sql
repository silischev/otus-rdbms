-- 1 --
SELECT row_number() OVER (PARTITION BY LEFT(title, 1)) AS num_by_film_name_first_letter,
       count(*) OVER() AS film_count,
       count(*) OVER(PARTITION BY LEFT(title, 1)) AS film_count_by_first_letter,
       lead(film_id) OVER() AS next_film_id,
       lag(film_id) OVER() AS previous_film_id,
       lag(title, 2) OVER() AS two_rows_before_film_name,
       film_id,
       title,
       description,
       release_year
FROM film;

-- 2 --
SELECT *
FROM (
     SELECT dense_rank() OVER (ORDER BY length) AS group_num,
            film.film_id,
            film.title,
            film_category.category_id,
            film.rating
     FROM film
            INNER JOIN film_category ON film.film_id = film_category.film_id
     ORDER BY length
     ) grouped_films
ORDER BY group_num, rating;

-- 3 (без аналитических ф-ций) --
SELECT s.staff_id, s.last_name, c.customer_id, c.last_name, r.rental_date, r.rental_id
FROM staff s
     INNER JOIN rental r ON s.staff_id = r.staff_id
     INNER JOIN customer c ON r.customer_id = c.customer_id
WHERE r.rental_id =
     (SELECT ri.rental_id FROM rental as ri WHERE ri.staff_id = s.staff_id ORDER BY ri.rental_date DESC LIMIT 1);

-- с аналитическими ф-циями --
WITH staff_groups AS (SELECT dense_rank() OVER (ORDER BY r.rental_date DESC) AS group_num,
       r.staff_id,
       r.rental_date,
       r.rental_id
FROM rental r
ORDER BY r.rental_date DESC)

SELECT s.staff_id, s.last_name, c.customer_id, c.last_name, r.rental_date, r.rental_id
FROM staff s
            INNER JOIN rental r ON s.staff_id = r.staff_id
            INNER JOIN customer c ON r.customer_id = c.customer_id
WHERE r.rental_id = (SELECT s_g.rental_id FROM staff_groups s_g WHERE s_g.staff_id=r.staff_id ORDER BY s_g.rental_date DESC LIMIT 1);

-- 4 (без аналитических ф-ций) --
WITH actors_films_info AS (SELECT a.actor_id aid, a.first_name afn, a.last_name aln, f.film_id fid, f.title ft, r.rental_date rd, r.rental_id rid
FROM actor a
      INNER JOIN film_actor fa on a.actor_id = fa.actor_id
      INNER JOIN film f on fa.film_id = f.film_id
      INNER JOIN rental r on fa.film_id = r.rental_id
ORDER BY a.actor_id, r.rental_date DESC)

SELECT aid, afn, aln, fid, ft, rd, rid
FROM actors_films_info
       INNER JOIN actor ON aid = actor.actor_id
WHERE rd = (SELECT max(rd) FROM actors_films_info WHERE aid = actor.actor_id);

-- с аналитическими ф-циями --
SELECT aid, afn, aln, fid, ft, rd, rid FROM (
    SELECT dense_rank() OVER (PARTITION BY a.actor_id ORDER BY r.rental_date DESC) group_num,
           a.actor_id    aid,
           a.first_name  afn,
           a.last_name   aln,
           f.film_id     fid,
           f.title       ft,
           r.rental_date rd,
           r.rental_id   rid
    FROM actor a
           INNER JOIN film_actor fa on a.actor_id = fa.actor_id
           INNER JOIN film f on fa.film_id = f.film_id
           INNER JOIN rental r on fa.film_id = r.rental_id
    ) t
WHERE group_num = 1;
