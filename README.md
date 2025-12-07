# adventofcode2025 - Advent of Code 2025 in T-SQL
*When all you have is a hammer, everything looks like a nail*

Project structure:

```
adventofcode2025
│   LICENSE
│   README.md
│   AdventOfCode2025.slnx              | SQL Server Management Studio 22 solution file
│   AdventOfCode2025.ssmssqlproj       | SQL Server scripts project
│   AdventOfCode2025_00_setup.sql      | Database setup (creates database and input schema)
│   AdventOfCode2025_01_day1.sql       | Code for day 1
│   AdventOfCode2025_02_day2.sql       | Code for day 2
│   .
│   .
│   AdventOfCode2025_12_day12.sql      | Code for day 12
│   docker-compose.yml                 | Docker compose file
└───input
│   │   docker-cp.sh                   | Run this to copy the input and sample files into the Docker container
│   └───day01
│   │   │   input.txt                  | Input file for day 1
│   │   └── sample.txt                 | Sample file for day 1
│   └───day02
│   │   │   input.txt                  | Input file for day 2
│   │   └── sample.txt                 | Sample file for day 2
│   .
│   .
│   └───day12
│       │   input.txt                  | Input file for day 12
│       └── sample.txt                 | Sample file for day 12
└───initdb
    └── setup.sql                      | (unused)
```

How it works:

1. Create a .env file with the following content:
	
	MSSQL_SA_PASSWORD="qwerty"

2. Start the Docker container:
	
	$ sudo docker-compose up -d

3. cd into init/ and place each day's input.txt file (not provided) into init/day the day's folder.
You can also create a sample.txt file with the sample data.

4. Run docker-cp.sh to properly copy each day's files into the Docker container

5. Open the solution file (with SQL Server Management Studio 22) or the project file (with any version of SSMS)
