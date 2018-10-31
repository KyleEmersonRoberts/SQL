/* 
This script will find the growth in salary per year. It's written to find the highest average 
regardless of the amount of time between end points on the timeline. However, I've found the 
the rate at which people's salary grows seems to decreese with time, as one would expect, and
there are rarely high values of salary growth that span over a long period of time.

To make the results more interesting, I've set a bench mark to show which employees had 
the highest rate of change in salary over a period of three years
*/

SELECT 
    demographics.*,
    S2.salary,
    ROUND((s2.salary - s1.salary) * 365 / DATEDIFF(s2.to_date, s1.from_date)) AS Salary_Growth,
    ROUND(DATEDIFF(s2.to_date, s1.from_date) / 365) AS Time_Span
FROM
    (SELECT 
        hire_date,
            Salaries.emp_no,
            first_name,
            last_name,
            salary,
            from_date,
            to_date
    FROM
        salaries, employees
    WHERE
        salaries.emp_no = employees.emp_no) AS S1,
    salaries AS S2,
    demographics
WHERE
    S1.emp_no = S2.emp_no
        AND DATEDIFF(s2.to_date, s1.from_date) > 400 * 2
        AND demographics.emp_no = S1.emp_no
ORDER BY salary_growth DESC;

