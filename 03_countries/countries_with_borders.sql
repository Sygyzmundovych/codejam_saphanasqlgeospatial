
select ST_UnionAggr("shape").ST_Intersection(new ST_Polygon('POLYGON ((5.467013359 45.329437256,10.98820591 45.329437256,10.98820591 48.306663513,5.467013359 48.306663513,5.467013359 45.329437256))',1000004326)) from
(
select b.CNTRY_NAME as "neighbour", b.shape.st_intersection(a.shape).st_Length('kilometer') as "border", b.shape.st_srid(1000004326).ST_Boundary() as "shape"
from "cntry00"  a
join "cntry00"  b on a."SHAPE".st_srid(1000004326).ST_Touches(b.shape.st_srid(1000004326)) = 1
where a.CNTRY_NAME like 'Switzerland'
order by "border" desc
);

select SHAPE.st_srid(1000004326).st_buffer(0.5).st_envelope().st_asEWKT()
from "cntry00"  a
where a.CNTRY_NAME like 'Switzerland';