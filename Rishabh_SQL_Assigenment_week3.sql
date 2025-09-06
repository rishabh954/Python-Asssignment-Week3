CREATE DATABASE Tsak_Mangement;
USE Tsak_Mangement;

-- create table for projects table
CREATE TABLE Projects (
	project_id INT PRIMARY KEY,
	project_name VARCHAR(100),
    start_date DATE,
    end_date DATE,
    budget DECIMAL(12,2),
    manger_id INT
);

-- insert value for  projects table 
INSERT INTO Projects VALUES
(1, 'AI Chatbot', '2024-01-01', '2024-06-01', 50000, 101),
(2, 'E-commerce Platform', '2024-02-01', '2024-07-15', 80000, 102),
(3, 'Healthcare System', '2024-03-01', '2024-08-30', 120000, 103),
(4, 'Banking App', '2024-04-01', '2024-10-10', 95000, 104),
(5, 'Game Development', '2024-05-01', '2024-11-15', 70000, 105);

-- icreate table for team
CREATE TABLE Team(
	team_id INT PRIMARY KEY,
    member_name VARCHAR(100),
    role VARCHAR(100),
    email VARCHAR(100) UNIQUE,
    PHONE VARCHAR(15)
);
-- insert value for team table
INSERT INTO Team VALUES
(101, 'Alice', 'Manager', 'alice@company.com', '9991112222'),
(102, 'Bob', 'Team Lead', 'bob@company.com', '8881112222'),
(103, 'Charlie', 'Developer', 'charlie@company.com', '7771112222'),
(104, 'David', 'Developer', 'david@company.com', '6661112222'),
(105, 'Eva', 'Team Lead', 'eva@company.com', '5551112222');

-- Create table for tasks
CREATE TABLE Tasks(
	task_id INT PRIMARY KEY,
    project_id INT,
    task_name VARCHAR(100),
    assigned_to INT,
    due_date DATE,
    status VARCHAR(15),
    FOREIGN KEY (project_id) REFERENCES Projects(project_id),
    FOREIGN KEY (assigned_to) REFERENCES Team(team_id)
);

-- insert value for tasks table
INSERT INTO Tasks VALUES
(201, 1, 'Build NLP model', 103, '2024-05-15', 'Completed'),
(202, 1, 'Integrate chatbot UI', 104, '2024-05-25', 'Pending'),
(203, 2, 'Set up payment gateway', 102, '2024-06-01', 'Completed'),
(204, 3, 'Develop patient module', 105, '2024-07-15', 'Pending'),
(205, 4, 'Security testing', 103, '2024-09-20', 'Pending');

-- Using CTE: project_name, total_tasks, completed_tasks
SELECT p.project_name, COUNT(t.task_id) as total_task, SUM(t.status ='Completed')as complete_task  from Projects as p
LEFT JOIN Tasks as t ON p.project_id = t.project_id
GROUP BY p.project_name;

-- Top 2 team members with highest number of tasks
SELECT member_name, task_count
FROM (
    SELECT tm.member_name,
           COUNT(ts.task_id) AS task_count,
           RANK() OVER (ORDER BY COUNT(ts.task_id) DESC) AS rnk
    FROM Team tm
    JOIN Tasks ts ON tm.team_id = ts.assigned_to
    GROUP BY tm.member_name
) ranked
WHERE rnk <= 2;

-- Correlated subquery: tasks with due_date earlier than avg due_date of project
SELECT t.task_id, t.task_name, t.due_date, t.project_id
FROM Tasks t
WHERE t.due_date < (
    SELECT AVG(t2.due_date)
    FROM Tasks t2
    WHERE t2.project_id = t.project_id
);

-- Project(s) with maximum budget
SELECT project_name, budget FROM Projects
WHERE budget = (SELECT MAX(budget) FROM Projects);

-- Percentage of completed tasks per project
SELECT p.project_name,
       ROUND(100.0 * SUM(CASE WHEN t.status='Completed' THEN 1 ELSE 0 END) / COUNT(t.task_id), 2) AS completion_percentage
FROM Projects p
JOIN Tasks t ON p.project_id = t.project_id
GROUP BY p.project_name;

-- Window function: each task with count of tasks per person
SELECT t.task_name, tm.member_name,
       COUNT(*) OVER (PARTITION BY t.assigned_to) AS task_count
FROM Tasks t
JOIN Team tm ON t.assigned_to = tm.team_id
ORDER BY tm.member_name;

-- Tasks assigned to team leads, not completed, due in next 15 days
SELECT t.task_id, t.task_name, tm.member_name, t.due_date
FROM Tasks t
JOIN Team tm ON t.assigned_to = tm.team_id
WHERE tm.role = 'Team Lead'
  AND t.status != 'Completed'
  AND t.due_date BETWEEN CURDATE() AND (CURDATE() + INTERVAL 15 DAY);

-- Projects with no tasks
SELECT p.project_name
FROM Projects p
LEFT JOIN Tasks t ON p.project_id = t.project_id
WHERE t.task_id IS NULL;

-- Model Training table
CREATE TABLE Model_Training (
    training_id INT PRIMARY KEY,
    project_id INT,
    model_name VARCHAR(100),
    accuracy DECIMAL(5,2),
    training_date DATE,
    FOREIGN KEY (project_id) REFERENCES Projects(project_id)
);

-- Data Sets table
CREATE TABLE Data_Sets (
    dataset_id INT PRIMARY KEY,
    project_id INT,
    dataset_name VARCHAR(100),
    size_gb DECIMAL(6,2),
    last_updated DATE,
    FOREIGN KEY (project_id) REFERENCES Projects(project_id)
);

-- Model Training value-- 
INSERT INTO Model_Training VALUES
(301, 1, 'GPT-small', 87.5, '2024-05-01'),
(302, 1, 'GPT-large', 92.3, '2024-05-20'),
(303, 2, 'RecSys-v1', 85.0, '2024-06-10'),
(304, 3, 'MedAI-v2', 90.1, '2024-07-01'),
(305, 4, 'BankAI-secure', 88.7, '2024-08-15');

-- Data Sets Values
INSERT INTO Data_Sets VALUES
(401, 1, 'Chat logs', 12.5, '2024-05-28'),
(402, 2, 'User purchases', 9.2, '2024-06-15'),
(403, 3, 'Patient records', 15.0, '2024-08-01'),
(404, 4, 'Transactions', 20.0, '2024-08-20'),
(405, 5, 'Game assets', 5.0, '2024-07-10');

-- Best AI model per project
SELECT mt.project_id, p.project_name, mt.model_name, mt.accuracy
FROM Model_Training mt
JOIN Projects p ON mt.project_id = p.project_id
WHERE mt.accuracy = (
    SELECT MAX(mt2.accuracy)
    FROM Model_Training mt2
    WHERE mt2.project_id = mt.project_id
);

-- Projects with datasets > 10GB updated in last 30 days-- 
SELECT p.project_name, d.dataset_name, d.size_gb, d.last_updated
FROM Data_Sets d
JOIN Projects p ON d.project_id = p.project_id
WHERE d.size_gb > 10
  AND d.last_updated >= CURDATE() - INTERVAL 30 DAY;