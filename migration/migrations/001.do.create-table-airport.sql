CREATE EXTENSION IF NOT EXISTS "uuid-ossp";

create table planetype
(
    id        uuid
        constraint planetype_pk
            primary key,
    type_name varchar(10) not null,
    speed     int         not null
);

comment on table planetype is 'types of planes';

INSERT INTO planetype (id, type_name, speed) VALUES ('1e90ef56-d5c2-4a5e-973d-13043ac78ac5', 'B733', 430);
INSERT INTO planetype (id, type_name, speed) VALUES ('39f05ee2-37d0-414c-9cd0-b403be7bb16a', 'PAY2', 230);
INSERT INTO planetype (id, type_name, speed) VALUES ('36123658-36e7-4e99-91f9-d3ca9e84b8e1', 'C500', 250);
INSERT INTO planetype (id, type_name, speed) VALUES ('f7c87abc-1a9e-4e9a-9196-310bc77c755c', 'B738', 440);
INSERT INTO planetype (id, type_name, speed) VALUES ('7881c792-449b-4eda-9320-8c29ab3e086b', 'PA34', 130);
INSERT INTO planetype (id, type_name, speed) VALUES ('513319b8-c1ad-451b-b7a4-add0e05d443d', 'A320', 420);

