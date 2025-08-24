-- ProtonBase Large Dataset Performance Testing
-- This script demonstrates query performance with 1 million records
-- Optimized queries for large-scale data analysis

\timing on

\echo '============================================='
\echo 'ProtonBase Large Dataset Performance Test'
\echo 'Testing with 1,000,000 property records'
\echo '============================================='

-- Test 1: Basic aggregation performance
\echo '\n=== TEST 1: Basic Aggregation Performance ==='
\echo 'Testing COUNT, AVG, MIN, MAX operations on large dataset'

SELECT 
    'Dataset Overview' as test_name,
    count(*) as total_properties,
    count(DISTINCT city) as unique_cities,
    count(DISTINCT property_type) as unique_property_types,
    min(price)::decimal(10,2) as min_price,
    max(price)::decimal(10,2) as max_price,
    avg(price)::decimal(10,2) as avg_price,
    percentile_cont(0.5) WITHIN GROUP (ORDER BY price)::decimal(10,2) as median_price
FROM property_data.unified_properties;

-- Test 2: JSON query performance
\echo '\n=== TEST 2: JSON Query Performance ==='
\echo 'Testing JSON operations on large dataset'

SELECT 
    'JSON Analysis' as test_name,
    count(*) as properties_with_air_conditioning,
    avg(price)::decimal(10,2) as avg_price_with_ac
FROM property_data.unified_properties
WHERE amenities->'indoor' ? 'Air Conditioning';

-- Test 3: Full-text search performance
\echo '\n=== TEST 3: Full-Text Search Performance ==='
\echo 'Testing text search capabilities'

SELECT 
    'Text Search Results' as test_name,
    count(*) as luxury_properties,
    avg(price)::decimal(10,2) as avg_luxury_price,
    min(price)::decimal(10,2) as min_luxury_price,
    max(price)::decimal(10,2) as max_luxury_price
FROM property_data.unified_properties
WHERE description_tsv @@ to_tsquery('english', 'luxury');

-- Test 4: Geospatial query performance
\echo '\n=== TEST 4: Geospatial Query Performance ==='
\echo 'Testing location-based queries'

WITH seattle_center AS (
    SELECT ST_SetSRID(ST_MakePoint(-122.3321, 47.6062), 4326)::geography AS center
)
SELECT 
    'Geospatial Analysis' as test_name,
    count(*) as properties_within_50_miles,
    avg(price)::decimal(10,2) as avg_price_near_seattle,
    count(*) FILTER (WHERE ST_DWithin(p.location_point, sc.center, 80467)) as within_50_miles,
    count(*) FILTER (WHERE ST_DWithin(p.location_point, sc.center, 16093)) as within_10_miles
FROM property_data.unified_properties p, seattle_center sc
WHERE ST_DWithin(p.location_point, sc.center, 80467);  -- 50 miles

-- Test 5: Vector similarity search performance
\echo '\n=== TEST 5: Vector Similarity Search Performance ==='
\echo 'Testing vector operations on large dataset'

WITH reference_vector AS (
    SELECT embedding as ref_vector
    FROM property_data.unified_properties
    WHERE id = (SELECT max(id) FROM property_data.unified_properties WHERE id <= 1000)
    LIMIT 1
)
SELECT 
    'Vector Similarity' as test_name,
    count(*) as similar_properties,
    avg(1 - (p.embedding <=> rv.ref_vector))::decimal(4,3) as avg_similarity,
    min(1 - (p.embedding <=> rv.ref_vector))::decimal(4,3) as min_similarity,
    max(1 - (p.embedding <=> rv.ref_vector))::decimal(4,3) as max_similarity
FROM property_data.unified_properties p, reference_vector rv
WHERE (p.embedding <=> rv.ref_vector) < 0.5
LIMIT 1000;  -- Limit for performance

-- Test 6: Complex multi-modal query
\echo '\n=== TEST 6: Complex Multi-Modal Query Performance ==='
\echo 'Testing combined operations across all data types'

WITH seattle_center AS (
    SELECT ST_SetSRID(ST_MakePoint(-122.3321, 47.6062), 4326)::geography AS center
),
search_params AS (
    SELECT 
        to_tsquery('english', 'luxury | modern') as search_query,
        (SELECT embedding FROM property_data.unified_properties WHERE id = 1 LIMIT 1) as reference_vector
)
SELECT 
    'Multi-Modal Query' as test_name,
    count(*) as matching_properties,
    avg(price)::decimal(10,2) as avg_price,
    avg(ST_Distance(p.location_point, sc.center) / 1609.344)::decimal(6,2) as avg_distance_miles,
    avg(1 - (p.embedding <=> sp.reference_vector))::decimal(4,3) as avg_similarity_score
