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
- LEFT JOIN bc specs (left table)
- Filter under WHERE: 86148="Legendary Entertainment" and 86150="Relativity Media." 
- Notice how NULL values returned as 0. How to return as NULL?*/

--INTIAL ATTEMPT:
SELECT
	d.company_name
,	COUNT(s.film_title) AS count_title
FROM distributors AS d
	LEFT JOIN specs AS s 
		ON d.distributor_id = s.domestic_distributor_id 
GROUP BY 
	d.company_name
ORDER BY 
	count_title;
--INITIAL ANS: *See Query Results* 23 records

-- 5. Write a query that returns the five distributors with the highest average movie budget.

/*NOTES:
- Tables: distributors, revenue, specs
*/

--INITIAL ATTEMPT:
SELECT
	d.company_name
,	ROUND(AVG(r.film_budget), 2) AS avg_budget
FROM specs AS s
	INNER JOIN distributors as d
		ON s.domestic_distributor_id = d.distributor_id
	INNER JOIN revenue as r
		ON s.movie_id = r.movie_id
GROUP BY d.company_name
ORDER BY avg_budget DESC
LIMIT 5;
/*INITIAL ANS:
"Walt Disney " = 148735526.32
"Sony Pictures"	= 139129032.26
"Lionsgate"	= 122600000.00
"DreamWorks" = 121352941.18
"Warner Bros." = 103430985.92
*/

-- 6. How many movies in the dataset are distributed by a company which is not headquartered in California? Which of these movies has the highest imdb rating?

/*NOTES:
- Tables: distributors, specs, rating
- COUNT(film_title)
- Filter headquarters NOT LIKE 'CA'
*/

--PT 1 INITIAL ATTEMPT:
SELECT
	s.film_title
,	MAX(r.imdb_rating) AS max_imdb
FROM specs AS s
	INNER JOIN distributors AS d
		ON s.domestic_distributor_id = d.distributor_id
	INNER JOIN rating AS r
		ON s.movie_id = r.movie_id
WHERE 
	d.headquarters NOT ILIKE '%CA'
GROUP BY 
	s.film_title
ORDER BY
	max_imdb DESC;
--INITIAL ANS: 2, Dirty Dancing (7.0)

-- 7. Which have a higher average rating, movies which are over two hours long or movies which are under two hours?

/*NOTES:
- Tables: rating, specs
- AVG imdb 
- Filter length_in_min >120 min OR <120
- Could potentially use CASE? Under SELECT, WHERE, or FROM?
*/

--INITIAL ATTEMPT:
SELECT
	CASE 
		WHEN s.length_in_min > 120 THEN 'Over 2 hrs'
		ELSE 'Under 2 hrs' 
		END AS filtered_length
,	ROUND(AVG(r.imdb_rating),2) AS avg_imdb
FROM specs AS s
	LEFT JOIN rating AS r
		ON s.movie_id = r.movie_id
GROUP BY 
	filtered_length
ORDER BY avg_imdb DESC;
--INITIAL ANS: (Over 2 hrs = 7.26) > (Under 2 hrs = 6.92)


--ALT ANSWER:
SELECT 'Less than 2 hours' AS movie_length, ROUND(AVG(avg_imdb_rating),2) avg_rating
FROM (
	SELECT AVG(r.imdb_rating) AS avg_imdb_rating
	FROM specs AS s
	INNER JOIN rating r
		USING(movie_id) 
	GROUP BY s.length_in_min
	HAVING s.length_in_min<120
	) 
UNION ALL
SELECT 'Greater than 2 hours' AS movie_length, ROUND(AVG(avg_imdb_rating),2) avg_rating
FROM (
	SELECT AVG(r.imdb_rating) AS avg_imdb_rating
	FROM specs AS s
	INNER JOIN rating r
		USING(movie_id) 
	GROUP BY s.length_in_min
	HAVING s.length_in_min>=120
	)

-- ## Joins Exercise Bonus Questions

-- 1.	Find the total worldwide gross and average imdb rating by decade. Then alter your query so it returns JUST the second highest average imdb rating and its decade. This should result in a table with just one row.
/*NOTES:
- Table: rating, specs, revenue 
- release_year
- SUM, FLOOR
*/

