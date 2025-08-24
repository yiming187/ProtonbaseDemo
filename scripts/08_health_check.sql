-- ProtonBase Demo Health Check Script
-- This script verifies system health and data integrity

\\timing on

\\echo '=============================================='
\\echo 'ProtonBase Demo Health Check'
\\echo '=============================================='

-- Check database connection and version
\\echo '\\n=== DATABASE CONNECTION CHECK ==='
SELECT 
    'Connection Status' as check_name,
    'SUCCESS' as status,
    version() as database_version;

-- Check schema existence
\\echo '\\n=== SCHEMA VALIDATION ==='
SELECT 
    'Schema Check' as check_name,
    CASE 
        WHEN EXISTS (SELECT 1 FROM information_schema.schemata WHERE schema_name = 'property_data') 
        THEN 'PASS' 
        ELSE 'FAIL' 
    END as status,
    'property_data schema exists' as description;

-- Check table existence and structure
\\echo '\\n=== TABLE STRUCTURE VALIDATION ==='
SELECT 
    'Table Check' as check_name,
    CASE 
        WHEN COUNT(*) = 2 THEN 'PASS'
        ELSE 'FAIL'
    END as status,
    COUNT(*) as tables_found,
    'Expected: unified_properties, neighborhoods' as description
FROM information_schema.tables 
WHERE table_schema = 'property_data' 
    AND table_name IN ('unified_properties', 'neighborhoods');

-- Check index existence
\\echo '\\n=== INDEX VALIDATION ==='
SELECT 
    'Index Check' as check_name,
    CASE 
        WHEN COUNT(*) >= 5 THEN 'PASS'
        ELSE 'FAIL'
    END as status,
    COUNT(*) as indexes_found,
    'Checking critical indexes' as description
FROM pg_indexes 
WHERE schemaname = 'property_data';

-- Check data integrity
\\echo '\\n=== DATA INTEGRITY CHECK ==='
SELECT 
    'Data Integrity' as check_name,
    CASE 
        WHEN COUNT(*) > 0 THEN 'PASS'
        ELSE 'FAIL'
    END as status,
    COUNT(*) as total_properties,
    'Properties table has data' as description
FROM property_data.unified_properties;

-- Check for null values in critical fields
\\echo '\\n=== NULL VALUE CHECK ==='
SELECT 
    'NULL Check' as check_name,
    CASE 
        WHEN COUNT(*) = 0 THEN 'PASS'
        ELSE 'WARN'
    END as status,
    COUNT(*) as null_values_found,
    'Critical fields should not be null' as description
FROM property_data.unified_properties 
WHERE title IS NULL 
    OR price IS NULL 
    OR location_point IS NULL 
    OR embedding IS NULL;

-- Check vector dimension consistency
\\echo '\\n=== VECTOR DIMENSION CHECK ==='
SELECT 
    'Vector Dimensions' as check_name,
    CASE 
        WHEN MIN(array_length(embedding, 1)) = MAX(array_length(embedding, 1)) 
            AND MIN(array_length(embedding, 1)) = 384 
        THEN 'PASS'
        ELSE 'FAIL'
    END as status,
    MIN(array_length(embedding, 1)) as min_dimensions,
    MAX(array_length(embedding, 1)) as max_dimensions,
    'All vectors should be 384-dimensional' as description
FROM property_data.unified_properties 
WHERE embedding IS NOT NULL;

-- Check JSON data validity
\\echo '\\n=== JSON DATA VALIDATION ==='
SELECT 
    'JSON Validity' as check_name,
    CASE 
        WHEN COUNT(*) = 0 THEN 'PASS'
        ELSE 'WARN'
    END as status,
    COUNT(*) as invalid_json_count,
    'All JSON fields should be valid' as description
FROM property_data.unified_properties 
WHERE NOT (amenities::text)::json IS NOT NULL 
    OR NOT (features::text)::json IS NOT NULL;

-- Check geographic data validity
\\echo '\\n=== GEOGRAPHIC DATA VALIDATION ==='
SELECT 
    'Geographic Validity' as check_name,
    CASE 
        WHEN COUNT(*) = 0 THEN 'PASS'
        ELSE 'WARN'
    END as status,
    COUNT(*) as invalid_geometry_count,
    'All location points should be valid' as description
FROM property_data.unified_properties 
WHERE location_point IS NOT NULL 
    AND NOT ST_IsValid(location_point::geometry);

-- Performance baseline check
\\echo '\\n=== PERFORMANCE BASELINE ==='
SELECT 
    'Query Performance' as check_name,
    'INFO' as status,
    COUNT(*) as total_records,
    'Current dataset size for performance reference' as description
FROM property_data.unified_properties;

\\echo '\\n=== HEALTH CHECK SUMMARY ==='
\\echo 'Health check completed. Review any FAIL or WARN status items above.'
\\echo 'All PASS items indicate healthy system components.'

\\timing off