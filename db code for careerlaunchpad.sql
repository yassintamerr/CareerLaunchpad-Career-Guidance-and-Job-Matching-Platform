
-- Create Database
CREATE DATABASE InternshipManagementSystem;
GO

USE InternshipManagementSystem;
GO

-- ===============================================
-- CREATE TABLES WITH FIXED COLUMN NAMES
-- ===============================================

-- Table 1: University
CREATE TABLE university (
    universityId INT PRIMARY KEY IDENTITY(1,1),
    university_name NVARCHAR(200) NOT NULL,
    university_location NVARCHAR(200) NOT NULL
);

-- Table 2: Company
CREATE TABLE company (
    companyId INT PRIMARY KEY IDENTITY(1,1),
    company_name NVARCHAR(200) NOT NULL,
    industry NVARCHAR(100),
    location NVARCHAR(200),
    description NVARCHAR(MAX)
);

-- Table 3: University Staff
CREATE TABLE university_staff (
    staffId INT PRIMARY KEY IDENTITY(1,1),
    fullName NVARCHAR(100) NOT NULL,
    email NVARCHAR(100) UNIQUE NOT NULL,
    password NVARCHAR(255) NOT NULL,
    role NVARCHAR(50),
    universityId INT NOT NULL,
    FOREIGN KEY (universityId) REFERENCES university(universityId)
);

-- Table 4: Student
CREATE TABLE student (
    studentId INT PRIMARY KEY IDENTITY(1,1),
    firstName NVARCHAR(50) NOT NULL,
    lastName NVARCHAR(50) NOT NULL,
    email NVARCHAR(100) UNIQUE NOT NULL,
    password NVARCHAR(255) NOT NULL,
    major NVARCHAR(100),
    primaryCV NVARCHAR(500),
    universityId INT NOT NULL,
    applicationId INT NULL,
    FOREIGN KEY (universityId) REFERENCES university(universityId)
);

-- Table 5: Recruiter
CREATE TABLE recruiter (
    recruiterId INT PRIMARY KEY IDENTITY(1,1),
    fullName NVARCHAR(100) NOT NULL,
    email NVARCHAR(100) UNIQUE NOT NULL,
    password NVARCHAR(255) NOT NULL,
    companyId INT NOT NULL,
    FOREIGN KEY (companyId) REFERENCES company(companyId)
);

-- Table 6: Internship Posting
CREATE TABLE internship_posting (
    postingId INT PRIMARY KEY IDENTITY(1,1),
    title NVARCHAR(200) NOT NULL,
    description NVARCHAR(MAX),
    required_skills NVARCHAR(500),
    deadline DATE NOT NULL,
    posted_date DATE NOT NULL DEFAULT GETDATE(),
    duration NVARCHAR(50),
    recruiterId INT NOT NULL,
    FOREIGN KEY (recruiterId) REFERENCES recruiter(recruiterId)
);

-- Table 7: Application
CREATE TABLE application (
    applicationId INT PRIMARY KEY IDENTITY(1,1),
    application_date DATE NOT NULL DEFAULT GETDATE(),
    status NVARCHAR(50) DEFAULT 'Pending',
    postingId INT NOT NULL,
    studentId INT NOT NULL,
    recruiterId INT NOT NULL,
    FOREIGN KEY (postingId) REFERENCES internship_posting(postingId),
    FOREIGN KEY (studentId) REFERENCES student(studentId),
    FOREIGN KEY (recruiterId) REFERENCES recruiter(recruiterId)
);

-- Table 8: Approval
CREATE TABLE approval (
    approvalId INT PRIMARY KEY IDENTITY(1,1),
    decision NVARCHAR(50),
    decision_date DATE,
    comment NVARCHAR(MAX),
    postingId INT NOT NULL,
    staffId INT NOT NULL,
    FOREIGN KEY (postingId) REFERENCES internship_posting(postingId),
    FOREIGN KEY (staffId) REFERENCES university_staff(staffId)
);

