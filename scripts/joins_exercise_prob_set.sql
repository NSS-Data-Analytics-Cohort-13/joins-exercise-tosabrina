--TABLES FOR REF:
SELECT *
FROM distributors;

SELECT *
FROM specs;

SELECT *
FROM rating;

SELECT *
FROM revenue;

-- 1. Give the name, release year, and worldwide gross of the lowest grossing movie.

--INTIAL ATTEMPT:
SELECT
	s.film_title
,	s.release_year 

, 	MIN(r.worldwide_gross) AS lowest_gross
FROM specs AS s
	LEFT JOIN revenue AS r
		ON s.movie_id = r.movie_id
GROUP BY 
	s.film_title
,	s.release_year
ORDER BY lowest_gross ASC
LIMIT 1;
--INITIAL ANS: Semi-Tough, 1977, 37187139

-- 2. What year has the highest average imdb rating?

--INTIAL ATTEMPT:
SELECT 
	s.release_year
,	ROUND(AVG(imdb_rating), 2) AS avg_rating
FROM specs AS s
	LEFT JOIN rating AS r
		ON s.movie_id = r.movie_id
GROUP BY
	s.release_year
ORDER BY 
	avg_rating DESC
LIMIT 1;
--INITIAL ANS: 1991, 7.45

-- 3. What is the highest grossing G-rated movie? Which company distributed it?

/*NOTES:
- you want matching a full match to all criteria, so INNER JOIN x2 (3 tables used)
*/

--INTIAL ATTEMPT:
SELECT
	s.film_title
,	d.company_name
,	r.worldwide_gross
FROM specs as s
	INNER JOIN distributors AS d
		ON s.domestic_distributor_id = d.distributor_id
	INNER JOIN revenue AS r
		ON s.movie_id = r.movie_id
WHERE s.mpaa_rating = 'G' 
ORDER BY r.worldwide_gross DESC;
--INITIAL ANS: Toy Story 4, Walt Disney, 1073394593

-- 4. Write a query that returns, for each distributor in the distributors table, the distributor name and the number of movies associated with that distributor in the movies table. Your result set should include all of the distributors, whether or not they have any movies in the movies table.

/*NOTES: 
- Use FULL JOIN. 
- Filter under WHERE: 86148="Legendary Entertainment" and 86150="Relativity Media." 
- Notice how NULL values returned as 0. How to return as NULL?*/

--INTIAL ATTEMPT:
SELECT
	d.company_name
,	COUNT(s.film_title) AS count_title
FROM distributors AS d
	FULL JOIN specs AS s 
		ON d.distributor_id = s.domestic_distributor_id 
GROUP BY 
	d.company_name
ORDER BY 
	count_title;
--INITIAL ANS: *See Query Results*

-- 5. Write a query that returns the five distributors with the highest average movie budget.

/*NOTES:
- Tables: distributors, revenue
*/

--INTIAL ATTEMPT:

--INITIAL ANS:

-- 6. How many movies in the dataset are distributed by a company which is not headquartered in California? Which of these movies has the highest imdb rating?

--INTIAL ATTEMPT:
--INITIAL ANS:

-- 7. Which have a higher average rating, movies which are over two hours long or movies which are under two hours?

--INTIAL ATTEMPT:
--INITIAL ANS:
