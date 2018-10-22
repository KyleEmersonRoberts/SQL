/*
Update Titles SET to_date = date_add(max(salaries.from_date), interval 1 year) where to_date > '3000-01-01';

The most interesting thing to look at would be the time in between title changes. Also, did their title change at all? If someone came in from a different company
as a senior level person, then naturally they'll have the highest income.



I think I'm going to need to fix this issue with the to_dates
*/

/* This update is only necessary because the data set that I'm using has erronious values for to_dates when it's the employees last year in the company
	This final to_date is usually something like 9999-01-01 which really messes up a lot of my math, so I go into salary and find the from_date of this 
    final year and add one year to it. Annoying! But a good problem for me to learn to solve.*/
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
