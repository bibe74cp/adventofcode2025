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

1. Place each day's input file (not provided) in the day's folder. You can also copy a file with the sample data.

2. cd into init/, then run docker-cp.sh to properly copy each day's files into the Docker container

3. Open the solution file (with SQL Server Management Studio 22) or the project file (with any version of SSMS)
