-- ProtonBase Consolidated Demo - Unified Multi-Modal Query
-- This script demonstrates how ProtonBase can query multiple data types in a single query
-- This is the key advantage of ProtonBase - no need for multiple databases

-- Connect to the postgres database
\c postgres;

-- Enable timing to show performance
\timing on

-- Password is already set via environment variable PGPASSWORD

-- =====================================================================
-- STORYLINE: LUXURY REAL ESTATE PLATFORM "ELITE PROPERTIES"
-- =====================================================================
-- Elite Properties is a premium real estate platform catering to high-net-worth
-- individuals looking for luxury properties. Their clients expect personalized
-- recommendations and sophisticated search capabilities.
--
-- The company previously used multiple specialized databases:
-- - PostgreSQL for property details
-- - MongoDB for flexible property features and amenities
-- - Elasticsearch for text search
-- - PostGIS for location-based search
-- - Pinecone for vector similarity search
--
-- This fragmented architecture caused:
-- - Complex data synchronization issues
-- - High infrastructure costs
-- - Slow query performance
-- - Difficult maintenance
--
-- By migrating to ProtonBase, they consolidated all data types into a single
-- database, enabling powerful multi-modal queries that were previously impossible
-- or extremely complex to implement.
-- =====================================================================

-- 1. BASIC UNIFIED QUERY: THE EXECUTIVE SEARCH
-- =====================================================================
-- STORYLINE: A C-level tech executive is relocating to Seattle and needs
-- a luxury property that meets very specific requirements. They want a
-- high-end property with smart home features, located near downtown,
-- with a gourmet kitchen and great views. The executive's personal style
-- preferences (represented by the vector embedding) also need to be considered.
-- =====================================================================

\echo '\n\n========== UNIFIED MULTI-MODAL QUERY: THE EXECUTIVE SEARCH ==========\n'
\echo 'This query demonstrates how ProtonBase can combine multiple data types in a single query:'
\echo '- Relational data (price, bedrooms, etc.)'
\echo '- JSON data (amenities, features)'
\echo '- Full-text search (description)'
\echo '- Geospatial data (location)'
\echo '- Vector similarity search (embedding)'
\echo '\nAll of this is done in a single database with a single query!\n'

-- Define a search vector for similarity search 
-- This represents the client's style preferences derived from their interaction history
-- In a real application, this would come from an embedding model analyzing the client's
-- previous property views, saved properties, and feedback
WITH search_vector AS (
    SELECT array_fill(0.036::float, ARRAY[384])::VECTOR(384) AS vector
),
-- Define a search query for full-text search
-- The client specifically mentioned wanting luxury properties with great kitchens and views
search_query AS (
    SELECT to_tsquery('english', 'luxury & kitchen & view') AS query
),
-- Define a reference point for geospatial search (Seattle downtown)
-- The client needs to be close to their new company headquarters in downtown Seattle
reference_point AS (
    SELECT ST_SetSRID(ST_MakePoint(-122.3321, 47.6062), 4326)::geography AS point
)

