-- ProtonBase Consolidated Demo Setup Script
-- This script creates a denormalized schema for the ProtonBase demo
-- showing how ProtonBase can handle multiple data types in a single table

-- Use the default postgres database
-- We'll create our schema and tables there

-- Enable required extensions
-- Note: These extensions are available in ProtonBase but may not be installed on this system
CREATE EXTENSION postgis; -- For PostGIS

-- Create schema
CREATE SCHEMA IF NOT EXISTS property_data;

-- Create a single denormalized table that includes all data types
-- This demonstrates how ProtonBase can store and query multiple data types in one table
-- Use Hybrid Table
CREATE TABLE property_data.unified_properties (
    -- Relational data
    id SERIAL PRIMARY KEY,
    title VARCHAR(255) NOT NULL,
    address VARCHAR(255) NOT NULL,
    city VARCHAR(100) NOT NULL,
    state VARCHAR(50) NOT NULL,
    zip_code VARCHAR(20) NOT NULL,
    price DECIMAL(10, 2) NOT NULL,
    bedrooms INT NOT NULL,
    bathrooms DECIMAL(3, 1) NOT NULL,
    square_feet INT NOT NULL,
    year_built INT,
    property_type VARCHAR(50) NOT NULL,
    listing_date DATE NOT NULL,
    status VARCHAR(20) NOT NULL,

    -- JSON data for property features and amenities
    amenities JSONB NOT NULL,
    features JSONB NOT NULL,

    -- Text data for full-text search
    description TEXT NOT NULL,
    description_tsv TSVECTOR GENERATED ALWAYS AS (to_tsvector('english', description)) STORED,

    -- Geospatial data
    location_point GEOGRAPHY(POINT, 4326),

    -- Vector data
    embedding vector(384) NOT NULL,

    -- Metadata
    created_at TIMESTAMP WITH TIME ZONE DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMP WITH TIME ZONE DEFAULT CURRENT_TIMESTAMP
) USING HYBRID;

-- Create indexes for better performance
-- Each index optimizes a different type of query

-- Global-secondary indexes
CREATE INDEX idx_unified_properties_price ON property_data.unified_properties(price);

-- Bitmap indexes
-- Use default adaptive bitmap indexes.

-- JSON data indexes
CREATE INDEX idx_unified_properties_amenities ON property_data.unified_properties USING SPLIT_GIN(amenities);
CREATE INDEX idx_unified_properties_features ON property_data.unified_properties USING SPLIT_GIN(features);

-- Full-text search index
CREATE INDEX idx_unified_properties_description_tsv ON property_data.unified_properties USING SPLIT_GIN(description_tsv);

-- Vector similarity search index
CREATE INDEX idx_unified_properties_embedding ON property_data.unified_properties USING SPLIT_HNSW (embedding vector_l2_ops) WITH (m=16, ef_construction = 64);

-- Create neighborhoods table for geospatial queries
CREATE TABLE property_data.neighborhoods (
    id SERIAL PRIMARY KEY,
    name VARCHAR(100) NOT NULL,
    location_polygon GEOGRAPHY(POLYGON, 4326),
    created_at TIMESTAMP WITH TIME ZONE DEFAULT CURRENT_TIMESTAMP
) using hybrid;

-- Print success message
\echo 'ProtonBase consolidated schema created successfully!'
\echo 'This schema demonstrates how ProtonBase can store and query multiple data types in a single table.'