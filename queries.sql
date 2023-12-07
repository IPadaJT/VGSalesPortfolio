--Question 1: What are the top 15 best-sellers of all time. 
-- Select all information about top 15 sellers and order from top down
SELECT * FROM sales
ORDER BY games_sold DESC
LIMIT 15;

-- Further insight: The best-sellers range from 1985-2019. Let's use the 
-- reviews table to gain a better understanding of the top sellers.
-- First let's make sure that all games in our sales table do not have
-- null scores in the reviews table

SELECT COUNT(sales.game)
FROM sales
LEFT JOIN reviews
ON sales.game=reviews.game
WHERE critic_score IS NULL AND
user_score IS NULL;

-- Now that we know all the games have review scores
-- Let's examine which years scored highest with critics
-- First, join the two tables in the database then group by year
-- Then we will find avg_critic_score and display top 10 highest results

SELECT s.year, 
ROUND(AVG(critic_score),2) as avg_critic_score
FROM sales as s
INNER JOIN reviews as r
ON s.game=r.game
GROUP BY year
ORDER BY avg_critic_score DESC
LIMIT 10; 

-- The data at this point narrows our range to between 1982-2002.
-- But let's look at the years 1982, 1994, 1992.
-- The average scores being rounded to 9.0 might indicate low volume of title releases in those years
-- Let's do this by running the same query above but displaying only years with more than 4 games.

SELECT s.year, 
ROUND(AVG(critic_score),2) AS avg_critic_score,
COUNT (s.game) AS games_count
FROM sales AS s
INNER JOIN reviews AS r
ON s.game = r.game
GROUP BY year
HAVING COUNT(s.game) > 4
ORDER BY avg_critic_score DESC
LIMIT 10;

--The resulting years are drastically different.
-- avg_critic_scores are lower but years span between 1999-2010 and 2019-2020.
-- To further examine the data, I will import the last two querties as new tables
-- see database.sql file for details
-- Let's examine the differences which years were dropped because of the low volume of games

SELECT year, avg_critic_score
FROM top_critic_years
EXCEPT
SELECT year, avg_critic_score
FROM top_critic_years_gamecount
ORDER BY avg_critic_score DESC;

-- Let's examine the same way with user scores to compare
SELECT s.year, 
AVG(user_score) AS avg_user_score,
COUNT(s.game) AS num_games
FROM sales AS s
INNER JOIN reviews AS r
ON s.game = r.game
GROUP BY year
HAVING COUNT(year) > 4
ORDER BY avg_user_score DESC
LIMIT 10;

-- Let's add the this result as a new table in the database
-- Then we'll compare the years present in both tables
-- This will better define our best years in the video game market

SELECT year, games_count
FROM top_user_years_gamecount
INNER JOIN top_critic_years_gamecount
USING (year);

-- Now for each year present in both tables
-- Let's look at their total sales

SELECT year,
SUM(games_sold) AS total_games_sold
FROM sales
WHERE year IN (SELECT year 
FROM top_critic_years_gamecount
INNER JOIN top_user_years_gamecount
USING (year))
GROUP BY year
ORDER BY total_games_sold DESC;