-- Create SubjectDetails table
CREATE TABLE SubjectDetails (
    SubjectId VARCHAR(10) PRIMARY KEY,
    SubjectName VARCHAR(50),
    MaxSeats INT,
    RemainingSeats INT
);
-- Create StudentDetails table
CREATE TABLE StudentDetails(
    StudentId INT PRIMARY KEY,
    StudentName VARCHAR(50),
    GPA FLOAT,
    Branch VARCHAR(50),
    Section VARCHAR(10)
);
-- Create StudentPreference table
CREATE TABLE StudentPreference(
    StudentId INT,
    SubjectId VARCHAR(10),
    Preference INT,
    FOREIGN KEY (StudentId) REFERENCES StudentDetails(StudentId),
    FOREIGN KEY (SubjectId) REFERENCES SubjectDetails(SubjectId)
);

-- Create Allotments table
CREATE TABLE Allotments (
    SubjectId VARCHAR(10),
    StudentId INT,
    FOREIGN KEY (SubjectId) REFERENCES SubjectDetails(SubjectId),
    FOREIGN KEY (StudentId) REFERENCES StudentDetails(StudentId)
);

-- Create UnallottedStudents table
CREATE TABLE UnallottedStudents (
    StudentId INT,
    FOREIGN KEY (StudentId) REFERENCES StudentDetails(StudentId)
);

-- Insert data into SubjectDetails
INSERT INTO SubjectDetails (SubjectId, SubjectName, MaxSeats, RemainingSeats) VALUES
('PO1491', 'Basics of Political Science', 60, 2),
('PO1492', 'Basics of Accounting', 120, 119),
('PO1493', 'Basics of Financial Markets', 90, 90),
('PO1494', 'Eco philosophy', 60, 50),
('PO1495', 'Automotive Trends', 60, 60);

-- Insert data into StudentDetails
INSERT INTO StudentDetails (StudentId, StudentName, GPA, Branch, Section) VALUES
(159103036, 'Mohit Agarwal', 8.9, 'CCE', 'A'),
(159103037, 'Rohit Agarwal', 5.2, 'CCE', 'A'),
(159103038, 'Shohit Garg', 7.1, 'CCE', 'B'),
(159103039, 'Mrinal Malhotra', 7.9, 'CCE', 'A'),
(159103040, 'Mehreet Singh', 5.6, 'CCE', 'A'),
(159103041, 'Arjun Tehlan', 9.2, 'CCE', 'B');

-- Insert data into StudentPreference
INSERT INTO StudentPreference (StudentId, SubjectId, Preference) VALUES
(159103036, 'PO1491', 1),
(159103036, 'PO1492', 2),
(159103036, 'PO1493', 3),
(159103036, 'PO1494', 4),
(159103036, 'PO1495', 5),
(159103037, 'PO1491', 1),
(159103037, 'PO1492', 2),
(159103037, 'PO1493', 3),
(159103037, 'PO1494', 4),
(159103037, 'PO1495', 5),
(159103038, 'PO1491', 1),
(159103038, 'PO1492', 2),
(159103038, 'PO1493', 3),
(159103038, 'PO1494', 4),
(159103038, 'PO1495', 5),
(159103039, 'PO1491', 1),
(159103039, 'PO1492', 2),
(159103039, 'PO1493', 3),
(159103039, 'PO1494', 4),
(159103039, 'PO1495', 5),
(159103040, 'PO1491', 1),
(159103040, 'PO1492', 2),
(159103040, 'PO1493', 3),
(159103040, 'PO1494', 4),
(159103040, 'PO1495', 5),
(159103041, 'PO1491', 1),
(159103041, 'PO1492', 2),
(159103041, 'PO1493', 3),
(159103041, 'PO1494', 4),
(159103041, 'PO1495', 5);

create procedure AllocateSubjects
as
begin
declare @StudentId int
declare @Preference int
declare @SubjectId varchar(255)
declare @RemainingSeats int
declare StudentCursor cursor for
select StudentId from StudentDetails order by GPA desc

open StudentCursor
fetch next from StudentCursor into @StudentId
while @@FETCH_STATUS = 0
begin set @Preference = 1
declare @Allocated bit
set @Allocated = 0
while @Preference <=5 and @Allocated = 0
begin
select @SubjectId=SubjectId
from StudentPreference
where StudentId = @StudentId and Preference=@Preference
if @RemainingSeats > 0
begin
insert into Allotments (SubjectId,StudentId)
values(@SubjectId,@StudentId)
update SubjectDetails
set RemainingSeats = RemainingSeats-1
where SubjectId=@SubjectId
set @Allocated = 1
end
set @Preference=@Preference+1
end
if @Allocated = 0
begin
insert into UnallotedStudents(StudentId)
values(@StudentId)
end
fetch next from StudentCursor into @StudentId
end
close StudentCursor
deallocate StudentCursor
end

exec AllocateSubjects;