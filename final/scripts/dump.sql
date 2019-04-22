DROP TABLE IF EXISTS users;

CREATE TABLE IF NOT EXISTS users (
  id         BIGSERIAL PRIMARY KEY,
  name       VARCHAR(60) NOT NULL,
  email      VARCHAR(60) NOT NULL,
  password   TEXT        NOT NULL,
  phone      VARCHAR(45) NOT NULL,
  created_at TIMESTAMP   NOT NULL DEFAULT CURRENT_TIMESTAMP,
  updated_at TIMESTAMP   NOT NULL DEFAULT CURRENT_TIMESTAMP,
  deleted_at TIMESTAMP            DEFAULT NULL
);

CREATE UNIQUE INDEX email_UNIQUE
  ON users (email ASC);

DROP TABLE IF EXISTS categories;

CREATE TABLE IF NOT EXISTS categories (
  id        SERIAL PRIMARY KEY,
  name      VARCHAR(255) NOT NULL,
  parent_id INTEGER DEFAULT NULL REFERENCES categories (id)
);

CREATE INDEX pid_fk_idx
  ON categories (parent_id ASC);

DROP TABLE IF EXISTS statuses;

CREATE TABLE IF NOT EXISTS statuses (
  id   SERIAL PRIMARY KEY,
  name VARCHAR(45) NOT NULL
);

DROP TABLE IF EXISTS advertisements;

CREATE TABLE IF NOT EXISTS advertisements (
  id               BIGSERIAL PRIMARY KEY,
  user_id          BIGINT       NOT NULL REFERENCES users (id),
  category_id      INTEGER      NOT NULL REFERENCES categories (id),
  status_id        INTEGER      NOT NULL REFERENCES statuses (id),
  status_meta_data JSON         NULL,
  title            VARCHAR(100) NOT NULL,
  description      VARCHAR(500) NOT NULL,
  address          VARCHAR(200) NULL,
  phone            VARCHAR(45)  NOT NULL,
  url              VARCHAR(300) NOT NULL,
  price            MONEY        NOT NULL,
  views            INTEGER      NOT NULL DEFAULT 0,
  created_at       TIMESTAMP    NOT NULL DEFAULT CURRENT_TIMESTAMP,
  expired_at       TIMESTAMP             DEFAULT NULL,
  published_at     TIMESTAMP             DEFAULT NULL,
  active           BOOLEAN      NOT NULL DEFAULT FALSE
);

CREATE INDEX user_id_fk_idx
  ON advertisements (user_id ASC);
CREATE UNIQUE INDEX url_UNIQUE
  ON advertisements (url ASC);
CREATE INDEX category_id_fk_idx
  ON advertisements (category_id ASC);
CREATE INDEX status_id_fk_idx
  ON advertisements (status_id ASC);

DROP TABLE IF EXISTS favorite_advertisements;

CREATE TABLE IF NOT EXISTS favorite_advertisements (
  id               BIGSERIAL PRIMARY KEY,
  advertisement_id BIGINT    NOT NULL REFERENCES advertisements (id),
  user_id          BIGINT    NOT NULL REFERENCES users (id),
  created_at       TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP
);

CREATE INDEX ads_fk_idx
  ON favorite_advertisements (advertisement_id ASC);
CREATE INDEX user_fk_idx
  ON favorite_advertisements (user_id ASC);
CREATE UNIQUE INDEX user_ads_uniq
  ON favorite_advertisements (advertisement_id ASC, user_id ASC);

DROP TABLE IF EXISTS history_actions;

CREATE TABLE IF NOT EXISTS history_actions (
  id          SERIAL PRIMARY KEY,
  code        VARCHAR(30) NULL,
  description TEXT        NOT NULL
);

CREATE UNIQUE INDEX code_UNIQUE
  ON history_actions (code ASC);

DROP TABLE IF EXISTS advertisements_history;

CREATE TABLE IF NOT EXISTS advertisements_history (
  id               BIGSERIAL PRIMARY KEY,
  advertisement_id BIGINT NULL REFERENCES advertisements (id),
  action_id        INT    NOT NULL REFERENCES history_actions (id),
  metadata         JSON   NULL
);

CREATE INDEX ads_history_fk_idx
  ON advertisements_history (advertisement_id ASC);
CREATE INDEX history_action_fk_idx
  ON advertisements_history (action_id ASC);