-- Main query combining all data types
SELECT 
    -- Relational data - Basic property information
    p.id,
    p.title,
    p.address,
    p.city,
    p.price,
    p.bedrooms,
    p.bathrooms,
    p.property_type,
    
    -- JSON data - Extract specific fields from nested JSON structures
    -- This allows for flexible schema design while maintaining queryability
    p.amenities->'indoor' AS indoor_amenities,
    p.features->'interior'->'kitchen'->'type' AS kitchen_type,
    
    -- Full-text search with highlighting - Makes it easy to see why a property matched
    ts_rank(p.description_tsv, sq.query) AS text_relevance,
    ts_headline('english', p.description, sq.query, 'StartSel=<b>, StopSel=</b>, MaxWords=50, MinWords=10') AS highlighted_text,
    
    -- Geospatial data - Calculate exact distance to downtown in miles
    ST_Distance(
        p.location_point::geography,
        rp.point
    ) / 1609.344 AS distance_miles,
    
    -- Vector similarity - Calculate how well the property matches the client's style preferences
    -- Higher values (closer to 1) indicate better style matches
    1 - (p.embedding <=> sv.vector) AS style_match_score,
    
    -- Combined relevance score (weighted combination of all factors)
    -- This creates a personalized ranking algorithm that balances all the client's preferences
    (
        -- Text relevance (30%) - How well the description matches the search terms
        ts_rank(p.description_tsv, sq.query) * 0.3 +
        
        -- Vector similarity (30%) - How well the property matches the client's style preferences
        -- This captures subtle aesthetic and design preferences that are hard to express in words
        (1 - (p.embedding <=> sv.vector)) * 0.3 +
        
        -- Inverse of normalized distance (20%) - Closer properties score higher
        -- The client needs to be within reasonable commuting distance to headquarters
        (1 - LEAST(ST_Distance(p.location_point::geography, rp.point) / 10000, 1)) * 0.2 +
        
        -- Price factor (10%) - Lower price gets higher score within the luxury range
        -- This rewards properties that offer better value while still meeting luxury standards
        (1 - (p.price / 5000000)) * 0.1 +
        
        -- Amenities factor (10%) - More amenities gets higher score
        -- This rewards properties with more comprehensive feature sets
        (jsonb_array_length(p.amenities->'indoor') + jsonb_array_length(p.amenities->'outdoor')) / 20.0 * 0.1
    ) AS combined_score
FROM 
    property_data.unified_properties p,
    search_vector sv,
    search_query sq,
    reference_point rp
WHERE 
    -- Full-text search condition: Find properties with luxury kitchens and views
    -- This filters properties based on their textual descriptions
    p.description_tsv @@ sq.query
    
    -- JSON condition: Must have smart home system (executive wants cutting-edge technology)
    -- This searches within the JSON structure without needing to create separate columns
    AND p.amenities->'indoor' ? 'Smart Home System'
    
    -- Geospatial condition: Within 10 miles of downtown Seattle headquarters
    -- This uses spatial indexing to efficiently find nearby properties
    AND ST_DWithin(
        p.location_point::geography,
        rp.point,
        16093.4  -- 10 miles in meters
    )
    
    -- Relational condition: Price and size requirements for an executive home
    -- Traditional SQL filtering on structured data
    AND p.price BETWEEN 1000000 AND 5000000  -- $1M to $5M price range
    AND p.bedrooms >= 3  -- At least 3 bedrooms for family and guests
    
    -- Vector similarity condition: Must align with client's style preferences
    -- This filters properties based on their style embedding similarity
    -- The threshold of 0.5 ensures only properties with reasonable style match are included
    AND (p.embedding <=> sv.vector) < 0.5
ORDER BY 
    -- Sort by the combined score to present the best overall matches first
    combined_score DESC;

-- 2. ADVANCED UNIFIED QUERY: THE NEIGHBORHOOD EXPERT
-- =====================================================================
-- STORYLINE: A luxury real estate agent specializing in Seattle neighborhoods
-- is helping a client who wants to live in a specific neighborhood. The agent
-- needs to find properties that match the client's requirements while also
-- providing neighborhood context to help the client understand the area.
-- =====================================================================

\echo '\n\n========== ADVANCED UNIFIED QUERY: THE NEIGHBORHOOD EXPERT ==========\n'
\echo 'This query adds neighborhood information to help clients understand the local context\n'

WITH search_vector AS (
    SELECT array_fill(0.036::float, ARRAY[384])::VECTOR(384) AS vector
),
search_query AS (
    SELECT to_tsquery('english', 'luxury & kitchen & view') AS query
),
reference_point AS (
    SELECT ST_GeomFromText('POINT(-122.3321 47.6062)',4326)::GEOGRAPHY AS point
)

