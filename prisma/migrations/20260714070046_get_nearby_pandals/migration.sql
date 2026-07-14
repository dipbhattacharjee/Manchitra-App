-- Create function to get nearby pandals using PostGIS ST_Distance
CREATE OR REPLACE FUNCTION get_nearby_pandals(
  user_lat double precision,
  user_lng double precision,
  max_dist_meters double precision DEFAULT 50000
)
RETURNS TABLE (
  id text,
  name text,
  area text,
  ward text,
  "committeeName" text,
  theme text,
  description text,
  "isFeatured2026" boolean,
  category text,
  latitude double precision,
  longitude double precision,
  "visitStartTime" text,
  "visitEndTime" text,
  "crowdLevel" text,
  distance_meters double precision
) AS $$
BEGIN
  RETURN QUERY
  SELECT 
    p.id,
    p.name,
    p.area,
    p.ward,
    p."committeeName",
    p.theme,
    p.description,
    p."isFeatured2026",
    p.category::text,
    p.latitude,
    p.longitude,
    p."visitStartTime",
    p."visitEndTime",
    p."crowdLevel"::text,
    ST_Distance(
      p.geo_location,
      ST_SetSRID(ST_MakePoint(user_lng, user_lat), 4326)::geography
    ) AS distance_meters
  FROM "Pandal" p
  WHERE ST_DWithin(
    p.geo_location,
    ST_SetSRID(ST_MakePoint(user_lng, user_lat), 4326)::geography,
    max_dist_meters
  )
  ORDER BY distance_meters ASC;
END;
$$ LANGUAGE plpgsql;