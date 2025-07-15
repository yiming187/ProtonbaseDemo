# ProtonBase Demo

This repository contains demonstrations of ProtonBase, a powerful multi-modal database system that can handle multiple data types in a single database.

## Overview

ProtonBase is a next-generation database that combines the capabilities of multiple specialized databases into a single unified platform. It can handle:

- **Relational data** - Traditional structured data
- **JSON data** - Flexible schema design
- **Text data** - Full-text search with ranking and highlighting
- **Geospatial data** - Location-based queries and spatial analysis
- **Vector data** - Similarity search for AI and machine learning

The key advantage of ProtonBase is its ability to handle all these data types in a single database with a single query, eliminating the need for multiple specialized databases and complex data synchronization.

## Repository Structure

```
ProtonbaseDemo-GitHub/
├── scripts/                           # SQL scripts for the demo
│   ├── 01_setup_schema.sql            # Creates the database schema
│   ├── 02_insert_data.sql             # Inserts sample data
│   ├── 03_unified_query.sql           # Standard query demonstrating multi-model capabilities
│   ├── 03_unified_query_enhanced.sql  # Enhanced query with detailed comments and business context
│   └── 04_cleanup.sql                 # Cleans up the database
├── presentation/                      # Presentations and documentation
│   ├── presentation.md                # Standard presentation
│   ├── consolidated_protonbase_presentation_enhanced.md # Enhanced presentation with business impact metrics
│   ├── enhanced_presentation.md       # Latest presentation with industry trends
│   └── vector_search_explanation.md   # Detailed explanation of vector search with examples
├── data/                              # Sample data files
│   └── sample_properties.json         # Sample property data in JSON format
├── run_demo.sh                        # Script to run the demo
└── README.md                          # This file
```

## Prerequisites

- PostgreSQL 14+ with the following extensions:
  - pg_trgm
  - postgis
  - vector
- psql command-line client
- Bash shell

## Configuration

Before running the demo, you need to configure your database connection:

1. Edit the `run_demo.sh` script
2. Replace `<YOUR_DATABASE_PASSWORD>` with your actual PostgreSQL password
3. If needed, modify other connection parameters in the script

## Running the Demo

To run the demo:

```bash
./run_demo.sh
```

The script will:

1. Check if PostgreSQL is running
2. Set up the schema
3. Insert sample data
4. Offer a choice between the standard query and the enhanced query with business storyline
5. Run the selected query
6. Offer to clean up the database
7. Offer a choice between the standard presentation and the enhanced presentation
8. Offer to view the detailed vector search explanation

## Demo Features

### Business Storyline

The demo includes a compelling business storyline about "Elite Properties," a luxury real estate platform that previously used multiple specialized databases:
- PostgreSQL for property details
- MongoDB for flexible property features and amenities
- Elasticsearch for text search
- PostGIS for location-based search
- Pinecone for vector similarity search

The storyline explains how they migrated to ProtonBase to solve data synchronization issues, reduce infrastructure costs, and improve query performance.

### Detailed Use Cases

The demo includes four detailed use cases:
- **The Executive Search**: A C-level tech executive relocating to Seattle with specific property requirements
- **The Neighborhood Expert**: A real estate agent helping clients find properties in specific neighborhoods
- **The Personalized Experience**: A detailed user preference profile translated into a sophisticated query
- **More Like This**: Finding similar properties when a client's favorite is unavailable

### Business Value of Vector Search

The demo emphasizes how vector search provides unique business value:
- Capturing the "feel" of a property that's hard to express in words
- Enabling truly personalized recommendations based on subtle preferences
- Complementing traditional search methods for a better user experience
- Driving higher engagement and conversion rates

## Key Takeaways

1. ProtonBase can handle multiple data types in a single database
2. A single query can combine relational, JSON, text, geospatial, and vector data
3. This eliminates the need for multiple specialized databases
4. Vector search provides unique business value by capturing subtle preferences
5. The result is simplified architecture, reduced complexity, and lower costs
6. Business benefits include higher engagement and conversion rates

## Security Note

**IMPORTANT**: This repository has been sanitized for public sharing. All sensitive information such as passwords, API keys, and personal data has been removed and replaced with placeholders. Before using this demo in your environment, make sure to:

1. Replace `<YOUR_DATABASE_PASSWORD>` in the `run_demo.sh` script with your actual database password
2. Review all scripts for any other placeholders that need to be replaced
3. Ensure your database is properly secured before loading the demo data

## License

MIT License

## Contact

For questions or support, please open an issue in this repository.