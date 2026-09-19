# NFL Statistics SQL Project (1999--2013)

## 📊 Project Overview

This project is a comprehensive **MySQL 8.0 data analysis project**
built around NFL player, season, combine, team, college, and geographic
data.

The project demonstrates how SQL can be used to move from basic data
exploration to more advanced analytical techniques such as **joins,
subqueries, conditional logic, set operations, window functions, views,
and indexing**.

The database is named `nfl_database` and contains tables covering player
profiles, player-season statistics, NFL combine results, teams, college
team records, and ZIP-code geographic information.

The project is designed to answer practical questions about **player
performance, positional production, team performance, draft outcomes,
physical measurements, career progression, and comparative rankings**.

------------------------------------------------------------------------

## 🎯 Project Objectives

The main objectives of this project are to:

-   Explore and understand NFL player and season-level data.
-   Identify high-performing players and positions.
-   Analyze team and positional production across seasons.
-   Connect player biographies with performance statistics.
-   Compare combine measurements across draft rounds.
-   Use subqueries to answer multi-step analytical questions.
-   Apply MySQL string, date, mathematical, and conditional functions.
-   Combine and compare datasets using `UNION` and related set-operation
    logic.
-   Apply MySQL 8.0 window functions for rankings and player
    progression.
-   Create reusable analytical views.
-   Improve query performance through appropriate indexing.
-   Demonstrate practical SQL skills suitable for data analyst and
    business analyst roles.

------------------------------------------------------------------------

## 🗂️ Database Structure

The project uses the following major tables:

  -----------------------------------------------------------------------
  Table                               Description
  ----------------------------------- -----------------------------------
  `players`                           Player biography, college, draft,
                                      physical, and background
                                      information

  `player_season_stats`               Player performance statistics by
                                      NFL season

  `combine_results`                   NFL Combine measurements and draft
                                      information

  `teams`                             Team names and conference
                                      information

  `college_team_records`              College team win/loss records and
                                      rankings

  `zip_codes`                         Geographic information including
                                      city, state, latitude, longitude,
                                      and population
  -----------------------------------------------------------------------

The database is created using MySQL with `utf8mb4` character encoding
and InnoDB tables.

------------------------------------------------------------------------

## 🔗 Key Relationships

The analysis connects tables primarily through player, team, college,
and season attributes.

``` text
players
   │
   │ player_id
   ▼
player_season_stats
   │
   │ player/team/season attributes
   │
   ├──────────────► teams
   │
   └──────────────► college_team_records

players
   │
   │ player_name
   ▼
combine_results

zip_codes
   │
   └── Geographic reference data
```

> **Note:** Some relationships, particularly between `players` and
> `combine_results`, are name-based in the source dataset. A shared
> player key would be preferable for a production database design.

------------------------------------------------------------------------

# 🧠 SQL Analysis Sections

## 1. Basic Queries

### Business / Analytical Question

**How can basic SQL queries be used to identify, filter, sort, and
explore NFL player-season records?**

This section introduces fundamental SQL operations including:

-   `SELECT`
-   `WHERE`
-   `DISTINCT`
-   `ORDER BY`
-   `LIMIT`
-   Multiple filtering conditions
-   Pattern matching with `LIKE`

### Examples

-   Inspect the first player-season records.
-   Find high-fantasy-point players.
-   Filter players by position and season.
-   Identify players from selected teams.
-   List available player positions.
-   Find top rushing performances.

------------------------------------------------------------------------

## 2. Aggregate and Grouping Functions

### Business / Analytical Question

**What does the dataset reveal about overall player-season production,
positional performance, team production, and draft-class strength?**

This section uses:

-   `COUNT()`
-   `AVG()`
-   `SUM()`
-   `MIN()`
-   `MAX()`
-   `GROUP BY`
-   `HAVING`

### Examples

-   Calculate passing statistics across the dataset.
-   Compare average performance by position.
-   Analyze team passing touchdowns by season.
-   Measure team rushing production.
-   Compare combine performance across draft rounds.

------------------------------------------------------------------------

## 3. Joins

### Business / Analytical Question

