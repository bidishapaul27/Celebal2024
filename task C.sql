-- Task 1

CREATE TABLE Projects (
    Task_ID INT,
    Start_Date DATE,
    End_Date DATE
);

INSERT INTO Projects (Task_ID, Start_Date, End_Date) VALUES
(1, '2015-10-01', '2015-10-02'),
(2, '2015-10-02', '2015-10-03'),
(3, '2015-10-03', '2015-10-04'),
(4, '2015-10-13', '2015-10-14'),
(5, '2015-10-14', '2015-10-15'),
(6, '2015-10-28', '2015-10-29'),
(7, '2015-10-30', '2015-10-31');

WITH ProjectBoundaries AS (
    SELECT 
        Task_ID, 
        Start_Date, 
        End_Date,
        CASE 
            WHEN LAG(End_Date) OVER (ORDER BY Start_Date) = Start_Date - INTERVAL '1 DAY' THEN 0 
            ELSE 1 
        END AS IsNewProject
    FROM 
        Projects
),
ProjectGroups AS (
    SELECT 
        Task_ID, 
        Start_Date, 
        End_Date,
        SUM(IsNewProject) OVER (ORDER BY Start_Date) AS Project_Number
    FROM 
        ProjectBoundaries
),
ProjectDates AS (
    SELECT 
        Project_Number,
        MIN(Start_Date) AS Project_Start_Date,
        MAX(End_Date) AS Project_End_Date,
        COUNT(*) AS Project_Days
    FROM 
        ProjectGroups
    GROUP BY 
        Project_Number
)
SELECT 
    Project_Start_Date, 
    Project_End_Date
FROM 
    ProjectDates
ORDER BY 
    Project_Days ASC, 
    Project_Start_Date ASC;



-- Task 2

CREATE TABLE Students (
    ID INT,
    Name VARCHAR(50)
);

INSERT INTO Students (ID, Name) VALUES
(1, 'Ashley'),
(2, 'Samantha'),
(3, 'Julia'),
(4, 'Scarlet');


CREATE TABLE Friends (
    ID INT,
    Friend_ID INT
);

INSERT INTO Friends (ID, Friend_ID) VALUES
(1, 2),
(2, 3),
(3, 4),
(4, 1);

CREATE TABLE Packages (
    ID INT,
    Salary FLOAT
);

INSERT INTO Packages (ID, Salary) VALUES
(1, 15.20),
(2, 10.06),
(3, 11.55),
(4, 12.12);


WITH Student_Salaries AS (
    SELECT
        s.ID AS Student_ID,
        s.Name AS Student_Name,
        p.Salary AS Student_Salary,
        f.Friend_ID AS Best_Friend_ID
    FROM
        Students s
        JOIN Friends f ON s.ID = f.ID
        JOIN Packages p ON s.ID = p.ID
),
Friend_Salaries AS (
    SELECT
        s.ID AS Best_Friend_ID,
        s.Name AS Best_Friend_Name,
        p.Salary AS Best_Friend_Salary
    FROM
        Students s
        JOIN Packages p ON s.ID = p.ID
)
SELECT
    ss.Student_Name
FROM
    Student_Salaries ss
    JOIN Friend_Salaries fs ON ss.Best_Friend_ID = fs.Best_Friend_ID
WHERE
    fs.Best_Friend_Salary > ss.Student_Salary
ORDER BY
    fs.Best_Friend_Salary;

-- Task 3

CREATE TABLE Pairs (
    X INT,
    Y INT
);

INSERT INTO Pairs (X, Y) VALUES
(20, 20),
(20, 20),
(20, 21),
(23, 22),
(22, 23),
(21, 20);


SELECT DISTINCT
    t1.X,
    t1.Y
FROM
    Pairs t1
JOIN
    Pairs t2 ON t1.X = t2.Y AND t1.Y = t2.X
WHERE
    t1.X <= t1.Y
ORDER BY
    t1.X, t1.Y;

-- Task 4

CREATE TABLE Contests (
    contest_id INT PRIMARY KEY,
    hacker_id INT,
    name VARCHAR(100)
);