SELECT
	SUM(rev.worldwide_gross) AS sum_gross
,	ROUND(AVG(rat.imdb_rating),2) AS avg_imdb
,	FLOOR(s.release_year/10)*10 AS decade
FROM specs AS s
	LEFT JOIN revenue AS rev
		ON s.movie_id = rev.movie_id
	LEFT JOIN rating AS rat
		ON s.movie_id = rat.movie_id
GROUP BY 
	decade
ORDER BY 
	avg_imdb DESC
LIMIT 1
OFFSET 1;
--ANS: 

-- 2.	Our goal in this question is to compare the worldwide gross for movies compared to their sequels.   
-- 	a.	Start by finding all movies whose titles end with a space and then the number 2. 

/*NOTES:
- specs, revenue
- movie_id, film_title
- filter: '% 2'
*/

--INITIAL ATTEMPT:
SELECT film_title
FROM specs
WHERE film_title ILIKE '% 2';
--INITIAL ANS: 18 records returned, see table*

-- 	b.	For each of these movies, create a new column showing the original film’s name by removing the last two characters of the film title. For example, for the film “Cars 2”, the original title would be “Cars”. Hint: You may find the string functions listed in Table 9-10 of https://www.postgresql.org/docs/current/functions-string.html to be helpful for this. 
-- 	c.	Bonus: This method will not work for movies like “Harry Potter and the Deathly Hallows: Part 2”, where the original title should be “Harry Potter and the Deathly Hallows: Part 1”. Modify your query to fix these issues.  
-- 	d.	Now, build off of the query you wrote for the previous part to pull in worldwide revenue for both the original movie and its sequel. Do sequels tend to make more in revenue? Hint: You will likely need to perform a self-join on the specs table in order to get the movie_id values for both the original films and their sequels. Bonus: A common data entry problem is trailing whitespace. In this dataset, it shows up in the film_title field, where the movie “Deadpool” is recorded as “Deadpool “. One way to fix this problem is to use the TRIM function. Incorporate this into your query to ensure that you are matching as many sequels as possible.

-- 3.	Sometimes movie series can be found by looking for titles that contain a colon. For example, Transformers: Dark of the Moon is part of the Transformers series of films.  
-- 	a.	Write a query which, for each film will extract the portion of the film name that occurs before the colon. For example, “Transformers: Dark of the Moon” should result in “Transformers”.  If the film title does not contain a colon, it should return the full film name. For example, “Transformers” should result in “Transformers”. Your query should return two columns, the film_title and the extracted value in a column named series. Hint: You may find the split_part function useful for this task.
-- 	b.	Keep only rows which actually belong to a series. Your results should not include “Shark Tale” but should include both “Transformers” and “Transformers: Dark of the Moon”. Hint: to accomplish this task, you could use a WHERE clause which checks whether the film title either contains a colon or is in the list of series values for films that do contain a colon.  
-- 	c.	Which film series contains the most installments?  
-- 	d.	Which film series has the highest average imdb rating? Which has the lowest average imdb rating?

-- 4.	How many film titles contain the word “the” either upper or lowercase? How many contain it twice? three times? four times? Hint: Look at the sting functions and operators here: https://www.postgresql.org/docs/current/functions-string.html 

-- 5.	For each distributor, find its highest rated movie. Report the company name, the film title, and the imdb rating. Hint: you may find the LATERAL keyword useful for this question. This keyword allows you to join two or more tables together and to reference columns provided by preceding FROM items in later items. See this article for examples of lateral joins in postgres: https://www.cybertec-postgresql.com/en/understanding-lateral-joins-in-postgresql/ 

-- 6.	Follow-up: Another way to answer 5 is to use DISTINCT ON so that your query returns only one row per company. You can read about DISTINCT ON on this page: https://www.postgresql.org/docs/current/sql-select.html. 

-- 7.	Which distributors had movies in the dataset that were released in consecutive years? For example, Orion Pictures released Dances with Wolves in 1990 and The Silence of the Lambs in 1991. Hint: Join the specs table to itself and think carefully about what you want to join ON. 