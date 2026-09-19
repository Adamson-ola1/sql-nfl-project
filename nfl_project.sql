/* ============================================================================
   NFL STATISTICS SQL PROJECT (1999-2013)
   Database: nfl_database.sql (MySQL)
   SQL Dialect: MySQL 8.0 / MySQL Workbench 8.0
   ============================================================================
   TABLES
   ------
   players               (player_id PK)  - one row per unique player, bio + combine bio
   player_season_stats   (stat_id PK, player_id FK -> players) - one row per player/year
   combine_results       (combine_id PK) - NFL combine measurables (draft classes ~2010-2013)
   teams                 (team_id PK)    - college team -> conference
   college_team_records  (record_id PK)  - college team win/loss/tie record 1999-2013
   zip_codes                              - city/state/zip -> lat/long/population lookup

     ============================================================================ */


/* ============================================================================
  SECTION 1 — BASIC QUERIES SELECT, FILTERING, LOGICAL OPERATORS, SORTING
    ============================================================================ 
  QUESTION: How can basic SQL queries be used to identify, filter, sort, 
  and explore NFL player-season records?
  
   ============================================================================ */

-- 1.1  All columns, limited rows
SELECT * FROM player_season_stats LIMIT 10;

-- 1.2  Select specific columns (players; player_name, dob, college, draft_year)
SELECT player_name, dob, college, draft_year
FROM players
LIMIT 10;

-- 1.3  Filtering with WHERE + comparison operators
-- Question: Which players scored more than 200 fantasy points in 2013?
SELECT
	player_name,
    season_year, 
    position, 
    fantasy_pts 
    FROM player_season_stats 
    WHERE season_year = 2013 
    AND fantasy_pts > 200;

-- 1.4  Logical operators: AND / OR / NOT
-- Question: Which RBs and WRs produced between 2010 and 2013,
-- excluding free-agent records?
SELECT 
	player_name, 
    season_year,
    position,
    rush_yds,
    rec_yds
FROM player_season_stats 
WHERE (position = 'RB' OR position = 'WR')
 AND season_year BETWEEN 2010 AND 2013 
 AND NOT team = 'FA';

-- 1.5  IN, BETWEEN, LIKE, IS NULL
-- Question: Which players on selected teams have a recorded start
-- and whose names begin with the letter T?
SELECT 
	player_name,
    season_year,
    team, 
    position
FROM player_season_stats
WHERE team IN ('NWE', 'DEN', 'GNB', 'SEA')
  AND games_started IS NOT NULL
  AND player_name LIKE 'T%';

-- 1.6  Sorting: ORDER BY multiple columns, ASC/DESC
-- Question: Who were the highest-scoring QBs in each recent season?
SELECT 
	player_name,
    season_year,
    position,
    fantasy_pts
FROM player_season_stats
WHERE position = 'QB'
ORDER BY 
	season_year DESC, 
    fantasy_pts DESC
LIMIT 15;

-- 1.7  DISTINCT
-- Question: What player positions exist in the dataset?
SELECT DISTINCT 
	position 
FROM player_season_stats
ORDER BY position;

-- 1.8  Combining filter + sort + limit for a leaderboard
-- Question: Who were the top 10 rushing RBs by rushing yards?
SELECT 
	player_name,
    season_year,
    rush_yds
FROM player_season_stats
WHERE position = 'RB' 
 AND rush_yds IS NOT NULL
ORDER BY rush_yds DESC
LIMIT 10;


/* ============================================================================
   SECTION 2 — AGGREGATE AND GROUPING FUNCTIONS
   ============================================================================ 
   
   QUESTION: What does the dataset reveal about overall player-season production,
   positional performance, team production, and draft-class strength?
   ============================================================================*/
-- 2.1 Overall aggregate statistics 
-- Question: What are the overall fantasy-point and passing-TD statistics 
-- across all player-season records?
SELECT
	COUNT(*) AS total_player_season,
    ROUND(AVG(fantasy_pts),2) AS avg_fantasy_pts,
    MAX(fantasy_pts) AS max_fantasy_pts,
	MIN(fantasy_pts)        AS min_fantasy_pts,
    SUM(pass_td)            AS total_passing_tds
FROM player_season_stats;
    
-- 2.2  GROUP BY position
-- Question: Which positions have the highest average fantasy production?
SELECT
    position,
    COUNT(*)                     AS num_seasons,
    ROUND(AVG(fantasy_pts), 2)   AS avg_fantasy_pts,
    ROUND(AVG(games_started),1)  AS avg_games_started
FROM player_season_stats
GROUP BY position
ORDER BY avg_fantasy_pts DESC;

-- 2.3  GROUP BY + HAVING (post-aggregation filter)
-- Question: Which teams and seasons recorded more than 30 passing TDs?
SELECT
    team,
    season_year,
    SUM(pass_td) AS team_passing_tds
FROM player_season_stats
GROUP BY team, season_year
HAVING SUM(pass_td) > 30
ORDER BY team_passing_tds DESC;

-- 2.4  Multi-level grouping: total rushing yards by team per year, best teams only
-- Question: Which team-season combinations produced the most rushing yards 
-- from RBs?
SELECT
    team,
    season_year,
    SUM(rush_yds)           AS team_rush_yds,
    COUNT(DISTINCT player_id) AS rushers_used
FROM player_season_stats
WHERE position = 'RB'
GROUP BY team, season_year
ORDER BY team_rush_yds DESC
LIMIT 10;

-- 2.5  Draft-class strength: average combine 40-yard time by draft round
-- Question: How did average combine performance vary by draft round?
SELECT
    draft_round,
    COUNT(*)                    AS players_drafted,
    ROUND(AVG(forty_yard), 3)   AS avg_forty_yard,
    ROUND(AVG(bench_press_reps),1) AS avg_bench_reps
FROM combine_results
WHERE draft_round BETWEEN 1 AND 7
GROUP BY draft_round
ORDER BY draft_round;


/* ============================================================================
   SECTION 3 — JOINS
   ============================================================================
   QUESTION: How can related NFL tables be combined to connect player biographies,
   season statistics, combine measurements, college information, and records?
   
   ============================================================================ */

-- 3.1  INNER JOIN: season stats with player bio info
-- Question: Who were the top fantasy players in 2013 and where did they 
-- attend college?
SELECT
    p.player_name,
    p.college,
    s.season_year,
    s.team,
    s.position,
    s.fantasy_pts
FROM player_season_stats s
INNER JOIN players p 
	ON p.player_id = s.player_id
WHERE s.season_year = 2013
ORDER BY s.fantasy_pts DESC
LIMIT 10;

-- 3.2  LEFT JOIN: players + combine measurements
-- Question: Which drafted players from 2010 onward have combine measurements?
SELECT
    p.player_name,
    p.college,
    c.forty_yard,
    c.vertical_in,
    c.bench_press_reps
FROM players p
LEFT JOIN combine_results c 
	ON c.player_name = p.player_name
WHERE p.draft_year >= 2010
ORDER BY p.player_name
LIMIT 15;

-- 3.3  LEFT JOIN with NULL check to find players who have NO combine record
-- Question: Which drafted players do not have a matching combine record?
SELECT 
	p.player_name, 
    p.college,
    p.draft_year
FROM players p
LEFT JOIN combine_results c 
	ON c.player_name = p.player_name
WHERE c.combine_id IS NULL
ORDER BY p.draft_year DESC
LIMIT 15;

-- 3.4  Joining fact table to a lookup table: college conference for each player
-- Question: Which conference did each player's college belong to?
SELECT
    p.player_name,
    p.college,
    t.conference AS college_conference
FROM players p
INNER JOIN teams t 
	ON t.team_name = p.college
ORDER BY p.player_name
LIMIT 15;

-- 3.5  Three-way JOIN: player + season stats + college win/loss record
-- Question: Which 2013 QBs combined strong fantasy production with
-- strong college win percentages?
SELECT
    p.player_name,
    p.college,
    s.season_year,
    s.fantasy_pts,
    r.win_pct AS college_win_pct
FROM player_season_stats s
JOIN players p          
	ON p.player_id  = s.player_id
JOIN college_team_records r 
	ON r.team_name = p.college
WHERE s.season_year = 2013 
	AND s.position = 'QB'
ORDER BY s.fantasy_pts DESC;

-- 3.6  Self JOIN: pair up teammates from the same college who played in the same season
-- Question: Which players attended the same college and played in the
-- same season?
SELECT
    pa.player_name AS player_a,
    pb.player_name AS player_b,
    pa.college,
    a.season_year
FROM player_season_stats a
JOIN players pa 
	ON pa.player_id = a.player_id
JOIN player_season_stats b 
	ON b.season_year = a.season_year
	AND b.player_id > a.player_id
JOIN players pb 
	ON pb.player_id = b.player_id 
    AND pb.college = pa.college
WHERE a.season_year = 2012
ORDER BY pa.college
LIMIT 10;


/* ============================================================================
   SECTION 4 — SUBQUERIES AND NESTED SELECTS
   ============================================================================
   
   QUESTION: How can subqueries identify players, colleges, and seasons that meet
   conditions derived from other records in the database?
   ============================================================================ */

-- 4.1  Scalar subquery in WHERE: players who beat the league-average fantasy pts
-- Question: Which player-seasons exceeded the league-wide average fantasy score?
SELECT 
	player_name, 
    season_year,
    fantasy_pts
FROM player_season_stats
WHERE fantasy_pts > (
	SELECT AVG(fantasy_pts) 
    FROM player_season_stats)
ORDER BY fantasy_pts DESC
LIMIT 10;

-- 4.2  Subquery in FROM (derived table): top scorer per position in 2013
-- Question: Which player-seasons exceeded the league-wide average fantasy score? SELECT
SELECT 
	position,
    player_id,
    season_year,
    top_pts
FROM (
    SELECT
        position,
        player_id,
        season_year,
        fantasy_pts AS top_pts,
        RANK() OVER (
			PARTITION BY position 
            ORDER BY fantasy_pts DESC) AS pos_rank
    FROM player_season_stats
    WHERE season_year = 2013
) AS ranked
WHERE pos_rank = 1;

-- 4.3  IN subquery: players who ever played for a Super-Bowl-caliber team (proxy: > 400 team pass yds/season)
-- Question: Which players played for New England between 2011 and 2013?
SELECT DISTINCT
	p.player_name,
    p.college 
FROM players p 
WHERE p.player_id IN (
	SELECT s.player_id 
    FROM player_season_stats s
    WHERE s.team = 'NWE' 
     AND s.season_year BETWEEN 2011 AND 2013 );

-- 4.4  Correlated subquery: each player's best single season vs their career average
-- Question: What was each player's best single season and how did it 
-- compare with their career average?
SELECT
    s.player_id,
    s.season_year,
    s.fantasy_pts,
    (SELECT ROUND(AVG(s2.fantasy_pts), 1)
       FROM player_season_stats s2
      WHERE s2.player_id = s.player_id) AS career_avg_pts
FROM player_season_stats s
WHERE s.fantasy_pts = (
    SELECT MAX(s3.fantasy_pts)
    FROM player_season_stats s3
    WHERE s3.player_id = s.player_id
)
ORDER BY s.fantasy_pts DESC
LIMIT 10;

-- 4.5  EXISTS: colleges that have produced at least one 2013 fantasy_pts > 250 player
-- Question: Which colleges produced at least one player with more than 
-- 250 fantasy points in 2013?
SELECT DISTINCT p.college
FROM players p
WHERE EXISTS (
    SELECT 1
    FROM player_season_stats s
    WHERE s.player_id = p.player_id
      AND s.season_year = 2013
      AND s.fantasy_pts > 250
)
ORDER BY p.college;

-- 4.6  NOT EXISTS: colleges with players drafted but who never appear in season stats
-- Question: Which colleges have players in the player table who never
-- appear in the season statistics table?
SELECT DISTINCT 
	p.college
FROM players p
WHERE NOT EXISTS (
    SELECT 1 
    FROM player_season_stats s 
    WHERE s.player_id = p.player_id
)
LIMIT 15;


/* ============================================================================
   SECTION 5 — STRING, DATE, AND MATH FUNCTIONS
   ============================================================================
   
   QUESTION:
   How can MySQL string, date, and mathematical functions transform raw NFL
   data into more useful analytical features?
    ============================================================================ */

-- 5.1  String functions
-- Question: How can player names, colleges, and hometowns be transformed?
SELECT
    player_name,
    UPPER(player_name) AS name_upper,
    LOWER(college) AS college_lower,
    LENGTH(player_name) AS name_length,
    SUBSTR(player_name, 1, 1) AS first_initial,
    REPLACE(hometown, 'St.', 'Saint') AS hometown_clean
FROM players
LIMIT 10;

-- 5.2  Splitting a full name into first/last using INSTR + SUBSTR
-- Question: How can a full player name be separated into first and last names?
SELECT
    player_name,
    SUBSTR(player_name, 1, INSTR(player_name, ' ') - 1) AS first_name,
    SUBSTR(player_name, INSTR(player_name, ' ') + 1) AS last_name
FROM players
WHERE INSTR(player_name, ' ') > 0
LIMIT 10;

-- 5.3  MySQL concatenation
-- Question: How can player name and college be combined into one label?
SELECT
    CONCAT(player_name, ' (', college, ')') AS player_college_label
FROM players
LIMIT 10;

-- 5.4  Date functions
-- Question: How old was each player at the beginning of the 2013 season?
SELECT
    player_name,
    dob,
    YEAR(dob) AS birth_year,
    TIMESTAMPDIFF(YEAR, dob, '2013-09-01') AS age_on_2013_kickoff
FROM players
WHERE dob IS NOT NULL
  AND dob != ''
LIMIT 10;

-- option 2
SELECT
    player_name,
    dob,
    YEAR(STR_TO_DATE(dob, '%Y-%m-%d')) AS birth_year,
    TIMESTAMPDIFF(
        YEAR,
        STR_TO_DATE(dob, '%Y-%m-%d'),
        '2013-09-01'
    ) AS age_on_2013_kickoff
FROM players
WHERE dob IS NOT NULL
  AND dob != ''
LIMIT 10;

-- 5.5  Birth-decade analysis
-- Question: How many players were born in each decade?
SELECT
    FLOOR(YEAR(dob) / 10) * 10 AS birth_decade,
    COUNT(*) AS num_players
FROM players
WHERE dob IS NOT NULL
  AND dob != ''
GROUP BY birth_decade
ORDER BY birth_decade;

-- 5.6  Math functions: ROUND, ABS, per-game rates
-- Question: Which players produced the most fantasy points per game?
SELECT
    player_name,
    season_year,
    fantasy_pts,
    games,
    ROUND(fantasy_pts / NULLIF(games, 0), 2) AS fantasy_pts_per_game,
    ROUND(SQRT(fantasy_pts), 2) AS sqrt_pts_demo,
    ABS(rush_ypa - rec_ypr) AS ypa_ypr_gap
FROM player_season_stats
WHERE fantasy_pts IS NOT NULL AND games > 0
ORDER BY fantasy_pts_per_game DESC
LIMIT 10;

-- 5.7  Completion percentage
-- Question: Which QBs had the highest completion percentage among those
-- with more than 100 pass attempts?
SELECT
    player_id, 
    season_year,
    pass_cmp,
    pass_att,
    ROUND(100.0 * pass_cmp / NULLIF(pass_att, 0), 1) AS completion_pct
FROM player_season_stats
WHERE position = 'QB'
 AND pass_att > 100
ORDER BY completion_pct DESC
LIMIT 10;


/* ============================================================================
   SECTION 6 — CASE EXPRESSIONS
   ============================================================================
   
    QUESTION:
   How can CASE expressions classify NFL players and create business-friendly
   performance categories from numerical statistics?
   ============================================================================ */

-- 6.1  Performance tiers
-- Question: How can players be classified into performance tiers?
SELECT
    p.player_name,
    s.season_year,
    s.fantasy_pts,
    CASE
        WHEN s.fantasy_pts >= 250 THEN 'Elite'
        WHEN s.fantasy_pts >= 150 THEN 'Starter'
        WHEN s.fantasy_pts >= 75  THEN 'Role Player'
        ELSE 'Bench'
    END AS performance_tier
FROM player_season_stats s
JOIN players p ON p.player_id = s.player_id
WHERE s.season_year = 2013
ORDER BY s.fantasy_pts DESC
LIMIT 20;

-- 6.2  CConditional aggregation
-- Question: How many players fell into each fantasy-performance tier
-- in each season?
SELECT
    season_year,
    COUNT(CASE WHEN fantasy_pts >= 250 THEN 1 END) AS elite_count,
    COUNT(CASE WHEN fantasy_pts BETWEEN 150 AND 249.99 THEN 1 END) AS starter_count,
    COUNT(CASE WHEN fantasy_pts < 150 THEN 1 END) AS bench_count
FROM player_season_stats
GROUP BY season_year
ORDER BY season_year;