**How can related NFL tables be combined to connect player biographies,
season statistics, combine measurements, college information, and
records?**

This section demonstrates:

-   `INNER JOIN`
-   `LEFT JOIN`
-   Multi-table joins
-   Self joins
-   Join filtering

### Examples

-   Combine player profiles with 2013 season statistics.
-   Identify drafted players with combine records.
-   Find players without combine records.
-   Connect players to team information.
-   Connect player, season, and college records.
-   Identify players from the same college during the same season.

------------------------------------------------------------------------

## 4. Subqueries and Nested SELECTs

### Business / Analytical Question

**How can subqueries identify players, colleges, and seasons that meet
conditions derived from other records in the database?**

This section demonstrates:

-   Scalar subqueries
-   Derived tables
-   Correlated subqueries
-   `IN`
-   `EXISTS`
-   `NOT EXISTS`

### Examples

-   Find player-seasons above the league fantasy average.
-   Rank the top scorer at each position.
-   Find players who played for a selected team during a period.
-   Compare a player's best season with their career average.
-   Identify colleges producing high-performing NFL players.
-   Find colleges represented in player data but missing season
    statistics.

------------------------------------------------------------------------

## 5. String, Date, and Mathematical Functions

### Business / Analytical Question

**How can MySQL string, date, and mathematical functions transform raw
NFL data into more useful analytical features?**

Functions demonstrated include:

### String Functions

-   `UPPER()`
-   `LOWER()`
-   `LENGTH()`
-   `SUBSTR()`
-   `INSTR()`
-   `TRIM()`
-   `REPLACE()`
-   `CONCAT()`

### Date Functions

-   `YEAR()`
-   `TIMESTAMPDIFF()`

### Mathematical Functions

-   `FLOOR()`
-   `SQRT()`
-   `ABS()`
-   `ROUND()`

### Examples

-   Standardize player names.
-   Extract first and last names.
-   Combine player and college information.
-   Calculate player age.
-   Group players into birth decades.
-   Calculate per-game fantasy production.
-   Compare rushing and receiving efficiency.
-   Calculate quarterback completion percentage.

------------------------------------------------------------------------

## 6. CASE Expressions

### Business / Analytical Question

**How can CASE expressions classify NFL players and create
business-friendly performance categories from numerical statistics?**

This section demonstrates how SQL can convert raw numerical values into
meaningful categories.

### Examples

Fantasy performance tiers:

    Fantasy Points Classification
  ---------------- ----------------
              250+ Elite
          150--249 Starter
           75--149 Role Player
          Below 75 Bench

Other classifications include:

-   Draft-round labels.
-   Conditional player counts.
-   Physicality/BMI-style calculations.
-   Performance segmentation.

`CASE` expressions are especially useful when transforming analytical
results into categories that can be consumed by dashboards and business
reports.

------------------------------------------------------------------------

## 7. UNION and Set Operations

### Business / Analytical Question

**How can multiple result sets be combined, compared, and filtered to
identify overlapping or exclusive groups of NFL player-seasons?**

This section demonstrates:

-   `UNION`
-   `UNION ALL`
-   Set-overlap logic
-   Exclusive-result logic

### Examples

Identify player-seasons that:

-   Produced at least 300 fantasy points.
-   Recorded at least 1,500 rushing yards.
-   Satisfied both conditions.
-   Satisfied one condition but not the other.
-   Appear in different player-related datasets.

For MySQL 8.0 compatibility, overlapping and exclusive results can also
be expressed directly with `AND`, `OR`, and `NOT EXISTS` conditions
where appropriate.

------------------------------------------------------------------------

## 8. Window Functions

### Business / Analytical Question

**How can MySQL 8.0 window functions measure player progression,
rankings, percentile standing, running totals, and season-to-season
performance?**

This section demonstrates advanced MySQL 8.0 analytical functions:

-   `ROW_NUMBER()`
-   `RANK()`
-   `DENSE_RANK()`
-   `LAG()`
-   `SUM() OVER()`
-   `AVG() OVER()`
-   `NTILE()`
-   `PERCENT_RANK()`
-   `CUME_DIST()`
-   `FIRST_VALUE()`

### Examples

