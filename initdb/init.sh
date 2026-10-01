#!/bin/bash
set -e

# Wait for sqlserver to be ready
echo "Waiting for SQL Server to be ready..."
for i in {1..60}; do
  /opt/mssql-tools18/bin/sqlcmd -S sqlserver -U sa -P "$MSSQL_SA_PASSWORD" -No -Q "SELECT 1" >/dev/null 2>&1 && break
  echo "Attempt $i/60 - waiting..."
  sleep 2
done

echo "SQL Server is ready. Running initialization..."

# Create database
/opt/mssql-tools18/bin/sqlcmd -S sqlserver -U sa -P "$MSSQL_SA_PASSWORD" -No -Q "CREATE DATABASE AdventOfCode2025;" 2>/dev/null || true

# Set recovery model and create schema
/opt/mssql-tools18/bin/sqlcmd -S sqlserver -U sa -P "$MSSQL_SA_PASSWORD" -No << EOF
ALTER DATABASE AdventOfCode2025 SET RECOVERY SIMPLE;
GO
USE AdventOfCode2025;
GO
CREATE SCHEMA [input];
GO
EOF

echo "Database initialization complete."
