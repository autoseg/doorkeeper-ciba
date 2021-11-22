
-- CIBA
select * from backchannel_auth_requests order by created_at desc ;

select * from backchannel_auth_consent_history ;
-- OAUTH2 (CIBA adds some columns in both tables)
select * from oauth_applications oa;
select * from oauth_access_tokens order by created_at desc;
-- OPEN_ID Connect
select * from users u ;

ROLES X CLIENT
users X 

select * from oauth_access_grants;
select * from oauth_openid_requests;

#### DEV ####

-- drop table backchannel_auth_requests;
-- drop table backchannel_auth_consent_history;

delete from backchannel_auth_requests;
commit;

SELECT "backchannel_auth_requests".* FROM 
"backchannel_auth_requests" WHERE 
"backchannel_auth_requests"."auth_req_id" = 'd751da1b-262c-49eb-a853-7fd8bdadead2' 
AND "backchannel_auth_requests"."status" = 'P';

update backchannel_auth_requests set status = 'X'
where "backchannel_auth_requests"."auth_req_id" = 'd751da1b-262c-49eb-a853-7fd8bdadead2' ;
commit;

update backchannel_auth_requests set STATUS = 'P' where auth_req_id = 'e942caed-e60a-4f7d-a603-094e484f17dc';

select * from oauth_access_tokens 
where ciba_auth_req_id = '7539963f-5065-4571-beb6-b4a783e4ba5a';

update "users" set email_verified = true where email  = 'email2@email.com';
select * from users where email  = 'email2@email.com';
commit;
SELECT "users".* FROM "users" WHERE "users".email_verified = true order by created_at ;
select * from oauth_access_grants;

delete from users where id in ('fe854d0d-a647-40b9-b6e4-9c605c2653e5',
'7dd02cd1-7931-42cf-b552-db64bc7bc6da',
'06a380a7-4fb2-4d2a-9c52-1c9accdb53b4',
'0946969b-54bb-442e-81b6-148362c5fc15')


select * from oauth_applications where "name" = 'CIBA';
delete from oauth_access_grants where application_id = '6e1a6e3a-10c7-4aca-acf0-d6f309fb0be3';
delete from oauth_access_tokens where application_id = '6e1a6e3a-10c7-4aca-acf0-d6f309fb0be3';
delete from oauth_applications where "id" = '6e1a6e3a-10c7-4aca-acf0-d6f309fb0be3';
commit;


