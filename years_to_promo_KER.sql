/*
This script places a number next to the name of each empoyee which counts how many times the employee's title changed and then it calculates
the time it took for the employee to be promoted. I elimanated results where the employee join and quickly left the company. This would give 
a very short change in title but falsely credit them with a metric of success.

*/

with salry 
		AS (select emp_no, max(from_date) as max_from from salaries group by emp_no)
update salry, titles 
		SET titles.to_date = date_add(salry.max_from, interval 1 year) 
        where salry.emp_no = titles.emp_no and titles.to_date > '3000-01-01';

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

select *
from(
		select 	t1.*, 
				count(*) as c,
				Round(datediff(t1.to_date,t1.from_date) / 365, 2) as years_to_promo
				
		from 	titles_emp as t1, 
				titles_emp as t2
				
		where t1.emp_no=t2.emp_no and t1.from_date <= t2.from_date
		group by t1.emp_no, t1.from_date
	) as d
    
where c > 1
order by years_to_promo;
