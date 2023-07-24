-- Q1. Total number of records in the table "fp"

SELECT COUNT(*) FROM fp;




-- Q2. Display all records in the table

SELECT * FROM fp;




-- Q3. Rename two columns 'admin1' and 'admin2', to 'state' and 'city' respectively

ALTER TABLE fp
	RENAME COLUMN admin1 TO state;
ALTER TABLE fp
	RENAME COLUMN admin2 TO city;
ALTER TABLE fp
	RENAME COLUMN price_INR TO price;






-- Q4. Find out from how many states data are taken?

SELECT COUNT(distinct state) AS number_of_states
FROM fp
	WHERE state IS NOT NULL;





-- Q5. List the top 10 states that have the highest price of rice under the 'cereals and tubers' category with retail purchases.

SELECT state, max(price) as highest_retail_price
FROM fp
	WHERE commodity ='Rice' AND category ='cereals and tubers' AND pricetype = 'retail'
	GROUP BY 1
	ORDER BY highest_retail_price desc
	LIMIT 10;





-- Q6. List states and market which have had the highest prices of Rice under cereals and tubers category- Wholesale purchases

SELECT state, city, market, max(price) AS highest_wholesale_price
FROM fp
	WHERE category='cereals and tubers' AND pricetype='wholesale' AND commodity='rice'
	GROUP BY 1,2,3
    ORDER BY highest_wholesale_price desc;





-- Q7. Finding out the average retail price of oil and fats for each state, over the years.

SELECT state, count(state) AS entries, avg(price) AS average_price
FROM fp
	WHERE pricetype='retail'
	GROUP BY state
	ORDER BY average_price DESC;

-- rewrite above query such that the average price displays only 2 decimal digits

SELECT state, count(state) AS entries, cast( (avg(price)) AS DECIMAL(10,2) )  AS average_price
FROM fp
	WHERE pricetype='retail'
	GROUP BY state
	ORDER BY average_price DESC;





-- Q.8 List the average retail price, in descending order, for all the commodities under 'cereals and tubers' category.

SELECT category, commodity, cast( (avg(price)) AS DECIMAL(10,2)) as average_price
FROM fp
	WHERE category ='cereals and tubers' AND pricetype='retail'
    GROUP BY 1, 2
    ORDER BY average_price DESC;

    
    


-- Q.9 Display the average price of sugar in the states of Orissa, TamilNadu, and Kerala during the year 1994
-- SOLUTION: perform UNION between 3 separate queries
    
SELECT  state, commodity, avg(price) AS average_price_1994
FROM fp
		WHERE date BETWEEN '01/01/1994' AND '31/12/1994'
        AND state='Orissa'
        AND commodity='Sugar'
        
UNION

SELECT  state, commodity, avg(price) AS average_price_1994
FROM fp
		WHERE date BETWEEN '01/01/1994' AND '31/12/1994'
        AND state='Tamil Nadu'
        AND commodity='Sugar'
        
UNION

SELECT  state, commodity, avg(price) AS average_price_1994
FROM fp
		WHERE date BETWEEN '01/01/1994' AND '31/12/1994'
        AND state='Kerala'
        AND commodity='Sugar'
        
ORDER BY average_price_1994;








-- Q.10 Display the average price of sugar in the state of Kerala during the year 1994 and 2005
-- Solution: alias 2 separate queries

SELECT k1.state, k1.commodity, k1.avg_price_1994, k2.avg_price_2005    -- may be also rewritten as "SELECT * "
FROM
	(
    SELECT state, commodity, avg(price) AS avg_price_1994
	FROM fp
			WHERE date BETWEEN '01/01/1994' AND '31/12/1994'
			AND state='Kerala'
			AND commodity='Sugar'
	) AS k1,
	(
	SELECT avg(price) AS avg_price_2005
	FROM fp
			WHERE date BETWEEN '01/01/2005' AND '31/12/2005'
			AND state='Kerala'
			AND commodity='Sugar'
	) AS k2;







-- Q.11 Create a new table called 'Zone'. 
-- Update this new table such that all the Indian states are classified into five zones: South, Central, North, NorthEast, West

