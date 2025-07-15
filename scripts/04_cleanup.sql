-- ProtonBase Consolidated Demo Cleanup Script (Simplified)
-- This script cleans up the database after the demo

-- Drop the tables and schema
DROP TABLE IF EXISTS property_data.unified_properties CASCADE;
DROP TABLE IF EXISTS property_data.neighborhoods CASCADE;
DROP SCHEMA IF EXISTS property_data CASCADE;

-- Print success message
\echo 'Cleanup complete!'