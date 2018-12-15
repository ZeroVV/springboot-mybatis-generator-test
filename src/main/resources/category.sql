create table category(
id int(11) primary key auto_increment not null,
name varchar(255) default null)
engine=innodb default charset=utf8;

create table product(
id int(11) primary key auto_increment not null,
name varchar(255)  default null,
price float default null,
cid int(11) default null,
constraint fk_product_category foreign key (cid) references category(id)
)engine=innodb default charset=utf8;