<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<%@ taglib uri="http://java.sun.com/jsp/jstl/core" prefix="c" %>
<%
    // Bonus 3: Theme Preference
    String currentTheme = "light";
    jakarta.servlet.http.Cookie[] cookies = request.getCookies();
    if (cookies != null) {
        for (jakarta.servlet.http.Cookie cookie : cookies) {
            if ("user_theme".equals(cookie.getName())) {
                currentTheme = cookie.getValue();
                break;
            }
        }
    }
    
    // Bonus 5: Activity Stats
    int visitCount = 0;
    long lastLogin = 0;
    if (cookies != null) {
        for (jakarta.servlet.http.Cookie cookie : cookies) {
            if ("visit_count".equals(cookie.getName())) {
                try { visitCount = Integer.parseInt(cookie.getValue()); } catch(Exception e){}
            } else if ("last_login".equals(cookie.getName())) {
                try { lastLogin = Long.parseLong(cookie.getValue()); } catch(Exception e){}
            }
        }
    }
    String lastLoginStr = "First visit";
    if (lastLogin > 0) {
        java.text.SimpleDateFormat sdf = new java.text.SimpleDateFormat("MMM dd, yyyy HH:mm");
        lastLoginStr = sdf.format(new java.util.Date(lastLogin));
    }