-- 6.3  Draft-round labels
-- Question: How can numerical draft rounds be converted into readable labels?
SELECT
    player_name,
    draft_round,
    CASE
        WHEN draft_round = 0 THEN 'Undrafted'
        WHEN draft_round = 1 THEN 'First Round'
        WHEN draft_round = 2 THEN 'Second Round'
        WHEN draft_round = 3 THEN 'Third Round'
        ELSE 'Rounds 4-7'
    END AS draft_label
FROM players
ORDER BY draft_round
LIMIT 15;

-- 6.4  BMI-style physicality index using average season weight
-- Question: What is the estimated BMI for players based on their height
-- and average recorded playing weight?
SELECT
    p.player_name,
    p.height_in,
    ROUND(AVG(s.weight_lb), 1) AS avg_weight_lb,
    CASE
        WHEN p.height_in IS NULL
             OR AVG(s.weight_lb) IS NULL
             OR p.height_in = 0
        THEN NULL
        ELSE ROUND(
            703.0 * AVG(s.weight_lb)
            / (p.height_in * p.height_in),
            1
        )
    END AS bmi_estimate
FROM players p
JOIN player_season_stats s
    ON s.player_id = p.player_id
GROUP BY
    p.player_id,
    p.player_name,
    p.height_in
LIMIT 10;

SELECT
    p.player_name,
    p.height_in,
    ROUND(AVG(s.weight_lb), 1) AS avg_weight_lb,
    CASE
        WHEN p.height_in IS NULL OR AVG(s.weight_lb) IS NULL THEN NULL
        ELSE ROUND(
            703.0 * AVG(s.weight_lb) / (p.height_in * p.height_in),
            1
        )
    END AS bmi_estimate
FROM players p
JOIN player_season_stats s
    ON s.player_id = p.player_id
GROUP BY
    p.player_id,
    p.player_name,
    p.height_in
LIMIT 10;

/* ============================================================================
   SECTION 7 — UNION AND SET OPERATIONS
   ============================================================================ 
   
   QUESTION:
   How can multiple result sets be combined, compared, and filtered to
   identify overlapping or exclusive groups of NFL player-seasons?
   ============================================================================ */

-- 7.1  UNION
-- Question: Which player-seasons were either elite fantasy seasons
-- or high-volume rushing seasons?
SELECT
    player_id,
    season_year,
    'Elite Fantasy Season' AS reason
FROM player_season_stats
WHERE fantasy_pts >= 300

UNION

SELECT
    player_id,
    season_year,
    'High Volume Rusher' AS reason
FROM player_season_stats
WHERE rush_yds >= 1500

ORDER BY season_year DESC;

-- 7.2  UNION ALL
-- Question: What happens when duplicate player-seasons are retained?
SELECT
    player_id,
    season_year
FROM player_season_stats
WHERE fantasy_pts >= 300

UNION ALL

SELECT
    player_id,
    season_year
FROM player_season_stats
WHERE rush_yds >= 1500;

-- 7.3  INTERSECT
-- Question: Which player-seasons were BOTH elite fantasy scorers
-- and high-volume rushers?
SELECT
    player_id,
    season_year
FROM player_season_stats
WHERE fantasy_pts >= 300
  AND rush_yds >= 1500;
  
-- 7.4  EXCEPT
-- Question: Which elite fantasy seasons were NOT high-volume rushing seasons?
SELECT
    player_id,
    season_year
FROM player_season_stats
WHERE fantasy_pts >= 300
  AND (
      rush_yds < 1500
      OR rush_yds IS NULL
  );

-- 7.5  UNION across differently sourced player-name lists
-- Question: Which names appear in either the combine dataset or the player
-- roster dataset?

SELECT DISTINCT player_name AS name, 'combine_prospect' AS source FROM combine_results
UNION
SELECT DISTINCT player_name AS name, 'rostered_player' AS source FROM players
ORDER BY name
LIMIT 20;


/* ============================================================================
   SECTION 8 — WINDOW FUNCTIONS
   ============================================================================

   QUESTION:
   How can MySQL 8.0 window functions measure player progression, rankings,
   percentile standing, running totals, and season-to-season performance?
   ============================================================================ */

-- 8.1  ROW_NUMBER: rank each player's seasons chronologically
-- Question: What was the chronological order of each player's seasons?
SELECT
    player_id, 
    season_year, 
    fantasy_pts,
    ROW_NUMBER() OVER (
		PARTITION BY player_id 
		ORDER BY season_year) AS season_number