--  INSERT DATA --
INSERT INTO users (name, email, phone, password) VALUES
  ('user_1', 'user_1@mail.com', '123-45-67', '$2y$10$tZymU9n9.8Sm8GR3fUbKPeZ2htXtBhTT1qmC6VerkrGbrTWGeLVYS'),
  ('user_2', 'user_2@mail.com', '152-33-42', '$2y$10$tZymU9n9.8Sm8GR3fUbKPeZ2htXtBhTT1qmC6VerkrGbrTWGeLVYS'),
  ('user_3', 'user_3@mail.com', '222-124-1551', '$2y$10$tZymU9n9.8Sm8GR3fUbKPeZ2htXtBhTT1qmC6VerkrGbrTWGeLVYS');

INSERT INTO categories (id, name, parent_id) VALUES
  (1, 'Home electronics', null),
  (2, 'TV', 1),
  (3, 'Cars', null);

INSERT INTO statuses (name) VALUES
  ('Waiting for activation'),
  ('Active'),
  ('Cancelled');

INSERT INTO history_actions (code, description) VALUES
  ('ADD_NEW_ADS', 'Add new ads by user'),
  ('CANCEL_ADS_NEW_BY_ADMIN', 'Cancel new ads by user'),
  ('CANCEL_ADS_NEW_BY_USER', 'Cancel new ads by admin'),
  ('VIEW_ADS_BY_USER', 'View ads by user'),
  ('UPD_ADS_BY_USER', 'Update ads by user'),
  ('USER_DEL_PROFILE', 'User delete profile'),
  ('USER_RESTORE_PROFILE', 'User restore profile');

-- CRUD ads --
START TRANSACTION;
INSERT INTO advertisements (user_id, category_id, status_id, status_meta_data, title, description, address, phone, url, price) VALUES
((SELECT id FROM users ORDER BY random() LIMIT 1), 2, 1, '{}', 'ads_1', 'description...', 'Spb, Lenina street', '123-4534', '/ads_1_23532', 1244);
INSERT INTO advertisements_history (advertisement_id, action_id) VALUES ((SELECT currval('advertisements_id_seq')), (SELECT id FROM history_actions WHERE code = 'ADD_NEW_ADS' LIMIT 1));
COMMIT;

START TRANSACTION;
INSERT INTO advertisements (user_id, category_id, status_id, status_meta_data, title, description, address, phone, url, price) VALUES
((SELECT id FROM users ORDER BY random() LIMIT 1), 3, 3, '{"reason" : "Invalid data"}', 'ads_2', 'description...', 'Spb, Lenina street', '123-4534', '/ads_2_44333', 511);
INSERT INTO advertisements_history (advertisement_id, action_id) VALUES ((SELECT currval('advertisements_id_seq')), (SELECT id FROM history_actions WHERE code = 'CANCEL_ADS_NEW_BY_ADMIN' LIMIT 1));
COMMIT;

START TRANSACTION;
INSERT INTO advertisements (user_id, category_id, status_id, status_meta_data, title, description, address, phone, url, price) VALUES
((SELECT id FROM users ORDER BY random() LIMIT 1), 1, 1, '{}', 'ads_3', 'description...', 'Spb, Lenina street', '123-4534', '/ads_3_34364', 5000);
INSERT INTO advertisements_history (advertisement_id, action_id) VALUES ((SELECT currval('advertisements_id_seq')), (SELECT id FROM history_actions WHERE code = 'ADD_NEW_ADS' LIMIT 1));
COMMIT;

START TRANSACTION;
WITH oldprice AS (SELECT price FROM advertisements WHERE id = (SELECT max(id) FROM advertisements) LIMIT 1)
INSERT INTO advertisements_history (advertisement_id, action_id, metadata) VALUES ((SELECT max(id) FROM advertisements), (SELECT id FROM history_actions WHERE code = 'ADD_NEW_ADS' LIMIT 1), cast(concat('{"old_price" : "', CAST((SELECT price FROM oldprice) AS TEXT), '"}') AS JSON));
WITH oldprice AS (SELECT price FROM advertisements WHERE id = (SELECT max(id) FROM advertisements) LIMIT 1)
UPDATE advertisements SET price = (SELECT price FROM oldprice) + CAST(100 AS MONEY) WHERE id = (SELECT max(id) FROM advertisements);
COMMIT;

START TRANSACTION;
UPDATE users SET deleted_at = NOW() WHERE id = (SELECT max(id) FROM users);
UPDATE advertisements SET active = FALSE WHERE user_id = (SELECT max(id) FROM users);
DELETE FROM favorite_advertisements WHERE user_id = (SELECT max(id) FROM users);
COMMIT;
