
-- Create 'departments' table
CREATE TABLE departments (
    id int  PRIMARY KEY auto_increment,
    name VARCHAR(50),
    manager_id INT
);

-- Create 'employees' table
CREATE TABLE employees (
    id int  PRIMARY KEY auto_increment,
    name VARCHAR(50),
    hire_date DATE,
    job_title VARCHAR(50),
    department_id INT REFERENCES departments(id)
);

-- Create 'projects' table
CREATE TABLE projects (
    id int PRIMARY KEY auto_increment,
    name VARCHAR(50),
    start_date DATE,
    end_date DATE,
    department_id INT REFERENCES departments(id)
);

-- Insert data into 'departments'
INSERT INTO departments (name, manager_id)
VALUES ('HR', 1), ('IT', 2), ('Sales', 3);

-- Insert data into 'employees'
INSERT INTO employees (name, hire_date, job_title, department_id)
VALUES ('John Doe', '2018-06-20', 'HR Manager', 1),
       ('Jane Smith', '2019-07-15', 'IT Manager', 2),
       ('Alice Johnson', '2020-01-10', 'Sales Manager', 3),
       ('Bob Miller', '2021-04-30', 'HR Associate', 1),
       ('Charlie Brown', '2022-10-01', 'IT Associate', 2),
       ('Dave Davis', '2023-03-15', 'Sales Associate', 3);

-- Insert data into 'projects'
INSERT INTO projects (name, start_date, end_date, department_id)
VALUES ('HR Project 1', '2023-01-01', '2023-06-30', 1),
       ('IT Project 1', '2023-02-01', '2023-07-31', 2),
       ('Sales Project 1', '2023-03-01', '2023-08-31', 3);
       
       UPDATE departments
SET manager_id = (SELECT id FROM employees WHERE name = 'John Doe')
WHERE name = 'HR';

UPDATE departments
SET manager_id = (SELECT id FROM employees WHERE name = 'Jane Smith')
WHERE name = 'IT';

UPDATE departments
SET manager_id = (SELECT id FROM employees WHERE name = 'Alice Johnson');

select * from departments;

select * from employees;

select * from projects;

-- 1.Find the longest ongoing project for each department

SELECT d.name, 
       p.name, 
       datediff(end_date,start_date) AS project_duration
FROM departments d
LEFT JOIN projects p
ON d.id = p.department_id ;

-- 2.Find all employees that are not managers

SELECT *
FROM employees 
WHERE job_title NOT LIKE   '%Manager';
                 
-- 3.Find all employees who have been hired after the start of a project in their department.

SELECT e.id,
       e.name,
       d.name AS department_name,
	   p.name AS project_name,
	   e.hire_date,
       p.start_date AS project_start_date
FROM employees e
JOIN departments d
ON e.department_id = d.id
JOIN projects p 
ON d.id = p.department_id
WHERE hire_date > p.start_date ;

-- 4. Rank employees within each department based on their hire date (earliest hire gets the highest rank).

SELECT e.name, 
       e.hire_date, 
       d.name AS department_name,
       RANK() OVER(PARTITION BY d.name ORDER BY hire_date ) AS employee_rank
FROM employees AS e
LEFT JOIN departments AS d 
ON e.department_id = d.id;    

-- 5.Find the duration between the hire date of each employee and the hire date of the next employee hired in the same department.
WITH hire_duration AS (     
   SELECT emp.name AS employee_name,
          emp.hire_date,
          dept.name AS department_name,
          ROW_NUMBER() OVER(PARTITION BY dept.name ORDER BY hire_date) AS rnk,
          LEAD(emp.name) OVER(PARTITION BY dept.name ORDER BY hire_date) AS new_hire,
		  LEAD(hire_date) OVER(PARTITION BY dept.name ORDER BY hire_date) AS next_hire
   FROM employees AS emp
   JOIN departments AS dept
   ON emp.department_id = dept.id)
   SELECT department_name, 
          employee_name,
          hire_date AS first_hire,
          new_hire,
          next_hire,
          datediff(next_hire,hire_date) AS hire_date_difference
   FROM hire_duration
   WHERE rnk = 1 ;
   