%>
<!DOCTYPE html>
<html data-theme="<%= currentTheme %>">
<head>
    <meta charset="UTF-8">
    <title>Dashboard</title>
    <style>
        * {
            margin: 0;
            padding: 0;
            box-sizing: border-box;
        }
        
        body {
            font-family: 'Segoe UI', Tahoma, Geneva, Verdana, sans-serif;
            background: #f5f5f5;
        }
        
        .navbar {
            background: #2c3e50;
            color: white;
            padding: 15px 30px;
            display: flex;
            justify-content: space-between;
            align-items: center;
        }
        
        .navbar h2 {
            font-size: 20px;
        }
        
        .navbar-right {
            display: flex;
            align-items: center;
            gap: 20px;
        }
        
        .user-info {
            display: flex;
            align-items: center;
            gap: 10px;
        }
        
        .role-badge {
            padding: 4px 12px;
            border-radius: 12px;
            font-size: 12px;
            font-weight: 600;
        }
        
        .role-admin {
            background: #e74c3c;
        }
        
        .role-user {
            background: #3498db;
        }
        
        .btn-logout {
            padding: 8px 20px;
            background: #e74c3c;
            color: white;
            text-decoration: none;
            border-radius: 5px;
            font-size: 14px;
            transition: background 0.3s;
        }
        
        .btn-logout:hover {
            background: #c0392b;
        }
        
        .container {
            max-width: 1200px;
            margin: 30px auto;
            padding: 0 20px;
        }
        
        .welcome-card {
            background: white;
            padding: 30px;
            border-radius: 10px;
            box-shadow: 0 2px 10px rgba(0,0,0,0.1);
            margin-bottom: 30px;
        }
        
        .welcome-card h1 {
            color: #2c3e50;
            margin-bottom: 10px;
        }
        
        .welcome-card p {
            color: #7f8c8d;
        }
        
        .stats-grid {
            display: grid;
            grid-template-columns: repeat(auto-fit, minmax(250px, 1fr));
            gap: 20px;
            margin-bottom: 30px;
        }
        
        .stat-card {
            background: white;
            padding: 25px;
            border-radius: 10px;
            box-shadow: 0 2px 10px rgba(0,0,0,0.1);
            display: flex;
            align-items: center;
            gap: 20px;
        }
        
        .stat-icon {
            font-size: 40px;
            width: 60px;
            height: 60px;
            display: flex;
            align-items: center;
            justify-content: center;
            border-radius: 10px;
        }
        
        .stat-icon-students {
            background: #e8f4fd;
        }
        
        .stat-content h3 {
            font-size: 28px;
            color: #2c3e50;
            margin-bottom: 5px;
        }
        
        .stat-content p {
            color: #7f8c8d;
            font-size: 14px;
        }
        
        .quick-actions {
            background: white;
            padding: 30px;
            border-radius: 10px;
            box-shadow: 0 2px 10px rgba(0,0,0,0.1);
        }
        
        .quick-actions h2 {
            color: #2c3e50;
            margin-bottom: 20px;
        }
        
        .action-grid {
            display: grid;
            grid-template-columns: repeat(auto-fit, minmax(200px, 1fr));
            gap: 15px;
        }
        
        .action-btn {
            padding: 20px;
            background: #3498db;
            color: white;
            text-decoration: none;
            border-radius: 8px;
            text-align: center;
            transition: all 0.3s;
            display: block;
        }
        
        .action-btn:hover {
            background: #2980b9;
            transform: translateY(-2px);
        }
        
        .action-btn-primary {
            background: #3498db;
        }
        
        .action-btn-success {
            background: #27ae60;
        }
        
        .action-btn-warning {
            background: #f39c12;
        }
        
        /* Bonus 3: Dark Mode Styles */
        [data-theme="dark"] body { background: #1a1a1a; color: #e0e0e0; }
        [data-theme="dark"] .navbar { background: #000; }
        [data-theme="dark"] .welcome-card, 
        [data-theme="dark"] .stat-card, 
        [data-theme="dark"] .quick-actions { background: #2d2d2d; color: #e0e0e0; }
        [data-theme="dark"] .welcome-card h1,
        [data-theme="dark"] .stat-content h3,
        [data-theme="dark"] .quick-actions h2 { color: #fff; }
        
        .theme-switch { margin-right: 15px; }
        .theme-switch a { color: white; text-decoration: none; margin: 0 5px; font-size: 12px; opacity: 0.7; }
        .theme-switch a.active { opacity: 1; font-weight: bold; text-decoration: underline; }
        
        .stats-info { margin-top: 20px; padding: 15px; background: rgba(0,0,0,0.05); border-radius: 8px; font-size: 14px; }
        [data-theme="dark"] .stats-info { background: rgba(255,255,255,0.05); }
    </style>
</head>
<body>
    <!-- Navigation Bar -->
    <div class="navbar">
        <h2>📚 Student Management System</h2>
        <div class="navbar-right">
            <!-- Bonus 3: Theme Switcher -->
            <div class="theme-switch">
                Theme: 
                <a href="theme?mode=light" class="<%= "light".equals(currentTheme) ? "active" : "" %>">Light</a> | 
                <a href="theme?mode=dark" class="<%= "dark".equals(currentTheme) ? "active" : "" %>">Dark</a>
            </div>
            
            <div class="user-info">
                <span>${sessionScope.fullName}</span>
                <span class="role-badge role-${sessionScope.role}">
                    ${sessionScope.role}
                </span>
            </div>
            <a href="change-password" class="btn-logout" style="background: #3498db;">Password</a>
            <a href="logout" class="btn-logout">Logout</a>
        </div>
    </div>
    
    <!-- Main Content -->
    <div class="container">
        <!-- Welcome Card -->
        <div class="welcome-card">
            <h1>${welcomeMessage}</h1>
            <p>Here's what's happening with your students today.</p>
            
            <!-- Bonus 5: Activity Stats -->
            <div class="stats-info">
                <strong>Total Visits:</strong> <%= visitCount %> &nbsp;|&nbsp; 
                <strong>Last Login:</strong> <%= lastLoginStr %>
            </div>
        </div>
        
        <!-- Statistics -->
        <div class="stats-grid">
            <div class="stat-card">
                <div class="stat-icon stat-icon-students">
                    👨🎓
                </div>
                <div class="stat-content">
                    <h3>${totalStudents}</h3>
                    <p>Total Students</p>
                </div>
            </div>
        </div>
        
        <!-- Quick Actions -->
        <div class="quick-actions">
            <h2>Quick Actions</h2>
            <div class="action-grid">
                <a href="student?action=list" class="action-btn action-btn-primary">
                    📋 View All Students
                </a>
                
                <c:if test="${sessionScope.role eq 'admin'}">
                    <a href="student?action=new" class="action-btn action-btn-success">
                        ➕ Add New Student
                    </a>
                </c:if>
                
                <a href="student?action=search" class="action-btn action-btn-warning">
                    🔍 Search Students
                </a>
            </div>
        </div>
    </div>
    
    <!-- Bonus 4: Session Timeout Warning -->
    <script>
        const SESSION_TIMEOUT = 30 * 60 * 1000; // 30 minutes
        const WARNING_TIME = 5 * 60 * 1000;     // 5 minutes
        let lastActivity = Date.now();
        
        ['mousemove', 'keypress', 'click', 'scroll'].forEach(evt => 
            document.addEventListener(evt, () => lastActivity = Date.now())
        );
        
        setInterval(() => {
            const timeLeft = SESSION_TIMEOUT - (Date.now() - lastActivity);
            if (timeLeft <= 0) {
                alert('Session expired. Please login again.');
                window.location.href = 'logout';
            } else if (timeLeft <= WARNING_TIME) {
                console.warn('Session expiring soon');
            }
        }, 60000);
    </script>
</body>
</html>
