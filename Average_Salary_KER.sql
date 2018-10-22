
/* 
The data in this DB has most people getting promoted after one year. I've written it to get the right answer with an arbitrary amount of time assosiated with each pay scale

The results produce a table of employees who have the highest average salary
*/
set sql_safe_updates=0;
update salaries SET to_date = date_add(from_date, interval 1 year) where to_date > '3000-01-01';

select distinct gender,
				birth_date, 
				Round(datediff(max(to_date),hire_date) / 365) as Years_Worked, 
                employees.emp_no, 
                first_name, 
                last_name, 
                hire_date, 
                max(to_date) as last_day, 
                Round(sum(salary*duration)/sum(duration)) as Average_Salary
                
from salaries 	left join (select datediff(to_date, from_date) as duration, emp_no from salaries) as Dury on salaries.emp_no=Dury.emp_no 
				left join employees on dury.emp_no=employees.emp_no
                
group by employees.emp_no
order by Average_Salary DESC;