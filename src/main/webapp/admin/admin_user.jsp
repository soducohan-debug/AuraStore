<%@page import="java.sql.*"%>
<%@page import="DAO.dbconnect"%>
<%@ page contentType="text/html;charset=UTF-8" %>

<jsp:include page="sidebar.jsp" />

<%
    String user = (String) session.getAttribute("user");
    String role = (String) session.getAttribute("role");

    if (user == null || !"admin".equals(role)) {
        response.sendRedirect("../login.jsp");
        return;
    }

    String path = request.getContextPath();
    Connection conn = dbconnect.getConnection();

    // ===== XÓA USER =====
    String xoa = request.getParameter("xoa");
    if (xoa != null && xoa.matches("\\d+")) {
        PreparedStatement ps = conn.prepareStatement(
                "DELETE FROM user WHERE id=? AND role!='admin'");
        ps.setInt(1, Integer.parseInt(xoa));
        ps.executeUpdate();
        ps.close();
        response.sendRedirect("admin_user.jsp?success=deleted");
        return;
    }

    // ===== KHÓA =====
    String block = request.getParameter("block");
    if (block != null && block.matches("\\d+")) {
        PreparedStatement ps = conn.prepareStatement(
                "UPDATE user SET status='blocked' WHERE id=? AND role!='admin'");
        ps.setInt(1, Integer.parseInt(block));
        ps.executeUpdate();
        ps.close();
        response.sendRedirect("admin_user.jsp?success=blocked");
        return;
    }

    // ===== MỞ =====
    String unblock = request.getParameter("unblock");
    if (unblock != null && unblock.matches("\\d+")) {
        PreparedStatement ps = conn.prepareStatement(
                "UPDATE user SET status='active' WHERE id=? AND role!='admin'");
        ps.setInt(1, Integer.parseInt(unblock));
        ps.executeUpdate();
        ps.close();
        response.sendRedirect("admin_user.jsp?success=unblocked");
        return;
    }

    // ===== SEARCH =====
    String keyword = request.getParameter("search");
    PreparedStatement st;

    if (keyword != null && !keyword.trim().isEmpty()) {
        st = conn.prepareStatement(
                "SELECT * FROM user WHERE username LIKE ? OR fullname LIKE ? OR email LIKE ? ORDER BY id DESC");
        String searchTerm = "%" + keyword.trim() + "%";
        st.setString(1, searchTerm);
        st.setString(2, searchTerm);
        st.setString(3, searchTerm);
    } else {
        st = conn.prepareStatement("SELECT * FROM user ORDER BY id DESC");
    }

    ResultSet rs = st.executeQuery();
    
    // Đếm số lượng user theo status
    int totalUsers = 0;
    int activeUsers = 0;
    int blockedUsers = 0;
    int adminUsers = 0;
    PreparedStatement stCount = conn.prepareStatement(
        "SELECT role, status, COUNT(*) as count FROM user GROUP BY role, status");
    ResultSet rsCount = stCount.executeQuery();
    while (rsCount.next()) {
        String roleUser = rsCount.getString("role");
        String status = rsCount.getString("status");
        int count = rsCount.getInt("count");
        totalUsers += count;
        if ("admin".equals(roleUser)) {
            adminUsers += count;
        } else if ("active".equals(status)) {
            activeUsers += count;
        } else if ("blocked".equals(status)) {
            blockedUsers += count;
        }
    }
    rsCount.close();
    stCount.close();
    
    String successMsg = request.getParameter("success");
    String errorMsg = request.getParameter("error");
%>

