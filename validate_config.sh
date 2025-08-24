#!/bin/bash

# ProtonBase Demo Configuration Validator
# This script validates the environment configuration

# Colors for output
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
RED='\033[0;31m'
BLUE='\033[0;34m'
NC='\033[0m' # No Color

echo -e "${BLUE}=============================================${NC}"
echo -e "${BLUE}   ProtonBase Demo Configuration Validator  ${NC}"
echo -e "${BLUE}=============================================${NC}"

# Function to check if a command exists
command_exists() {
    command -v "$1" >/dev/null 2>&1
}

# Function to check file existence
check_file() {
    local file_path="$1"
    local description="$2"
    
    if [ -f "$file_path" ]; then
        echo -e "${GREEN}✓${NC} $description: $file_path"
        return 0
    else
        echo -e "${RED}✗${NC} $description: $file_path (missing)"
        return 1
    fi
}

# Function to check environment variable
check_env_var() {
    local var_name="$1"
    local description="$2"
    
    if [ -n "${!var_name}" ]; then
        echo -e "${GREEN}✓${NC} $description: $var_name is set"
        return 0
    else
        echo -e "${RED}✗${NC} $description: $var_name is not set"
        return 1
    fi
}

echo -e "\n${YELLOW}Checking Prerequisites...${NC}"

# Check required commands
prerequisites_ok=true

if command_exists psql; then
    echo -e "${GREEN}✓${NC} PostgreSQL client (psql) is available"
else
    echo -e "${RED}✗${NC} PostgreSQL client (psql) is not available"
    prerequisites_ok=false
fi

if command_exists bash; then
    echo -e "${GREEN}✓${NC} Bash shell is available"
else
    echo -e "${RED}✗${NC} Bash shell is not available"
    prerequisites_ok=false
fi

echo -e "\n${YELLOW}Checking Configuration Files...${NC}"

# Check configuration files
config_ok=true

check_file ".env" "Environment configuration" || config_ok=false
check_file ".env.example" "Environment template" || config_ok=false
check_file ".gitignore" "Git ignore rules" || config_ok=false

echo -e "\n${YELLOW}Checking SQL Scripts...${NC}"

# Check SQL scripts
scripts_ok=true

check_file "scripts/01_setup_schema.sql" "Schema setup script" || scripts_ok=false
check_file "scripts/02_insert_data.sql" "Data insertion script" || scripts_ok=false
check_file "scripts/03_unified_query.sql" "Basic query script" || scripts_ok=false
check_file "scripts/03_unified_query_enhanced.sql" "Enhanced query script" || scripts_ok=false
check_file "scripts/04_cleanup.sql" "Cleanup script" || scripts_ok=false
check_file "scripts/05_generate_large_dataset.sql" "Large dataset script" || scripts_ok=false
check_file "scripts/06_test_large_dataset.sql" "Performance test script" || scripts_ok=false

echo -e "\n${YELLOW}Checking Environment Variables...${NC}"

# Load environment variables if .env exists
if [ -f ".env" ]; then
    source .env
    echo -e "${BLUE}Loaded variables from .env file${NC}"
fi

# Check required environment variables
env_ok=true

check_env_var "PGHOST" "Database host" || env_ok=false
check_env_var "PGPORT" "Database port" || env_ok=false
check_env_var "PGUSER" "Database user" || env_ok=false
check_env_var "PGDATABASE" "Database name" || env_ok=false
check_env_var "PGPASSWORD" "Database password" || env_ok=false

echo -e "\n${YELLOW}Testing Database Connection...${NC}"

# Test database connection
if [ "$env_ok" = true ]; then
    if psql -h "$PGHOST" -p "$PGPORT" -U "$PGUSER" -d "$PGDATABASE" -c "SELECT 1;" >/dev/null 2>&1; then
        echo -e "${GREEN}✓${NC} Database connection successful"
        connection_ok=true
    else
        echo -e "${RED}✗${NC} Database connection failed"
        connection_ok=false
    fi
else
    echo -e "${YELLOW}⚠${NC} Skipping connection test due to missing environment variables"
    connection_ok=false
fi

echo -e "\n${BLUE}=============================================${NC}"
echo -e "${BLUE}   Configuration Validation Summary          ${NC}"
echo -e "${BLUE}=============================================${NC}"

# Summary
if [ "$prerequisites_ok" = true ] && [ "$config_ok" = true ] && [ "$scripts_ok" = true ] && [ "$env_ok" = true ] && [ "$connection_ok" = true ]; then
    echo -e "${GREEN}✓ All checks passed! System is ready for demo.${NC}"
    exit 0
else
    echo -e "${RED}✗ Some checks failed. Please fix the issues above before running the demo.${NC}"
    
    if [ "$prerequisites_ok" = false ]; then
        echo -e "${YELLOW}  → Install missing prerequisites${NC}"
    fi
    
    if [ "$config_ok" = false ]; then
        echo -e "${YELLOW}  → Check configuration files${NC}"
    fi
    
    if [ "$scripts_ok" = false ]; then
        echo -e "${YELLOW}  → Verify SQL script files${NC}"
    fi
    
    if [ "$env_ok" = false ]; then
        echo -e "${YELLOW}  → Configure environment variables in .env file${NC}"
    fi
    
    if [ "$connection_ok" = false ]; then
        echo -e "${YELLOW}  → Verify database connection settings${NC}"
    fi
    
    exit 1
fi