FROM player_season_stats
ORDER BY player_id, season_number
LIMIT 15;

-- 8.2  RANK / DENSE_RANK
-- Question: How did RBs rank against one another in fantasy points in 2013?
SELECT
    p.player_name,
    s.season_year, 
    s.position, 
    s.fantasy_pts,
    RANK() OVER (
		PARTITION BY s.season_year, s.position 
        ORDER BY s.fantasy_pts DESC) AS rnk,
    DENSE_RANK() OVER (
		PARTITION BY s.season_year, s.position
        ORDER BY s.fantasy_pts DESC) AS dense_rnk
FROM player_season_stats s
JOIN players p ON p.player_id = s.player_id
WHERE s.season_year = 2013 AND s.position = 'RB'
ORDER BY rnk
LIMIT 10;

-- 8.3  LAG 
-- Question: How much did each player's fantasy production change
-- from the previous season?
SELECT
    player_id,
    season_year,
    fantasy_pts,
    LAG(fantasy_pts)  OVER (
		PARTITION BY player_id
		ORDER BY season_year) AS prev_season_pts,
    fantasy_pts - 
    LAG(fantasy_pts) OVER (
		PARTITION BY player_id 
        ORDER BY season_year) AS pts_change
FROM player_season_stats
ORDER BY player_id, season_year
LIMIT 15;

-- 8.4  Running total 
-- Question: How did each RB's cumulative career rushing yards grow
-- over successive seasons?
SELECT
    player_id,
    season_year, 
    rush_yds,
    SUM(rush_yds) OVER (
		PARTITION BY player_id 
        ORDER BY season_year
		ROWS BETWEEN UNBOUNDED PRECEDING AND CURRENT ROW) 
        AS career_rush_yds_to_date
FROM player_season_stats
WHERE position = 'RB'
ORDER BY player_id, season_year
LIMIT 15;

-- 8.5  Moving average
-- Question: What was each player's trailing three-season average
-- fantasy production?
SELECT
    player_id,
    season_year,
    fantasy_pts,
    ROUND(AVG(fantasy_pts) OVER (
		PARTITION BY player_id 
        ORDER BY season_year
       ROWS BETWEEN 2 PRECEDING AND CURRENT ROW), 1)
       AS trailing_3yr_avg
FROM player_season_stats
ORDER BY player_id, season_year
LIMIT 15;

-- 8.6  NTILE
-- Question: How can 2013 QBs be divided into four fantasy-performance
-- quartiles?
SELECT
    p.player_name, 
    s.fantasy_pts,
    NTILE(4) OVER (
		ORDER BY s.fantasy_pts DESC) AS quartile
FROM player_season_stats s
JOIN players p ON p.player_id = s.player_id
WHERE s.season_year = 2013 AND s.position = 'QB'
ORDER BY s.fantasy_pts DESC;

-- 8.7  PERCENT_RANK / CUME_DIST
-- Question: Where did the top 2013 players rank relative to the entire
-- 2013 fantasy-point distribution?
SELECT
    p.player_name,
    s.fantasy_pts,
    ROUND( PERCENT_RANK() OVER (
		ORDER BY s.fantasy_pts), 3) AS pct_rank,
    ROUND(CUME_DIST() OVER (
		ORDER BY s.fantasy_pts),3) AS cume_distribution
FROM player_season_stats s
JOIN players p
    ON p.player_id = s.player_id
WHERE s.season_year = 2013
ORDER BY s.fantasy_pts DESC
LIMIT 10;

-- 8.8  FIRST_VALUE / LAST_VALUE
-- Question: How does each player's rookie-season fantasy production
-- compare with later seasons?
SELECT
    player_id,
    season_year, 
    fantasy_pts,
    FIRST_VALUE(fantasy_pts) OVER (
		PARTITION BY player_id 
        ORDER BY season_year
        ROWS BETWEEN UNBOUNDED PRECEDING AND UNBOUNDED FOLLOWING) 
        AS rookie_season_pts
FROM player_season_stats
ORDER BY player_id, season_year
LIMIT 15;


/* ============================================================================
   SECTION 9 — VIEWS AND INDEXING
    ============================================================================

   QUESTION:
   How can indexes improve query performance and how can reusable SQL views
   simplify recurring NFL analysis?
   ============================================================================ */