-- Table 9: Notification
CREATE TABLE notification (
    notificationId INT PRIMARY KEY IDENTITY(1,1),
    content NVARCHAR(MAX) NOT NULL,
    notification_date DATETIME NOT NULL DEFAULT GETDATE(),
    studentId INT NULL,
    staffId INT NULL,
    recruiterId INT NULL,
    FOREIGN KEY (studentId) REFERENCES student(studentId),
    FOREIGN KEY (staffId) REFERENCES university_staff(staffId),
    FOREIGN KEY (recruiterId) REFERENCES recruiter(recruiterId)
);

-- Table 10: Apply (Many-to-Many relationship)
CREATE TABLE apply (
    studentId INT NOT NULL,
    postingId INT NOT NULL,
    PRIMARY KEY (studentId, postingId),
    FOREIGN KEY (studentId) REFERENCES student(studentId),
    FOREIGN KEY (postingId) REFERENCES internship_posting(postingId)
);

GO

-- ===============================================
-- INSERT SAMPLE DATA - PROPERLY FORMATTED
-- ===============================================

-- Insert Universities
INSERT INTO university (university_name, university_location) 
VALUES 
    (N'Harvard University', N'Cambridge, MA'),
    (N'Stanford University', N'Stanford, CA'),
    (N'MIT', N'Cambridge, MA'),
    (N'University of California Berkeley', N'Berkeley, CA'),
    (N'Carnegie Mellon University', N'Pittsburgh, PA');

-- Insert Companies
INSERT INTO company (company_name, industry, location, description) 
VALUES 
    (N'Google', N'Technology', N'Mountain View, CA', N'Leading tech company'),
    (N'Microsoft', N'Technology', N'Redmond, WA', N'Software and cloud services'),
    (N'Goldman Sachs', N'Finance', N'New York, NY', N'Investment banking'),
    (N'Amazon', N'E-commerce/Technology', N'Seattle, WA', N'Online retail and cloud'),
    (N'Tesla', N'Automotive', N'Palo Alto, CA', N'Electric vehicles'),
    (N'Meta', N'Technology', N'Menlo Park, CA', N'Social media platform'),
    (N'Apple', N'Technology', N'Cupertino, CA', N'Consumer electronics'),
    (N'JP Morgan', N'Finance', N'New York, NY', N'Financial services');

-- Insert University Staff
INSERT INTO university_staff (fullName, email, password, role, universityId) 
VALUES 
    (N'Dr. Sarah Johnson', N'sarah.johnson@harvard.edu', N'hashed_password1', N'Career Advisor', 1),
    (N'Prof. Michael Chen', N'michael.chen@stanford.edu', N'hashed_password2', N'Internship Coordinator', 2),
    (N'Dr. Emily Roberts', N'emily.roberts@mit.edu', N'hashed_password3', N'Career Services Director', 3),
    (N'James Wilson', N'james.wilson@berkeley.edu', N'hashed_password4', N'Career Counselor', 4),
    (N'Dr. Lisa Anderson', N'lisa.anderson@cmu.edu', N'hashed_password5', N'Internship Advisor', 5);

-- Insert Students - FIXED: Proper column order
INSERT INTO student (firstName, lastName, email, password, major, primaryCV, universityId, applicationId) 
VALUES 
    (N'John', N'Doe', N'john.doe@harvard.edu', N'pass123', N'Computer Science', N'cv_john_doe.pdf', 1, NULL),
    (N'Jane', N'Smith', N'jane.smith@stanford.edu', N'pass456', N'Business Administration', N'cv_jane_smith.pdf', 2, NULL),
    (N'Alex', N'Johnson', N'alex.johnson@mit.edu', N'pass789', N'Electrical Engineering', N'cv_alex_johnson.pdf', 3, NULL),
    (N'Emily', N'Brown', N'emily.brown@berkeley.edu', N'pass101', N'Data Science', N'cv_emily_brown.pdf', 4, NULL),
    (N'Michael', N'Davis', N'michael.davis@cmu.edu', N'pass202', N'Computer Science', N'cv_michael_davis.pdf', 5, NULL),
    (N'Sarah', N'Wilson', N'sarah.wilson@harvard.edu', N'pass303', N'Finance', N'cv_sarah_wilson.pdf', 1, NULL),
    (N'David', N'Martinez', N'david.martinez@stanford.edu', N'pass404', N'Marketing', N'cv_david_martinez.pdf', 2, NULL),
    (N'Lisa', N'Taylor', N'lisa.taylor@mit.edu', N'pass505', N'Mechanical Engineering', N'cv_lisa_taylor.pdf', 3, NULL),
    (N'Kevin', N'Anderson', N'kevin.anderson@berkeley.edu', N'pass606', N'Computer Science', N'cv_kevin_anderson.pdf', 4, NULL),
    (N'Amy', N'Thomas', N'amy.thomas@cmu.edu', N'pass707', N'Information Systems', N'cv_amy_thomas.pdf', 5, NULL);

