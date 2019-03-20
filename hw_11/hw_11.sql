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
FROM film