SELECT 
    -- Relational data
    p.id,
    p.title,
    p.address,
    p.city,
    p.price,
    p.bedrooms,
    p.bathrooms,
    p.property_type,
    
    -- Neighborhood information - Critical context for location-conscious buyers
    -- This joins property locations with neighborhood boundaries using spatial relationships
    n.name AS neighborhood,
    
    -- JSON data - extract specific fields
    p.amenities->'indoor' AS indoor_amenities,
    p.features->'interior'->'kitchen'->'type' AS kitchen_type,
    
    -- Full-text search with highlighting
    ts_rank(p.description_tsv, sq.query) AS text_relevance,
    ts_headline('english', p.description, sq.query, 'StartSel=<b>, StopSel=</b>, MaxWords=50, MinWords=10') AS highlighted_text,
    
    -- Geospatial data - calculate distance
    ST_Distance(
        p.location_point::geography,
        rp.point
    ) / 1609.344 AS distance_miles,
    
    -- Vector similarity - calculate cosine similarity
    1 - (p.embedding <=> sv.vector) AS style_match_score,
    
    -- Combined relevance score
    (
        ts_rank(p.description_tsv, sq.query) * 0.3 +
        (1 - (p.embedding <=> sv.vector)) * 0.3 +
        (1 - LEAST(ST_Distance(p.location_point::geography, rp.point) / 10000, 1)) * 0.2 +
        (1 - (p.price / 5000000)) * 0.1 +
        (jsonb_array_length(p.amenities->'indoor') + jsonb_array_length(p.amenities->'outdoor')) / 20.0 * 0.1
    ) AS combined_score
FROM 
    -- Join properties with neighborhoods using spatial relationship
    -- This spatial join finds which neighborhood polygon contains each property point
    property_data.unified_properties p
    LEFT JOIN property_data.neighborhoods n ON ST_Contains(n.location_polygon::geometry, p.location_point::geometry),
    search_vector sv,
    search_query sq,
    reference_point rp
WHERE 
    -- Full-text search condition: Find properties with luxury kitchens and views
    p.description_tsv @@ sq.query
    
    -- JSON condition: Must have smart home system
    AND p.amenities->'indoor' ? 'Smart Home System'
    
    -- Geospatial condition: Within 10 miles of downtown Seattle
    AND ST_DWithin(
        p.location_point::geography,
        rp.point,
        16093.4  -- 10 miles in meters
    )
    
    -- Relational condition: Price and size requirements
    AND p.price BETWEEN 1000000 AND 5000000
    AND p.bedrooms >= 3
    
    -- Vector similarity condition: Must align with client's style preferences
    AND (p.embedding <=> sv.vector) < 0.5
ORDER BY 
    combined_score DESC;

-- 3. REAL-WORLD PROPERTY SEARCH: THE PERSONALIZED EXPERIENCE
-- =====================================================================
-- STORYLINE: Elite Properties' website allows clients to create detailed
-- preference profiles. This query demonstrates how a client's specific
-- preferences are translated into a sophisticated multi-modal query that
-- considers every aspect of their requirements.
--
-- The client is a tech executive who:
-- - Loves modern luxury homes with great views
-- - Needs at least 3 bedrooms and 2 bathrooms
-- - Has a budget of $1.5M to $3.5M
-- - Requires smart home technology and air conditioning
-- - Prefers high-end kitchen appliances (Wolf Range, Sub-Zero)
-- - Needs to be within 5 miles of downtown for commuting
-- - Prefers the Downtown Seattle neighborhood
-- - Has specific style preferences based on previously viewed properties
-- =====================================================================

\echo '\n\n========== REAL-WORLD PROPERTY SEARCH: THE PERSONALIZED EXPERIENCE ==========\n'
\echo 'This query simulates a real-world property search with detailed user preferences\n'

