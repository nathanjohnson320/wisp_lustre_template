-- migrate:up
create table items (
  id integer,
  title varchar(255) not null,
  status varchar(255) not null
);

-- migrate:down
drop table items;

