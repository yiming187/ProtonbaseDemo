#!/bin/bash

# ProtonBase All-In-One Demo Script
# Restructured into 3 main parts: 1. Initialization, 2. Testing Loop, 3. Cleanup

# Set colors for output
GREEN='\033[0;32m'
BLUE='\033[0;34m'
YELLOW='\033[1;33m'
RED='\033[0;31m'
NC='\033[0m' # No Color

echo -e "${BLUE}=======================================================${NC}"
echo -e "${BLUE}   ProtonBase All-In-One Demo                            ${NC}"
echo -e "${BLUE}   One Database for All Your Data Types                ${NC}"
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

# ==============================================
# PART 1: SCHEMA INITIALIZATION AND DATA SETUP
# ==============================================

initialize_database() {
    echo -e "\n${BLUE}=============================================${NC}"
    echo -e "${BLUE}   PART 1: Database Initialization${NC}"
    echo -e "${BLUE}=============================================${NC}"
    
    # Create a directory for output
    mkdir -p output
    
    # Run the setup script
    echo -e "\n${YELLOW}Setting up the schema...${NC}"
    psql -h $PGHOST -p $PGPORT -U $PGUSER -d $PGDATABASE -f scripts/01_setup_schema.sql 2>&1 | tee output/setup_output.txt
    
    # Check if the setup was successful
    if [ $? -eq 0 ]; then
        echo -e "${GREEN}Schema setup complete.${NC}"
    else
        echo -e "${RED}Schema setup failed. Please check the output.${NC}"
        exit 1
    fi
    
    # Insert sample data
    echo -e "\n${YELLOW}Inserting sample data...${NC}"
    psql -h $PGHOST -p $PGPORT -U $PGUSER -d $PGDATABASE -f scripts/02_insert_data.sql 2>&1 | tee output/data_output.txt
    
    # Check if the data insertion was successful
    if [ $? -eq 0 ]; then
        echo -e "${GREEN}Sample data inserted successfully.${NC}"
    else
        echo -e "${RED}Data insertion failed. Please check the output.${NC}"
        exit 1
    fi
    
    # Ask if user wants to generate large dataset with custom size
    echo -e "\n${YELLOW}Do you want to generate additional test data for performance testing? (y/n)${NC}"
    read -r large_dataset_answer
    if [[ "$large_dataset_answer" =~ ^[Yy]$ ]]; then
        echo -e "\n${YELLOW}Please enter the number of records to generate:${NC}"
        echo -e "${YELLOW}Suggested values: 1000 (quick), 10000 (medium), 100000 (large), 1000000 (full scale)${NC}"
        read -r dataset_size
        
        # Validate input
        if ! [[ "$dataset_size" =~ ^[0-9]+$ ]] || [ "$dataset_size" -lt 100 ]; then
            echo -e "${RED}Invalid input. Using default size of 10000 records.${NC}"
            dataset_size=10000
        fi
        
        echo -e "\n${YELLOW}Generating $dataset_size test records...${NC}"
        if [ "$dataset_size" -gt 100000 ]; then
            echo -e "${YELLOW}Warning: This may take 5-10 minutes for large datasets.${NC}"
        fi
        
        # Modify the SQL file to use the specified size
        sed "s/\\\\set DATASET_SIZE 10000/\\\\set DATASET_SIZE $dataset_size/g" scripts/05_generate_large_dataset.sql > /tmp/temp_dataset.sql
        
        psql -h $PGHOST -p $PGPORT -U $PGUSER -d $PGDATABASE -f /tmp/temp_dataset.sql 2>&1 | tee output/large_dataset_output.txt
        
        # Clean up temp file
        rm -f /tmp/temp_dataset.sql
        
        if [ $? -eq 0 ]; then
            echo -e "${GREEN}Dataset with $dataset_size records generated successfully!${NC}"
        else
            echo -e "${RED}Dataset generation failed. Please check the output.${NC}"
        fi
    else
        echo -e "${YELLOW}Using standard 5-record dataset for demonstration.${NC}"
    fi
    
    # Show current dataset size
    record_count=$(psql -h $PGHOST -p $PGPORT -U $PGUSER -d $PGDATABASE -t -c "SELECT count(*) FROM property_data.unified_properties;" 2>/dev/null | tr -d ' ')
    echo -e "\n${GREEN}Database initialization complete. Current dataset size: $record_count records${NC}"
}

# ==============================================
# PART 2: INTERACTIVE TESTING LOOP
# ==============================================

