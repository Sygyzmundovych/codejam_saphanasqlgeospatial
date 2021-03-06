--Download Countries (cntry00.zip) from http://techcenter.jefferson.kctcs.edu/gis/data/default.html and load with SRID 4326

IMPORT "TESTSGEO"."cntry00" AS SHAPEFILE FROM '/usr/sap/HXE/home/Downloads/cntry00/cntry00' WITH REPLACE SRID 1000004326 THREADS 4;
--Check the content of the table after the load

--Find all Germany neighbours and sort them accordingly to the borders' lengths in kilometers
select 
b.CNTRY_NAME as "neighbour", 
b.shape.ST_Intersection(a.shape).ST_SRID(4326).st_Length('kilometer') as "border"
from "TESTSGEO"."cntry00"  a
join "TESTSGEO"."cntry00"  b on a."SHAPE".ST_Touches(b.shape) = 1
where a.CNTRY_NAME like 'Germany'
order by "border" desc;

--compare to the length in the straight line

--Who has the most neighbours
select a.CNTRY_NAME as "country", count(b.CNTRY_NAME) as "neighbours"
from "CODEJAMPREP"."cntry00"  a
join "CODEJAMPREP"."cntry00"  b on a."SHAPE".st_srid(1000004326).ST_Touches(b.shape.st_srid(1000004326)) = 1
--where a.CNTRY_NAME like 'Poland'
group by a.CNTRY_NAME
order by "neighbours" desc;

--The longest border
select top 1 a.CNTRY_NAME as "country",
b.CNTRY_NAME as "neighbour", 
b.shape.ST_Intersection(a.shape).ST_SRID(4326).st_Length('kilometer') as "border"
from "TESTSGEO"."cntry00"  a
join "TESTSGEO"."cntry00"  b on a."SHAPE".ST_Touches(b.shape) = 1
where b.shape.ST_Intersection(a.shape).st_GeometryType() <> 'ST_Point'
order by "border" desc;

-- Analyzing countries and continents
--Find continents where Turkey is

--Find all trascontinental countries
 select b.CNTRY_NAME, count(*) as "count"
 from "TESTSGEO"."continent" a
 join "TESTSGEO"."cntry00" b on b.shape.ST_Intersects(a.shape) = 1
 group by b.CNTRY_NAME --, a.CONTINENT
 having count(*) > 1
 order by 1, 2;
