create database session13;
use session13;

insert into posts (user_id, content, created_at)
values (1, 'post để test like', now());

delimiter //
create trigger tg_like_before_insert
before insert on likes
for each row
begin
    if new.user_id = (
        select user_id from posts where post_id = new.post_id
    ) then
        signal sqlstate '45000'
        set message_text = 'không được like bài viết của chính mình';
    end if;
end;
//
delimiter ;

delimiter //
create trigger tg_like_after_update
after update on likes
for each row
begin
    -- giảm like của post cũ
    update posts
    set like_count = like_count - 1
    where post_id = old.post_id;

    -- tăng like của post mới
    update posts
    set like_count = like_count + 1
    where post_id = new.post_id;
end;
//
delimiter ;

-- Thử like bài của chính mình
insert into likes (user_id, post_id) values (1, 1);
-- Thêm like hợp lệ, kiểm tra like_count
insert into likes (user_id, post_id) values (2, 1);
select post_id, like_count from posts where post_id = 1;
-- UPDATE một like sang post khác, kiểm tra like_count của cả hai post
update likes
set post_id = 2
where user_id = 2 and post_id = 1;
select post_id, like_count from posts where post_id in (1,2);
-- Xóa like và kiểm tra
delete from likes
where user_id = 3 and post_id = 3;
select post_id, like_count from posts where post_id = 3;
select post_id, user_id, like_count from posts;
select * from user_statistics; 