run_test_menu() {
    while true; do
        # Get current dataset size
        record_count=$(psql -h $PGHOST -p $PGPORT -U $PGUSER -d $PGDATABASE -t -c "SELECT count(*) FROM property_data.unified_properties;" 2>/dev/null | tr -d ' ')
        
        echo -e "\n${BLUE}=============================================${NC}"
        echo -e "${BLUE}   PART 2: Testing Options${NC}"
        echo -e "${BLUE}=============================================${NC}"
        echo -e "${YELLOW}Current dataset size: $record_count records${NC}"
        echo -e "\n${YELLOW}Select a test to run:${NC}"
        echo -e "1. Standard Demo (Multi-modal Query Examples)"
        echo -e "2. Enhanced Demo (Business Storyline - Elite Properties)"
        echo -e "3. Performance Test (Comprehensive Performance Analysis)"
        echo -e "4. Exit to cleanup options"
        
        echo -e "\n${YELLOW}Enter your choice (1, 2, 3, or 4): ${NC}"
        read -r demo_choice
        
        case $demo_choice in
            1)
                run_standard_demo
                ask_continue_testing
                if [ $? -ne 0 ]; then
                    break
                fi
                ;;
            2)
                run_enhanced_demo
                ask_continue_testing
                if [ $? -ne 0 ]; then
                    break
                fi
                ;;
            3)
                run_performance_test
                ask_continue_testing
                if [ $? -ne 0 ]; then
                    break
                fi
                ;;
            4)
                echo -e "${YELLOW}Exiting test menu...${NC}"
                break
                ;;
            *)
                echo -e "${RED}Invalid choice. Please enter 1, 2, 3, or 4.${NC}"
                echo -e "\n${YELLOW}Press Enter to try again...${NC}"
                read -r
                ;;
        esac
    done
}

ask_continue_testing() {
    echo -e "\n${BLUE}=======================================${NC}"
    echo -e "${YELLOW}What would you like to do next?${NC}"
    echo -e "1. Run another test"
    echo -e "2. Exit to cleanup options"
    echo -e "\n${YELLOW}Enter your choice (1 or 2): ${NC}"
    read -r continue_choice
    
    case $continue_choice in
        1)
            return 0  # Continue testing
            ;;
        2)
            return 1  # Exit testing
            ;;
        *)
            echo -e "${RED}Invalid choice. Returning to test menu...${NC}"
            return 0  # Default to continue
            ;;
    esac
}

run_standard_demo() {
    echo -e "\n${YELLOW}Running standard unified multi-modal query...${NC}"
    echo -e "${YELLOW}This demonstrates how ProtonBase can query multiple data types in a single query.${NC}"
    echo -e "${YELLOW}Results will be saved to output/query_output.txt${NC}"
    
    psql -h $PGHOST -p $PGPORT -U $PGUSER -d $PGDATABASE -f scripts/03_unified_query.sql 2>&1 | tee output/query_output.txt
    
    if [ $? -eq 0 ]; then
        echo -e "${GREEN}Standard demo completed successfully!${NC}"
        echo -e "${GREEN}Results saved to output/query_output.txt${NC}"
        echo -e "\n${BLUE}======== Demo Results Summary ========${NC}"
        echo -e "${YELLOW}The query demonstrates ProtonBase's ability to:${NC}"
        echo -e "• Combine relational data (price, bedrooms) with JSON attributes"
        echo -e "• Perform full-text search on property descriptions"
        echo -e "• Execute geospatial queries for location-based filtering"
        echo -e "• Run vector similarity search for personalized recommendations"
        echo -e "• Deliver all results in a single, unified query"
    else
        echo -e "${RED}Standard demo encountered an error. Please check the output.${NC}"
    fi
    
    echo -e "\n${YELLOW}Press Enter to continue...${NC}"
    read -r
}

run_enhanced_demo() {
    echo -e "\n${YELLOW}Running enhanced unified multi-modal query with business storyline...${NC}"
    echo -e "${YELLOW}This demonstrates ProtonBase in a real-world luxury real estate platform scenario.${NC}"
    echo -e "${YELLOW}Results will be saved to output/query_output.txt${NC}"
    
    psql -h $PGHOST -p $PGPORT -U $PGUSER -d $PGDATABASE -f scripts/03_unified_query_enhanced.sql 2>&1 | tee output/query_output.txt
    
    if [ $? -eq 0 ]; then
        echo -e "${GREEN}Enhanced demo completed successfully!${NC}"
        echo -e "${GREEN}Results saved to output/query_output.txt${NC}"
        echo -e "\n${BLUE}======== Enhanced Demo Summary ========${NC}"
        echo -e "${YELLOW}This scenario demonstrates:${NC}"
        echo -e "• Real-world use case: Elite Properties luxury real estate platform"
        echo -e "• Business storyline: Matching high-end properties to wealthy clients"
        echo -e "• Multi-modal data integration for sophisticated property matching"
        echo -e "• AI-powered recommendations based on client preferences and behavior"
        echo -e "• Competitive advantage through unified data platform"
    else
        echo -e "${RED}Enhanced demo encountered an error. Please check the output.${NC}"
    fi
    
    echo -e "\n${YELLOW}Press Enter to continue...${NC}"
    read -r
}