INSERT INTO Contests (contest_id, hacker_id, name) VALUES
(66406, 17973, 'Rose'),
(66556, 79153, 'Angela'),
(94828, 80275, 'Frank');

CREATE TABLE Colleges (
    college_id INT PRIMARY KEY,
    contest_id INT
);

INSERT INTO Colleges (college_id, contest_id) VALUES
(11219, 66406),
(32473, 66556),
(56685, 94828);

CREATE TABLE Challenges (
    challenge_id INT PRIMARY KEY,
    college_id INT
);

INSERT INTO Challenges (challenge_id, college_id) VALUES
(18765, 11219),
(47127, 11219),
(60292, 32473),
(72974, 56685);

CREATE TABLE View_Stats (
    challenge_id INT,
    total_views INT,
    total_unique_views INT
);

INSERT INTO View_Stats (challenge_id, total_views, total_unique_views) VALUES
(47127, 26, 19),
(47127, 15, 14),
(18765, 43, 10),
(18765, 72, 13),
(75516, 35, 17),
(60292, 11, 10),
(72974, 41, 15),
(75516, 75, 11);

CREATE TABLE Submission_Stats (
    challenge_id INT,
    total_submissions INT,
    total_accepted_submissions INT
);

INSERT INTO Submission_Stats (challenge_id, total_submissions, total_accepted_submissions) VALUES
(75516, 34, 12),
(47127, 27, 10),
(47127, 56, 18),
(75516, 74, 12),
(75516, 83, 8),
(72974, 68, 24),
(72974, 82, 14),
(47127, 28, 11);


SELECT
    c.contest_id,
    c.hacker_id,
    c.name,
    SUM(s.total_submissions) AS total_submissions,
    SUM(s.total_accepted_submissions) AS total_accepted_submissions,
    SUM(v.total_views) AS total_views,
    SUM(v.total_unique_views) AS total_unique_views
FROM
    Contests c
JOIN Colleges cl ON c.contest_id = cl.contest_id
JOIN Challenges ch ON cl.college_id = ch.college_id
LEFT JOIN Submission_Stats s ON ch.challenge_id = s.challenge_id
LEFT JOIN View_Stats v ON ch.challenge_id = v.challenge_id
GROUP BY
    c.contest_id,
    c.hacker_id,
    c.name
ORDER BY
    c.contest_id;

-- Task 5

CREATE TABLE Hackers (
    hacker_id INT PRIMARY KEY,
    name VARCHAR(100)
);

INSERT INTO Hackers (hacker_id, name) VALUES
(15758, 'Rose'),
(20703, 'Angela'),
(36396, 'Frank'),
(38289, 'Patrick'),
(44065, 'Lisa'),
(53473, 'Kimberly'),
(62529, 'Bonnie'),
(79722, 'Michael');

CREATE TABLE Submissions (
    submission_date DATE,
    submission_id INT PRIMARY KEY,
    hacker_id INT,
    score INT
);

INSERT INTO Submissions (submission_date, submission_id, hacker_id, score) VALUES
('2016-03-01', 8464, 20703, 0),
('2016-03-01', 22403, 53473, 15),
('2016-03-01', 23965, 79722, 60),
('2016-03-01', 30173, 36396, 70),
('2016-03-02', 34928, 20703, 0),
('2016-03-02', 38740, 15758, 60),
('2016-03-02', 42769, 79722, 25),
('2016-03-02', 44364, 79722, 60),
('2016-03-03', 45440, 20703, 0),
('2016-03-03', 49050, 36396, 70),
('2016-03-03', 50273, 79722, 5),
('2016-03-04', 53044, 20703, 0),
('2016-03-04', 51360, 44065, 90),
('2016-03-04', 54404, 53473, 65),
('2016-03-04', 61533, 79722, 45),
('2016-03-05', 72852, 20703, 0),
('2016-03-05', 74546, 38289, 0),
('2016-03-05', 76487, 62529, 0),
('2016-03-05', 82439, 36396, 10),
('2016-03-05', 90006, 36396, 40),
('2016-03-06', 90404, 20703, 0);

