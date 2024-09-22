-- 15 Business Problems & Solutions

--1. Count the number of Movies vs TV Shows

select

	type ,

	count(*)  as totat_count

from netflix 

group by type 



---2. Find the most common rating for movies and TV shows
select 
type , 
rating

from (
select 

type , rating,

count(*) ,

Rank() over(partition  by type order by count(* ) desc ) as ranking 	

from netflix

group by 1,  2 ) as t1	

where ranking  = 1

--order by 1, 3 DESC


--3. List all movies released in a specific year (e.g., 2020)

select * from netflix 
where 
type =  'Movie' and 
release_year  = 2020 


4. Find the top 5 countries with the most content on Netflix

select 
	unnest (string_to_array(country, ',')) as new_country,
	count(show_id) as total_content
from netflix
group by 1 
order by 2 desc
limit 5

--5. Identify the longest movie

 --syntax >> split_part(<string>,<delimiter>, <field_number>)


select * from 
 (select distinct title as movie,
  split_part(duration,' ',1):: int as lodurations 
  from netflix
  where type ='Movie') as subquery
where lodurations = (select max(split_part(duration,' ',1):: int ) from netflix)





--6. Find content added in the last 5 years and the count of movies and tv shows

--- TO_DATE(date_added, 'Month dd, YYYY')

select current_Date -Interval '5 years'

select  type,
	count (*) from netflix
	
where 
TO_DATE(date_added, 'Month dd, YYYY') >= current_Date -Interval '5 years'

group by 1


--7. Find all the movies/TV shows by director 'Rajiv Chilaka'!


SELECT *
FROM
(

SELECT 
	*,
	UNNEST(STRING_TO_ARRAY(director, ',')) as director_name
FROM 
netflix
)
WHERE 
	director_name = 'Rajiv Chilaka'


--8. List all TV shows with more than 5 seasons


SELECT *
FROM netflix
WHERE 
	TYPE = 'TV Show'
	AND
	SPLIT_PART(duration, ' ', 1)::INT > 5

	
-- 9. Count the number of content items in each genre


SELECT 
	UNNEST(STRING_TO_ARRAY(listed_in, ',')) as genre,
	COUNT(*) as total_content
FROM netflix
GROUP BY 1

--10.Find each year and the average numbers of content release in India on netflix. return top 5 year with highest avg content release!

select 

	EXTRACT( YEAR from TO_DATE(date_added, 'MONTH DD, YYYY')) as year, 
	count(*) as yearly_content,

	round(count(*)::numeric / (select count(*)  from netflix where country = 'India')* 100  
	, 2)as avg_content_per_year 
	
from netflix
where country  = 'India'
group by 1 

--solution 2

SELECT 
	country,
	release_year,
	COUNT(show_id) as total_release,
	ROUND(
		COUNT(show_id)::numeric/
								(SELECT COUNT(show_id) FROM netflix WHERE country = 'India')::numeric * 100 
		,2
		)
		as avg_release
FROM netflix
WHERE country = 'India' 
GROUP BY country, 2
ORDER BY avg_release DESC 
LIMIT 5

	

--11. List all movies that are documentaries


select * from netflix 

where listed_in ILIKE '%documentaries%'


--12. Find all content without a director

select * from netflix 
where director is null


--13. Find how many movies actor 'Salman Khan' appeared in last 10 years!

--  select extract (year from current_date)-10  from netflix

select * from netflix 
where
casts ILIKE '%Salman khan%'
and release_year > extract (year from current_date) - 10 

--14. Find the top 10 actors who have appeared in the highest number of movies produced in India.

select 
UNNEST(STRING_TO_ARRAY(casts, ','))as actors, 
count(*) as total_content
from netflix
where country ilike   '%india'
GROUP BY 1 order by 2 desc
limit 10
 
--15.Categorize the content based on the presence of the keywords 'kill' and 'violence' in the description field. 
--Label content containing these keywords as 'Bad' and all other content as 'Good'. 
--Count how many items fall into each category.

with new_table 
as (
select 
 *,  
case 
	when description ilike '%kill%'  OR
	 description ilike '%violence%' then 'Bad content ' 
	else   'good content'
end category 
from netflix
) 
select  category , count (*) as total_content

from new_table 
group by 1 



