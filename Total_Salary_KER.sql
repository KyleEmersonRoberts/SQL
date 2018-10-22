
/* 
The data in this DB has everyone getting promoted after one year exactly. This script could be simplified with a Count or a simple sum function
to calculate things like avg salary. But I did it the hard way that would allow tuples to have arbitrary date ranges.
*/
set sql_safe_updates=0;
update salaries SET to_date = date_add(from_date, interval 1 year) where to_date > '3000-01-01';

select distinct gender,
				birth_date, 
				Round(datediff(max(to_date),hire_date) / 365) as Years_Worked, 
                salaries.emp_no, 
                first_name, 
                last_name, 
                hire_date, 
                max(to_date) as last_day, 
                Round(sum(salary*duration)/sum(duration)) as Average_Salary,
                Total_Salary
                
from salaries 	left join (select datediff(to_date, from_date) as duration, emp_no from salaries) as Dury on salaries.emp_no=Dury.emp_no 
				left join employees on salaries.emp_no=employees.emp_no
                left join (select Round(sum(salary*datediff(to_date, from_date))/365) as Total_Salary, emp_no from salaries group by emp_no) as ttlsalry on salaries.emp_no=ttlsalry.emp_no
                
group by salaries.emp_no
order by Total_Salary DESC;