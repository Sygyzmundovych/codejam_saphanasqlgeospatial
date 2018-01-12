DROP PROCEDURE "TESTSGEO"."CONTINENT_MAINLAND_CENTER";
CREATE PROCEDURE "TESTSGEO"."CONTINENT_MAINLAND_CENTER" 
(IN continent_name NVARCHAR (20), OUT nr_shapes INT, OUT point_centroid NVARCHAR (64), OUT point_middle NVARCHAR (64))
 LANGUAGE SQLSCRIPT 
 READS SQL DATA AS
 whole_continet ST_GEOMETRY;
 BEGIN
    DECLARE single_shape, theshape, temp_shape ST_GEOMETRY;
    DECLARE shape_area, shapei_area DECIMAL = 0;    
    DECLARE i INTEGER;
    select "SHAPE" into whole_continet FROM "TESTSGEO"."continent" WHERE CONTINENT=:continent_name;
    nr_shapes := whole_continet.ST_NumGeometries();
    --CREATE COLUMN TABLE TEMP_TAB (AREA DECIMAL, SHAPE ST_GEOMETRY); 
    FOR i IN 1..nr_shapes DO
    	single_shape := :whole_continet.ST_GeometryN(i);
    	shapei_area := single_shape.ST_Area();
        --INSERT INTO TEMP_TAB VALUES (:shape_area, :single_shape);
		IF shape_area < shapei_area
		THEN
			shape_area := shapei_area;
			theshape := single_shape;
		END IF;
    END FOR;
	--Calculate centroid
	temp_shape := theshape.ST_Centroid();
	point_centroid := temp_shape.st_asWKT();
	--Calculate midpoint
	temp_shape := theshape.ST_Envelope();
	temp_shape := temp_shape.ST_Centroid();
	point_middle := temp_shape.st_asWKT();
 END;
 
CALL "TESTSGEO"."CONTINENT_MAINLAND_CENTER"(
	CONTINENT_NAME => ?,
	NR_SHAPES => ?,
	POINT_CENTROID => ?,
	POINT_MIDDLE => ?
);
