
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


SELECT "users".* FROM "users" WHERE "users".email_verified = true order by created_at ;
select * from oauth_access_grants;



