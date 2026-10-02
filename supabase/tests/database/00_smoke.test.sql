begin;
select plan(1);

select ok(true, 'pgTAP is available on the local stack');

select * from finish();
rollback;