<!DOCTYPE html>
<html>
    <head>
        <title>Quản lý người dùng - AURA Admin</title>
        <link href="https://fonts.googleapis.com/css2?family=Quicksand:wght@300;400;500;600;700&display=swap" rel="stylesheet">
        <link href="https://fonts.googleapis.com/css2?family=Material+Symbols+Outlined:wght@100..700&display=swap" rel="stylesheet">
        <style>
            * { box-sizing: border-box; margin: 0; padding: 0; }
            body {
                font-family: 'Quicksand', sans-serif;
                background: #f8f7f4;
                min-height: 100vh;
                padding-left: 240px;
                color: #2d2d2d;
            }
            .container {
                max-width: 1400px;
                margin: 0 auto;
                padding: 24px 28px 40px;
            }
            .page-header {
                display: flex;
                align-items: center;
                justify-content: space-between;
                margin-bottom: 24px;
                flex-wrap: wrap;
                gap: 12px;
            }
            .page-title {
                font-size: 22px;
                font-weight: 600;
                color: #2d2d2d;
            }
            .page-title span { color: #c9a96e; }
            .page-subtitle {
                font-size: 13px;
                color: #8a8a8a;
                margin-top: 4px;
                font-weight: 300;
            }

            .alert-success {
                background: #d4edda;
                color: #155724;
                padding: 12px 20px;
                border-radius: 8px;
                margin-bottom: 16px;
                border: 1px solid #c3e6cb;
                display: flex;
                justify-content: space-between;
                align-items: center;
            }
            .alert-error {
                background: #f8d7da;
                color: #721c24;
                padding: 12px 20px;
                border-radius: 8px;
                margin-bottom: 16px;
                border: 1px solid #f5c6cb;
                display: flex;
                justify-content: space-between;
                align-items: center;
            }
            .close-btn {
                background: none;
                border: none;
                font-size: 18px;
                cursor: pointer;
                color: inherit;
                opacity: 0.5;
            }
            .close-btn:hover { opacity: 1; }

            /* ===== STATS ===== */
            .stats-grid {
                display: grid;
                grid-template-columns: repeat(4, 1fr);
                gap: 16px;
                margin-bottom: 24px;
            }
            .stat-card {
                background: #ffffff;
                border-radius: 12px;
                padding: 18px 24px;
                border: 1px solid #e8e5e0;
                transition: all 0.3s ease;
            }
            .stat-card:hover {
                transform: translateY(-2px);
                box-shadow: 0 8px 24px rgba(0,0,0,0.04);
            }
            .stat-card .stat-label {
                font-size: 11px;
                font-weight: 500;
                text-transform: uppercase;
                letter-spacing: 0.5px;
                color: #8a8a8a;
            }
            .stat-card .stat-value {
                font-size: 24px;
                font-weight: 600;
                margin-top: 2px;
            }
            .stat-card .stat-value.gold { color: #c9a96e; }
            .stat-card .stat-value.green { color: #27ae60; }
            .stat-card .stat-value.red { color: #dc3545; }
            .stat-card .stat-value.blue { color: #00639c; }

            /* ===== FILTER ===== */
            .filter-bar {
                background: #ffffff;
                border-radius: 12px;
                padding: 16px 20px;
                margin-bottom: 20px;
                border: 1px solid #e8e5e0;
                display: flex;
                gap: 16px;
                flex-wrap: wrap;
                align-items: flex-end;
            }
            .filter-group {
                display: flex;
                flex-direction: column;
                gap: 4px;
            }
            .filter-group label {
                font-size: 11px;
                font-weight: 500;
                color: #8a8a8a;
                text-transform: uppercase;
                letter-spacing: 0.5px;
            }
            .filter-group input {
                padding: 8px 14px;
                border-radius: 8px;
                border: 1px solid #e8e5e0;
                font-family: 'Quicksand', sans-serif;
                font-size: 13px;
                background: #faf9f8;
                min-width: 200px;
                transition: all 0.3s ease;
                color: #2d2d2d;
            }
            .filter-group input:focus {
                border-color: #c9a96e;
                outline: none;
                background: #ffffff;
            }
            .btn-filter {
                padding: 8px 20px;
                border: none;
                border-radius: 8px;
                font-family: 'Quicksand', sans-serif;
                font-size: 13px;
                font-weight: 500;
                cursor: pointer;
                transition: all 0.3s ease;
                background: linear-gradient(135deg, #1a1a2e 0%, #16213e 50%, #0f3460 100%);
                color: #ffffff;
                display: inline-flex;
                align-items: center;
                gap: 6px;
            }
            .btn-filter:hover {
                transform: translateY(-2px);
                box-shadow: 0 4px 16px rgba(15, 52, 96, 0.2);
            }
            .btn-filter.reset {
                background: #e8e5e0;
                color: #2d2d2d;
            }
            .btn-filter.reset:hover {
                background: #d4d4d4;
            }

            /* ===== TABLE ===== */
            .table-card {
                background: #ffffff;
                border-radius: 12px;
                border: 1px solid #e8e5e0;
                overflow: hidden;
                overflow-x: auto;
            }
            table {
                width: 100%;
                border-collapse: collapse;
                min-width: 800px;
            }
            thead {
                background: #faf9f8;
                border-bottom: 1px solid #e8e5e0;
            }
            th {
                padding: 12px 16px;
                text-align: left;
                font-size: 11px;
                font-weight: 600;
                text-transform: uppercase;
                letter-spacing: 0.5px;
                color: #8a8a8a;
                white-space: nowrap;
            }
            td {
                padding: 10px 16px;
                border-bottom: 1px solid #f0eeeb;
                font-size: 13px;
                vertical-align: middle;
            }
            tr:hover {
                background: #faf9f8;
            }
            .id-badge {
                background: #f0ede8;
                color: #888;
                font-size: 11px;
                font-weight: 500;
                padding: 3px 8px;
                border-radius: 6px;
                white-space: nowrap;
            }

            .badge-role {
                padding: 3px 12px;
                border-radius: 12px;
                font-size: 11px;
                font-weight: 500;
                white-space: nowrap;
                display: inline-block;
            }
            .badge-admin {
                background: #1a1a2e;
                color: #ffffff;
            }
            .badge-user {
                background: #e8e5e0;
                color: #2d2d2d;
            }

            .badge-status {
                padding: 3px 12px;
                border-radius: 12px;
                font-size: 11px;
                font-weight: 500;
                white-space: nowrap;
                display: inline-block;
            }
            .badge-active {
                background: #d4edda;
                color: #155724;
            }
            .badge-blocked {
                background: #f8d7da;
                color: #721c24;
            }

            /* ===== ACTION BUTTONS ===== */
            .action-wrap {
                display: flex;
                align-items: center;
                gap: 6px;
                flex-wrap: wrap;
                justify-content: flex-end;
            }
            .btn-action {
                padding: 6px 14px;
                border: none;
                border-radius: 6px;
                font-family: 'Quicksand', sans-serif;
                font-size: 12px;
                font-weight: 500;
                cursor: pointer;
                transition: all 0.3s ease;
                text-decoration: none;
                display: inline-flex;
                align-items: center;
                gap: 4px;
                min-width: 60px;
                justify-content: center;
                white-space: nowrap;
            }
            .btn-action:hover {
                transform: translateY(-1px);
            }
            .btn-block {
                background: #dc3545;
                color: #ffffff;
            }
            .btn-block:hover {
                background: #c0392b;
            }
            .btn-unblock {
                background: #27ae60;
                color: #ffffff;
            }
            .btn-unblock:hover {
                background: #1e7e34;
            }
            .btn-del {
                background: #dc3545;
                color: #ffffff;
            }
            .btn-del:hover {
                background: #c0392b;
            }
            .btn-disabled {
                background: #e8e5e0;
                color: #999;
                cursor: not-allowed;
                opacity: 0.6;
                white-space: nowrap;
            }
            .btn-disabled:hover {
                transform: none;
            }

            .empty-state {
                text-align: center;
                padding: 60px 20px;
                color: #a8a4a0;
            }
            .empty-state .icon { font-size: 56px; opacity: 0.3; display: block; margin-bottom: 12px; }
            .empty-state h3 { font-weight: 400; font-size: 16px; }
            .empty-state p { font-size: 13px; margin-top: 4px; }

            @media (max-width: 992px) {
                body { padding-left: 0; padding-top: 70px; }
                .container { padding: 16px; }
                .stats-grid { grid-template-columns: repeat(2, 1fr); }
            }
            @media (max-width: 600px) {
                .stats-grid { grid-template-columns: 1fr; }
                .filter-bar { flex-direction: column; }
                .filter-group { width: 100%; }
                .filter-group input { min-width: 100%; }
                .action-wrap { flex-direction: column; }
                .btn-action { width: 100%; justify-content: center; }
            }
        </style>
    </head>
    <body>
        <div class="container">
            <!-- ===== HEADER ===== -->
            <div class="page-header">
                <div>
                    <div class="page-title">Quản lý người dùng</div>
                    <div class="page-subtitle">
                        Tổng số: <strong><%= totalUsers %></strong> người dùng
                        | <span style="color:#27ae60;"><%= activeUsers %> hoạt động</span>
                        | <span style="color:#dc3545;"><%= blockedUsers %> bị khóa</span>
                        | <span style="color:#1a1a2e;"><%= adminUsers %> admin</span>
                    </div>
                </div>
            </div>

            <!-- ===== THÔNG BÁO ===== -->
            <% if (successMsg != null) { %>
            <div class="alert-success" id="alertMessage">
                <span>
                    <% if ("deleted".equals(successMsg)) { %>
                    Đã xóa người dùng thành công!
                    <% } else if ("blocked".equals(successMsg)) { %>
                    Đã khóa người dùng!
                    <% } else if ("unblocked".equals(successMsg)) { %>
                    Đã mở khóa người dùng!
                    <% } %>
                </span>
                <button class="close-btn" onclick="closeAlert()">✕</button>
            </div>
            <% } %>

            <% if (errorMsg != null) { %>
            <div class="alert-error" id="alertMessage">
                <span>Có lỗi xảy ra: <%= errorMsg %></span>
                <button class="close-btn" onclick="closeAlert()">✕</button>
            </div>
            <% } %>

            <!-- ===== STATS ===== -->
            <div class="stats-grid">
                <div class="stat-card">
                    <div class="stat-label">Tổng người dùng</div>
                    <div class="stat-value gold"><%= totalUsers %></div>
                </div>
                <div class="stat-card">
                    <div class="stat-label">Đang hoạt động</div>
                    <div class="stat-value green"><%= activeUsers %></div>
                </div>
                <div class="stat-card">
                    <div class="stat-label">Đã khóa</div>
                    <div class="stat-value red"><%= blockedUsers %></div>
                </div>
                <div class="stat-card">
                    <div class="stat-label">Quản trị viên</div>
                    <div class="stat-value blue"><%= adminUsers %></div>
                </div>
            </div>

            <!-- ===== FILTER ===== -->
            <div class="filter-bar">
                <form method="get" style="display: flex; gap: 16px; flex-wrap: wrap; align-items: flex-end; width: 100%;">
                    <div class="filter-group">
                        <label>Tìm kiếm</label>
                        <input type="text" name="search" placeholder="Tên, username, email..." 
                               value="<%= keyword != null ? keyword : "" %>">
                    </div>
                    <button type="submit" class="btn-filter">Tìm</button>
                    <a href="admin_user.jsp" class="btn-filter reset">Xóa lọc</a>
                </form>
            </div>

            <!-- ===== TABLE ===== -->
            <div class="table-card">
                <table>
                    <thead>
                        <tr>
                            <th style="width:60px;">ID</th>
                            <th>Tên đăng nhập</th>
                            <th>Họ tên</th>
                            <th>Email</th>
                            <th>SĐT</th>
                            <th style="width:90px;">Vai trò</th>
                            <th style="width:100px;">Trạng thái</th>
                            <th style="width:200px;text-align:center;">Thao tác</th>
                        </tr>
                    </thead>
                    <tbody>
                        <% 
                            boolean hasData = false;
                            while (rs.next()) {
                                hasData = true;
                                int id = rs.getInt("id");
                                String username = rs.getString("username");
                                String fullname = rs.getString("fullname");
                                String email = rs.getString("email");
                                String phone = rs.getString("phone");
                                String roleUser = rs.getString("role");
                                String status = rs.getString("status");
                                boolean isAdmin = "admin".equals(roleUser);
                        %>
                        <tr>
                            <td><span class="id-badge">#<%= String.format("%03d", id) %></span></td>
                            <td><strong><%= username %></strong></td>
                            <td><%= fullname != null ? fullname : "---" %></td>
                            <td><%= email != null ? email : "---" %></td>
                            <td><%= phone != null ? phone : "---" %></td>
                            <td>
                                <span class="badge-role <%= isAdmin ? "badge-admin" : "badge-user" %>">
                                    <%= isAdmin ? "Admin" : "User" %>
                                </span>
                            </td>
                            <td>
                                <span class="badge-status <%= "active".equals(status) ? "badge-active" : "badge-blocked" %>">
                                    <%= "active".equals(status) ? "Hoạt động" : "Đã khóa" %>
                                </span>
                            </td>
                            <td>
                                <div class="action-wrap">
                                    <% if (!isAdmin) { %>
                                        <% if ("active".equals(status)) { %>
                                            <a href="?block=<%= id %><%= keyword != null ? "&search=" + keyword : "" %>" 
                                               class="btn-action btn-block"
                                               onclick="return confirm('Khóa người dùng <%= username %>?')">
                                                Khóa
                                            </a>
                                        <% } else { %>
                                            <a href="?unblock=<%= id %><%= keyword != null ? "&search=" + keyword : "" %>" 
                                               class="btn-action btn-unblock"
                                               onclick="return confirm('Mở khóa người dùng <%= username %>?')">
                                                Mở
                                            </a>
                                        <% } %>
                                        <a href="?xoa=<%= id %><%= keyword != null ? "&search=" + keyword : "" %>" 
                                           class="btn-action btn-del"
                                           onclick="return confirm('Xóa người dùng <%= username %>?\nHành động này không thể hoàn tác!')">
                                            Xóa
                                        </a>
                                    <% } else { %>
                                        <span class="btn-action btn-disabled">Admin</span>
                                    <% } %>
                                </div>
                            </td>
                        </tr>
                        <% } 
                        if (!hasData) { %>
                        <tr>
                            <td colspan="8">
                                <div class="empty-state">
                                    <span class="icon">📭</span>
                                    <h3>Không tìm thấy người dùng</h3>
                                    <p>Hãy thay đổi từ khóa tìm kiếm</p>
                                </div>
                            </td>
                        </tr>
                        <% } %>
                    </tbody>
                </table>
            </div>

            <!-- ===== FOOTER ===== -->
            <div style="margin-top:20px;text-align:center;font-size:12px;color:#c0bdb8;letter-spacing:0.5px;">
                AURA Admin Panel
            </div>
        </div>

        <script>
            function closeAlert() {
                var alert = document.getElementById('alertMessage');
                if (alert) {
                    alert.style.transition = 'opacity 0.3s';
                    alert.style.opacity = '0';
                    setTimeout(function() { alert.style.display = 'none'; }, 300);
                }
            }

            setTimeout(function() {
                var alert = document.getElementById('alertMessage');
                if (alert) {
                    alert.style.transition = 'opacity 0.5s';
                    alert.style.opacity = '0';
                    setTimeout(function() { alert.style.display = 'none'; }, 500);
                }
            }, 5000);
        </script>
    </body>
</html>

<%
    rs.close();
    st.close();
    conn.close();
%>