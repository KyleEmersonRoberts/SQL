/* This script will find the growth in salary per year. It's written to find the highest average regardless of the amount of time between data points.
However, I've found the the rate at which people's salary grows seems to decreese with time, and there are rarely high values of salary growth that span
over a long period of time.*/

select 	hire_date, 
		S2.emp_no,
        first_name,
        last_name,
        S2.salary,
        S1.from_date,
        S2.to_date, 
        Round((s2.salary-s1.salary) * 365 / datediff(s2.to_date,s1.from_date)) as Salary_Growth,
        Round(datediff(s2.to_date,s1.from_date) / 365) as Time_Span
        
        
from 	(select hire_date, Salaries.emp_no,first_name,last_name,salary, from_date,to_date from salaries, employees where salaries.emp_no=employees.emp_no) as S1, 
		salaries as S2
 
where 	S1.emp_no=S2.emp_no and datediff(s2.to_date,s1.from_date) > 400*2 /* this allows you to filter the results of the derivative to custom time spans*/ 

ORDER BY salary_growth desc