-- created new table 'z'
DROP TABLE if exists z;
CREATE TABLE z
(	state Varchar(200),
    zone Varchar(100),
    PRIMARY KEY (state)
);


-- insert distinct state names from table-fp to table-z
INSERT INTO z (state, zone)
SELECT Distinct state, null
FROM fp
WHERE state IS NOT Null;


SELECT * FROM z ORDER BY state;
SELECT Count(*) FROM z;

-- if you want to remove any records where state=null in table-z, use below syntax
-- DELETE FROM z WHERE state IS NULL;


-- update all records in table-z to display corresponding zones
UPDATE z  
	SET zone='South' 
    WHERE state IN ('Kerala', 'Tamil Nadu', 'Telangana', 'Andhra Pradesh', 'Karnataka', 'Maharashtra', 'Goa');
        
UPDATE z  
	SET zone='North' 
    WHERE state IN ('Himachal Pradesh','Punjab', 'Uttarakhand', 'Uttar Pradesh', 'Haryana', 'Delhi', 'Chandigarh');
    
UPDATE z  
	SET zone='West' 
    WHERE state IN ('Rajasthan','Gujarat');
    
UPDATE z  
	SET zone='Central' 
    WHERE state IN ('Madhya Pradesh','Chattisgarh');

UPDATE z  
	SET zone='East' 
    WHERE state IN ('Orissa','West Bengal','Bihar','Jharkand');

UPDATE z  
	SET zone='NorthEast' 
    WHERE state IN ('Sikkim','Assam','Nagaland', 'Manipur', 'Mizoram','Tripura','Meghalaya','Arunachal Pradesh');
    
SELECT * FROM z ORDER BY zone;







-- Q.12 Display state, city, market, and corresponding zones
-- SOLUTION: to display only the distinct states, use INNER JOIN

SELECT distinct fp.state, fp.city, fp.market, z.zone
FROM fp
JOIN z
ON fp.state = z.state
ORDER BY z.zone;








-- Q.13 Display states, corresponding zone, and the total number of commodities sold per state
-- Solution: 
-- Using WITH clause, create a temporary table (temp1) to count number of commodities sold in each state.
-- merge this temp1 with another temporary table (temp2).
-- finally, display output from temp2.

WITH
    temp1 AS 
	(
		SELECT DISTINCT state, count(distinct commodity) AS tot_count_commodities
		FROM fp
		GROUP BY state
    ),
    temp2 AS
    (
		SELECT temp1.state, z.zone, temp1.tot_count_commodities
		FROM temp1
		JOIN z
		ON temp1.state = z.state
	)
SELECT *
FROM temp2
ORDER BY tot_count_commodities DESC;







-- Q.14 For all the commodities, list the average wholesale price and average retail price.

SELECT r.commodity, r.retail_avg_price, w.wholesale_avg_price

FROM
	(
	SELECT DISTINCT commodity, avg(price) AS retail_avg_price
	FROM fp
		WHERE pricetype='retail'
		GROUP BY commodity
	) AS r
    
LEFT JOIN
	(
		SELECT DISTINCT commodity, avg(price) AS wholesale_avg_price
		FROM fp
			WHERE pricetype='wholesale'
			GROUP BY commodity
	) AS w
    
ON r.commodity = w.commodity;







-- Q.15 Average retail price of all commodities zone wise
-- Solution: 
-- create a virtual table using CREATE VIEW statement. And, insert the required columns from table-fp and table-z.
-- print the average price from this virtual table, grouped by i) zone,  ii)category, iii)commodity

CREATE VIEW commodity_prices AS
	SELECT fp.state, z.zone, fp.category, fp.commodity, fp.unit, fp.pricetype, fp.price
	FROM z
	JOIN fp
	WHERE z.state = fp.state AND fp.pricetype='retail';

SELECT * FROM commodity_prices;

-- to delete view
-- DROP VIEW commodity_prices;

-- print the average prices zone wise
SELECT zone, category, commodity, AVG(price) as avg_price
FROM commodity_prices
	GROUP BY 1, 2, 3
	ORDER BY 1, 2, avg_price DESC;
