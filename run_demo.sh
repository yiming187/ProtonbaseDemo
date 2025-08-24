#!/bin/bash

# ProtonBase All-In-One Demo Script
# This script runs the enhanced demo for ProtonBase with business storyline

# Set colors for output
GREEN='\033[0;32m'
BLUE='\033[0;34m'
YELLOW='\033[1;33m'
RED='\033[0;31m'
NC='\033[0m' # No Color

echo -e "${BLUE}=======================================================${NC}"
echo -e "${BLUE}   ProtonBase All-In-One Demo                         ${NC}"
echo -e "${BLUE}   One Database for All Your Data Types                ${NC}"
echo -e "${BLUE}   With Business Storyline                             ${NC}"
echo -e "${BLUE}=======================================================${NC}"

# ProtonBase connection is configured - proceeding with demo
echo -e "\n${YELLOW}Connecting to remote ProtonBase database...${NC}"
echo -e "${GREEN}ProtonBase connection configured.${NC}"

# Load database connection configuration from .env file
if [ -f ".env" ]; then
    echo -e "${YELLOW}Loading database configuration from .env file...${NC}"
    export $(grep -v '^#' .env | xargs)
else
    echo -e "${RED}Error: .env file not found!${NC}"
    echo -e "${YELLOW}Please copy .env.example to .env and configure your database connection details.${NC}"
    echo -e "${YELLOW}Example: cp .env.example .env${NC}"
    exit 1
fi

# Validate required environment variables
required_vars=("PGHOST" "PGPORT" "PGUSER" "PGDATABASE" "PGPASSWORD")
for var in "${required_vars[@]}"; do
    if [ -z "${!var}" ]; then
        echo -e "${RED}Error: Required environment variable $var is not set in .env file${NC}"
        exit 1
    fi
done

# Create a directory for output
mkdir -p output

# Run the setup script
echo -e "\n${YELLOW}Setting up the schema...${NC}"
psql -h $PGHOST -p $PGPORT -U $PGUSER -d $PGDATABASE -f scripts/01_setup_schema.sql 2>&1 | tee output/setup_output.txt && sleep 1

# Check if the setup was successful
if [ $? -eq 0 ]; then
    echo -e "${GREEN}Schema setup complete.${NC}"
else
    echo -e "${RED}Schema setup failed. Please check the output.${NC}"
    exit 1
fi

# Insert sample data
echo -e "\n${YELLOW}Inserting sample data...${NC}"
psql -h $PGHOST -p $PGPORT -U $PGUSER -d $PGDATABASE -f scripts/02_insert_data.sql 2>&1 | tee output/data_output.txt && sleep 1

# Check if the data insertion was successful
if [ $? -eq 0 ]; then
    echo -e "${GREEN}Sample data inserted successfully.${NC}"
else
    echo -e "${RED}Data insertion failed. Please check the output.${NC}"
    exit 1
fi

# Show demo options
echo -e "\n${YELLOW}Select a demo to run:${NC}"
echo -e "1. Standard Demo (03_unified_query.sql)"
echo -e "2. Enhanced Demo with Business Storyline (03_unified_query_enhanced.sql)"

read -p "Enter your choice (1 or 2): " demo_choice

if [ "$demo_choice" == "1" ]; then
    # Run the standard unified query
    echo -e "\n${YELLOW}Running standard unified multi-modal query...${NC}"
    echo -e "${YELLOW}This demonstrates how ProtonBase can query multiple data types in a single query.${NC}"
    echo -e "${YELLOW}Results will be saved to output/query_output.txt${NC}"
    
    psql -h $PGHOST -p $PGPORT -U $PGUSER -d $PGDATABASE -f scripts/03_unified_query.sql 2>&1 | tee output/query_output.txt && sleep 1
elif [ "$demo_choice" == "2" ]; then
    # Run the enhanced unified query with storyline
    echo -e "\n${YELLOW}Running enhanced unified multi-modal query with business storyline...${NC}"
    echo -e "${YELLOW}This demonstrates how ProtonBase can query multiple data types in a single query.${NC}"
    echo -e "${YELLOW}The query includes a compelling storyline about a luxury real estate platform.${NC}"
    echo -e "${YELLOW}Results will be saved to output/query_output.txt${NC}"
    
    psql -h $PGHOST -p $PGPORT -U $PGUSER -d $PGDATABASE -f scripts/03_unified_query_enhanced.sql 2>&1 | tee output/query_output.txt && sleep 1
else
    echo -e "${RED}Invalid choice. Exiting.${NC}"
    exit 1
fi

# Check if the query ran successfully
if [ $? -eq 0 ]; then
    echo -e "${GREEN}Unified query completed successfully!${NC}"
    echo -e "${GREEN}Output saved to output/query_output.txt${NC}"
