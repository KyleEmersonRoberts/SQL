/*
This script returns the start and ending dates of the different departments that each employee worked in. It also returns the manager
the employee had along with the number of years the manager supervised them.

What made this scipt much more complicated thanI expected was that the data from this fake database had start and end points equal for all tuples.
I had to replace to_dates to equal the from_dates of a subsiquent transfer, or if the employee never transfered departments, I had to find the final
date of their salary payments and use that as the correct endpoint.


*/

/*
This common table calculates the last day that each employee is logged as receiving a salary. I assume this to be their final date of employment. This
is a really important number because it allows me to find the final end point. If the data given by the original source had correctly set the end points
of these deptartment timelines, this wouldn't be necessary. To make this project more interesting, I'm just setting their employment end date to be the
end date of their foremost deptartment.
*/

with last_Date as (SELECT 
        emp_no, MAX(to_date) AS to_date
    FROM
        salaries
    GROUP BY emp_no
    ORDER BY MAX(to_date) DESC)
    

  
select	tablex.*,
		Manager._name,
		(CASE
        WHEN
            tablex.from_date <= Manager.from_date
                AND tablex.to_date >= Manager.to_date	/* These conditional statements determine how the timelines of an employee and their manager overlaps */
        THEN											/*	and then returns the propper difference */
            DATEDIFF(Manager.to_date,
                    Manager.from_date) / 365
        WHEN
            tablex.from_date >= Manager.from_date
                AND tablex.to_date >= Manager.to_date
        THEN
            DATEDIFF(Manager.to_date, tablex.from_date) / 365
        WHEN
            tablex.from_date <= Manager.from_date
                AND tablex.to_date <= Manager.to_date
        THEN
            DATEDIFF(tablex.to_date, Manager.from_date) / 365
        WHEN tablex.from_date >= Manager.from_date and tablex.to_date <= Manager.to_date
        then datediff(tablex.to_date, tablex.from_date) / 365
        else 0
    END) AS `For(years):`
		 
from(
		select 	distinct dept_emp.emp_no, 
				dept_emp.dept_no,
				first_name, 
				last_name, 
				dept_emp.from_date, 
				if(trans_span.from_date is null, last_date.to_date, trans_span.to_date) as to_date
			   
			/* 	
				The following series of joins is where the magic happens in this script. The trans_span table finds the rows with an employee who changed departments
				by doing an inner join of the emp_dept table with it self, grouping on empoyee id, and matching only tuples in the group that have a start date greater
                than it's own. I also calculate a difference so the time in that department can be calculated.
                
                Then I left join this table back with emp_date and mark the rows left out as null. These null rows are examples were the from_date for a given employee 
                was the max, meaning this was the final deptartment the employee was in. After this is working, the script is simple.
			*/	
               
		from 	dept_emp left join 
				(select datediff(w2.to_date, w1.from_date), 
						w1.emp_no, 
                        w1.from_date, 
                        w2.to_date 
				 from dept_emp as w1, dept_emp as w2 
				 where w1.emp_no = w2.emp_no and w1.from_date < w2.to_date group by emp_no, w1.from_date order by w1.emp_no) as trans_span
				 on dept_emp.emp_no = trans_span.emp_no and dept_emp.from_date = trans_span.from_date, employees, last_date
			 
		where employees.emp_no = dept_emp.emp_no and last_date.emp_no = dept_emp.emp_no
		order by emp_no
) as tablex, (select concat(first_name, ' ', last_name) as _name, dept_manager.emp_no, dept_no, from_date, to_date from dept_manager, employees where dept_manager.emp_no = employees.emp_no) as Manager

where tablex.dept_no = Manager.dept_no and manager.to_date > tablex.from_date and manager.from_date < tablex.to_date

order by emp_no;