WITH DailySubmissions AS (
    SELECT 
        submission_date, 
        hacker_id, 
        COUNT(*) AS num_submissions
    FROM 
        Submissions
    GROUP BY 
        submission_date, 
        hacker_id
),
UniqueHackerCount AS (
    SELECT 
        submission_date,
        COUNT(DISTINCT hacker_id) AS unique_hackers
    FROM 
        Submissions
    GROUP BY 
        submission_date
),
MaxSubmissionsPerDay AS (
    SELECT 
        submission_date, 
        MAX(num_submissions) AS max_submissions
    FROM 
        DailySubmissions
    GROUP BY 
        submission_date
),
TopHackers AS (
    SELECT 
        ds.submission_date, 
        ds.hacker_id, 
        ds.num_submissions
    FROM 
        DailySubmissions ds
    JOIN 
        MaxSubmissionsPerDay msp 
    ON 
        ds.submission_date = msp.submission_date 
        AND ds.num_submissions = msp.max_submissions
),
TopHackerPerDay AS (
    SELECT 
        th.submission_date, 
        MIN(th.hacker_id) AS hacker_id
    FROM 
        TopHackers th
    GROUP BY 
        th.submission_date
)
SELECT 
    usc.submission_date, 
    usc.unique_hackers, 
    thpd.hacker_id, 
    h.name
FROM 
    UniqueHackerCount usc
JOIN 
    TopHackerPerDay thpd 
ON 
    usc.submission_date = thpd.submission_date
JOIN 
    Hackers h 
ON 
    thpd.hacker_id = h.hacker_id
ORDER BY 
    usc.submission_date;

-- Task 6

CREATE TABLE STATION (
    ID INT,
    CITY VARCHAR(21),
    STATE CHAR(2),
    LAT_N DECIMAL(10, 2),
    LONG_W DECIMAL(10, 2)
);

INSERT INTO STATION (ID, CITY, STATE, LAT_N, LONG_W) VALUES 
(1, 'CityA', 'ST', 10.0, 20.0),
(2, 'CityB', 'ST', 30.0, 40.0),
(3, 'CityC', 'ST', 50.0, 60.0);

WITH Points AS (
    SELECT
        MIN(LAT_N) AS min_lat,
        MIN(LONG_W) AS min_long,
        MAX(LAT_N) AS max_lat,
        MAX(LONG_W) AS max_long
    FROM
        STATION
)
SELECT
    ROUND(ABS(max_lat - min_lat) + ABS(max_long - min_long), 1) AS ManhattanDistance
FROM
    Points;

-- Task 7

WITH RECURSIVE PrimeNumbers AS (
    SELECT 2 AS num
    UNION ALL
    SELECT num + 1
    FROM PrimeNumbers
    WHERE num + 1 <= 1000
),
PrimeCheck AS (
    SELECT num
    FROM PrimeNumbers p1
    WHERE NOT EXISTS (
        SELECT 1
        FROM PrimeNumbers p2
        WHERE p2.num < p1.num AND p1.num % p2.num = 0
    )
)
SELECT GROUP_CONCAT(num ORDER BY num SEPARATOR '&') AS Primes
FROM PrimeCheck;

-- Task 8

CREATE TABLE OCCUPATIONS (
    Name VARCHAR(50),
    Occupation VARCHAR(50)
);

INSERT INTO OCCUPATIONS (Name, Occupation) VALUES 
('Samantha', 'Doctor'),
('Julia', 'Actor'),
('Maria', 'Actor'),
('Meera', 'Singer'),
('Ashley', 'Professor'),
('Ketty', 'Professor'),
('Christeen', 'Professor'),
('Jane', 'Actor'),
('Jenny', 'Doctor'),
('Priya', 'Singer');


SELECT
    MAX(CASE WHEN Occupation = 'Doctor' THEN Name ELSE NULL END) AS Doctor,
    MAX(CASE WHEN Occupation = 'Professor' THEN Name ELSE NULL END) AS Professor,
    MAX(CASE WHEN Occupation = 'Singer' THEN Name ELSE NULL END) AS Singer,
    MAX(CASE WHEN Occupation = 'Actor' THEN Name ELSE NULL END) AS Actor
