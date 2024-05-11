-- migrate:up
create table todos (
  id integer,
  title varchar(255) not null,
  status varchar(255) not null
);

-- migrate:down
drop table todos;

