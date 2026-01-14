create database SocialNetworkDB;
use SocialNetworkDB;

create table users(
		user_id int primary key auto_increment,
        username varchar(100),
        total_posts int default 0
);

create table posts(
		post_id int primary key auto_increment,
        user_id int,
        content text,
        created_at DATETIME,
        foreign key (user_id) references users(user_id)
);

create table post_audits(
		audit_id int primary key auto_increment,
        post_id INT,
        old_content text,
        new_content text,
        changed_at datetime
);
-- Task 1
delimiter //
create trigger tg_checkpostcontent
before insert on posts
for each row
begin
    if length(trim(new.content)) = 0 then
        signal sqlstate '45000'
        set message_text = 'Nội dung bài viết không được để trống!';
    end if;
end//
delimiter ;
-- Task 2
delimiter //
create trigger tg_updatepostcountafterinsert
after insert on posts
for each row
begin
    update users
    set total_posts = total_posts + 1
    where user_id = new.user_id;
end//
delimiter ;
-- Task 3
delimiter //
create trigger tg_logpostchanges
after update on posts
for each row
begin
    if old.content <> new.content then
        insert into post_audits(post_id, old_content, new_content, changed_at)
        values (old.post_id, old.content, new.content, now());
    end if;
end//
delimiter ;
-- Task 4
delimiter //
create trigger tg_updatepostcountafterdelete
after delete on posts
for each row
begin
    update users
    set total_posts = total_posts - 1
    where user_id = old.user_id;
end//
delimiter ;
-- Tạo 1 người dùng mới
insert into users(username) values ('test_user');
insert into posts(user_id, content, created_at) values (1, 'bài viết đầu tiên', now());
insert into posts(user_id, content, created_at) values (1, '   ', now());
-- Thử nghiệm Update
update posts
set content = 'noi dung da chinh sua'
where post_id = 3;
select * from post_audits;
-- Thử nghiệm Delete
delete from posts where post_id = 2;
select user_id, total_posts from users where user_id = 2;
-- Xóa toàn bộ các Trigger 
drop trigger tg_checkpostcontent;
drop trigger  tg_updatepostcountafterinsert;
drop trigger  tg_logpostchanges;
drop trigger  tg_updatepostcountafterdelete;
select post_id, content from posts where post_id = 1;