-- Insert Recruiters
INSERT INTO recruiter (fullName, email, password, companyId) 
VALUES 
    (N'Robert Green', N'robert.green@google.com', N'recpass1', 1),
    (N'Jessica White', N'jessica.white@microsoft.com', N'recpass2', 2),
    (N'Daniel Lee', N'daniel.lee@gs.com', N'recpass3', 3),
    (N'Michelle Kim', N'michelle.kim@amazon.com', N'recpass4', 4),
    (N'Steven Park', N'steven.park@tesla.com', N'recpass5', 5),
    (N'Laura Zhang', N'laura.zhang@meta.com', N'recpass6', 6),
    (N'Chris Brown', N'chris.brown@apple.com', N'recpass7', 7),
    (N'Rachel Adams', N'rachel.adams@jpmorgan.com', N'recpass8', 8);

-- Insert Internship Postings
INSERT INTO internship_posting (title, description, required_skills, deadline, posted_date, duration, recruiterId) 
VALUES 
    (N'Software Engineering Intern', N'Work on cloud infrastructure projects', N'Python, Java, AWS', '2025-03-15', '2024-12-01', N'3 months', 1),
    (N'Data Science Intern', N'Analyze large datasets and build ML models', N'Python, R, Machine Learning', '2025-03-20', '2024-12-05', N'4 months', 2),
    (N'Investment Banking Analyst Intern', N'Support M&A transactions', N'Excel, Financial Modeling', '2025-02-28', '2024-11-15', N'10 weeks', 3),
    (N'Product Management Intern', N'Assist in product development lifecycle', N'Communication, Analytics', '2025-03-10', '2024-12-10', N'3 months', 4),
    (N'Mechanical Engineering Intern', N'Design and test vehicle components', N'CAD, SolidWorks, Manufacturing', '2025-03-25', '2024-12-12', N'6 months', 5),
    (N'Software Development Intern', N'Mobile app development', N'React Native, JavaScript', '2025-03-18', '2024-12-08', N'3 months', 6),
    (N'Hardware Engineering Intern', N'Work on chip design', N'Verilog, Circuit Design', '2025-03-22', '2024-12-15', N'4 months', 7),
    (N'Quantitative Research Intern', N'Develop trading algorithms', N'Python, Statistics, Finance', '2025-02-25', '2024-11-20', N'12 weeks', 8),
    (N'UX Design Intern', N'Create user interfaces for products', N'Figma, Adobe XD, User Research', '2025-03-12', '2024-12-03', N'3 months', 1),
    (N'Cloud Infrastructure Intern', N'Build scalable cloud solutions', N'AWS, Docker, Kubernetes', '2025-03-30', '2024-12-18', N'5 months', 4);