FROM (
    SELECT Name, Occupation, ROW_NUMBER() OVER (PARTITION BY Occupation ORDER BY Name) AS rn
    FROM OCCUPATIONS
) sub
GROUP BY rn
ORDER BY rn;

-- Task 9

CREATE TABLE Tree (
    N INT,
    P INT
);

INSERT INTO Tree (N, P) VALUES 
(1, 2),
(3, 2),
(6, 8),
(9, 8),
(2, 5),
(8, 5),
(5, NULL);

SELECT 
    t.N,
    CASE
        WHEN t.P IS NULL THEN 'Root'
        WHEN NOT EXISTS (SELECT 1 FROM Tree WHERE P = t.N) THEN 'Leaf'
        ELSE 'Inner'
    END AS NodeType
FROM 
    Tree t
ORDER BY 
    t.N;

-- Task 10

CREATE TABLE Company (
    company_code VARCHAR(10),
    founder VARCHAR(50)
);

INSERT INTO Company (company_code, founder) VALUES 
('C1', 'Monika'),
('C2', 'Samantha');

CREATE TABLE Lead_Manager (
    lead_manager_code VARCHAR(10),
    company_code VARCHAR(10)
);

INSERT INTO Lead_Manager (lead_manager_code, company_code) VALUES 
('LM1', 'C1'),
('LM2', 'C2');

CREATE TABLE Senior_Manager (
    senior_manager_code VARCHAR(10),
    lead_manager_code VARCHAR(10),
    company_code VARCHAR(10)
);

INSERT INTO Senior_Manager (senior_manager_code, lead_manager_code, company_code) VALUES 
('SM1', 'LM1', 'C1'),
('SM2', 'LM1', 'C1'),
('SM3', 'LM2', 'C2');

CREATE TABLE Manager (
    manager_code VARCHAR(10),
    senior_manager_code VARCHAR(10),
    lead_manager_code VARCHAR(10),
    company_code VARCHAR(10)
);

INSERT INTO Manager (manager_code, senior_manager_code, lead_manager_code, company_code) VALUES 
('M1', 'SM1', 'LM1', 'C1'),
('M2', 'SM3', 'LM2', 'C2'),
('M3', 'SM3', 'LM2', 'C2');

CREATE TABLE Employee (
    employee_code VARCHAR(10),
    manager_code VARCHAR(10),
    senior_manager_code VARCHAR(10),
    lead_manager_code VARCHAR(10),
    company_code VARCHAR(10)
);

INSERT INTO Employee (employee_code, manager_code, senior_manager_code, lead_manager_code, company_code) VALUES 
('E1', 'M1', 'SM1', 'LM1', 'C1'),
('E2', 'M1', 'SM1', 'LM1', 'C1'),
('E3', 'M2', 'SM3', 'LM2', 'C2'),
('E4', 'M3', 'SM3', 'LM2', 'C2');

SELECT 
    c.company_code,
    c.founder,
    COALESCE(lm.lead_manager_count, 0) AS lead_manager_count,
    COALESCE(sm.senior_manager_count, 0) AS senior_manager_count,
    COALESCE(m.manager_count, 0) AS manager_count,
    COALESCE(e.employee_count, 0) AS employee_count
FROM 
    Company c
LEFT JOIN 
    (SELECT company_code, COUNT(*) AS lead_manager_count FROM Lead_Manager GROUP BY company_code) lm 
    ON c.company_code = lm.company_code
LEFT JOIN 
    (SELECT company_code, COUNT(*) AS senior_manager_count FROM Senior_Manager GROUP BY company_code) sm 
    ON c.company_code = sm.company_code
LEFT JOIN 
    (SELECT company_code, COUNT(*) AS manager_count FROM Manager GROUP BY company_code) m 
    ON c.company_code = m.company_code
LEFT JOIN 
    (SELECT company_code, COUNT(*) AS employee_count FROM Employee GROUP BY company_code) e 
    ON c.company_code = e.company_code
