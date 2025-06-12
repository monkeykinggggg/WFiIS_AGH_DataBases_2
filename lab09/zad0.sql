use lab9;
go

-- Zadanie 0
-- Przedstawić przykładowe dane testowe dla przedstawionych przykładów Lab09.06, Lab09.07, Lab09.08 i Lab09.09. 
use lab9;
go
create table test ( pkt dbo.Punkt);
insert into test (pkt) values('2,3');
select pkt.ToString() as punkt, 
pkt.Odleglosc() as odleglosc_od_pocz,
pkt.OdlegloscOd('2,3') as odleglosc,
pkt.OdlegloscOd('2,1') as odleglosc2
from test;

drop table test;
go


use lab9;
go
if object_id('test') is not null
	drop table test;
go
create table test ( val int);
insert into test (val) values(2),(3),(4),(10),(0),(1),(5),(-3), (-10), (-20);
select * from test order by val;
go

select dbo.uda_CountOfRange(val) as range_2_to_2,
dbo.uda_CountOfNegatives(val) as negative,
dbo.Median(val) as median
from test;

if object_id('dbo.f_median') is not null
	drop function dbo.f_median;
go

create function dbo.f_median()
returns int
as
begin
	DECLARE @c BIGINT = (SELECT COUNT(*) FROM test);
	SELECT AVG(1.0 * val)
	FROM (
		SELECT val FROM test
		 ORDER BY val
		 OFFSET (@c - 1) / 2 ROWS
		 FETCH NEXT 1 + (1 - @c % 2) ROWS ONLY
	) AS x;a
	return x;
end;
go






