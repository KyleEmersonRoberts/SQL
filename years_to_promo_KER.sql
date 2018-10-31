/*
This script places a number next to the name of each empoyee which counts how many times 
the employee's title changed and then it calculates the time it took for the employee to
be promoted. I elimanated results where the employee join and quickly left the company. 
This would give a very short change in title but falsely credit them with a metric of success.

*/

with titles_emp
		AS (
        
        select 	titles.emp_no,
					first_name,
					last_name,
					title,
					titles.from_date,
					titles.to_date
				

			from titles, employees
			where titles.emp_no=employees.emp_no
			order by employees.emp_no)

SELECT 
    demographics.*, c, years_to_promo
FROM
    (SELECT 
        t1.*,
            COUNT(*) AS c,
            ROUND(DATEDIFF(t1.to_date, t1.from_date) / 365, 2) AS years_to_promo
    FROM
        titles_emp AS t1, titles_emp AS t2
    WHERE
        t1.emp_no = t2.emp_no
            AND t1.from_date <= t2.from_date
    GROUP BY t1.emp_no , t1.from_date) AS d,
    demographics
WHERE
    c > 1 AND demographics.emp_no = d.emp_no
        AND d.from_date = demographics.from_date
        AND d.title = demographics.title
ORDER BY years_to_promo
LIMIT 2000;