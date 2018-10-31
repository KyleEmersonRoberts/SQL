
/* 
This script is the same as Average_Salary except it has an extra Total_Salary column that
 calculates the sum total of income that the employee made over the years.		
*/

SELECT 
    Demographics.*, Average_Salary, Total_Salary
FROM
    demographics,
    (SELECT 
        ROUND(SUM(salary * duration) / SUM(duration)) AS Average_Salary,
            Total_Salary,
            employees.emp_no
    FROM
        salaries
    LEFT JOIN (SELECT 
        DATEDIFF(to_date, from_date) AS duration, emp_no
    FROM
        salaries) AS Dury ON salaries.emp_no = Dury.emp_no
    LEFT JOIN employees ON salaries.emp_no = employees.emp_no
    LEFT JOIN (SELECT 
        ROUND(SUM(salary * DATEDIFF(to_date, from_date)) / 365) AS Total_Salary,
            emp_no
    FROM
        salaries
    GROUP BY emp_no) AS ttlsalry ON salaries.emp_no = ttlsalry.emp_no
    LEFT JOIN demographics ON demographics.emp_no = employees.emp_no
    GROUP BY salaries.emp_no) AS tot_sal
WHERE
    demographics.emp_no = tot_sal.emp_no
ORDER BY Total_Salary DESC;