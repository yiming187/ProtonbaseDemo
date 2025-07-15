-- ProtonBase Consolidated Demo Setup Script
-- This script creates a denormalized schema for the ProtonBase demo
-- showing how ProtonBase can handle multiple data types in a single table

-- Use the default postgres database
-- We'll create our schema and tables there

-- Enable required extensions
-- Note: These extensions are available in ProtonBase but may not be installed on this system
-- We'll use pg_trgm for text search, but simulate the other extensions
CREATE EXTENSION IF NOT EXISTS pg_trgm;  -- For text search
-- PostGIS and vector extensions are not available, so we'll use simpler types

-- Create schema
CREATE SCHEMA IF NOT EXISTS property_data;

-- Create a single denormalized table that includes all data types
-- This demonstrates how ProtonBase can store and query multiple data types in one table
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
    
    -- Geospatial data (simplified without PostGIS)
    latitude DECIMAL(10, 8) NOT NULL,
    longitude DECIMAL(11, 8) NOT NULL,
    -- location field removed as it requires PostGIS
    
    -- Vector data (simplified without vector extension)
    embedding TEXT NOT NULL, -- Store as JSON array text instead of VECTOR type
    
    -- Metadata
    created_at TIMESTAMP WITH TIME ZONE DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMP WITH TIME ZONE DEFAULT CURRENT_TIMESTAMP
);

-- Create indexes for better performance
-- Each index optimizes a different type of query

-- Relational data indexes
CREATE INDEX idx_unified_properties_property_type ON property_data.unified_properties(property_type);
CREATE INDEX idx_unified_properties_status ON property_data.unified_properties(status);
CREATE INDEX idx_unified_properties_price ON property_data.unified_properties(price);
CREATE INDEX idx_unified_properties_bedrooms ON property_data.unified_properties(bedrooms);

-- JSON data indexes
CREATE INDEX idx_unified_properties_amenities ON property_data.unified_properties USING GIN(amenities);
CREATE INDEX idx_unified_properties_features ON property_data.unified_properties USING GIN(features);

-- Full-text search index
CREATE INDEX idx_unified_properties_description_tsv ON property_data.unified_properties USING GIN(description_tsv);

-- Geospatial index removed as it requires PostGIS

-- Vector similarity search index removed as it requires vector extension

-- Create a function to update the updated_at column
CREATE OR REPLACE FUNCTION update_updated_at_column()
RETURNS TRIGGER AS $$
BEGIN
    NEW.updated_at = CURRENT_TIMESTAMP;
    RETURN NEW;
END;
$$ LANGUAGE plpgsql;

-- Create trigger to automatically update the updated_at column
CREATE TRIGGER update_unified_properties_updated_at
BEFORE UPDATE ON property_data.unified_properties
FOR EACH ROW
EXECUTE FUNCTION update_updated_at_column();

-- Create neighborhoods table for geospatial queries (simplified without PostGIS)
CREATE TABLE property_data.neighborhoods (
    id SERIAL PRIMARY KEY,
    name VARCHAR(100) NOT NULL,
    -- boundary field removed as it requires PostGIS
    -- Using simple lat/lon bounds instead
    min_latitude DECIMAL(10, 8) NOT NULL,
    max_latitude DECIMAL(10, 8) NOT NULL,
    min_longitude DECIMAL(11, 8) NOT NULL,
    max_longitude DECIMAL(11, 8) NOT NULL,
    created_at TIMESTAMP WITH TIME ZONE DEFAULT CURRENT_TIMESTAMP
);

-- Create indexes on neighborhoods lat/lon bounds
CREATE INDEX idx_neighborhoods_lat ON property_data.neighborhoods(min_latitude, max_latitude);
CREATE INDEX idx_neighborhoods_lon ON property_data.neighborhoods(min_longitude, max_longitude);

-- Print success message
\echo 'ProtonBase consolidated schema created successfully!'
\echo 'This schema demonstrates how ProtonBase can store and query multiple data types in a single table.'