-- 9.1  Indexing 

CREATE INDEX idx_pss_player_id
    ON player_season_stats(player_id);

CREATE INDEX idx_pss_season_year
    ON player_season_stats(season_year);

CREATE INDEX idx_pss_position
    ON player_season_stats(position);

CREATE INDEX idx_players_name
    ON players(player_name);

CREATE INDEX idx_players_college
    ON players(college);

CREATE INDEX idx_combine_name
    ON combine_results(player_name);

CREATE INDEX idx_teams_name
    ON teams(team_name);

CREATE INDEX idx_college_rec_name
    ON college_team_records(team_name);

-- Composite index for year + position lookups
CREATE INDEX idx_pss_year_position
    ON player_season_stats(season_year, position);

/* ---------------------------------------------------------------------------
   9.2 PLAYER CAREER SUMMARY VIEW
   ---------------------------------------------------------------------------

   Question:
   Which players accumulated the most fantasy points across their careers?
   --------------------------------------------------------------------------- */
CREATE OR REPLACE VIEW v_player_career_summary AS
SELECT
    p.player_id,
    p.player_name,
    p.college,
    COUNT(s.stat_id) AS seasons_played,
    SUM(s.fantasy_pts) AS career_fantasy_pts,
    ROUND(AVG(s.fantasy_pts), 2) AS avg_season_fantasy_pts,
    MIN(s.season_year) AS first_season,
    MAX(s.season_year) AS last_season
FROM players p
JOIN player_season_stats s
    ON s.player_id = p.player_id
GROUP BY
    p.player_id,
    p.player_name,
    p.college;

-- Using the view like any table:
SELECT * FROM v_player_career_summary
ORDER BY career_fantasy_pts DESC
LIMIT 10;

/* ---------------------------------------------------------------------------
   9.3 SEASON POSITION RANKING VIEW
   ---------------------------------------------------------------------------

   Question:
   Who were the top-ranked players at each position in every season?
   --------------------------------------------------------------------------- */
CREATE OR REPLACE VIEW v_season_position_ranks AS
SELECT
    p.player_name,
    s.season_year,
    s.position,
    s.fantasy_pts,
    RANK() OVER (
		PARTITION BY s.season_year, s.position 
        ORDER BY s.fantasy_pts DESC) AS position_rank
FROM player_season_stats s
JOIN players p ON p.player_id = s.player_id;

-- Show the top three players at each position in 2013
SELECT * FROM v_season_position_ranks
WHERE season_year = 2013 AND position_rank <= 3
ORDER BY position, position_rank;

/* ---------------------------------------------------------------------------
   9.4 QB EFFICIENCY VIEW
   ---------------------------------------------------------------------------

   Question:
   Which quarterbacks combined strong completion percentage,
   passing efficiency, and touchdown production?
   --------------------------------------------------------------------------- */
CREATE OR REPLACE VIEW  v_qb_efficiency AS
SELECT
    p.player_name,
    s.season_year,
    s.pass_att,
    s.pass_cmp,
    s.pass_yds,
    s.pass_td,
    s.pass_int,
    ROUND(100.0 * s.pass_cmp / NULLIF(s.pass_att, 0), 1) AS completion_pct,
    ROUND(1.0 * s.pass_yds  / NULLIF(s.pass_att, 0), 2)  AS yards_per_attempt,
    CASE
        WHEN s.pass_td >= 30 THEN 'Elite'
        WHEN s.pass_td >= 20 THEN 'Solid'
        ELSE 'Below Average'
    END AS td_tier
FROM player_season_stats s
JOIN players p ON p.player_id = s.player_id
WHERE s.position = 'QB' AND s.pass_att > 50;

-- Use the QB efficiency view
SELECT * FROM v_qb_efficiency
ORDER BY completion_pct DESC
LIMIT 10;

/* ---------------------------------------------------------------------------
   9.5 HOUSEKEEPING / OBJECT MANAGEMENT
   ---------------------------------------------------------------------------
   To remove an index, use:

       DROP INDEX idx_pss_year_position
       ON player_season_stats;

   To remove a view, use:

       DROP VIEW IF EXISTS v_qb_efficiency;

   These statements are intentionally commented out so that project objects
   remain available.
   --------------------------------------------------------------------------- */

/* ============================================================================
   END OF PROJECT
   ============================================================================ */