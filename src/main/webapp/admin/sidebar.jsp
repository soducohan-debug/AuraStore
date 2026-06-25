<%-- 
    Document   : sidebar
    Created on : Mar 25, 2026, 2:25:14 PM
    Author     : Ma
--%>
<%@ page contentType="text/html;charset=UTF-8" %>

<style>
    * { margin: 0; padding: 0; box-sizing: border-box; }
    body {
        margin: 0;
        padding-left: 240px;
        font-family: 'Quicksand', sans-serif;
        background: #f8f7f4;
        color: #2d2d2d;
    }
    .sidebar {
        width: 240px;
        height: 100vh;
        background: linear-gradient(135deg, #1a1a2e 0%, #16213e 50%, #0f3460 100%);
        color: #2d2d2d;
        position: fixed;
        top: 0;
        left: 0;
        padding: 24px 16px;
        display: flex;
        flex-direction: column;
        border-right: 1px solid #e8e5e0;
        z-index: 100;
        overflow-y: auto;
    }
    .sidebar-brand {
        font-family: 'Playfair Display', serif;
        font-size: 22px;
        font-weight: 700;
        letter-spacing: 0.15em;
        color: #e8c87a;
        padding: 0 12px 20px 12px;
        margin-bottom: 8px;
        border-bottom: 1px solid #e8e5e0;
        display: flex;
        align-items: center;
        gap: 8px;
    }
    .sidebar-brand span { color: #c9a96e; }
    .sidebar-brand .sub {
        font-family: 'Quicksand', sans-serif;
        font-size: 9px;
        font-weight: 300;
        letter-spacing: 0.1em;
        color: #a8a4a0;
        margin-left: 4px;
    }
    .sidebar-menu { flex: 1; padding-top: 4px; }
    .sidebar-menu .menu-label {
        font-size: 10px;
        font-weight: 600;
        text-transform: uppercase;
        letter-spacing: 0.1em;
        color: #c0bdb8;
        padding: 12px 12px 8px 12px;
    }
    .sidebar-menu .menu-label:first-of-type { padding-top: 0; }
    .sidebar a {
        color: #8a8a8a;
        text-decoration: none;
        padding: 10px 14px;
        border-radius: 8px;
        font-size: 14px;
        margin-bottom: 2px;
        display: flex;
        align-items: center;
        gap: 12px;
        transition: all 0.25s ease;
        font-weight: 400;
        font-family: 'Quicksand', sans-serif;
        border-left: 3px solid transparent;
    }
    .sidebar a .material-symbols-outlined {
        font-size: 20px;
        font-variation-settings: 'FILL' 0, 'wght' 300, 'GRAD' 0, 'opsz' 24;
        color: #b0b0b0;
        transition: all 0.25s ease;
        width: 24px;
        text-align: center;
    }
    .sidebar a:hover {
        background: #f5f4f0;
        color: #2d2d2d;
        border-left-color: #c9a96e;
    }
    .sidebar a:hover .material-symbols-outlined { color: #c9a96e; }
    .sidebar a.active {
        background: #f5f4f0;
        color: #2d2d2d;
        font-weight: 500;
        border-left-color: #c9a96e;
    }
    .sidebar a.active .material-symbols-outlined { color: #c9a96e; }
    .sidebar-footer {
        border-top: 1px solid #e8e5e0;
        padding-top: 12px;
        margin-top: 4px;
    }
    .sidebar-footer a { color: #8a8a8a; }
    .sidebar-footer a:hover {
        color: #dc3545;
        border-left-color: #dc3545;
    }
    .sidebar-footer a:hover .material-symbols-outlined { color: #dc3545; }

    @media (max-width: 992px) {
        body { padding-left: 0; padding-top: 70px; }
        .sidebar {
            width: 100%;
            height: auto;
            position: fixed;
            top: 0;
            left: 0;
            flex-direction: row;
            padding: 8px 16px;
            border-right: none;
            border-bottom: 1px solid #e8e5e0;
            background: rgba(255,255,255,0.95);
            backdrop-filter: blur(8px);
            overflow-x: auto;
            overflow-y: hidden;
            z-index: 999;
        }
        .sidebar-brand {
            font-size: 16px;
            padding: 4px 12px;
            border-bottom: none;
            margin-bottom: 0;
            white-space: nowrap;
        }
        .sidebar-brand .sub { display: none; }
        .sidebar-menu {
            display: flex;
            align-items: center;
            gap: 2px;
            padding-top: 0;
            flex: 1;
            overflow-x: auto;
        }
        .sidebar-menu .menu-label { display: none; }
        .sidebar a {
            padding: 6px 10px;
            font-size: 12px;
            white-space: nowrap;
            border-left: none;
            border-bottom: 2px solid transparent;
            border-radius: 0;
        }
        .sidebar a .material-symbols-outlined { font-size: 16px; width: 20px; }
        .sidebar a.active {
            border-bottom-color: #c9a96e;
            border-left-color: transparent;
            background: transparent;
        }
        .sidebar a:hover {
            border-left-color: transparent;
            border-bottom-color: #c9a96e;
            background: transparent;
        }
        .sidebar-footer {
            border-top: none;
            padding-top: 0;
            margin-top: 0;
            display: flex;
            align-items: center;
        }
        .sidebar-footer a { border-bottom: 2px solid transparent; }
        .sidebar-footer a:hover { border-bottom-color: #dc3545; border-left-color: transparent; }
    }
    @media (max-width: 576px) {
        .sidebar a { font-size: 11px; padding: 4px 8px; }
        .sidebar a .material-symbols-outlined { font-size: 14px; width: 16px; }
        .sidebar-brand { font-size: 14px; padding: 2px 8px; }
    }
</style>

<%
    String uri = request.getRequestURI();
%>

<div class="sidebar">
    <!-- Brand -->
    <div class="sidebar-brand">
        AURA<span class="sub">ADMIN</span>
    </div>

    <!-- Menu -->
    <div class="sidebar-menu">
        <!-- Quản lý chính -->
        <div class="menu-label">Quản lý chính</div>

        <a href="<%= request.getContextPath() %>/admin/admin_dashboard.jsp"
           class="<%= uri.contains("admin_dashboard") ? "active" : "" %>">
            <span class="material-symbols-outlined">dashboard</span>
            Dashboard
        </a>

        <a href="<%= request.getContextPath() %>/admin/admin_sanpham.jsp"
           class="<%= uri.contains("admin_sanpham") ? "active" : "" %>">
            <span class="material-symbols-outlined">inventory_2</span>
            Quản lý sản phẩm
        </a>

        <a href="<%= request.getContextPath() %>/admin/admin_user.jsp"
           class="<%= uri.contains("admin_user") ? "active" : "" %>">
            <span class="material-symbols-outlined">people</span>
            Quản lý người dùng
        </a>

        <a href="<%= request.getContextPath() %>/admin/admin_donhang.jsp"
           class="<%= uri.contains("admin_donhang") ? "active" : "" %>">
            <span class="material-symbols-outlined">receipt_long</span>
            Quản lý đơn hàng
        </a>

        <!-- Thống kê -->
        <div class="menu-label">Thống kê</div>

        <a href="<%= request.getContextPath() %>/admin/admin_doanhthu.jsp"
           class="<%= uri.contains("admin_doanhthu") ? "active" : "" %>">
            <span class="material-symbols-outlined">trending_up</span>
            Doanh thu
        </a>

        <!-- Khác -->
        <div class="menu-label"></div>
    </div>

    <!-- Footer - Đăng xuất -->
    <div class="sidebar-footer">
        <a href="<%= request.getContextPath() %>/logout">
            <span class="material-symbols-outlined">logout</span>
            Đăng xuất
        </a>
    </div>
</div>