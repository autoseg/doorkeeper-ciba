drop table backchannel_auth_requests;
drop table backchannel_auth_consent_history;

delete from backchannel_auth_requests;
commit;

select * from backchannel_auth_requests order by created_at desc ;
select * from backchannel_auth_consent_history ;


SELECT "backchannel_auth_requests".* FROM 
"backchannel_auth_requests" WHERE 
"backchannel_auth_requests"."auth_req_id" = 'e942caed-e60a-4f7d-a603-094e484f17dc' AND 
"backchannel_auth_requests"."identified_user_id" = 'f831fdc8-1089-4151-b758-3dd084185892' 
AND "backchannel_auth_requests"."status" = 'P';

update backchannel_auth_requests set STATUS = 'P' where auth_req_id = 'e942caed-e60a-4f7d-a603-094e484f17dc';


select * from oauth_applications oa;
select * from oauth_access_grants;

select * from oauth_access_tokens;
select * from oauth_openid_requests;

SELECT "users".* FROM "users" WHERE "users"."soft_deleted" = false AND "users"."email" = 'email1@email.com';