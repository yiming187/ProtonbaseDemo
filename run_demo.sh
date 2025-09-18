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

# Database connection helper function
execute_sql_script() {
    local script_file="$1"
    local output_file="$2"
    local description="${3:-Executing SQL script}"
    
    echo -e "${BLUE}$description: $script_file${NC}"
    
    if [ ! -f "$script_file" ]; then
        echo -e "${RED}Error: SQL script file not found: $script_file${NC}"
        return 1
    fi
    
    if [ -n "$output_file" ]; then
        psql -h $PGHOST -p $PGPORT -U $PGUSER -d $PGDATABASE -f "$script_file" 2>&1 | tee "$output_file"
        local exit_code=${PIPESTATUS[0]}
    else
        psql -h $PGHOST -p $PGPORT -U $PGUSER -d $PGDATABASE -f "$script_file"
        local exit_code=$?
    fi
    
    if [ $exit_code -ne 0 ]; then
        echo -e "${RED}Error: $description failed with exit code $exit_code${NC}"
        if [ -n "$output_file" ]; then
            echo -e "${YELLOW}Check $output_file for detailed error information${NC}"
        fi
    fi
    
    return $exit_code
}

# Database query helper function
execute_sql_query() {
    local query="$1"
    local description="${2:-Executing SQL query}"
    
    echo -e "${BLUE}$description${NC}" >&2
    
    local result=$(psql -h $PGHOST -p $PGPORT -U $PGUSER -d $PGDATABASE -t -c "$query" 2>/dev/null | tr -d ' ')
    local exit_code=$?
    
    if [ $exit_code -ne 0 ]; then
        echo -e "${RED}Error: $description failed${NC}" >&2
        return 1
    fi
    
    echo "$result"
}

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
    execute_sql_script "scripts/01_setup_schema.sql" "output/setup_output.txt"
    
    # Check if the setup was successful
    if [ $? -eq 0 ]; then
        echo -e "${GREEN}Schema setup complete.${NC}"
    else
        echo -e "${RED}Schema setup failed. Please check the output.${NC}"
        exit 1
    fi
    
    # Insert sample data
    echo -e "\n${YELLOW}Inserting sample data...${NC}"
    execute_sql_script "scripts/02_insert_data.sql" "output/data_output.txt"
    
    # Check if the data insertion was successful
    if [ $? -eq 0 ]; then
        echo -e "${GREEN}Sample data inserted successfully.${NC}"
    else
        echo -e "${RED}Data insertion failed. Please check the output.${NC}"
        exit 1
    fi
    
    # Ask if user wants to generate large dataset with custom size
    echo -e "\n${YELLOW}Generate additional test data for performance testing? Press Enter to use default 10000, enter n to skip, or enter a number:${NC}"
    read -r dataset_size
    if [[ -z "$dataset_size" ]]; then
        dataset_size=10000
    fi
    if [[ "$dataset_size" =~ ^[Nn]$ ]]; then
        echo -e "${YELLOW}Skipping large dataset generation. Using standard 5-record demo.${NC}"
    else
        if ! [[ "$dataset_size" =~ ^[0-9]+$ ]] || [ "$dataset_size" -lt 100 ]; then
            echo -e "${RED}Invalid input. Using default size of 10000 records.${NC}"
            dataset_size=10000
        fi
        echo -e "\n${YELLOW}Generating $dataset_size test records...${NC}"
        if [ "$dataset_size" -gt 100000 ]; then
            echo -e "${YELLOW}Warning: This may take 5-10 minutes for large datasets.${NC}"
        fi
        sed "s/\\set DATASET_SIZE 10000/\\set DATASET_SIZE $dataset_size/g" scripts/05_generate_large_dataset.sql > /tmp/temp_dataset.sql
        execute_sql_script "/tmp/temp_dataset.sql" "output/large_dataset_output_$(date +%Y%m%d%H%M%S).txt"
        rm -f /tmp/temp_dataset.sql
        if [ $? -eq 0 ]; then
            echo -e "${GREEN}Dataset with $dataset_size records generated successfully!${NC}"
        else
            echo -e "${RED}Dataset generation failed. Please check the output.${NC}"
        fi
    fi
    
    # Show current dataset size
    record_count=$(execute_sql_query "SELECT count(*) FROM property_data.unified_properties;")
    echo -e "\n${GREEN}Database initialization complete. Current dataset size: $record_count records${NC}"
}

# ==============================================
# PART 2: INTERACTIVE TESTING LOOP
# ==============================================