-- User preferences - In a real application, these would come from the user's profile
WITH user_preferences AS (
    SELECT
        'luxury modern view'::text AS search_terms,
        3::int AS min_bedrooms,
        2::int AS min_bathrooms,
        1500000::numeric AS min_price,
        3500000::numeric AS max_price,
        ARRAY['Smart Home System', 'Air Conditioning']::text[] AS required_amenities,
        ARRAY['Wolf Range', 'Sub-Zero Refrigerator']::text[] AS preferred_appliances,
        5::int AS max_miles_from_downtown,
        'Downtown Seattle'::text AS preferred_neighborhood,
        array_fill(0.036::float, ARRAY[384])::VECTOR(384) AS style_preference_vector
),
-- Derived search parameters - Transform user preferences into query parameters
search_params AS (
    SELECT
        -- Convert search terms to a proper tsquery for full-text search
        to_tsquery('english', regexp_replace(search_terms, '\s+', ' & ', 'g')) AS search_query,
        
        -- Define the downtown point for distance calculations
        ST_GeomFromText('POINT(-122.3321 47.6062)', 4326)::geography AS downtown_point,
        
        -- Pass through other preferences
        min_bedrooms,
        min_bathrooms,
        min_price,
        max_price,
        required_amenities,
        preferred_appliances,
        max_miles_from_downtown,
        preferred_neighborhood,
        style_preference_vector
    FROM user_preferences
)

SELECT 
    -- Property details - Basic information about each property
    p.id,
    p.title,
    p.address,
    p.city,
    p.price,
    p.bedrooms,
    p.bathrooms,
    p.square_feet,
    p.year_built,
    p.property_type,
    
    -- Neighborhood - Important for location-conscious buyers
    n.name AS neighborhood,
    
    -- Distance from downtown - Critical for commute time calculation
    ST_Distance(
        p.location_point,
        sp.downtown_point
    ) / 1609.344 AS miles_from_downtown,
    
    -- Matched amenities - Show which required amenities are present
    -- This extracts only the amenities that match the client's requirements
    (
        SELECT jsonb_agg(amenity)
        FROM jsonb_array_elements_text(p.amenities->'indoor') AS amenity
        WHERE amenity::text = ANY(sp.required_amenities)
    ) AS matched_amenities,
    
    -- Matched appliances - Show which preferred appliances are present
    -- This extracts only the appliances that match the client's preferences
    (
        SELECT jsonb_agg(appliance)
        FROM jsonb_array_elements_text(p.features->'interior'->'kitchen'->'appliances') AS appliance
        WHERE appliance::text = ANY(sp.preferred_appliances)
    ) AS matched_appliances,
    
    -- Relevance scores - Show why each property matched
    ts_rank(p.description_tsv, sp.search_query) AS text_relevance,
    1 - (p.embedding <=> sp.style_preference_vector) AS style_match,
    
    -- Highlighted description - Make it easy to see why the property matched
    ts_headline('english', p.description, sp.search_query, 'StartSel=<b>, StopSel=</b>, MaxWords=50, MinWords=10') AS highlighted_description,
    
    -- Overall match score (weighted combination of all factors)
    -- This creates a sophisticated personalized ranking algorithm
    (
        -- Text relevance (25%) - How well the description matches the search terms
        ts_rank(p.description_tsv, sp.search_query) * 0.25 +
        
        -- Style vector similarity (25%) - How well the property matches the client's style preferences
        -- This is where vector search shines - capturing subtle aesthetic preferences
        -- that would be impossible to express in traditional search filters
        (1 - (p.embedding <=> sp.style_preference_vector)) * 0.25 +
        
        -- Location score (20%) - Closer to downtown is better for the client's commute
        (1 - LEAST(ST_Distance(p.location_point, sp.downtown_point) / (sp.max_miles_from_downtown * 1609.34), 1)) * 0.20 +
        
        -- Neighborhood match (10%) - Bonus if in preferred neighborhood
        CASE WHEN n.name = sp.preferred_neighborhood THEN 0.10 ELSE 0 END +
        
        -- Amenities match (10%) - Percentage of required amenities matched
        -- This rewards properties that have more of the client's required amenities
        (
            SELECT COUNT(*)::float / ARRAY_LENGTH(sp.required_amenities, 1)
            FROM unnest(sp.required_amenities) AS req_amenity
            WHERE EXISTS (
                SELECT 1
                FROM jsonb_array_elements_text(p.amenities->'indoor') AS amenity
                WHERE amenity::text = req_amenity
            )
        ) * 0.10 +
        
        -- Appliances match (10%) - Percentage of preferred appliances matched
        -- This rewards properties that have more of the client's preferred appliances
        (
            SELECT COUNT(*)::float / ARRAY_LENGTH(sp.preferred_appliances, 1)
            FROM unnest(sp.preferred_appliances) AS pref_appliance
            WHERE EXISTS (
                SELECT 1
                FROM jsonb_array_elements_text(p.features->'interior'->'kitchen'->'appliances') AS appliance
                WHERE appliance::text = pref_appliance
            )
        ) * 0.10
    ) AS overall_match_score
