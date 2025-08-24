-- ProtonBase Large Dataset Generation Script
-- This script generates test data for performance testing
-- Supports different dataset sizes based on requirements

\timing on

-- Configuration: Change this value to generate different dataset sizes
-- Options: 1000 (quick test), 10000 (medium test), 100000 (large test), 1000000 (full scale)
-- Default: 10000 records for balanced performance and testing
\set DATASET_SIZE 10000

\echo '=========================================='
\echo 'ProtonBase Dataset Generation'
\echo 'Target: ' :DATASET_SIZE ' property records'
\echo 'Estimated time: 1-5 minutes depending on size'
\echo '=========================================='

-- Verify required tables exist before generating data
DO $$
BEGIN
    -- Check if schema and tables are properly set up
    IF (SELECT count(*) FROM information_schema.tables 
        WHERE table_schema = 'property_data' 
        AND table_name IN ('unified_properties', 'neighborhoods')) < 2 THEN
        RAISE EXCEPTION 'Required tables not found. Please run scripts/01_setup_schema.sql first.';
    END IF;
END $$;

-- Clear existing large data first (keep only original 5 records for unified_properties)
DELETE FROM property_data.unified_properties WHERE id > 5;
-- Clear existing large data from neighborhoods (keep only original 5 records)
DELETE FROM property_data.neighborhoods WHERE id > 5;

-- Generate additional neighborhoods for the large dataset
-- This provides more realistic neighborhood distribution for the properties
INSERT INTO property_data.neighborhoods (name, location_polygon)
SELECT 
    -- Generate neighborhood names
    CASE (series_id % 20)
        WHEN 0 THEN 'Tech District ' || ((series_id / 20) + 1)
        WHEN 1 THEN 'Riverside ' || ((series_id / 20) + 1)
        WHEN 2 THEN 'Green Valley ' || ((series_id / 20) + 1)
        WHEN 3 THEN 'Downtown Core ' || ((series_id / 20) + 1)
        WHEN 4 THEN 'Historic Quarter ' || ((series_id / 20) + 1)
        WHEN 5 THEN 'Marina District ' || ((series_id / 20) + 1)
        WHEN 6 THEN 'University Area ' || ((series_id / 20) + 1)
        WHEN 7 THEN 'Arts District ' || ((series_id / 20) + 1)
        WHEN 8 THEN 'Financial Center ' || ((series_id / 20) + 1)
        WHEN 9 THEN 'Waterfront ' || ((series_id / 20) + 1)
        WHEN 10 THEN 'Hillside ' || ((series_id / 20) + 1)
        WHEN 11 THEN 'Garden District ' || ((series_id / 20) + 1)
        WHEN 12 THEN 'Business Park ' || ((series_id / 20) + 1)
        WHEN 13 THEN 'Old Town ' || ((series_id / 20) + 1)
        WHEN 14 THEN 'New Town ' || ((series_id / 20) + 1)
        WHEN 15 THEN 'Suburban ' || ((series_id / 20) + 1)
        WHEN 16 THEN 'Industrial ' || ((series_id / 20) + 1)
        WHEN 17 THEN 'Shopping District ' || ((series_id / 20) + 1)
        WHEN 18 THEN 'Cultural Center ' || ((series_id / 20) + 1)
        ELSE 'Residential ' || ((series_id / 20) + 1)
    END AS name,
    
    -- Generate polygon areas around different base coordinates
    ST_GeomFromText(
        'POLYGON((' ||
        -- Base longitude + small variation
        (-122.5 + (series_id % 50) * 0.02)::text || ' ' ||
        -- Base latitude + small variation  
        (47.4 + (series_id % 25) * 0.02)::text || ', ' ||
        -- Create a small rectangular polygon (approx 0.01 degrees = ~1km)
        (-122.5 + (series_id % 50) * 0.02 + 0.01)::text || ' ' ||
        (47.4 + (series_id % 25) * 0.02)::text || ', ' ||
        (-122.5 + (series_id % 50) * 0.02 + 0.01)::text || ' ' ||
        (47.4 + (series_id % 25) * 0.02 + 0.01)::text || ', ' ||
        (-122.5 + (series_id % 50) * 0.02)::text || ' ' ||
        (47.4 + (series_id % 25) * 0.02 + 0.01)::text || ', ' ||
        (-122.5 + (series_id % 50) * 0.02)::text || ' ' ||
        (47.4 + (series_id % 25) * 0.02)::text ||
        '))', 4326) AS location_polygon
        
