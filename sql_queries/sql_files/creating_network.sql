
-- Una vez que se tiene cargada la capa de red vial extraida desde OSM se deben desagregar las calles para 
-- ejecutar los algoritmos de ruteo. Esto se hizo en QGIS con la funcion split with lines, luego se subió a la bd postgres.


-- Se agregan los campos de source y target para que la capa sea routable
alter table capas_estaticas.roads_final add column source integer;
alter table capas_estaticas.roads_final add column target integer;
SELECT pgr_createTopology('capas_estaticas.roads_final', '0.00001' ,'geom', 'id');



DROP TABLE IF EXISTS capas_estaticas.roads_routing;
 
CREATE TABLE capas_estaticas.roads_routing as (
SELECT id, name, maxspeed, lanes, source, target, ST_Length(ST_Transform(geom, 32718)) as cost, ST_Transform(geom, 32718) as geom  FROM capas_estaticas.roads_final
);


DROP TABLE IF EXISTS capas_estaticas.isochrone_test;

CREATE TABLE capas_estaticas.isochrone_test as (
SELECT ST_ConcaveHull(ST_Collect(geom),1,true) 
FROM capas_estaticas.roads_routing as roads
	JOIN (SELECT  * FROM pgr_drivingdistance('SELECT id, source, target, cost from capas_estaticas.roads_routing', ARRAY[724,721], 150, false)) 
AS route 
ON roads.id = route.edge
GROUP BY route.from_v
)
	

'''

CREATE TABLE isochrone_test as (
SELECT ST_ConcaveHull(ST_Collect(geom),<<concave>>,false) 
FROM capas_estaticas.roads 
JOIN (SELECT * FROM pgr_drivingdistance('SELECT id, source, target, cost AS cost from roads', 1234, 2, false, false)) 
AS route 
ON roads.source = route.id
)


'''