FROM 
    -- Join properties with neighborhoods
    property_data.unified_properties p
    LEFT JOIN property_data.neighborhoods n ON ST_Contains(n.location_polygon::geometry, p.location_point::geometry),
    search_params sp
WHERE 
    -- Basic property criteria - Traditional relational filtering
    p.bedrooms >= sp.min_bedrooms
    AND p.bathrooms >= sp.min_bathrooms
    AND p.price BETWEEN sp.min_price AND sp.max_price
    AND p.status = 'Active'
    
    -- Text search - Find properties matching the client's description
    -- This uses the full-text search capabilities for natural language understanding
    AND p.description_tsv @@ sp.search_query
    
    -- Location criteria - Find properties within the client's commute radius
    -- This uses spatial indexing for efficient proximity search
    AND ST_DWithin(
        p.location_point,
        sp.downtown_point,
        sp.max_miles_from_downtown * 1609.34  -- Convert miles to meters
    )
    
    -- At least one required amenity - Client won't consider properties without these
    -- This searches within the JSON structure for specific amenities
    AND EXISTS (
        SELECT 1
        FROM jsonb_array_elements_text(p.amenities->'indoor') AS amenity
        WHERE amenity::text = ANY(sp.required_amenities)
    )
    
    -- Style similarity threshold - Must match the client's aesthetic preferences
    -- This is where vector search provides unique value - finding properties that
    -- "feel right" to the client based on their previous interactions
    AND (p.embedding <=> sp.style_preference_vector) < 0.5
ORDER BY 
    -- Sort by the overall match score to present the best matches first
    overall_match_score DESC;

-- 4. PROPERTY RECOMMENDATION ENGINE: "MORE LIKE THIS"
-- =====================================================================
-- STORYLINE: A client has found a property they love (Property ID 1) but
-- it's already under contract. The "More Like This" feature needs to find
-- similar properties based on multiple factors: style, amenities, location,
-- and description. This is where vector search truly shines, as it can
-- capture the "feel" of a property that's difficult to express in words.
-- =====================================================================

\echo '\n\n========== PROPERTY RECOMMENDATION ENGINE: "MORE LIKE THIS" ==========\n'
\echo 'This query demonstrates how ProtonBase can power sophisticated recommendation engines\n'

-- Get the reference property that the client is interested in
WITH user_interest AS (
    SELECT 
        id,
        embedding,
        amenities,
        features,
        description_tsv,
        location_point,
        property_type,
        price
    FROM property_data.unified_properties
    WHERE id = 1  -- The property the client is viewing
)