FROM generate_series(1, LEAST(:DATASET_SIZE / 50, 200)) AS series_id;  -- Generate neighborhoods (1 per 50 properties, max 200)

-- Generate records efficiently
INSERT INTO property_data.unified_properties (
    title, address, city, state, zip_code, price, bedrooms, bathrooms, 
    square_feet, year_built, property_type, listing_date, status,
    amenities, features, description, location_point, embedding
)
SELECT 
    -- Simple title generation
    'Property #' || series_id AS title,
    
    -- Simple address
    (1000 + (series_id % 9000))::text || ' Test St' AS address,
    
    -- Cycle through cities
    CASE (series_id % 6)
        WHEN 0 THEN 'Seattle'
        WHEN 1 THEN 'Portland'
        WHEN 2 THEN 'San Francisco'
        WHEN 3 THEN 'Los Angeles'
        WHEN 4 THEN 'Austin'
        ELSE 'New York'
    END AS city,
    
    -- Cycle through states
    CASE (series_id % 5)
        WHEN 0 THEN 'WA'
        WHEN 1 THEN 'CA'
        WHEN 2 THEN 'OR'
        WHEN 3 THEN 'NY'
        ELSE 'TX'
    END AS state,
    
    (98000 + (series_id % 999))::text AS zip_code,
    
    -- Price based on series
    (200000 + (series_id % 4800000))::decimal(10,2) AS price,
    
    -- Bedrooms: 1-6
    (1 + (series_id % 6))::int AS bedrooms,
    
    -- Bathrooms: 1-4
    (1 + (series_id % 4))::decimal(3,1) AS bathrooms,
    
    -- Square feet
    (500 + (series_id % 7500))::int AS square_feet,
    
    -- Year built
    (1950 + (series_id % 75))::int AS year_built,
    
    -- Property type
    CASE (series_id % 5)
        WHEN 0 THEN 'Condo'
        WHEN 1 THEN 'Single Family'
        WHEN 2 THEN 'Townhouse'
        WHEN 3 THEN 'Loft'
        ELSE 'Duplex'
    END AS property_type,
    
    -- Listing date
    (CURRENT_DATE - (series_id % 730)) AS listing_date,
    
    -- Status
    CASE (series_id % 3)
        WHEN 0 THEN 'Active'
        WHEN 1 THEN 'Pending'
        ELSE 'Sold'
    END AS status,
    
    -- Simple JSON amenities
    CASE (series_id % 2)
        WHEN 0 THEN '{"indoor": ["Air Conditioning", "High-Speed Internet"], "outdoor": ["Pool", "Garden"]}'::jsonb
        ELSE '{"indoor": ["Washer/Dryer", "Smart Home System"], "outdoor": ["Patio", "Garage"]}'::jsonb
    END AS amenities,
    
    -- Simple JSON features
    '{"interior": {"flooring": "Hardwood", "kitchen": {"type": "Modern Kitchen", "appliances": ["Stainless Steel"]}}}'::jsonb AS features,
    
    -- Simple description with keywords for text search
    CASE (series_id % 3)
        WHEN 0 THEN 'This luxury property offers modern amenities and beautiful views.'
        WHEN 1 THEN 'Beautiful home with spacious rooms and excellent location.'
        ELSE 'Stunning property featuring modern design and premium finishes.'
    END AS description,
    
    -- Geographic locations around Seattle area
    ST_SetSRID(
        ST_MakePoint(
            -122.5 + (series_id % 100) * 0.01,  -- Longitude variation
            47.4 + (series_id % 50) * 0.01      -- Latitude variation
        ), 
        4326
    )::geography AS location_point,
    
    -- Simple vector generation (fixed length array)
    array_fill(((series_id % 1000) / 1000.0)::float, ARRAY[384])::vector(384) AS embedding

FROM generate_series(1, :DATASET_SIZE) AS series_id;

-- Update statistics for both tables
ANALYZE property_data.unified_properties;
ANALYZE property_data.neighborhoods;

-- Show results for unified_properties
SELECT 
    'Properties Dataset Generation Complete' as status,
    count(*) as total_properties,
    min(price) as min_price,
    max(price) as max_price,
    avg(price)::decimal(10,2) as avg_price
FROM property_data.unified_properties;

-- Show results for neighborhoods
SELECT 
    'Neighborhoods Dataset Generation Complete' as status,
    count(*) as total_neighborhoods
FROM property_data.neighborhoods;

\echo 'Dataset generation completed successfully for both tables!'
\echo 'Properties and neighborhoods are ready for performance testing and demos.'