run_test_menu() {
    # Get current dataset size
    record_count=$(psql -h $PGHOST -p $PGPORT -U $PGUSER -d $PGDATABASE -t -c "SELECT count(*) FROM property_data.unified_properties;" 2>/dev/null | tr -d ' ')
    echo -e "\n${BLUE}=============================================${NC}"
    echo -e "${BLUE}   PART 2: Testing Options${NC}"
    echo -e "${BLUE}=============================================${NC}"
    echo -e "${YELLOW}Current dataset size: $record_count records${NC}"
    echo -e "\n${YELLOW}Select tests to run (comma separated, Enter for all):${NC}"
    echo -e "1. Standard Demo (Multi-modal Query Examples)"
    echo -e "2. Enhanced Demo (Business Storyline - Elite Properties)"
    echo -e "3. Performance Test (Comprehensive Performance Analysis)"
    read -r test_choices
    if [[ -z "$test_choices" ]]; then
        test_choices="1,2,3"
    fi
    IFS=',' read -ra choices <<< "$test_choices"
    for choice in "${choices[@]}"; do
        case $(echo $choice | xargs) in
            1)
                run_standard_demo
                ;;
            2)
                run_enhanced_demo
                ;;
            3)
                run_performance_test
                ;;
            *)
                echo -e "${RED}Invalid choice: $choice. Skipping.${NC}"
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
    local outfile="output/query_output_standard_$(date +%Y%m%d%H%M%S).txt"
    echo -e "\n${YELLOW}Running standard unified multi-modal query demo...${NC}"
    echo -e "${YELLOW}Results will be saved to $outfile${NC}"
    psql -h $PGHOST -p $PGPORT -U $PGUSER -d $PGDATABASE -f scripts/03_unified_query.sql 2>&1 | tee "$outfile"
    if [ $? -eq 0 ]; then
        echo -e "${GREEN}Standard demo completed! Results saved to $outfile${NC}"
    else
        echo -e "${RED}Standard demo failed. Please check the output.${NC}"
    fi
}

run_enhanced_demo() {
    local outfile="output/query_output_enhanced_$(date +%Y%m%d%H%M%S).txt"
    echo -e "\n${YELLOW}Running enhanced unified multi-modal query demo (business storyline)...${NC}"
    echo -e "${YELLOW}Results will be saved to $outfile${NC}"
    psql -h $PGHOST -p $PGPORT -U $PGUSER -d $PGDATABASE -f scripts/03_unified_query_enhanced.sql 2>&1 | tee "$outfile"
    if [ $? -eq 0 ]; then
        echo -e "${GREEN}Enhanced demo completed! Results saved to $outfile${NC}"
    else
        echo -e "${RED}Enhanced demo failed. Please check the output.${NC}"
    fi
}

run_performance_test() {
    record_count=$(psql -h $PGHOST -p $PGPORT -U $PGUSER -d $PGDATABASE -t -c "SELECT count(*) FROM property_data.unified_properties;" 2>/dev/null | tr -d ' ')
    local outfile="output/performance_test_output_$(date +%Y%m%d%H%M%S).txt"
    echo -e "\n${YELLOW}Running comprehensive performance test...${NC}"
    echo -e "${YELLOW}This will test query performance on $record_count records.${NC}"
    echo -e "${YELLOW}Results will be saved to $outfile${NC}"
    if [ "$record_count" -gt 50000 ]; then
        echo -e "${YELLOW}Warning: Large dataset detected. Performance test may take 2-5 minutes.${NC}"
    fi
    psql -h $PGHOST -p $PGPORT -U $PGUSER -d $PGDATABASE -f scripts/06_test_large_dataset.sql 2>&1 | tee "$outfile"
    if [ $? -eq 0 ]; then
        echo -e "${GREEN}Performance test completed! Results saved to $outfile${NC}"
    else
        echo -e "${RED}Performance test failed. Please check the output.${NC}"
    fi
}

# ==============================================
# PART 3: CLEANUP AND FINALIZATION
# ==============================================

cleanup_and_finalize() {
    echo -e "\n${BLUE}=============================================${NC}"
    echo -e "${BLUE}   PART 3: Cleanup and Finalization${NC}"
    echo -e "${BLUE}=============================================${NC}"
    echo -e "\n${YELLOW}Do you want to clean up the database (remove all demo data)? Press Enter to skip, y to clean up:${NC}"
    read -r answer
    if [[ "$answer" =~ ^[Yy]$ ]]; then
        echo -e "\n${YELLOW}Cleaning up database...${NC}"
        psql -h $PGHOST -p $PGPORT -U $PGUSER -d $PGDATABASE -f scripts/04_cleanup.sql 2>&1 | tee output/cleanup_output_$(date +%Y%m%d%H%M%S).txt
        if [ $? -eq 0 ]; then
            echo -e "${GREEN}Database cleanup completed.${NC}"
        else
            echo -e "${RED}Cleanup failed. Please check the output.${NC}"
        fi
    else
        echo -e "${YELLOW}Skipping cleanup. Database will remain intact.${NC}"
    fi
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