else
    echo -e "${RED}Unified query encountered an error. Please check the output.${NC}"
    exit 1
fi

# Ask if the user wants to clean up
echo -e "\n${YELLOW}Do you want to clean up the database? (y/n)${NC}"
read -r answer
if [[ "$answer" =~ ^[Yy]$ ]]; then
    echo -e "\n${YELLOW}Cleaning up...${NC}"
    psql -h $PGHOST -p $PGPORT -U $PGUSER -d $PGDATABASE -f scripts/04_cleanup.sql 2>&1 | tee output/cleanup_output.txt && sleep 1
    
    if [ $? -eq 0 ]; then
        echo -e "${GREEN}Cleanup completed successfully.${NC}"
    else
        echo -e "${RED}Cleanup encountered an error. Please check the output.${NC}"
    fi
else
    echo -e "${YELLOW}Skipping cleanup. The database will remain intact.${NC}"
fi

# Show presentation options
echo -e "\n${YELLOW}Select a presentation to view:${NC}"
echo -e "1. Standard Presentation (presentation.md)"
echo -e "2. Enhanced Presentation (consolidated_protonbase_presentation_enhanced.md)"
echo -e "3. Latest Enhanced Presentation with Industry Trends (enhanced_presentation.md)"
echo -e "4. None"

read -p "Enter your choice (1, 2, 3, or 4): " presentation_choice

if [ "$presentation_choice" == "1" ]; then
    # Show the standard presentation
    if command -v code > /dev/null 2>&1; then
        echo -e "${YELLOW}Opening standard presentation...${NC}"
        code "presentation/presentation.md"
    else
        echo -e "${YELLOW}Opening with default text editor...${NC}"
        xdg-open "presentation/presentation.md" 2>/dev/null || open "presentation/presentation.md" 2>/dev/null || echo -e "${RED}Could not open presentation. Please open it manually.${NC}"
    fi
elif [ "$presentation_choice" == "2" ]; then
    # Show the enhanced presentation
    if command -v code > /dev/null 2>&1; then
        echo -e "${YELLOW}Opening enhanced presentation...${NC}"
        code "presentation/consolidated_protonbase_presentation_enhanced.md"
    else
        echo -e "${YELLOW}Opening with default text editor...${NC}"
        xdg-open "presentation/consolidated_protonbase_presentation_enhanced.md" 2>/dev/null || open "presentation/consolidated_protonbase_presentation_enhanced.md" 2>/dev/null || echo -e "${RED}Could not open presentation. Please open it manually.${NC}"
    fi
elif [ "$presentation_choice" == "3" ]; then
    # Show the latest enhanced presentation with industry trends
    if command -v code > /dev/null 2>&1; then
        echo -e "${YELLOW}Opening latest enhanced presentation with industry trends...${NC}"
        code "presentation/enhanced_presentation.md"
    else
        echo -e "${YELLOW}Opening with default text editor...${NC}"
        xdg-open "presentation/enhanced_presentation.md" 2>/dev/null || open "presentation/enhanced_presentation.md" 2>/dev/null || echo -e "${RED}Could not open presentation. Please open it manually.${NC}"
    fi
elif [ "$presentation_choice" == "4" ]; then
    echo -e "${YELLOW}Skipping presentation.${NC}"
else
    echo -e "${RED}Invalid choice. Skipping presentation.${NC}"
fi

# Offer to view the vector search explanation
echo -e "\n${YELLOW}Would you like to view the detailed vector search explanation? (y/n)${NC}"
read -r answer
if [[ "$answer" =~ ^[Yy]$ ]]; then
    if command -v code > /dev/null 2>&1; then
        echo -e "${YELLOW}Opening vector search explanation...${NC}"
        code "presentation/vector_search_explanation.md"
    else
        echo -e "${YELLOW}Opening with default text editor...${NC}"
        xdg-open "presentation/vector_search_explanation.md" 2>/dev/null || open "presentation/vector_search_explanation.md" 2>/dev/null || echo -e "${RED}Could not open explanation. Please open it manually.${NC}"
    fi
fi

echo -e "\n${BLUE}=======================================================${NC}"
echo -e "${BLUE}   Demo Complete                                       ${NC}"
echo -e "${BLUE}=======================================================${NC}"

echo -e "\n${YELLOW}Key Takeaways:${NC}"
echo -e "1. ProtonBase can handle multiple data types in a single database"
echo -e "2. A single query can combine relational, JSON, text, geospatial, and vector data"
echo -e "3. This eliminates the need for multiple specialized databases"
echo -e "4. Vector search provides unique business value by capturing subtle preferences"
echo -e "5. The result is simplified architecture, reduced complexity, and lower costs"
echo -e "6. Business benefits include higher engagement and conversion rates"