SELECT 
    -- Property details
    p.id,
    p.title,
    p.address,
    p.city,
    p.price,
    p.bedrooms,
    p.bathrooms,
    p.property_type,
    
    -- Similarity scores - Show why each property is similar
    -- Style similarity - Based on vector embeddings
    -- This captures the "feel" of the property that's hard to express in words
    1 - (p.embedding <=> ui.embedding) AS style_similarity,
    
    -- Common amenities - Count how many indoor amenities match
    (
        SELECT COUNT(*)
        FROM jsonb_array_elements_text(p.amenities->'indoor') AS p_amenity
        WHERE EXISTS (
            SELECT 1
            FROM jsonb_array_elements_text(ui.amenities->'indoor') AS ui_amenity
            WHERE p_amenity = ui_amenity
        )
    ) AS common_indoor_amenities,
    
    -- Common kitchen features - Count how many kitchen features match
    (
        SELECT COUNT(*)
        FROM jsonb_array_elements_text(p.features->'interior'->'kitchen'->'features') AS p_feature
        WHERE EXISTS (
            SELECT 1
            FROM jsonb_array_elements_text(ui.features->'interior'->'kitchen'->'features') AS ui_feature
            WHERE p_feature = ui_feature
        )
    ) AS common_kitchen_features,
    
    -- Distance between properties - How close they are geographically
    ST_Distance(
        p.location_point,
        ui.location_point
    ) / 1609.344 AS distance_miles,
    
    -- Text similarity - Use simple ranking against reference property description
    ts_rank(p.description_tsv, plainto_tsquery('english', 
        (SELECT description FROM property_data.unified_properties WHERE id = 1)
    )) AS description_similarity,
    
    -- Overall similarity score - Weighted combination of all factors
    (
        -- Vector embedding similarity (40%) - The "feel" of the property
        -- This is the most important factor because it captures subtle
        -- aesthetic and design elements that are hard to express in words
        (1 - (p.embedding <=> ui.embedding)) * 0.4 +
        
        -- Amenities similarity (20%) - Similar features and amenities
        (
            SELECT COUNT(*)::float / 
                GREATEST(
                    jsonb_array_length(p.amenities->'indoor') + jsonb_array_length(p.amenities->'outdoor'),
                    jsonb_array_length(ui.amenities->'indoor') + jsonb_array_length(ui.amenities->'outdoor')
                )
            FROM jsonb_array_elements_text(p.amenities->'indoor') AS p_amenity
            WHERE EXISTS (
                SELECT 1
                FROM jsonb_array_elements_text(ui.amenities->'indoor') AS ui_amenity
                WHERE p_amenity = ui_amenity
            )
        ) * 0.2 +
        
        -- Location proximity (20%) - Similar neighborhood/area
        (1 - LEAST(ST_Distance(p.location_point, ui.location_point) / 16093.4, 1)) * 0.2 +
        
        -- Property type match (10%) - Same property type (condo, house, etc.)
        CASE WHEN p.property_type = ui.property_type THEN 0.1 ELSE 0 END +
        
        -- Price similarity (10%) - Similar price range
        (1 - LEAST(ABS(p.price - ui.price) / ui.price, 0.5) / 0.5) * 0.1
    ) AS overall_similarity
FROM 
    property_data.unified_properties p,
    user_interest ui
WHERE 
    p.id != ui.id  -- Exclude the reference property
ORDER BY 
    -- Sort by overall similarity to find the most similar properties
    overall_similarity DESC
LIMIT 3;  -- Show the top 3 recommendations

-- Turn off timing
\timing off

\echo '\n\n========== BUSINESS IMPACT OF UNIFIED MULTI-MODAL QUERIES ==========\n'
\echo '1. Increased Conversion Rates: More relevant search results lead to higher engagement'
\echo '2. Enhanced User Experience: Faster, more intuitive property search'
\echo '3. Reduced Infrastructure Costs: Single database instead of 5+ specialized systems'
\echo '4. Simplified Architecture: No complex data synchronization required'
\echo '5. Faster Development: New features can be implemented more quickly'
\echo '6. Better Recommendations: Vector search captures subtle preferences that boost satisfaction'
\echo '7. Competitive Advantage: Capabilities that competitors with traditional databases cannot match'