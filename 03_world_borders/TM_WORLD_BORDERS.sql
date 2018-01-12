--Download http://thematicmapping.org/downloads/world_borders.php and load with SRID 4326

IMPORT "TESTSGEO"."TM_WORLD_BORDERS-0.3" AS SHAPEFILE FROM '/usr/sap/HXE/home/Downloads/tm_world_border/TM_WORLD_BORDERS-0.3' WITH REPLACE SRID 4326 THREADS 4;
--Check the content of the table after the load

--Find all German neighbours and sort them accordingly to the borders' lengths in kilometers
select b.name as "neighbour", b.shape.st_intersection(a.shape).st_Length('kilometer') as "border"
from "TESTSGEO"."TM_WORLD_BORDERS-0.3"  a
join "TESTSGEO"."TM_WORLD_BORDERS-0.3"  b on 1 = 1
where a.name like 'Germany'
and a."SHAPE".st_srid(1000004326).ST_Touches(b.shape.st_srid(1000004326)) = 1
order by "border" desc;

--compare to the length in the straight line

-- Analyzing countries and continents
--Find continents where Turkey is

--Find all trascontinental countries
select b.name, count(*) as "count"
 from "TESTSGEO"."continent" a
 join "TESTSGEO"."TM_WORLD_BORDERS-0.3" b on 1=1
 where b.shape.st_srid(1000004326).st_intersects(a.shape) = 1
 group by b.name
 having count(*) > 1
 order by 1, 2;
