

import tkinter as tk
from tkinter import ttk, messagebox
import pyodbc


class InternshipManagementSystem:
    def __init__(self, root):
        self.root = root
        self.root.title("Internship Management System")
        self.root.geometry("1400x850")
        self.root.configure(bg='#ecf0f1')

        self.conn = None
        self.connect_database()
        self.create_ui()

    def connect_database(self):
        """Connect to SQL Server"""
        try:
            # IMPORTANT: Update these settings for your SQL Server
            connection_string = (
                "DRIVER={SQL Server};"
                "SERVER=YASSINTAMER\SQLEXPRESS;"  # Change to your server
                "DATABASE=InternshipManagementSystem;"
                "Trusted_Connection=yes;"
            )
            self.conn = pyodbc.connect(connection_string)
            print("✓ Database connected successfully!")
        except Exception as e:
            messagebox.showerror("Database Error", f"Connection failed:\n{str(e)}")

    def create_ui(self):
        """Create main interface"""
        # Header
        header = tk.Frame(self.root, bg='#2c3e50', height=70)
        header.pack(fill='x')
        header.pack_propagate(False)
        tk.Label(header, text="🎓 Internship Management System",
                 font=('Arial', 22, 'bold'), bg='#2c3e50', fg='white').pack(pady=15)

        # Notebook with tabs
        notebook = ttk.Notebook(self.root)
        notebook.pack(fill='both', expand=True, padx=15, pady=15)

        # Create all tabs
        tabs = {
            '📝 Insert': tk.Frame(notebook, bg='#ecf0f1'),
            '🗑️ Delete': tk.Frame(notebook, bg='#ecf0f1'),
            '✏️ Update': tk.Frame(notebook, bg='#ecf0f1'),
            '🔍 Select': tk.Frame(notebook, bg='#ecf0f1'),
            '🔗 Join': tk.Frame(notebook, bg='#ecf0f1'),
            '📊 Report': tk.Frame(notebook, bg='#ecf0f1')
        }

        for name, frame in tabs.items():
            notebook.add(frame, text=name)

        self.build_all_tabs(list(tabs.values()))

    def build_all_tabs(self, tabs):
        """Build all tab contents"""
        self.build_insert_tab(tabs[0])
        self.build_delete_tab(tabs[1])
        self.build_update_tab(tabs[2])
        self.build_select_tab(tabs[3])
        self.build_join_tab(tabs[4])
        self.build_report_tab(tabs[5])

    # ========== INSERT TAB (2 tables required) ==========
    def build_insert_tab(self, parent):
        sub_nb = ttk.Notebook(parent)
        sub_nb.pack(fill='both', expand=True, padx=10, pady=10)

        # INSERT Student
        f1 = tk.Frame(sub_nb, bg='#ecf0f1')
        sub_nb.add(f1, text='Add Student')
        tk.Label(f1, text="Add New Student", font=('Arial', 14, 'bold'), bg='#ecf0f1').pack(pady=10)

        form1 = tk.Frame(f1, bg='#ecf0f1')
        form1.pack(pady=10)

        fields1 = ['First Name:', 'Last Name:', 'Email:', 'Password:', 'Major:', 'University ID:']
        self.student_entries = {}
        for i, field in enumerate(fields1):
            tk.Label(form1, text=field, bg='#ecf0f1').grid(row=i, column=0, sticky='e', padx=5, pady=3)
            entry = tk.Entry(form1, width=35, show='*' if 'Password' in field else '')
            entry.grid(row=i, column=1, padx=5, pady=3)
            self.student_entries[field] = entry

        tk.Button(form1, text="Add Student", command=self.insert_student,
                  bg='#27ae60', fg='white', font=('Arial', 10, 'bold'), padx=20).grid(row=6, columnspan=2, pady=15)

        # INSERT Company
        f2 = tk.Frame(sub_nb, bg='#ecf0f1')
        sub_nb.add(f2, text='Add Company')
        tk.Label(f2, text="Add New Company", font=('Arial', 14, 'bold'), bg='#ecf0f1').pack(pady=10)

        form2 = tk.Frame(f2, bg='#ecf0f1')
        form2.pack(pady=10)

        fields2 = ['Company Name:', 'Industry:', 'Location:']
        self.company_entries = {}
        for i, field in enumerate(fields2):
            tk.Label(form2, text=field, bg='#ecf0f1').grid(row=i, column=0, sticky='e', padx=5, pady=3)
            entry = tk.Entry(form2, width=40)
            entry.grid(row=i, column=1, padx=5, pady=3)
            self.company_entries[field] = entry

        tk.Label(form2, text='Description:', bg='#ecf0f1').grid(row=3, column=0, sticky='ne', padx=5, pady=3)
        self.company_desc = tk.Text(form2, width=40, height=4)
        self.company_desc.grid(row=3, column=1, padx=5, pady=3)

        tk.Button(form2, text="Add Company", command=self.insert_company,
                  bg='#27ae60', fg='white', font=('Arial', 10, 'bold'), padx=20).grid(row=4, columnspan=2, pady=15)

    def insert_student(self):
        try:
            cursor = self.conn.cursor()
            cursor.execute("""INSERT INTO student (firstName, lastName, email, password, major, universityId)
                           VALUES (?, ?, ?, ?, ?, ?)""",
                           (self.student_entries['First Name:'].get(),
                            self.student_entries['Last Name:'].get(),
                            self.student_entries['Email:'].get(),
                            self.student_entries['Password:'].get(),
                            self.student_entries['Major:'].get(),
                            int(self.student_entries['University ID:'].get())))
            self.conn.commit()
            messagebox.showinfo("Success", "Student added!")
            for e in self.student_entries.values(): e.delete(0, tk.END)
        except Exception as e:
            messagebox.showerror("Error", str(e))

    def insert_company(self):
        try:
            cursor = self.conn.cursor()
            cursor.execute("""INSERT INTO company (company_name, industry, location, description)
                           VALUES (?, ?, ?, ?)""",
                           (self.company_entries['Company Name:'].get(),
                            self.company_entries['Industry:'].get(),
                            self.company_entries['Location:'].get(),
                            self.company_desc.get('1.0', tk.END).strip()))
            self.conn.commit()
            messagebox.showinfo("Success", "Company added!")
            for e in self.company_entries.values(): e.delete(0, tk.END)
            self.company_desc.delete('1.0', tk.END)
        except Exception as e:
            messagebox.showerror("Error", str(e))

    # ========== DELETE TAB (2 tables with conditions) ==========
    def build_delete_tab(self, parent):
        sub_nb = ttk.Notebook(parent)
        sub_nb.pack(fill='both', expand=True, padx=10, pady=10)

        # DELETE Application
        f1 = tk.Frame(sub_nb, bg='#ecf0f1')
        sub_nb.add(f1, text='Delete Application')
        tk.Label(f1, text="Delete Application by ID and Status",
                 font=('Arial', 14, 'bold'), bg='#ecf0f1').pack(pady=10)

        form1 = tk.Frame(f1, bg='#ecf0f1')
        form1.pack(pady=20)

        tk.Label(form1, text="Application ID:", bg='#ecf0f1').grid(row=0, column=0, padx=5, pady=5)
        self.del_app_id = tk.Entry(form1, width=30)
        self.del_app_id.grid(row=0, column=1, padx=5, pady=5)

        tk.Label(form1, text="Status:", bg='#ecf0f1').grid(row=1, column=0, padx=5, pady=5)
        self.del_app_status = ttk.Combobox(form1, width=28, values=['Pending', 'Accepted', 'Rejected'])
        self.del_app_status.grid(row=1, column=1, padx=5, pady=5)

        tk.Button(form1, text="Delete", command=self.delete_application,
                  bg='#e74c3c', fg='white', font=('Arial', 10, 'bold'), padx=20).grid(row=2, columnspan=2, pady=15)

        # DELETE Notification
        f2 = tk.Frame(sub_nb, bg='#ecf0f1')
        sub_nb.add(f2, text='Delete Notification')
        tk.Label(f2, text="Delete Old Notifications",
                 font=('Arial', 14, 'bold'), bg='#ecf0f1').pack(pady=10)

        form2 = tk.Frame(f2, bg='#ecf0f1')
        form2.pack(pady=20)

        tk.Label(form2, text="Delete before date:", bg='#ecf0f1').grid(row=0, column=0, padx=5, pady=5)
        self.del_notif_date = tk.Entry(form2, width=30)
        self.del_notif_date.grid(row=0, column=1, padx=5, pady=5)
        tk.Label(form2, text="(YYYY-MM-DD)", bg='#ecf0f1', font=('Arial', 8)).grid(row=1, column=1, sticky='w')

        tk.Button(form2, text="Delete", command=self.delete_notification,
                  bg='#e74c3c', fg='white', font=('Arial', 10, 'bold'), padx=20).grid(row=2, columnspan=2, pady=15)

    def delete_application(self):
        try:
            cursor = self.conn.cursor()
            cursor.execute("DELETE FROM application WHERE applicationId=? AND status=?",
                           (int(self.del_app_id.get()), self.del_app_status.get()))
            self.conn.commit()
            if cursor.rowcount > 0:
                messagebox.showinfo("Success", "Application deleted!")
            else:
                messagebox.showwarning("Not Found", "No matching record found.")
            self.del_app_id.delete(0, tk.END)
        except Exception as e:
            messagebox.showerror("Error", str(e))

    def delete_notification(self):
        try:
            cursor = self.conn.cursor()
            cursor.execute("DELETE FROM notification WHERE notification_date < ?",
                           (self.del_notif_date.get(),))
            self.conn.commit()
            messagebox.showinfo("Success", f"{cursor.rowcount} notification(s) deleted!")
            self.del_notif_date.delete(0, tk.END)
        except Exception as e:
            messagebox.showerror("Error", str(e))

    # ========== UPDATE TAB (2 tables with conditions) ==========
    def build_update_tab(self, parent):
        sub_nb = ttk.Notebook(parent)
        sub_nb.pack(fill='both', expand=True, padx=10, pady=10)

        # UPDATE Student
        f1 = tk.Frame(sub_nb, bg='#ecf0f1')
        sub_nb.add(f1, text='Update Student')
        tk.Label(f1, text="Update Student Email",
                 font=('Arial', 14, 'bold'), bg='#ecf0f1').pack(pady=10)

        form1 = tk.Frame(f1, bg='#ecf0f1')
        form1.pack(pady=20)

        tk.Label(form1, text="Student ID:", bg='#ecf0f1').grid(row=0, column=0, padx=5, pady=5)
        self.upd_student_id = tk.Entry(form1, width=30)
        self.upd_student_id.grid(row=0, column=1, padx=5, pady=5)

        tk.Label(form1, text="New Email:", bg='#ecf0f1').grid(row=1, column=0, padx=5, pady=5)
        self.upd_student_email = tk.Entry(form1, width=30)
        self.upd_student_email.grid(row=1, column=1, padx=5, pady=5)

        tk.Button(form1, text="Update", command=self.update_student,
                  bg='#3498db', fg='white', font=('Arial', 10, 'bold'), padx=20).grid(row=2, columnspan=2, pady=15)

        # UPDATE Posting
        f2 = tk.Frame(sub_nb, bg='#ecf0f1')
        sub_nb.add(f2, text='Update Posting')
        tk.Label(f2, text="Update Posting Deadline",
                 font=('Arial', 14, 'bold'), bg='#ecf0f1').pack(pady=10)

        form2 = tk.Frame(f2, bg='#ecf0f1')
        form2.pack(pady=20)

        tk.Label(form2, text="Posting ID:", bg='#ecf0f1').grid(row=0, column=0, padx=5, pady=5)
        self.upd_post_id = tk.Entry(form2, width=30)
        self.upd_post_id.grid(row=0, column=1, padx=5, pady=5)

        tk.Label(form2, text="New Deadline:", bg='#ecf0f1').grid(row=1, column=0, padx=5, pady=5)
        self.upd_post_deadline = tk.Entry(form2, width=30)
        self.upd_post_deadline.grid(row=1, column=1, padx=5, pady=5)
        tk.Label(form2, text="(YYYY-MM-DD)", bg='#ecf0f1', font=('Arial', 8)).grid(row=2, column=1, sticky='w')

        tk.Button(form2, text="Update", command=self.update_posting,
                  bg='#3498db', fg='white', font=('Arial', 10, 'bold'), padx=20).grid(row=3, columnspan=2, pady=15)

    def update_student(self):
        try:
            cursor = self.conn.cursor()
            cursor.execute("UPDATE student SET email=? WHERE studentId=?",
                           (self.upd_student_email.get(), int(self.upd_student_id.get())))
            self.conn.commit()
            if cursor.rowcount > 0:
                messagebox.showinfo("Success", "Email updated!")
            else:
                messagebox.showwarning("Not Found", "Student not found.")
            self.upd_student_id.delete(0, tk.END)
            self.upd_student_email.delete(0, tk.END)
        except Exception as e:
            messagebox.showerror("Error", str(e))

    def update_posting(self):
        try:
            cursor = self.conn.cursor()
            cursor.execute("UPDATE internship_posting SET deadline=? WHERE postingId=?",
                           (self.upd_post_deadline.get(), int(self.upd_post_id.get())))
            self.conn.commit()
            if cursor.rowcount > 0:
                messagebox.showinfo("Success", "Deadline updated!")
            else:
                messagebox.showwarning("Not Found", "Posting not found.")
            self.upd_post_id.delete(0, tk.END)
            self.upd_post_deadline.delete(0, tk.END)
        except Exception as e:
            messagebox.showerror("Error", str(e))

    # ========== SELECT TAB (Single table) ==========
    def build_select_tab(self, parent):
        tk.Label(parent, text="View All Students",
                 font=('Arial', 14, 'bold'), bg='#ecf0f1').pack(pady=10)
        tk.Button(parent, text="Load Students", command=self.select_students,
                  bg='#9b59b6', fg='white', font=('Arial', 10, 'bold'), padx=20).pack(pady=5)

        frame = tk.Frame(parent)
        frame.pack(fill='both', expand=True, padx=10, pady=10)

        scroll = tk.Scrollbar(frame)
        scroll.pack(side='right', fill='y')

        self.student_tree = ttk.Treeview(frame, yscrollcommand=scroll.set,
                                         columns=('ID', 'First', 'Last', 'Email', 'Major', 'Univ'),
                                         show='headings')
        self.student_tree.pack(fill='both', expand=True)
        scroll.config(command=self.student_tree.yview)

        for col in ['ID', 'First', 'Last', 'Email', 'Major', 'Univ']:
            self.student_tree.heading(col, text=col)
            self.student_tree.column(col, width=100 if col != 'Email' else 200)

    def select_students(self):
        try:
            for i in self.student_tree.get_children():
                self.student_tree.delete(i)

            cursor = self.conn.cursor()
            cursor.execute("SELECT studentId, firstName, lastName, email, major, universityId FROM student")
            for row in cursor.fetchall():
                self.student_tree.insert('', 'end', values=row)
            messagebox.showinfo("Success", f"Loaded {len(self.student_tree.get_children())} students")
        except Exception as e:
            messagebox.showerror("Error", str(e))

    # ========== JOIN TAB (Multiple tables) ==========
    def build_join_tab(self, parent):
        tk.Label(parent, text="Applications with Details (JOIN 4 tables)",
                 font=('Arial', 14, 'bold'), bg='#ecf0f1').pack(pady=10)
        tk.Button(parent, text="Load Data", command=self.select_join,
                  bg='#16a085', fg='white', font=('Arial', 10, 'bold'), padx=20).pack(pady=5)

        frame = tk.Frame(parent)
        frame.pack(fill='both', expand=True, padx=10, pady=10)

        scroll = tk.Scrollbar(frame)
        scroll.pack(side='right', fill='y')

        self.join_tree = ttk.Treeview(frame, yscrollcommand=scroll.set,
                                      columns=('ID', 'Student', 'Email', 'Posting', 'Company', 'Status', 'Date'),
                                      show='headings')
        self.join_tree.pack(fill='both', expand=True)
        scroll.config(command=self.join_tree.yview)

        headers = {'ID': 50, 'Student': 120, 'Email': 180, 'Posting': 200,
                   'Company': 120, 'Status': 80, 'Date': 90}
        for col, width in headers.items():
            self.join_tree.heading(col, text=col)
            self.join_tree.column(col, width=width)

    def select_join(self):
        try:
            for i in self.join_tree.get_children():
                self.join_tree.delete(i)

            cursor = self.conn.cursor()
            cursor.execute("""
                SELECT a.applicationId, s.firstName + ' ' + s.lastName, s.email,
                       ip.title, c.company_name, a.status, a.application_date
                FROM application a
                JOIN student s ON a.studentId = s.studentId
                JOIN internship_posting ip ON a.postingId = ip.postingId
                JOIN recruiter r ON ip.recruiterId = r.recruiterId
                JOIN company c ON r.companyId = c.companyId
                ORDER BY a.application_date DESC
            """)
            for row in cursor.fetchall():
                self.join_tree.insert('', 'end', values=row)
            messagebox.showinfo("Success", f"Loaded {len(self.join_tree.get_children())} records")
        except Exception as e:
            messagebox.showerror("Error", str(e))

    # ========== REPORT TAB (BONUS) ==========
    def build_report_tab(self, parent):
        tk.Label(parent, text="📊 Application Status Report (BONUS)",
                 font=('Arial', 14, 'bold'), bg='#ecf0f1').pack(pady=10)
        tk.Button(parent, text="Generate Report", command=self.generate_report,
                  bg='#e67e22', fg='white', font=('Arial', 10, 'bold'), padx=30, pady=5).pack(pady=10)

        self.report_text = tk.Text(parent, width=100, height=30, font=('Courier', 10))
        self.report_text.pack(padx=20, pady=10, fill='both', expand=True)

    def generate_report(self):
        try:
            cursor = self.conn.cursor()
            cursor.execute("""
                SELECT c.company_name, ip.title,
                       COUNT(a.applicationId) as total_apps,
                       SUM(CASE WHEN a.status='Accepted' THEN 1 ELSE 0 END) as accepted,
                       SUM(CASE WHEN a.status='Pending' THEN 1 ELSE 0 END) as pending,
                       SUM(CASE WHEN a.status='Rejected' THEN 1 ELSE 0 END) as rejected
                FROM company c
                JOIN recruiter r ON c.companyId = r.companyId
                JOIN internship_posting ip ON r.recruiterId = ip.recruiterId
                LEFT JOIN application a ON ip.postingId = a.postingId
                GROUP BY c.company_name, ip.title
                HAVING COUNT(a.applicationId) > 0
                ORDER BY total_apps DESC
            """)

            report = "=" * 100 + "\n"
            report += "INTERNSHIP APPLICATION STATUS REPORT\n"
            report += "=" * 100 + "\n\n"
            report += f"{'Company':<25} {'Position':<30} {'Total':<8} {'Accepted':<10} {'Pending':<10} {'Rejected':<10}\n"
            report += "-" * 100 + "\n"

            for row in cursor.fetchall():
                report += f"{row[0]:<25} {row[1]:<30} {row[2]:<8} {row[3]:<10} {row[4]:<10} {row[5]:<10}\n"

            report += "=" * 100 + "\n"

            self.report_text.delete('1.0', tk.END)
            self.report_text.insert('1.0', report)
            messagebox.showinfo("Success", "Report generated!")
        except Exception as e:
            messagebox.showerror("Error", str(e))


# ========== RUN APPLICATION ==========
if __name__ == "__main__":
    root = tk.Tk()
    app = InternshipManagementSystem(root)
    root.mainloop()