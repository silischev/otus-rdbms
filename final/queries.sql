-- Категории по которым имеются объявления
SELECT categories.name
FROM categories
  INNER JOIN advertisements ON categories.id = advertisements.category_id;

-- Категории по которым отсутствуют объявления
SELECT categories.name
FROM categories
  LEFT JOIN advertisements ON categories.id = advertisements.category_id
WHERE category_id ISNULL;

-- Запросы с предложением WHERE

-- Выборка неактивных объявлений
SELECT *
FROM advertisements
WHERE active = FALSE;

-- Объявления в определенной категории
SELECT *
FROM advertisements
WHERE category_id = (SELECT min(id) FROM categories);

-- Объявления в определенной группе категорий
SELECT *
FROM advertisements
WHERE category_id IN ((SELECT min(id) FROM categories), (SELECT max(id) FROM categories));

-- Список пользователей зарегистрированных в системе с 16.02.19
SELECT *
FROM users
WHERE created_at >= '2019-02-16';

-- Список пользователей зарегистрированных в системе с 16.02.19 по 18.02.19
SELECT *
FROM users
WHERE created_at BETWEEN '2019-02-16' AND '2019-02-19';