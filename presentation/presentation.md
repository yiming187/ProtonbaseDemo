---
marp: true
theme: default
paginate: true
backgroundColor: #fff
---

<!-- 
_class: lead
_backgroundColor: #1a237e
_color: white
-->

# ProtonBase: One Database for All Your Data Types

## Unified Multi-Modal Database for Modern Applications

---

<!-- 
_backgroundColor: #f5f5f5
-->

# The Problem: Data Silos in Modern Applications

![bg right:40% 80%](https://via.placeholder.com/800x600/ffffff/000000?text=Data+Silos)

- **Today's applications need multiple data types:**
  - Structured data (users, transactions, products)
  - Semi-structured data (JSON for flexible attributes)
  - Text data (search, content, descriptions)
  - Geospatial data (locations, routes, boundaries)
  - Vector data (embeddings for AI/ML features)

- **Traditional solution: Multiple specialized databases**
  - Each optimized for a specific data type
  - Results in complex architecture and high costs

---

<!-- 
_backgroundColor: #e8f5e9
-->

# The Business Impact of Data Silos

![bg right:40% 80%](https://via.placeholder.com/800x600/ffffff/000000?text=Business+Impact)

- **Increased Infrastructure Costs**
  - Multiple database licenses and infrastructure

- **Complex Data Synchronization**
  - Keeping data consistent across systems
  - Latency issues and potential inconsistencies

- **Development Complexity**
  - Engineers need expertise in multiple systems
  - Complex integration code and error handling

- **Operational Overhead**
  - Multiple systems to monitor and maintain
  - Different backup, scaling, and security models

---

<!-- 
_backgroundColor: #e3f2fd
-->

# The Solution: ProtonBase

![bg right:40% 80%](https://via.placeholder.com/800x600/ffffff/000000?text=ProtonBase)

- **One database for all data types:**
  - Relational data with ACID transactions
  - JSON data with flexible schema
  - Full-text search with ranking and highlighting
  - Geospatial data with spatial indexing
  - Vector data with similarity search

- **Benefits:**
  - Simplified architecture
  - No data synchronization issues
  - Lower infrastructure costs
  - Easier to maintain and scale
  - Faster development cycles

---

<!-- 
_backgroundColor: #fff3e0
-->

# Case Study: Elite Properties Luxury Real Estate Platform

![bg right:40% 80%](https://via.placeholder.com/800x600/ffffff/000000?text=Elite+Properties)

## The Challenge

Elite Properties is a premium real estate platform catering to high-net-worth individuals looking for luxury properties. Their clients expect personalized recommendations and sophisticated search capabilities.

## Previous Architecture

- PostgreSQL for property details
- MongoDB for flexible property features and amenities
- Elasticsearch for text search
- PostGIS for location-based search
- Pinecone for vector similarity search

---

<!-- 
_backgroundColor: #f3e5f5
-->

# Elite Properties: The Problems with Multiple Databases

![bg right:40% 80%](https://via.placeholder.com/800x600/ffffff/000000?text=Problems)

- **Data Synchronization Issues**
  - Property updates had to propagate to 5 different systems
  - Inconsistencies led to poor user experience

- **High Infrastructure Costs**
  - Multiple database licenses and infrastructure
  - Specialized expertise required for each system

- **Complex Development**
  - Engineers spent more time on integration than features
  - New features required changes to multiple systems

- **Slow Query Performance**
  - Multi-database queries required multiple network hops
  - Client-side joining of results was inefficient

---

<!-- 
_backgroundColor: #e0f7fa
-->

# Elite Properties: Migration to ProtonBase

![bg right:40% 80%](https://via.placeholder.com/800x600/ffffff/000000?text=Migration)

- **Unified Data Model**
  - Single table with all property data
  - Generated columns for efficient indexing

- **Simplified Architecture**
  - One database instead of five
  - No need for complex ETL processes

- **Improved Development**
  - Developers focus on features, not integration
  - Faster iteration cycles

- **Enhanced Performance**
  - Single query instead of multiple queries
  - No client-side joining or processing

---

<!-- 
_backgroundColor: #e8eaf6
-->

# Unified Data Model

```sql
CREATE TABLE property_data.unified_properties (
    -- Relational data
    id SERIAL PRIMARY KEY,
    title VARCHAR(255) NOT NULL,
    price DECIMAL(10, 2) NOT NULL,
    bedrooms INT NOT NULL,
    
    -- JSON data for flexible attributes
    amenities JSONB NOT NULL,
    features JSONB NOT NULL,
    
    -- Text data with vector for search
    description TEXT NOT NULL,
    description_tsv TSVECTOR GENERATED ALWAYS AS 
        (to_tsvector('english', description)) STORED,
    
    -- Geospatial data
    latitude DECIMAL(10, 8) NOT NULL,
    longitude DECIMAL(11, 8) NOT NULL,
    location GEOMETRY(POINT, 4326) GENERATED ALWAYS AS 
        (ST_SetSRID(ST_MakePoint(longitude, latitude), 4326)) STORED,
    
    -- Vector data for similarity search
    embedding VECTOR(384) NOT NULL
);
```

---

<!-- 
_backgroundColor: #f9fbe7
-->

# Use Case 1: The Executive Search

![bg right:40% 80%](https://via.placeholder.com/800x600/ffffff/000000?text=Executive+Search)

## Scenario

A C-level tech executive is relocating to Seattle and needs a luxury property that meets very specific requirements:

- High-end property with smart home features
- Located near downtown Seattle (for commuting)
- Must have a gourmet kitchen and great views
- Matches their personal style preferences

## Challenge

How can we combine all these different search criteria into a single, personalized search experience?

---

<!-- 
_backgroundColor: #fff3e0
-->

# The Executive Search: Multi-Modal Query

```sql
SELECT 
    -- Basic property information (relational data)
    p.id, p.title, p.price, p.bedrooms,
    
    -- Smart home features (JSON data)
    p.amenities->'indoor' AS indoor_amenities,
    p.features->'interior'->'kitchen'->'type' AS kitchen_type,
    
    -- Description highlights (text search)
    ts_headline(p.description, query, 'StartSel=<b>, StopSel=</b>') AS highlighted_text,
    
    -- Distance to downtown (geospatial)
    ST_Distance(p.location::geography, downtown_point) / 1609.344 AS miles_from_downtown,
    
    -- Style match score (vector similarity)
    1 - (p.embedding <=> style_vector) AS style_match_score,
    
    -- Combined relevance score (weighted ranking)
    (ts_rank(p.description_tsv, query) * 0.3 +
     (1 - (p.embedding <=> style_vector)) * 0.3 +
     (1 - LEAST(ST_Distance(p.location::geography, downtown_point) / 10000, 1)) * 0.2 +
     (1 - (p.price / 5000000)) * 0.1 +
     (jsonb_array_length(p.amenities->'indoor')) / 20.0 * 0.1) AS overall_score
FROM property_data.unified_properties p
WHERE 
    -- Text search: Luxury properties with kitchens and views
    p.description_tsv @@ to_tsquery('english', 'luxury & kitchen & view')
    
    -- JSON search: Must have smart home system
    AND p.amenities->'indoor' ? 'Smart Home System'
    
    -- Geospatial search: Within 10 miles of downtown
    AND ST_DWithin(p.location::geography, downtown_point, 16093.4)
    
    -- Relational filters: Price and size requirements
    AND p.price BETWEEN 1000000 AND 5000000
    AND p.bedrooms >= 3
    
    -- Vector similarity: Must match style preferences
    AND (p.embedding <=> style_vector) < 0.5
ORDER BY overall_score DESC;
```

---

<!-- 
_backgroundColor: #e0f7fa
-->

# The Power of Vector Search

![bg right:40% 80%](https://via.placeholder.com/800x600/ffffff/000000?text=Vector+Search)

## What are Vector Embeddings?

- Mathematical representations of content in high-dimensional space
- Capture semantic meaning and subtle characteristics
- Enable "fuzzy" matching beyond exact keywords

## Business Value in Real Estate

- **Capture the "feel" of a property**
  - Modern vs. traditional, cozy vs. spacious
  - Design aesthetics that are hard to express in words
  
- **Personalized recommendations**
  - Match properties to client's taste based on viewing history
  - "I can't describe it, but I know it when I see it"

---

<!-- 
_backgroundColor: #f3e5f5
-->

# Use Case 2: "More Like This" Recommendations

![bg right:40% 80%](https://via.placeholder.com/800x600/ffffff/000000?text=More+Like+This)

## Scenario

A client has found a property they love (Property ID 1) but it's already under contract. They want to find similar properties.

## Challenge

How do we define "similar" across multiple dimensions?
- Similar style and aesthetics
- Similar amenities and features
- Similar location and neighborhood
- Similar price range and property type

## Solution

Use vector similarity as the primary factor, combined with other data types

---

<!-- 
_backgroundColor: #e8f5e9
-->

# "More Like This" Query

```sql
-- Get the reference property the client loves
WITH user_interest AS (
    SELECT id, embedding, amenities, features, location, property_type, price
    FROM property_data.unified_properties
    WHERE id = 1  -- The property the client is viewing
)

SELECT 
    -- Property details
    p.id, p.title, p.address, p.price, p.bedrooms,
    
    -- Similarity scores
    1 - (p.embedding <=> ui.embedding) AS style_similarity,
    
    -- Common amenities count
    (SELECT COUNT(*) FROM jsonb_array_elements_text(p.amenities->'indoor') AS p_amenity
     WHERE EXISTS (SELECT 1 FROM jsonb_array_elements_text(ui.amenities->'indoor') 
                  AS ui_amenity WHERE p_amenity = ui_amenity)) AS common_amenities,
    
    -- Distance between properties
    ST_Distance(p.location::geography, ui.location::geography) / 1609.344 AS distance_miles,
    
    -- Overall similarity score (weighted)
    ((1 - (p.embedding <=> ui.embedding)) * 0.4 +  -- Style similarity (40%)
     [amenities similarity calculation] * 0.2 +    -- Amenities (20%)
     [location proximity calculation] * 0.2 +      -- Location (20%)
     [property type match] * 0.1 +                 -- Property type (10%)
     [price similarity calculation] * 0.1          -- Price range (10%)
    ) AS overall_similarity
FROM property_data.unified_properties p, user_interest ui
WHERE p.id != ui.id  -- Exclude the reference property
ORDER BY overall_similarity DESC
LIMIT 3;  -- Show the top 3 recommendations
```

---

<!-- 
_backgroundColor: #e3f2fd
-->

# Business Impact: Before vs. After

| Metric | Before ProtonBase | After ProtonBase | Improvement |
|--------|------------------|-----------------|-------------|
| Infrastructure Costs | $25,000/month | $8,000/month | 68% reduction |
| Data Sync Latency | 2-5 minutes | 0 (real-time) | 100% improvement |
| Query Response Time | 800-1200ms | 150-250ms | 80% faster |
| Development Velocity | 3 weeks/feature | 1 week/feature | 67% faster |
| User Engagement | 4.2 min avg session | 7.8 min avg session | 86% increase |
| Conversion Rate | 2.3% | 3.8% | 65% increase |

---

<!-- 
_backgroundColor: #fff3e0
-->

# Why Vector Search is a Game-Changer

![bg right:40% 80%](https://via.placeholder.com/800x600/ffffff/000000?text=Game+Changer)

## Traditional Search Limitations

- Keyword matching misses semantic meaning
- Structured filters are too rigid
- Can't capture subjective qualities

## Vector Search Benefits

- **Captures the "unspeakable"**
  - Subtle qualities that users can't articulate
  - "I know it when I see it" preferences

- **Learns from user behavior**
  - Embeddings can be trained on user interactions
  - Improves over time with more data

- **Enables truly personalized experiences**
  - Each user gets results tailored to their taste
  - Higher engagement and conversion rates

---

<!-- 
_backgroundColor: #f9fbe7
-->

# Beyond Real Estate: Other Use Cases

![bg right:40% 80%](https://via.placeholder.com/800x600/ffffff/000000?text=Other+Use+Cases)

## E-commerce
- Product recommendations based on visual style
- Search by image + text + filters

## Content Platforms
- Article recommendations based on reading history
- Multi-modal content discovery

## Financial Services
- Risk assessment using multiple data types
- Fraud detection combining structured and unstructured data

## Healthcare
- Patient similarity for treatment recommendations
- Medical image search with metadata

---

<!-- 
_backgroundColor: #e0f7fa
-->

# Implementation Roadmap

![bg right:40% 80%](https://via.placeholder.com/800x600/ffffff/000000?text=Roadmap)

## Phase 1: Data Consolidation (1-2 months)
- Unified schema design
- Data migration from existing systems

## Phase 2: Basic Multi-Modal Queries (2-3 weeks)
- Implement basic search functionality
- Optimize indexes for performance

## Phase 3: Advanced Features (3-4 weeks)
- Vector embedding generation
- Personalized recommendation engine

## Phase 4: Optimization & Scaling (Ongoing)
- Performance tuning
- Monitoring and maintenance

---

<!-- 
_backgroundColor: #f3e5f5
-->

# Key Takeaways

![bg right:40% 80%](https://via.placeholder.com/800x600/ffffff/000000?text=Key+Takeaways)

1. **Unified Data Model**
   - One database for all your data types
   - Eliminates data silos and synchronization issues

2. **Multi-Modal Queries**
   - Combine different data types in a single query
   - Create sophisticated ranking algorithms

3. **Business Benefits**
   - Lower infrastructure costs
   - Faster development cycles
   - Better user experience
   - Higher engagement and conversion rates

4. **Vector Search Value**
   - Capture subtle preferences that keywords can't express
   - Enable truly personalized experiences

---

<!-- 
_class: lead
_backgroundColor: #1a237e
_color: white
-->

# ProtonBase: One Database for All Your Data Types

## Transform Your Data Architecture Today

### Questions?