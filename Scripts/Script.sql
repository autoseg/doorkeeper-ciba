drop table backchannel_auth_requests;
drop table backchannel_auth_consent_history;

delete from backchannel_auth_requests;
commit;

select * from backchannel_auth_requests order by created_at desc ;
select * from backchannel_auth_consent_history ;


SELECT "backchannel_auth_requests".* FROM 
"backchannel_auth_requests" WHERE 
"backchannel_auth_requests"."auth_req_id" = 'd751da1b-262c-49eb-a853-7fd8bdadead2' 
AND "backchannel_auth_requests"."status" = 'P';

update backchannel_auth_requests set status = 'X'
where "backchannel_auth_requests"."auth_req_id" = 'd751da1b-262c-49eb-a853-7fd8bdadead2' ;
commit;

update backchannel_auth_requests set STATUS = 'P' where auth_req_id = 'e942caed-e60a-4f7d-a603-094e484f17dc';

select * from users u ;
select * from oauth_applications oa;
select * from oauth_access_grants;

select * from oauth_access_tokens;
select * from oauth_openid_requests;

SELECT "users".* FROM "users" WHERE "users".email_verified = false;



