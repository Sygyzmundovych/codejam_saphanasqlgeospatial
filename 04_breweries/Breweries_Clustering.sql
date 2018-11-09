--Visualize all points with breweries at geojson.io
select ST_UnionAggr("loc_4326").st_asWKT()
from "OPENBEERDB"."V_BREWERIES_GEO"
where "country" = 'United States';

--Visualize all points with breweries at geojson.io
select ST_UnionAggr("loc_4326").st_asEWKT()
from "OPENBEERDB"."V_BREWERIES_GEO"
join "GEOTECH"."cntry00" on "loc_4326".ST_SRID(1000004326).ST_Within("SHAPE") = 1
where "CNTRY_NAME" = 'United States';


--Grid
select ST_UnionAggr("Envelope").st_asWKT() from
(select ST_CLUSTERID() AS "CID", 
	ST_CLUSTERENVELOPE() AS "Envelope",
	COUNT(*) AS "Number of breweries in this cluster"
 from "OPENBEERDB"."V_BREWERIES_GEO"
 where "country" = 'United States'
 GROUP CLUSTER BY "loc_4326" 
USING GRID X CELLS 40 Y CELLS 20
order by 3 desc);

--KMeans
select ST_UnionAggr("ConvexHull").st_asWKT() from
(select ST_CLUSTERID() AS "CID",
	ST_CONVEXHULLAGGR("loc_3857").st_transform(4326) AS "ConvexHull",
	COUNT(*) AS "Number of breweries in this cluster"
 from "OPENBEERDB"."V_BREWERIES_GEO"
 where "country" = 'United States'
 GROUP CLUSTER BY "loc_3857"
 USING KMEANS CLUSTERS 20
 --For the whole world CLUSTERS 9 throws JDBC: [669]: spatial error: exception 1600002: An internal error occurred at function aggr::st_unionaggr()
order by 3 desc)
--where "ConvexHull".st_isValid() = 1
;

--DBSCAN
SELECT ST_CLUSTERID() AS "CID",
COUNT(*) AS "COU"
	FROM "OPENBEERDB"."V_BREWERIES_GEO"
 GROUP CLUSTER BY "loc_3857" USING DBSCAN EPS 100000 MINPTS 8
 order by 2 desc;

--Use DBSCAN in Window function
SELECT 
  ST_ClusterID() OVER (CLUSTER BY "loc_3857" USING DBSCAN EPS 100000 MINPTS 8) AS "cluster_id",
  "brewery_id",
  "loc_3857" 
FROM "OPENBEERDB"."V_BREWERIES_GEO"
WHERE "country" = 'United States'
ORDER BY 1, "brewery_id";

select "cluster_id", st_unionAggr("loc_3857").st_transform(4326) as "cluster"
from (
SELECT 
  ST_ClusterID() OVER (CLUSTER BY "loc_3857" USING DBSCAN EPS 30000 MINPTS 4) AS "cluster_id",
  "brewery_id",
  "loc_3857" 
FROM "OPENBEERDB"."V_BREWERIES_GEO"
WHERE "country" = 'United States'
ORDER BY 1, "brewery_id"
)
where "cluster_id" <> 0
group by "cluster_id";

--AlphaShape
--https://www.youtube.com/watch?v=YQxbi_Ydfaw
select st_unionAggr("cluster") from (
select "cluster_id", st_unionAggr("loc_3857").ST_AlphaShape(250000).st_transform(4326) as "cluster"
from (
SELECT 
  ST_ClusterID() OVER (CLUSTER BY "loc_3857" USING DBSCAN EPS 250000 MINPTS 9) AS "cluster_id",
  "brewery_id",
  "loc_3857" 
FROM "OPENBEERDB"."V_BREWERIES_GEO"
WHERE "country" = 'United States'
ORDER BY 1, "brewery_id"
)
where "cluster_id" <> 0
group by "cluster_id");
