-- Query 1: Application statistics by company
--Count Applications per Company with Average Status
--Purpose: Show how many applications each company received and calculate statistics about application status.
SELECT 
    c.companyId,
    c.company_name,
    c.industry,
    COUNT(a.applicationId) AS total_applications,
    COUNT(CASE WHEN a.status = 'Accepted' THEN 1 END) AS accepted_count,
    COUNT(CASE WHEN a.status = 'Pending' THEN 1 END) AS pending_count,
    COUNT(CASE WHEN a.status = 'Rejected' THEN 1 END) AS rejected_count
FROM company c
JOIN recruiter r ON c.companyId = r.companyId
JOIN internship_posting ip ON r.recruiterId = ip.recruiterId
JOIN application a ON ip.postingId = a.postingId
GROUP BY c.companyId, c.company_name, c.industry
HAVING COUNT(a.applicationId) > 0
ORDER BY total_applications DESC;

-- Query 2: Average applications per student grouped by major
--Average Applications per Student by Major
--Purpose: Analyze which majors have students applying to more internships on average.
SELECT 
    s.major,
    COUNT(DISTINCT s.studentId) AS total_students,
    COUNT(a.applicationId) AS total_applications,
    CAST(COUNT(a.applicationId) AS FLOAT) / COUNT(DISTINCT s.studentId) AS avg_applications_per_student,
    MAX(application_date) AS most_recent_application
FROM student s
LEFT JOIN application a ON s.studentId = a.studentId
GROUP BY s.major
HAVING COUNT(a.applicationId) > 0
ORDER BY avg_applications_per_student DESC;

-- Query 3: Students applying more than average (subquery in WHERE)
--Students Who Applied to More Postings Than Average
--Purpose: Find high-activity students who are applying to more internships than their peers.
SELECT 
    s.studentId,
    s.firstName,
    s.lastName,
    s.email,
    s.major,
    COUNT(app.applicationId) AS application_count
FROM student s
JOIN application app ON s.studentId = app.studentId
GROUP BY s.studentId, s.firstName, s.lastName, s.email, s.major
HAVING COUNT(app.applicationId) > (
    SELECT AVG(app_count)
    FROM (
        SELECT COUNT(applicationId) AS app_count
        FROM application
        GROUP BY studentId
    ) AS subquery
)
ORDER BY application_count DESC;

-- Query 4: Postings without applications (subquery with NOT EXISTS)
--nternship Postings With No Applications
--Purpose: Find postings that haven't received any applications yet (may need promotion or review).
SELECT 
    ip.postingId,
    ip.title,
    ip.description,
    ip.required_skills,
    ip.deadline,
    ip.posted_date,
    r.fullName AS recruiter_name,
    c.company_name
FROM internship_posting ip
JOIN recruiter r ON ip.recruiterId = r.recruiterId
JOIN company c ON r.companyId = c.companyId
WHERE NOT EXISTS (
    SELECT 1
    FROM application a
    WHERE a.postingId = ip.postingId
)
AND ip.deadline >= GETDATE()
ORDER BY ip.deadline ASC;


-- Query 5: Comprehensive application view joining 5 tables
--Complete Application Details (5 Tables)
--Purpose: Show full application information including student, posting, company, and approval details.
SELECT 
    a.applicationId,
    a.application_date,
    a.status,
    s.firstName + ' ' + s.lastName AS student_name,
    s.email AS student_email,
    s.major,
    ip.title AS internship_title,
    ip.required_skills,
    c.company_name,
    c.industry,
    c.location AS company_location,
    r.fullName AS recruiter_name,
    ap.decision AS approval_decision,
    ap.decision_date
FROM application a
JOIN student s ON a.studentId = s.studentId
JOIN internship_posting ip ON a.postingId = ip.postingId
JOIN recruiter r ON ip.recruiterId = r.recruiterId
JOIN company c ON r.companyId = c.companyId
LEFT JOIN approval ap ON ip.postingId = ap.postingId
ORDER BY a.application_date DESC;

-- Query 6: Staff approval activity with posting and company details (4 tables)
--University Staff Monitoring (4 Tables)
--Purpose: Show which staff members approved which postings and track their decision patterns.
SELECT 
    us.staffId,
    us.fullName AS staff_name,
    us.role,
    u.university_name,
    COUNT(ap.approvalId) AS total_approvals,
    SUM(CASE WHEN ap.decision = 'Approved' THEN 1 ELSE 0 END) AS approved_count,
    SUM(CASE WHEN ap.decision = 'Rejected' THEN 1 ELSE 0 END) AS rejected_count,
    ip.title AS recent_posting_reviewed,
    c.company_name AS recent_company
FROM university_staff us
JOIN university u ON us.universityId = u.universityId
LEFT JOIN approval ap ON us.staffId = ap.staffId
LEFT JOIN internship_posting ip ON ap.postingId = ip.postingId
LEFT JOIN recruiter r ON ip.recruiterId = r.recruiterId
LEFT JOIN company c ON r.companyId = c.companyId
GROUP BY us.staffId, us.fullName, us.role, u.university_name, ip.title, c.company_name
ORDER BY total_approvals DESC;

-- Query 7: Students who haven't applied to any internships
--Students Without Applications (Join + Filter)
--Purpose: Identify students who haven't applied to any internships (may need guidance).
SELECT 
    s.studentId,
    s.firstName,
    s.lastName,
    s.email,
    s.major,
    u.university_name
FROM student s
JOIN university u ON s.universityId = u.universityId
LEFT JOIN application a ON s.studentId = a.studentId
WHERE a.applicationId IS NULL
ORDER BY s.major, s.lastName;

-- Query 8: Recruiter performance with posting and application metrics
--Purpose: Analyze recruiter effectiveness - postings created, applications received, and approval rates.
SELECT 
    r.recruiterId,
    r.fullName AS recruiter_name,
    r.email,
    c.company_name,
    COUNT(DISTINCT ip.postingId) AS total_postings,
    COUNT(DISTINCT a.applicationId) AS total_applications_received,
    CAST(COUNT(DISTINCT a.applicationId) AS FLOAT) / 
        NULLIF(COUNT(DISTINCT ip.postingId), 0) AS avg_applications_per_posting,
    COUNT(DISTINCT ap.approvalId) AS postings_reviewed,
    SUM(CASE WHEN ap.decision = 'Approved' THEN 1 ELSE 0 END) AS approved_postings
FROM recruiter r
JOIN company c ON r.companyId = c.companyId
LEFT JOIN internship_posting ip ON r.recruiterId = ip.recruiterId
LEFT JOIN application a ON ip.postingId = a.postingId
LEFT JOIN approval ap ON ip.postingId = ap.postingId
GROUP BY r.recruiterId, r.fullName, r.email, c.company_name
HAVING COUNT(DISTINCT ip.postingId) > 0
ORDER BY total_applications_received DESC;