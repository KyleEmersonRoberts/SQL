/*

This script creates a table called demographics and stores the subsiquent query within it. The 
query pulls a bunch of descriptive information from other tables but also calculates the timelines
of department transfers for each employee and their managers.

What made this scipt much more complicated than expected was that the data from this fake database 
had start and end points set equal. I had to replace end points with starting points of a subsiquent
transfer timelines, or if the employee never transfered departments, I had to find the final date
of their salary payments and use that as the correct endpoint.

Once that's done, I have a conditional statement that calculates the correct time span that an 
employee was managed by a manager given the relative positions of end points on these timelines.

*/

use employees;
drop table if exists demographics; 
CREATE TABLE Demographics (
	emp_no		int				not null,
    dept_no		char(4)			not null,
    Emp_name 	char(50)		not null,
    gender      ENUM ('M','F')  NOT NULL,    
    birth_date  DATE            NOT NULL,
    hire_date	DATE			NOT NULL,
    from_date	DATE			NOT NULL,
    to_date		DATE			NOT NULL,
    title		char(50)		NOT NULL,
    `Emp_For(years):`	float			not null,
    dept_name	char(50)		not null,
    Mnger_name	char(50)		not null,
    `Mnger_For(years):` float		not null,
PRIMARY KEY(emp_no, dept_no, title, from_date, Mnger_name, `Emp_For(years):`, `Mnger_For(years):`)
);


insert into demographics  

/*	This common table calculates the last day that each employee is logged as receiving a salary. 
	I assume this to be their final date of employment.*/
with last_Date as (SELECT 
        emp_no, MAX(to_date) AS to_date
    FROM
        salaries
    GROUP BY emp_no
    ORDER BY MAX(to_date) DESC)


select	distinct tablex.*,
		title,
        datediff(titles.to_date, titles.from_date) / 365 as `Emp_For(years):`,
		dept_name,
		Manager.Mngr_name,
        #	These conditional statements determine how the timelines of an employee and their manager overlaps
        #	by looking at end points and then returns the propper difference
		(CASE
        WHEN
            tablex.from_date <= Manager.from_date
                AND tablex.to_date >= Manager.to_date	 
        THEN											
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
		END) AS `Mngr_For(years):`
        		 
from(
		select 	distinct dept_emp.emp_no, 
				dept_emp.dept_no,
				concat(first_name, ' ',
				last_name) as Emp_Name,
                gender,
                birth_date,
                hire_date,
				dept_emp.from_date, 
				if(trans_span.from_date is null, last_date.to_date, trans_span.to_date) as to_date
			   
			/* 	The trans_span table finds only rows with an employee who changed departments
				by doing an inner join of the emp_dept table with itself, grouping on empoyee id, 
                and matching only tuples in the group that have a start date greater than it's own.
                I also calculate a difference so the time in that department can be calculated.
                
                Then I left join this table back with emp_date and mark the rows left out as null.
                These null rows are examples were the from_date for a given employee was the max,
                meaning this was the final deptartment the employee was in. After this is working,
                the script is simple.
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
) as tablex, 
	(select 	concat(first_name, ' ', last_name) as Mngr_name, 
							dept_manager.emp_no, 
							dept_no, 
							from_date, 
							to_date, 
							birth_date, 
							gender, 
							hire_date 
					from dept_manager, employees 
					where dept_manager.emp_no = employees.emp_no
) as Manager, 
departments,
titles

where tablex.dept_no = Manager.dept_no and manager.to_date > tablex.from_date and manager.from_date < tablex.to_date and departments.dept_no = tablex.dept_no and titles.emp_no = tablex.emp_no;
