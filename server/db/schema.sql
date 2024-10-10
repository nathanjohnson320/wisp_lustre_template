CREATE TABLE IF NOT EXISTS "schema_migrations" (version varchar(128) primary key);
CREATE TABLE items (
  id varchar(64) primary key not null,
  title varchar(255) not null,
  status varchar(255) not null
);
-- Dbmate schema migrations
INSERT INTO "schema_migrations" (version) VALUES
  ('20240511203036');
