# ProtonBase Demo

This repository contains the demo files for ProtonBase, a unified multi-modal database platform that combines relational, JSON, text, geospatial, and vector data types in a single system.

## Overview

ProtonBase is a next-generation database platform that eliminates data silos by providing a unified solution for all your data needs:

- **Instant Lakehouse** - Real-time performance at scale with sub-second analytics
- **Online Retrieval** - Real-time vector and semantic search with zero-latency updates
- **PostgreSQL Compatibility** - High compatibility with existing tools and extensions
- **Cloud-Native Design** - Instant elasticity for dynamic workloads
- **Bring AI to Your Data** - Extract knowledge and discover insights with AI

### Unified Data Types

ProtonBase supports multiple data types in a single platform:

- **Relational data** - Traditional structured data with ACID transactions
- **JSON data** - Flexible schema design for semi-structured data
- **Text data** - Full-text search with ranking and highlighting
- **Geospatial data** - Location-based queries and spatial analysis
- **Vector data** - Similarity search for AI and machine learning applications

### Key Advantages

- **Single Point of Truth** - One database for all your data needs
- **Simplified Architecture** - No need to integrate multiple specialized databases
- **Lower Latency** - No cross-database joins or data movement
- **Consistent Data** - No synchronization issues between systems
- **Reduced Costs** - Fewer systems to maintain and operate

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

## Database Connection Configuration

This demo is designed to work with a remote ProtonBase database instance. Before running the demo, you need to configure the database connection parameters.

### Prerequisites

- Access to a ProtonBase database instance (cloud or on-premises)
- Database connection credentials (host, port, username, password, database name)
- PostgreSQL client tools installed (`psql`)

### Connection Methods

#### Method 1: Using Environment Configuration File (Recommended)

The demo uses a `.env` file to store database connection parameters securely. This file is excluded from version control to protect sensitive information.

**Setup Steps:**

1. **Copy the template file:**
   ```bash
   cp .env.example .env
   ```

2. **Edit the `.env` file with your database credentials:**
   ```bash
   # ProtonBase Database Connection Configuration
   PGHOST=your-protonbase-host.com
   PGPORT=5432
   PGUSER=your-username@domain.com
   PGDATABASE=postgres
   PGPASSWORD=your-password
   ```

3. **Run the demo:**
   ```bash
   ./run_demo.sh
   ```

The script will automatically load the configuration from `.env` and validate all required parameters.

#### Method 2: Environment Variables

Set the connection parameters as environment variables in your shell:

```bash
export PGHOST="your-protonbase-host.com"
export PGPORT="5432"
export PGUSER="your-username@domain.com"
export PGDATABASE="postgres"
export PGPASSWORD="your-password"

# Then run psql commands directly
psql -c "SELECT version();"
```

### Security Considerations

- **Use `.env` files for sensitive data** - Store database credentials in `.env` files that are excluded from version control
- **Never commit passwords to version control** - The `.gitignore` file ensures `.env` files are not tracked by git
- **Use `.env.example` for documentation** - Provide template files without sensitive information for team sharing
- **Use SSL connections** when connecting to remote databases
- **Limit database user permissions** to only what's needed for the demo
- **Consider using connection pooling** for production environments
- **Rotate passwords regularly** and use strong, unique passwords for each environment

### Troubleshooting Connection Issues

#### Common Connection Errors and Solutions:

1. **"Connection refused"**
   - Check if the host address and port are correct
   - Verify firewall rules allow connections to the database port
   - Ensure the ProtonBase service is running

2. **"Authentication failed"**
   - Verify username and password are correct
   - Check if the user has permission to connect to the specified database
   - Ensure the authentication method matches the server configuration

3. **"Database does not exist"**
   - Verify the database name is correct (usually "postgres" for ProtonBase)
   - Check if you have permission to access the specified database

4. **"SSL connection error"**
   - Add SSL parameters if required: `psql "sslmode=require host=... port=... user=... dbname=..."`

#### Testing Your Connection

Before running the full demo, test your connection with:

```bash
PGPASSWORD="your-password" psql -h your-host -p 5432 -U your-username -d postgres -c "SELECT version();"
```

Successful output should show the ProtonBase version information.

## Getting Started

## Getting Started

### Quick Start with Automated Script

### Quick Start with Automated Script

1. **Copy the configuration template**: 
   ```bash
   cp .env.example .env
   ```
2. **Configure Database Connection**: Edit the `.env` file with your ProtonBase database credentials
3. **Clone this repository**: `git clone <repository-url>`
4. **Run the automated demo**: `./run_demo.sh`
5. **Select demo type**: Choose between standard demo (option 1) or enhanced demo with business storyline (option 2)
6. **Choose cleanup**: Decide whether to clean up the database after the demo

The automated script will:
- Set up the database schema and tables
- Load sample property data
- Execute multi-modal queries
- Display results and performance metrics
- Optionally clean up the database

### Manual Execution

Alternatively, you can run the scripts manually:

1. **Set up connection**: Configure your database connection (see Database Connection Configuration)
2. **Create schema**: Run the setup script to create tables and indexes
   ```bash
   psql -h your-host -p 5432 -U your-username -d postgres -f scripts/01_setup_schema.sql
   ```
3. **Load sample data**: Insert the demo property data
   ```bash
   psql -h your-host -p 5432 -U your-username -d postgres -f scripts/02_insert_data.sql
   ```
4. **Run basic queries**: Execute unified multi-modal query examples
   ```bash
   psql -h your-host -p 5432 -U your-username -d postgres -f scripts/03_unified_query.sql
   ```
5. **Try advanced queries**: Run enhanced queries with business storyline
   ```bash
   psql -h your-host -p 5432 -U your-username -d postgres -f scripts/03_unified_query_enhanced.sql
   ```
6. **Clean up**: Remove demo data when finished
   ```bash
   psql -h your-host -p 5432 -U your-username -d postgres -f scripts/04_cleanup.sql
   ```

### What You'll See

The demo showcases:
- **Unified queries** combining relational, JSON, text, geospatial, and vector data
- **Real-time performance** with query execution times under 200ms
- **Personalized recommendations** using vector similarity search
- **Geospatial analysis** with distance calculations and location-based filtering
- **Full-text search** with highlighted results
- **Business impact metrics** showing the value of unified data platforms

## Demo Output

The demo generates several output files in the `output/` directory:

- **`query_output.txt`** - Complete query results and execution logs
- **`setup_output.txt`** - Database schema creation logs
- **`data_output.txt`** - Sample data insertion logs
- **`cleanup_output.txt`** - Database cleanup logs

These files contain detailed information about:
- Query execution times and performance metrics
- Complete result sets showing multi-modal data integration
- SQL query explanations and business context
- Error messages and troubleshooting information

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

## Use Cases

ProtonBase excels in various use cases:

- **AI Applications** - Bring AI to your data with vector embeddings and similarity search
- **Real-time Analytics** - Process and analyze data in real-time with sub-second performance
- **Personalization** - Create personalized experiences based on user preferences and behavior
- **Fraud Detection** - Identify suspicious patterns across multiple data dimensions
- **Content Discovery** - Help users find relevant content through multi-modal search

### Getting Help

If you encounter issues not covered here:
1. Check the output files in the `output/` directory for detailed error messages
2. Review the database connection configuration
3. Test basic connectivity with `psql -h host -p port -U username -d database -c "SELECT version();"`
4. Contact ProtonBase support with specific error messages and configuration details

## License

This demo is provided for educational purposes only. ProtonBase is a commercial product.

## Contact

For more information about ProtonBase, visit [protonbase.com](https://protonbase.com/) or contact service@protonbase.com.