FROM property_data.unified_properties p, seattle_center sc, search_params sp
WHERE 
    -- Price range filter
    p.price BETWEEN 500000 AND 3000000
    -- JSON filter
    AND p.amenities->'indoor' ? 'Air Conditioning'
    -- Text search filter
    AND p.description_tsv @@ sp.search_query
    -- Geographic filter (within 25 miles of Seattle)
    AND ST_DWithin(p.location_point, sc.center, 40233)
    -- Vector similarity filter
    AND (p.embedding <=> sp.reference_vector) < 0.7
    -- Recent listings
    AND p.listing_date > CURRENT_DATE - INTERVAL '1 year';

-- Test 7: Pagination performance test
\echo '\n=== TEST 7: Pagination Performance Test ==='
\echo 'Testing LIMIT/OFFSET performance on large dataset'

SELECT 
    'Pagination Test' as test_name,
    id, title, price, city, bedrooms, bathrooms
FROM property_data.unified_properties
WHERE price > 1000000
ORDER BY price DESC, id
LIMIT 20 OFFSET 50000;  -- Page 2501 with 20 records per page

-- Test 8: Aggregation by categories
\echo '\n=== TEST 8: Category Aggregation Performance ==='
\echo 'Testing GROUP BY operations on large dataset'

SELECT 
    property_type,
    city,
    count(*) as property_count,
    avg(price)::decimal(10,2) as avg_price,
    min(price)::decimal(10,2) as min_price,
    max(price)::decimal(10,2) as max_price
FROM property_data.unified_properties
WHERE status = 'Active'
GROUP BY property_type, city
HAVING count(*) > 1000
ORDER BY property_count DESC
LIMIT 20;

-- Test 9: Window functions performance
\echo '\n=== TEST 9: Window Functions Performance ==='
\echo 'Testing analytical functions on large dataset'

SELECT 
    'Window Functions' as test_name,
    count(*) as total_analyzed,
    avg(price_rank)::decimal(8,2) as avg_price_rank,
    avg(city_price_rank)::decimal(8,2) as avg_city_rank
FROM (
    SELECT 
        id,
        price,
        city,
        row_number() OVER (ORDER BY price DESC) as price_rank,
        row_number() OVER (PARTITION BY city ORDER BY price DESC) as city_price_rank
    FROM property_data.unified_properties
    WHERE status = 'Active'
    LIMIT 10000  -- Sample for performance
) ranked_properties;

-- Test 10: Neighborhoods table performance
\echo '\n=== TEST 10: Neighborhoods Performance ===' 
\echo 'Testing neighborhood-based queries'

SELECT 
    'Neighborhood Analysis' as test_name,
    count(*) as total_neighborhoods,
    count(DISTINCT substring(name from '^[A-Za-z ]+')) as unique_neighborhood_types,
    avg(ST_Area(location_polygon::geometry)) as avg_area_degrees
FROM property_data.neighborhoods;

-- Test spatial relationships between neighborhoods and properties
\echo 'Testing spatial joins between neighborhoods and properties'

SELECT 
    'Spatial Join Analysis' as test_name,
    count(*) as properties_in_neighborhoods,
    count(DISTINCT n.id) as neighborhoods_with_properties,
    avg(property_count) as avg_properties_per_neighborhood
FROM (
    SELECT 
        n.id,
        n.name,
        count(p.id) as property_count
    FROM property_data.neighborhoods n
    LEFT JOIN property_data.unified_properties p 
        ON ST_Contains(n.location_polygon::geometry, p.location_point::geometry)
    GROUP BY n.id, n.name
    HAVING count(p.id) > 0
    LIMIT 100  -- Sample for performance
) neighborhood_stats, property_data.neighborhoods n
WHERE neighborhood_stats.id = n.id;

-- Test 11: Index usage verification
\echo '\n=== TEST 11: Index Usage Analysis ==='
\echo 'Checking index effectiveness'

EXPLAIN (ANALYZE, BUFFERS) 
SELECT count(*) 
FROM property_data.unified_properties 
WHERE price BETWEEN 800000 AND 1200000 
AND amenities->'indoor' ? 'Smart Home System';

\echo '\n============================================='
\echo 'Performance Testing Complete!'
\echo 'All tests executed on 1 million record dataset'
\echo '============================================='