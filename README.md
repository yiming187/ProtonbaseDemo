# ProtonBase Demo

This repository contains the demo files for ProtonBase, a unified multi-modal database that combines relational, JSON, text, geospatial, and vector data types in a single database.

## Overview

ProtonBase is a next-generation database that eliminates data silos by supporting multiple data types in a single platform:

- **Relational data** - Traditional structured data with ACID transactions
- **JSON data** - Flexible schema design for semi-structured data
- **Text data** - Full-text search with ranking and highlighting
- **Geospatial data** - Location-based queries and spatial analysis
- **Vector data** - Similarity search for AI and machine learning applications

## Repository Contents

### Scripts

- `01_setup.sql` - Creates the database schema and tables
- `02_load_data.sql` - Loads sample property data into the database
- `03_unified_query.sql` - Basic unified multi-modal query examples
- `03_unified_query_enhanced.sql` - Advanced unified multi-modal query examples
- `04_cleanup.sql` - Cleans up the database after the demo

### Presentation

- `presentation.md` - Slide deck for presenting the ProtonBase demo
- `vector_search_explanation.md` - Detailed explanation of vector search functionality

### Data

- `sample_properties.json` - Sample property data used in the demo

## Getting Started

1. Install ProtonBase following the instructions at [protonbase.io/install](https://protonbase.io/install)
2. Clone this repository
3. Run the setup script: `psql -f scripts/01_setup.sql`
4. Load the sample data: `psql -f scripts/02_load_data.sql`
5. Run the example queries: `psql -f scripts/03_unified_query.sql`
6. Try the advanced queries: `psql -f scripts/03_unified_query_enhanced.sql`
7. Clean up when finished: `psql -f scripts/04_cleanup.sql`

## Key Features Demonstrated

### 1. Unified Data Model

The demo shows how to create a unified data model that combines multiple data types:

```sql
CREATE TABLE property_data.unified_properties (
    -- Relational data
    id SERIAL PRIMARY KEY,
    title VARCHAR(255) NOT NULL,
    price DECIMAL(10, 2) NOT NULL,
    
    -- JSON data for flexible attributes
    amenities JSONB NOT NULL,
    features JSONB NOT NULL,
    
    -- Text data with vector for search
    description TEXT NOT NULL,
    description_tsv TSVECTOR GENERATED ALWAYS AS 
        (to_tsvector('english', description)) STORED,
    
    -- Geospatial data
    location GEOMETRY(POINT, 4326) NOT NULL,
    
    -- Vector data for similarity search
    embedding VECTOR(384) NOT NULL
);
```

### 2. Multi-Modal Queries

The demo includes examples of multi-modal queries that combine different data types:

```sql
SELECT 
    -- Relational data
    p.id, p.title, p.price,
    
    -- JSON data
    p.amenities->'indoor' AS indoor_amenities,
    
    -- Full-text search with highlighting
    ts_headline(p.description, query) AS highlighted_text,
    
    -- Geospatial data
    ST_Distance(p.location::geography, point) / 1609.344 AS miles_from_downtown,
    
    -- Vector similarity
    1 - (p.embedding <=> vector) AS style_match_score
FROM 
    property_data.unified_properties p
WHERE 
    -- Text search condition
    p.description_tsv @@ query
    
    -- JSON condition
    AND p.amenities->'indoor' ? 'Smart Home System'
    
    -- Geospatial condition
    AND ST_DWithin(p.location::geography, point, 16093.4)
    
    -- Vector similarity condition
    AND (p.embedding <=> vector) < 0.5;
```

### 3. Personalized Recommendations

The demo shows how to create personalized property recommendations using vector similarity search:

```sql
-- Get the reference property the client loves
WITH user_interest AS (
    SELECT id, embedding, amenities, features, location
    FROM property_data.unified_properties
    WHERE id = 1  -- The property the client is viewing
)

SELECT 
    p.id, p.title,
    1 - (p.embedding <=> ui.embedding) AS style_similarity
FROM 
    property_data.unified_properties p,
    user_interest ui
WHERE 
    p.id != ui.id  -- Exclude the reference property
ORDER BY 
    style_similarity DESC
LIMIT 3;  -- Show the top 3 recommendations
```

## Business Benefits

- **Simplified Architecture** - One database instead of multiple specialized systems
- **No Data Synchronization** - All data types in a single platform
- **Lower Infrastructure Costs** - Fewer systems to maintain and scale
- **Faster Development** - No need to integrate multiple databases
- **Better User Experience** - Faster, more intuitive search and recommendations

## License

This demo is provided for educational purposes only. ProtonBase is a commercial product.

## Contact

For more information about ProtonBase, visit [protonbase.io](https://protonbase.io) or contact info@protonbase.io.