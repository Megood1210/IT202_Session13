create database session13;
use session13;

delimiter //
create procedure add_user(
    in p_username varchar(50),
    in p_email varchar(100),
    in p_created_at datetime
)
begin
    insert into users(username, email, created_at)
    values (p_username, p_email, p_created_at);
end;
//
delimiter ;

delimiter //
create trigger tg_validate_user_before_insert
before insert on users
for each row
begin
    -- kiểm tra email
    if new.email not like '%@%.%' then
        signal sqlstate '45000'
        set message_text = 'email khong hop le';
    end if;

    -- kiểm tra username (chỉ chữ, số, _)
    if new.username not regexp '^[a-zA-Z0-9_]+$' then
        signal sqlstate '45000'
        set message_text = 'username chi duoc chua chu, so va dau gach duoi';
    end if;
end;
//
delimiter ;

-- Gọi procedure với dữ liệu hợp lệ 
call add_user('john_doe', 'john@example.com', now());
-- Gọi procedure với dữ liệu không hợp lệ 
 call add_user('bademail', 'bademail.com', now());

select * from users;