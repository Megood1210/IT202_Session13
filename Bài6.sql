create database session13;
use session13;

create table friendships(
	follower_id int,
    followee_id int,
    foreign key(follower_id) references users(user_id),
    foreign key(followee_id) references users(user_id),
    status enum('pending', 'accepted') default 'accepted' 
);
-- Tạo trigger after insert/delete trên friendships để cập nhật follower_count của follower.
delimiter //
create trigger tg_after_insert_friend
after insert on friendships
for each row
begin
	update users
    set follower_count = follower_count + 1
    where user_id = new.followee_id;
end //
delimiter ;

delimiter //
create trigger tg_delete_friend
after delete
on friendships
for each row
begin
	update users
    set follower_count = follower_count - 1
    where user_id = old.followee_id;
end //
delimiter ;
-- Tạo procedure follow_user(follower_id, followee_id, status) xử lý logic (tránh tự follow, tránh trùng).
delimiter //
create procedure follow_user(in_follower_id int, in_followee_id int, in_status enum('pending', 'accepted'))
begin
	if in_follower_id = in_followee_id then
		signal sqlstate '45000' 
        set message_text = 'lỗi: không thể tự follow bản thân';
	else 
		insert into friendships(follower_id,followee_id,status) value (in_follower_id, in_followee_id,in_status);
	end if;
end //
delimiter ;
-- Tạo view user_profile chi tiết.
create view user_profile as
select * from users;
-- kiểm tra dữ liệu
select * from user_profile;
-- Thực hiện một số follow/unfollow và kiểm chứng follower_count, view.
call follow_user(1,1,'accepted');
call follow_user(2,1,'accepted');
call follow_user(3,1,'accepted');

delete from friendships
where followee_id = 1 and follower_id = 2;