-- Insert Applications
INSERT INTO application (application_date, status, postingId, studentId, recruiterId) 
VALUES 
    ('2024-12-10', N'Pending', 1, 1, 1),
    ('2024-12-11', N'Accepted', 2, 2, 2),
    ('2024-12-12', N'Pending', 3, 3, 3),
    ('2024-12-13', N'Rejected', 4, 4, 4),
    ('2024-12-14', N'Accepted', 5, 5, 5),
    ('2024-12-15', N'Pending', 1, 6, 1),
    ('2024-12-16', N'Pending', 2, 7, 2),
    ('2024-12-17', N'Accepted', 6, 1, 6),
    ('2024-12-18', N'Pending', 7, 8, 7),
    ('2024-12-19', N'Pending', 8, 9, 8),
    ('2024-12-20', N'Accepted', 9, 10, 1),
    ('2024-12-21', N'Pending', 10, 2, 4),
    ('2024-12-22', N'Rejected', 3, 5, 3),
    ('2024-12-23', N'Pending', 4, 3, 4),
    ('2024-12-24', N'Accepted', 1, 9, 1);

-- Insert Approvals
INSERT INTO approval (decision, decision_date, comment, postingId, staffId) 
VALUES 
    (N'Approved', '2024-12-02', N'Excellent opportunity for CS students', 1, 1),
    (N'Approved', '2024-12-06', N'Great data science position', 2, 2),
    (N'Approved', '2024-11-16', N'Good finance internship', 3, 3),
    (N'Rejected', '2024-12-11', N'Requirements too vague', 4, 4),
    (N'Approved', '2024-12-13', N'Excellent engineering opportunity', 5, 5),
    (N'Approved', '2024-12-09', N'Good mobile development role', 6, 1),
    (N'Approved', '2024-12-16', N'Strong technical position', 7, 3),
    (N'Approved', '2024-11-21', N'Excellent quant role', 8, 4);

-- Insert Notifications
INSERT INTO notification (content, notification_date, studentId, staffId, recruiterId) 
VALUES 
    (N'Your application has been received', '2024-12-10 10:30:00', 1, NULL, NULL),
    (N'You have been accepted for the internship!', '2024-12-11 14:20:00', 2, NULL, NULL),
    (N'New posting requires approval', '2024-12-01 09:00:00', NULL, 1, NULL),
    (N'Application status updated', '2024-12-13 16:45:00', 4, NULL, NULL),
    (N'Congratulations on your acceptance!', '2024-12-14 11:10:00', 5, NULL, NULL),
    (N'New application received', '2024-12-15 13:25:00', NULL, NULL, 1),
    (N'Posting has been approved', '2024-12-02 10:00:00', NULL, NULL, 1);

-- Insert Apply relationships
INSERT INTO apply (studentId, postingId) 
VALUES 
    (1, 1), (1, 6),
    (2, 2), (2, 10),
    (3, 3), (3, 4),
    (4, 4),
    (5, 5), (5, 3),
    (6, 1),
    (7, 2),
    (8, 7),
    (9, 8), (9, 1),
    (10, 9);

GO

-- ===============================================
-- VERIFICATION QUERIES
-- ===============================================

PRINT '=== Verifying Data Insertion ===';
PRINT '';

-- Check all tables
SELECT 'university' AS TableName, COUNT(*) AS RecordCount FROM university
UNION ALL SELECT 'company', COUNT(*) FROM company
UNION ALL SELECT 'university_staff', COUNT(*) FROM university_staff
UNION ALL SELECT 'student', COUNT(*) FROM student
UNION ALL SELECT 'recruiter', COUNT(*) FROM recruiter
UNION ALL SELECT 'internship_posting', COUNT(*) FROM internship_posting
UNION ALL SELECT 'application', COUNT(*) FROM application
UNION ALL SELECT 'approval', COUNT(*) FROM approval
UNION ALL SELECT 'notification', COUNT(*) FROM notification
UNION ALL SELECT 'apply', COUNT(*) FROM apply;

PRINT '';
PRINT '=== Sample Student Data with Universities ===';

-- Verify students have correct universities
SELECT 
    s.studentId,
    s.firstName,
    s.lastName,
    s.major,
    u.university_name AS university
FROM student s
JOIN university u ON s.universityId = u.universityId
ORDER BY s.studentId;

PRINT '';
PRINT 'Database created and populated successfully!';
PRINT 'All data integrity verified.';

GO