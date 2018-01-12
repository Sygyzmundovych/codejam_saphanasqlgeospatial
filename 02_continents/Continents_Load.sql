CREATE SCHEMA "TESTSGEO";
SET SCHEMA "TESTSGEO";

--Download continents.zip from http://techcenter.jefferson.kctcs.edu/gis/data/default.html 
--See the shapes using http://mapshaper.org/

--Load ESRI Shapefile via Eclipse HANA Studio or from the SQL
IMPORT "TESTSGEO"."continent" AS SHAPEFILE FROM '/usr/sap/HXE/home/Downloads/continents/continent' WITH REPLACE SRID 1000004326 THREADS 4;

--Check the content of the table, check SRIDs of the shapes, types of the shapes
--Calculate centroid of the Europe
--Calculate mid point of Europe
--Aggregate all continents into the one geometry