run_performance_test() {
    record_count=$(psql -h $PGHOST -p $PGPORT -U $PGUSER -d $PGDATABASE -t -c "SELECT count(*) FROM property_data.unified_properties;" 2>/dev/null | tr -d ' ')
    
    echo -e "\n${YELLOW}Running comprehensive performance test...${NC}"
    echo -e "${YELLOW}This will test query performance on $record_count records.${NC}"
    echo -e "${YELLOW}Performance tests include: aggregation, JSON queries, full-text search,${NC}"
    echo -e "${YELLOW}geospatial operations, vector similarity, neighborhoods analysis, and multi-modal queries.${NC}"
    echo -e "${YELLOW}Results will be saved to output/performance_test_output.txt${NC}"
    
    if [ "$record_count" -gt 50000 ]; then
        echo -e "${YELLOW}Warning: Large dataset detected. Performance test may take 2-5 minutes.${NC}"
    fi
    
    psql -h $PGHOST -p $PGPORT -U $PGUSER -d $PGDATABASE -f scripts/06_test_large_dataset.sql 2>&1 | tee output/performance_test_output.txt
    
    if [ $? -eq 0 ]; then
        echo -e "${GREEN}Performance test completed successfully!${NC}"
        echo -e "${GREEN}Results saved to output/performance_test_output.txt${NC}"
        echo -e "\n${BLUE}======== Performance Test Summary ========${NC}"
        echo -e "${YELLOW}Comprehensive performance analysis completed on $record_count records:${NC}"
        echo -e "• Aggregation queries: Basic counting and grouping operations"
        echo -e "• JSON operations: Complex attribute filtering and extraction"
        echo -e "• Full-text search: Multi-language text search capabilities"
        echo -e "• Geospatial queries: Location-based distance and area calculations"
        echo -e "• Vector similarity: AI-powered semantic similarity search"
        echo -e "• Neighborhood analysis: Spatial joins and area-based queries"
        echo -e "• Multi-modal integration: Combined data type operations"
        echo -e "\n${YELLOW}Check the output file for detailed timing and execution statistics.${NC}"
    else
        echo -e "${RED}Performance test encountered an error. Please check the output.${NC}"
    fi
    
    echo -e "\n${YELLOW}Press Enter to continue...${NC}"
    read -r
}

# ==============================================
# PART 3: CLEANUP AND FINALIZATION
# ==============================================

cleanup_and_finalize() {
    echo -e "\n${BLUE}=============================================${NC}"
    echo -e "${BLUE}   PART 3: Cleanup and Finalization${NC}"
    echo -e "${BLUE}=============================================${NC}"
    
    # Ask if the user wants to clean up
    echo -e "\n${YELLOW}Do you want to clean up the database (remove all demo data)? (y/n)${NC}"
    read -r answer
    if [[ "$answer" =~ ^[Yy]$ ]]; then
        echo -e "\n${YELLOW}Cleaning up database...${NC}"
        psql -h $PGHOST -p $PGPORT -U $PGUSER -d $PGDATABASE -f scripts/04_cleanup.sql 2>&1 | tee output/cleanup_output.txt
        
        if [ $? -eq 0 ]; then
            echo -e "${GREEN}Database cleanup completed successfully.${NC}"
        else
            echo -e "${RED}Cleanup encountered an error. Please check the output.${NC}"
        fi
    else
        echo -e "${YELLOW}Skipping cleanup. Database will remain intact for future testing.${NC}"
    fi
    
    # Show final summary
    show_final_summary
}

show_final_summary() {
    echo -e "\n${BLUE}=======================================================${NC}"
    echo -e "${BLUE}   Demo Complete - Summary                             ${NC}"
    echo -e "${BLUE}=======================================================${NC}"
    
    echo -e "\n${YELLOW}Key Takeaways:${NC}"
    echo -e "1. ${GREEN}Unified Data Platform${NC}: ProtonBase handles multiple data types in a single database"
    echo -e "2. ${GREEN}Multi-Modal Queries${NC}: Single queries can combine relational, JSON, text, geospatial, and vector data"
    echo -e "3. ${GREEN}Simplified Architecture${NC}: Eliminates the need for multiple specialized databases"
    echo -e "4. ${GREEN}AI-Powered Search${NC}: Vector search captures subtle preferences for better recommendations"
    echo -e "5. ${GREEN}Cost Reduction${NC}: Simplified architecture reduces complexity and operational costs"
    echo -e "6. ${GREEN}Business Value${NC}: Higher engagement and conversion rates through better user experience"
    
    echo -e "\n${YELLOW}Generated Output Files:${NC}"
    if [ -f "output/query_output.txt" ]; then
        echo -e "- ${GREEN}output/query_output.txt${NC}: Query demonstration results"
    fi
    if [ -f "output/performance_test_output.txt" ]; then
        echo -e "- ${GREEN}output/performance_test_output.txt${NC}: Performance test results"
    fi
    if [ -f "output/large_dataset_output.txt" ]; then
        echo -e "- ${GREEN}output/large_dataset_output.txt${NC}: Large dataset generation log"
    fi
    
    echo -e "\n${YELLOW}Thank you for exploring ProtonBase!${NC}"
    echo -e "${YELLOW}For more information, visit: https://protonbase.io${NC}"
}

# ==============================================
# MAIN EXECUTION FLOW
# ==============================================

# Execute the three main parts
initialize_database
run_test_menu
cleanup_and_finalize