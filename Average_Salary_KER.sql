
/* 
The data in this DB has most people getting promoted after one year. I've written it to get
the right answer with an arbitrary amount of time assosiated with each pay scale

The results produce a table of employees who have the highest average salary
*/

SELECT DISTINCT
    demographics.*,
    ROUND(DATEDIFF(MAX(salaries.to_date),
                    demographics.hire_date) / 365) AS Years_Worked,
    ROUND(SUM(salary * duration) / SUM(duration)) AS Average_Salary
FROM
    salaries
        LEFT JOIN
    (SELECT 
        DATEDIFF(to_date, from_date) AS duration, emp_no
    FROM
        salaries) AS Dury ON salaries.emp_no = Dury.emp_no
        LEFT JOIN
    employees ON dury.emp_no = employees.emp_no
        LEFT JOIN
    demographics ON demographics.emp_no = employees.emp_no
GROUP BY employees.emp_no
ORDER BY Average_Salary DESC;