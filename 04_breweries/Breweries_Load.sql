--CREATE SCHEMA TESTSGEO;
SET SCHEMA TESTSGEO;

DROP TABLE "TESTSGEO"."BREWERIES_GEO" ;
CREATE COLUMN TABLE "TESTSGEO"."BREWERIES_GEO" (
"id" SMALLINT NOT NULL, 
"brewery_id" SMALLINT NOT NULL, 
"latitude" DECIMAL(12,4) NOT NULL, 
"longitude" DECIMAL(12,4) NOT NULL, 
"accuracy" NVARCHAR(32), 
"loc_4326" ST_POINT(4326), 
"loc_3857" ST_POINT(3857), 
PRIMARY KEY ("id")
);

--File to import must be in $DIR_INSTANCE/work (note 2109565)
IMPORT FROM CSV FILE '/usr/sap/HXE/HDB90/work/openbeerdb_csv/breweries_geocode.csv' 
INTO "TESTSGEO"."BREWERIES_GEO"
WITH SKIP FIRST 1 ROW;

--Populate 
update "TESTSGEO"."BREWERIES_GEO"
set "loc_4326" = ST_GeomFromText('POINT ('||"longitude"||' '||"latitude"||')',4326);

update "TESTSGEO"."BREWERIES_GEO"
set "loc_3857" = "loc_4326".ST_Transform(3857);

commit;

--DROP TABLE "TESTSGEO"."BREWERIES" ;
CREATE COLUMN TABLE "TESTSGEO"."BREWERIES"(
	"id" SMALLINT NOT NULL,
	"name" NVARCHAR(64),
	"address1" NVARCHAR(64),
	"address2" NVARCHAR(64),
	"city" NVARCHAR(180),
	"state" NVARCHAR(32),
	"code" NVARCHAR(16),
	"country" NVARCHAR(64),
	"phone" NVARCHAR(32),
	"website" NVARCHAR(128),
	"filepath" NVARCHAR(128),
	"descript" NCLOB MEMORY THRESHOLD 1000,
	"last_mod" LONGDATE,
	PRIMARY KEY (
		"id"
	)
);

--City name has to accomodate the longest official name, which is Bangkok :-)
select length('Krungthepmahanakhon Amonrattanakosin Mahintharayutthaya Mahadilokphop Noppharatratchathaniburirom Udomratchaniwetmahasathan Amonphimanawatansathit Sakkathattiyawitsanukamprasit') from dummy;

--File to import must be in $DIR_INSTANCE/work (note 2109565)
IMPORT FROM CSV FILE '/usr/sap/HXE/HDB90/work/openbeerdb_csv/breweries.csv' 
INTO "TESTSGEO"."BREWERIES"
WITH SKIP FIRST 1 ROW;

--Create a view
--DROP VIEW "TESTSGEO"."V_BREWERIES_GEO";
create view "TESTSGEO"."V_BREWERIES_GEO" as 
select 
T0."brewery_id",
T0."loc_4326",
T0."loc_3857",
T0."latitude",
T0."longitude",
T1."name",
T1."city",
T1."state",
T1."country"
 from 
"TESTSGEO"."BREWERIES_GEO" T0 inner join "TESTSGEO"."BREWERIES" T1
 on  T0."brewery_id" = T1."id";
 
--Check select
SELECT TOP 10
	"brewery_id",
	"loc_4326",
	"loc_3857",
	"latitude",
	"longitude",
	"name",
	"city",
	"state",
	"country"
FROM "TESTSGEO"."V_BREWERIES_GEO";