ORDER BY 
    c.company_code;

-- Task 11

SELECT 
    s.Name
FROM 
    Students s
JOIN 
    FRIENDS f ON s.ID = f.ID
JOIN 
    PACKAGES p1 ON s.ID = p1.ID
JOIN 
    PACKAGES p2 ON f.Friend_ID = p2.ID
WHERE 
    p2.Salary > p1.Salary
ORDER BY 
    p2.Salary;

-- Task 12

CREATE TABLE JobFamilyCost (
    JobFamily VARCHAR(100),
    Cost FLOAT,
    Location VARCHAR(50)
);

INSERT INTO JobFamilyCost (JobFamily, Cost, Location) VALUES
('Engineering', 100000, 'India'),
('Engineering', 200000, 'International'),
('Sales', 50000, 'India'),
('Sales', 150000, 'International');

SELECT 
    JobFamily,
    Location,
    Cost,
    (Cost / (SELECT SUM(Cost) FROM JobFamilyCost) * 100) AS CostPercentage
FROM 
    JobFamilyCost;

-- Task 13

CREATE TABLE BusinessUnit (
    BU VARCHAR(100),
    Month VARCHAR(10),
    Cost FLOAT,
    Revenue FLOAT
);

INSERT INTO BusinessUnit (BU, Month, Cost, Revenue) VALUES
('BU1', 'January', 100000, 150000),
('BU1', 'February', 120000, 180000),
('BU2', 'January', 80000, 120000),
('BU2', 'February', 90000, 130000);

SELECT 
    BU,
    Month,
    (Cost / Revenue) AS CostRevenueRatio
FROM 
    BusinessUnit;

-- Task 14

CREATE TABLE Employees (
    EmployeeID INT,
    SubBand VARCHAR(100)
);

INSERT INTO Employees (EmployeeID, SubBand) VALUES
(1, 'A'),
(2, 'A'),
(3, 'B'),
(4, 'B'),
(5, 'B'),
(6, 'C');

SELECT 
    SubBand,
    COUNT(EmployeeID) AS Headcount,
    (COUNT(EmployeeID) * 100.0 / (SELECT COUNT(*) FROM Employees)) AS HeadcountPercentage
FROM 
    Employees
GROUP BY 
    SubBand;

-- Task 15

CREATE TABLE EMPLOYEES1 (
    EmployeeID INT PRIMARY KEY,
    FirstName VARCHAR(50),
    LastName VARCHAR(50),
    Salary DECIMAL(18, 2),
    Department VARCHAR(50),
    HireDate DATE
);

INSERT INTO EMPLOYEES1 (EmployeeID, FirstName, LastName, Salary, Department, HireDate)
VALUES
(1, 'John', 'Doe', 60000, 'IT', '2020-01-15'),
(2, 'Jane', 'Smith', 75000, 'Finance', '2019-03-23'),
(3, 'Michael', 'Brown', 80000, 'HR', '2018-06-12'),
(4, 'Emily', 'Davis', 90000, 'IT', '2021-07-19'),
(5, 'Daniel', 'Miller', 50000, 'Finance', '2019-10-25'),
(6, 'Emma', 'Wilson', 120000, 'IT', '2022-02-13');


WITH RankedSalaries AS (
    SELECT
        EmployeeID,
        FirstName,
        LastName,
        Salary,
        RANK() OVER (ORDER BY Salary DESC) AS SalaryRank
    FROM EMPLOYEES1
)
SELECT EmployeeID, FirstName, LastName, Salary
FROM RankedSalaries
WHERE SalaryRank <= 5;
-- -----------------------------------------------------------------------------------------




-- Task 16
    
CREATE TABLE ExampleTable (
    ID INT PRIMARY KEY,
    ColumnA INT,
    ColumnB INT
);

INSERT INTO ExampleTable (ID, ColumnA, ColumnB) VALUES 
(1, 10, 20),
(2, 30, 40),
(3, 50, 60);

SELECT * FROM ExampleTable;

UPDATE ExampleTable
SET ColumnA = ColumnA + ColumnB;