-   Number each player's seasons chronologically.
-   Rank running backs by fantasy points.
-   Compare current and previous-season performance.
-   Calculate cumulative career rushing yards.
-   Calculate a three-season trailing average.
-   Divide quarterbacks into performance quartiles.
-   Calculate percentile and cumulative distribution positions.
-   Compare each season with a player's rookie season.

### Example Window Analysis

``` sql
SELECT
    player_name,
    season_year,
    fantasy_pts,
    LAG(fantasy_pts) OVER (
        PARTITION BY player_id
        ORDER BY season_year
    ) AS previous_season_pts
FROM player_season_stats;
```

This allows season-to-season performance changes to be analyzed without
collapsing individual records.

------------------------------------------------------------------------

## 9. Views and Indexing

### Business / Analytical Question

**How can indexes improve query performance and how can reusable SQL
views simplify recurring NFL analysis?**

This section focuses on making the database more efficient and reusable.

### Indexes

Indexes are created on commonly filtered or joined columns, including:

-   `player_season_stats.player_id`
-   `player_season_stats.season_year`
-   `player_season_stats.position`
-   `players.player_name`
-   `players.college`
-   `combine_results.player_name`
-   `teams.team_name`
-   `college_team_records.team_name`
-   `(season_year, position)`

### Views

Reusable views include:

-   `v_player_career_summary`
-   `v_season_position_ranks`
-   `v_qb_efficiency`

These views simplify recurring analysis and allow future queries to work
with prepared analytical datasets.

------------------------------------------------------------------------

# 📈 Key Analytical Areas

The project covers several important dimensions of NFL analysis:

### Player Performance

-   Fantasy points
-   Passing production
-   Rushing production
-   Receiving production
-   Games and starts
-   Per-game performance

### Positional Analysis

-   Quarterbacks
-   Running backs
-   Wide receivers
-   Other player positions available in the dataset

### Team Analysis

-   Team passing touchdowns
-   Team rushing production
-   Player-team relationships
-   Seasonal team performance

### Draft Analysis

-   Draft round
-   Draft position
-   Combine measurements
-   Draft-class comparisons

### Physical Analysis

-   Height
-   Weight
-   BMI-style calculations
-   40-yard dash
-   Vertical jump
-   Broad jump
-   Bench press
-   Shuttle
-   Three-cone performance

### Career Analysis

-   Number of seasons
-   Career fantasy points
-   Career averages
-   Best and lowest seasons
-   Cumulative rushing production
-   Season-to-season changes

------------------------------------------------------------------------

# 🛠️ Technologies Used

-   **MySQL 8.0**
-   **MySQL Workbench 8.0**
-   SQL
-   Relational database concepts
-   Window functions
-   Query optimization
-   Database views
-   Database indexing

------------------------------------------------------------------------

# 📁 Suggested Project Structure

``` text
NFL-Statistics-SQL-Project/
│
├── README.md
├── nfl_database.sql
│
├── sql/
│   ├── 01_basic_queries.sql
│   ├── 02_aggregate_grouping.sql
│   ├── 03_joins.sql
│   ├── 04_subqueries.sql
│   ├── 05_string_date_math.sql
│   ├── 06_case_expressions.sql
│   ├── 07_union_set_operations.sql
│   ├── 08_window_functions.sql
│   └── 09_views_indexing.sql
│
└── screenshots/
    └── mysql-workbench-results/
```

------------------------------------------------------------------------

# ▶️ How to Run the Project

## 1. Install MySQL

Install:

-   MySQL Server 8.0
-   MySQL Workbench 8.0

## 2. Open the SQL File

Open:

``` text
nfl_database.sql
```

in MySQL Workbench.

## 3. Create the Database

The script creates and selects:

``` sql
DROP DATABASE IF EXISTS nfl_database;

CREATE DATABASE nfl_database
DEFAULT CHARACTER SET utf8mb4;

USE nfl_database;
```

## 4. Load the Data

Run the database creation and data-loading statements.

## 5. Execute the Analysis

Run the queries section by section:

``` text
01 → Basic Queries
02 → Aggregate & Grouping
03 → Joins
04 → Subqueries
05 → String, Date & Math
06 → CASE Expressions
07 → UNION & Set Operations
08 → Window Functions
09 → Views & Indexing
```

> **Important:** Index creation statements should generally be executed
> once. Re-running an existing `CREATE INDEX` statement can produce a
> duplicate-index error in MySQL.

------------------------------------------------------------------------

# 🔍 MySQL 8.0 Compatibility Notes

This project was adapted specifically for **MySQL 8.0 Workbench**.

### Date Functions

SQLite-style:

``` sql
STRFTIME()
JULIANDAY()
```

were replaced with MySQL-compatible functions such as:

``` sql
YEAR()
TIMESTAMPDIFF()
```

### String Concatenation

Instead of:

``` sql
player_name || college
```

use:

``` sql
CONCAT(player_name, college)
```

### Index Creation

MySQL 8.0 does not use:

``` sql
CREATE INDEX IF NOT EXISTS
```

The project uses standard:

``` sql
CREATE INDEX index_name
ON table_name(column_name);
```

### Views

Reusable views use:

``` sql
CREATE OR REPLACE VIEW
```

### Window Functions

The project uses MySQL 8.0 window-function support for ranking, lag
analysis, cumulative calculations, quartiles, percentiles, and
distribution analysis.

------------------------------------------------------------------------

# 💼 Business Questions Addressed

This project can support questions such as:

1.  Which players produced the highest fantasy totals?
2.  Which positions generated the greatest average production?
3.  Which teams produced the most passing touchdowns?
4.  Which teams generated the most rushing production?
5.  How does player performance vary by position?
6.  How do combine measurements differ across draft rounds?
7.  Which players performed above the league average?
8.  Which colleges produced high-performing NFL players?
9.  How does a player's performance change from season to season?
10. How does a player's best season compare with their career average?
11. Which players rank highest within their position?
12. Which players demonstrate sustained production across multiple
    seasons?
13. How can player performance be segmented into business-friendly
    categories?
14. Which player-seasons satisfy multiple performance thresholds?
15. How can reusable SQL views simplify recurring NFL analysis?

------------------------------------------------------------------------

# 📚 SQL Skills Demonstrated

This project demonstrates practical knowledge of:

``` text
SELECT
WHERE
DISTINCT
ORDER BY
LIMIT
LIKE

COUNT
SUM
AVG
MIN
MAX
GROUP BY
HAVING

INNER JOIN
LEFT JOIN
SELF JOIN

SUBQUERIES
DERIVED TABLES
CORRELATED SUBQUERIES
EXISTS
NOT EXISTS
IN

STRING FUNCTIONS
DATE FUNCTIONS
MATHEMATICAL FUNCTIONS

CASE
UNION
UNION ALL

ROW_NUMBER
RANK
DENSE_RANK
LAG
SUM OVER
AVG OVER
NTILE
PERCENT_RANK
CUME_DIST
FIRST_VALUE

CREATE VIEW
CREATE INDEX
DROP INDEX
DROP VIEW
```

------------------------------------------------------------------------

# 🚀 Portfolio Value

This project demonstrates the ability to use SQL beyond simple data
retrieval.

It combines:

**Data Exploration → Data Transformation → Relational Analysis →
Advanced Analytics → Performance Optimization**

The project is particularly relevant to roles such as:

-   Data Analyst
-   Business Analyst
-   SQL Analyst
-   BI Analyst
-   Junior Data Scientist
-   Reporting Analyst
-   Data/Business Intelligence Intern

------------------------------------------------------------------------

# 🧑‍💻 Author

**Olokodana Adamson Olasunkanmi**

Data Scientist · Machine Learning Engineer · Business Analyst

GitHub: [Adamson-ola1](https://github.com/Adamson-ola1)

------------------------------------------------------------------------

## ⭐ Project Summary

The **NFL Statistics SQL Project (1999--2013)** demonstrates how MySQL
8.0 can be used to transform a multi-table sports dataset into
structured analytical insights.

From basic filtering and aggregation to joins, subqueries, `CASE`
expressions, set operations, window functions, views, and indexes, the
project provides a practical demonstration of SQL-based data analysis
and database optimization.
