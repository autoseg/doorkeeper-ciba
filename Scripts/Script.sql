drop table backchannel_auth_requests;
drop table backchannel_auth_consent_history;

delete from backchannel_auth_requests;
commit;

select * from backchannel_auth_requests ;
select * from backchannel_auth_consent_history ;

select * from oauth_applications oa;

SELECT "users".* FROM "users" WHERE "users"."soft_deleted" = false AND "users"."email" = 'email2@email.com';