UPDATE ExampleTable
SET ColumnB = ColumnA - ColumnB;

UPDATE ExampleTable
SET ColumnA = ColumnA - ColumnB;
    
SELECT * FROM ExampleTable;

-- Task 17

-- Create a Login
CREATE LOGIN Bidisha WITH PASSWORD = 'Bidi1234';
-- Create a Database User
USE AdventureWorks2019;
CREATE USER BidishaPaul FOR LOGIN Bidisha;
-- Provide DB_OWNER Permissions to the User
ALTER ROLE db_owner ADD MEMBER BidishaPaul;

-- Task 18

CREATE TABLE EmployeeCosts (
    EmployeeID INT,
    BU_ID INT,
    MonthYear DATE, -- This can be in 'YYYY-MM-01' format to represent the month
    Salary DECIMAL(10, 2),
    WorkingDays INT
);

INSERT INTO EmployeeCosts (EmployeeID, BU_ID, MonthYear, Salary, WorkingDays) VALUES
(1, 101, '2023-01-01', 5000, 20),
(2, 101, '2023-01-01', 6000, 22),
(1, 101, '2023-02-01', 5000, 18),
(2, 101, '2023-02-01', 6000, 20),
(1, 102, '2023-01-01', 7000, 20),
(2, 102, '2023-01-01', 8000, 22);


SELECT 
    BU_ID,
    MonthYear,
    SUM(Salary * WorkingDays) / SUM(WorkingDays) AS WeightedAverageCost
FROM 
    EmployeeCosts
GROUP BY 
    BU_ID, 
    MonthYear
ORDER BY 
    BU_ID, 
    MonthYear;

-- Task 19

CREATE TABLE EmployeeSalaries (
    EmployeeID INT,
    BU_ID INT,
    MonthYear DATE,
    Salary DECIMAL(10, 2)
);

INSERT INTO EmployeeSalaries (EmployeeID, BU_ID, MonthYear, Salary) VALUES
(1, 101, '2023-01-01', 5000),
(2, 101, '2023-01-01', 6000),
(1, 101, '2023-02-01', 5000),
(2, 101, '2023-02-01', 6000),
(1, 102, '2023-01-01', 7000),
(2, 102, '2023-01-01', 8000);


SELECT 
    Actual.BU_ID,
    Actual.MonthYear,
    Actual.ActualAverageSalary,
    Miscalculated.MiscalculatedAverageSalary,
    Miscalculated.MiscalculatedAverageSalary - Actual.ActualAverageSalary AS Difference
FROM 
    (SELECT 
        BU_ID,
        MonthYear,
        AVG(Salary) AS ActualAverageSalary
     FROM 
        EmployeeSalaries
     GROUP BY 
        BU_ID, 
        MonthYear) AS Actual
JOIN 
    (SELECT 
        BU_ID,
        MonthYear,
        AVG(Salary + 500) AS MiscalculatedAverageSalary
     FROM 
        EmployeeSalaries
     GROUP BY 
        BU_ID, 
        MonthYear) AS Miscalculated
ON 
    Actual.BU_ID = Miscalculated.BU_ID
    AND Actual.MonthYear = Miscalculated.MonthYear
ORDER BY 
    Actual.BU_ID, 
    Actual.MonthYear;

-- Task 20

CREATE TABLE A_table (
    id INT,
    data VARCHAR(100),
    PRIMARY KEY (id, data)
);

INSERT INTO A_table (id, data) VALUES 
(1, 'Data 1'),
(2, 'Data 2'),
(3, 'Data 3'),
(4, 'Data 4');

CREATE TABLE B_table (
    id INT,
    data VARCHAR(100),
    PRIMARY KEY (id, data)
);

INSERT INTO B_table (id, data) VALUES 
(1, 'Data 1'),
(2, 'Data 2');

INSERT INTO B_table (id, data)
SELECT s.id, s.data
FROM A_table s
LEFT JOIN B_table d ON s.id = d.id AND s.data = d.data
WHERE d.id IS NULL;

SELECT * FROM B_table;







