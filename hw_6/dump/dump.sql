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
