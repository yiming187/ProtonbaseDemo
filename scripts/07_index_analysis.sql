-- ProtonBase Index Optimization and Analysis Script
-- This script checks index usage and suggests optimizations

\\timing on

\\echo '=============================================='
\\echo 'ProtonBase Index Usage Analysis'
\\echo '=============================================='

-- Check table sizes
\\echo '\\n=== TABLE SIZE ANALYSIS ==='
SELECT 
    schemaname,
    tablename,
    pg_size_pretty(pg_total_relation_size(schemaname||'.'||tablename)) as total_size,
    pg_size_pretty(pg_relation_size(schemaname||'.'||tablename)) as table_size,
    pg_size_pretty(pg_total_relation_size(schemaname||'.'||tablename) - pg_relation_size(schemaname||'.'||tablename)) as index_size
FROM pg_tables 
WHERE schemaname = 'property_data'
ORDER BY pg_total_relation_size(schemaname||'.'||tablename) DESC;

-- Check index usage statistics
\\echo '\\n=== INDEX USAGE STATISTICS ==='
SELECT 
    schemaname,
    tablename,
    indexname,
    idx_scan as index_scans,
    idx_tup_read as tuples_read,
    idx_tup_fetch as tuples_fetched,
    pg_size_pretty(pg_relation_size(indexrelid)) as index_size
FROM pg_stat_user_indexes 
WHERE schemaname = 'property_data'
ORDER BY idx_scan DESC;

-- Check for unused indexes
\\echo '\\n=== POTENTIALLY UNUSED INDEXES ==='
SELECT 
    schemaname,
    tablename,
    indexname,
    idx_scan,
    pg_size_pretty(pg_relation_size(indexrelid)) as index_size
FROM pg_stat_user_indexes 
WHERE schemaname = 'property_data' 
    AND idx_scan = 0
ORDER BY pg_relation_size(indexrelid) DESC;

-- Analyze query performance for common patterns
\\echo '\\n=== QUERY PERFORMANCE ANALYSIS ==='

-- Test price range query performance
EXPLAIN (ANALYZE, BUFFERS) 
SELECT count(*) 
FROM property_data.unified_properties 
WHERE price BETWEEN 500000 AND 2000000;

-- Test JSON query performance
EXPLAIN (ANALYZE, BUFFERS)
SELECT count(*) 
FROM property_data.unified_properties 
WHERE amenities->'indoor' ? 'Air Conditioning';

-- Test full-text search performance
EXPLAIN (ANALYZE, BUFFERS)
SELECT count(*) 
FROM property_data.unified_properties 
WHERE description_tsv @@ to_tsquery('english', 'luxury');

-- Test geospatial query performance
EXPLAIN (ANALYZE, BUFFERS)
SELECT count(*) 
FROM property_data.unified_properties 
WHERE ST_DWithin(
    location_point, 
    ST_SetSRID(ST_MakePoint(-122.3321, 47.6062), 4326)::geography, 
    16093.4
);

-- Test vector similarity performance
EXPLAIN (ANALYZE, BUFFERS)
SELECT count(*) 
FROM property_data.unified_properties 
WHERE (embedding <=> (SELECT embedding FROM property_data.unified_properties LIMIT 1)) < 0.5;

\\echo '\\n=== OPTIMIZATION RECOMMENDATIONS ==='
\\echo 'Check the above query plans for:'
\\echo '1. Sequential scans that should use indexes'
\\echo '2. High buffer usage indicating I/O bottlenecks'
\\echo '3. Unused indexes that can be dropped'
\\echo '4. Missing indexes for frequently queried columns'

\\timing off