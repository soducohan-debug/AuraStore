<%-- 
    Document   : header
    Created on : Mar 18, 2026
    Author     : Ma
--%>
<%@page import="DAO.dbconnect"%>
<%@ page contentType="text/html; charset=UTF-8" pageEncoding="UTF-8" %>
<%@ page import="java.sql.*, DAO.dbconnect" %>
<%
    String user = (String) session.getAttribute("user");
    String fullname = (String) session.getAttribute("fullname");
    java.util.List cart = (java.util.List) session.getAttribute("cart");
    int count = (cart != null) ? cart.size() : 0;
%>
<link rel="preconnect" href="https://fonts.googleapis.com">
<link rel="preconnect" href="https://fonts.gstatic.com" crossorigin>
<link href="https://fonts.googleapis.com/css2?family=Playfair+Display:wght@400;500;600;700&family=Montserrat:wght@300;400;500;600&display=swap" rel="stylesheet">
<link href="https://fonts.googleapis.com/css2?family=Material+Symbols+Outlined:wght,FILL@100..700,0..1&display=swap" rel="stylesheet">

<style>
    /* ===== HEADER AURA STYLE ===== */
    .aura-header {
        position: fixed;
        top: 0;
        left: 0;
        right: 0;
        z-index: 999;
        background: rgba(249, 249, 249, 0.85);
        backdrop-filter: blur(16px);
        -webkit-backdrop-filter: blur(16px);
        border-bottom: 0.5px solid rgba(207, 196, 197, 0.3);
        transition: all 0.3s ease;
        padding: 0 40px;
        height: 72px;
        display: flex;
        align-items: center;
        justify-content: space-between;
    }
    .aura-header.scrolled {
        background: rgba(249, 249, 249, 0.98);
        box-shadow: 0 2px 20px rgba(0, 0, 0, 0.06);
    }
    .aura-brand {
        font-family: 'Playfair Display', serif;
        font-size: 22px;
        font-weight: 700;
        letter-spacing: 0.2em;
        color: #000000;
        text-decoration: none;
        display: flex;
        align-items: center;
        gap: 12px;
    }
    .aura-brand .divider {
        width: 1px;
        height: 20px;
        background: #c0c0c0;
    }
    .aura-brand .sub {
        font-family: 'Montserrat', sans-serif;
        font-size: 10px;
        font-weight: 300;
        letter-spacing: 0.15em;
        color: #5d5e5f;
        text-transform: uppercase;
    }
    .aura-nav {
        display: flex;
        align-items: center;
        gap: 32px;
        list-style: none;
        margin: 0;
        padding: 0;
    }
    .aura-nav li {
        list-style: none;
    }
    .aura-nav a {
        font-family: 'Montserrat', sans-serif;
        font-size: 11px;
        font-weight: 500;
        letter-spacing: 0.1em;
        text-transform: uppercase;
        color: #5d5e5f;
        text-decoration: none;
        transition: color 0.3s ease;
        position: relative;
        padding-bottom: 4px;
    }
    .aura-nav a:hover,
    .aura-nav a.active {
        color: #000000;
    }
    .aura-nav a::after {
        content: '';
        position: absolute;
        bottom: 0;
        left: 50%;
        width: 0;
        height: 1px;
        background: #000000;
        transition: all 0.3s ease;
        transform: translateX(-50%);
    }
    .aura-nav a:hover::after,
    .aura-nav a.active::after {
        width: 100%;
    }
    /* Dropdown */
    .aura-dropdown {
        position: relative;
    }
    .aura-dropdown-menu {
        display: none;
        position: absolute;
        top: 100%;
        left: 50%;
        transform: translateX(-50%);
        background: #ffffff;
        min-width: 180px;
        padding: 8px 0;
        border-radius: 8px;
        box-shadow: 0 12px 40px rgba(0, 0, 0, 0.08);
        border: 0.5px solid rgba(207, 196, 197, 0.3);
        margin-top: 12px;
    }
    .aura-dropdown:hover .aura-dropdown-menu {
        display: block;
    }
    .aura-dropdown-menu li {
        padding: 0;
    }
    .aura-dropdown-menu a {
        display: block;
        padding: 8px 20px;
        font-size: 11px;
        font-weight: 400;
        color: #5d5e5f;
        text-transform: none;
        letter-spacing: 0.05em;
    }
    .aura-dropdown-menu a:hover {
        color: #000000;
        background: rgba(0, 0, 0, 0.03);
    }
    .aura-dropdown-menu a::after {
        display: none;
    }
    /* Right Actions */
    .aura-actions {
        display: flex;
        align-items: center;
        gap: 20px;
    }
    .aura-actions a,
    .aura-actions button {
        color: #5d5e5f;
        text-decoration: none;
        transition: color 0.3s ease;
        background: none;
        border: none;
        cursor: pointer;
        font-family: 'Montserrat', sans-serif;
        font-size: 13px;
    }
    .aura-actions a:hover,
    .aura-actions button:hover {
        color: #000000;
    }
    .aura-actions .material-symbols-outlined {
        font-size: 22px;
        font-variation-settings: 'FILL' 0, 'wght' 300, 'GRAD' 0, 'opsz' 24;
    }
    .aura-cart {
        position: relative;
        display: flex;
        align-items: center;
        gap: 4px;
    }
    .aura-cart .badge {
        position: absolute;
        top: -6px;
        right: -10px;
        background: #000000;
        color: #ffffff;
        font-size: 9px;
        font-weight: 600;
        font-family: 'Montserrat', sans-serif;
        width: 18px;
        height: 18px;
        border-radius: 50%;
        display: flex;
        align-items: center;
        justify-content: center;
    }
    .aura-actions .user-name {
        font-size: 12px;
        font-weight: 400;
        color: #5d5e5f;
    }
    .aura-actions .btn-outline {
        padding: 6px 16px;
        border: 0.5px solid #5d5e5f;
        border-radius: 4px;
        font-size: 10px;
        font-weight: 500;
        letter-spacing: 0.1em;
        text-transform: uppercase;
        transition: all 0.3s ease;
    }
    .aura-actions .btn-outline:hover {
        background: #000000;
        color: #ffffff;
        border-color: #000000;
    }
    .aura-actions .btn-primary-hdr {
        padding: 6px 16px;
        background: #000000;
        color: #ffffff;
        border-radius: 4px;
        font-size: 10px;
        font-weight: 500;
        letter-spacing: 0.1em;
        text-transform: uppercase;
        transition: all 0.3s ease;
    }
    .aura-actions .btn-primary-hdr:hover {
        background: #333333;
    }
    /* Search */
    .aura-search {
        display: flex;
        align-items: center;
        border-bottom: 0.5px solid rgba(207, 196, 197, 0.5);
        padding-bottom: 2px;
    }
    .aura-search input {
        border: none;
        background: transparent;
        padding: 4px 8px;
        font-family: 'Montserrat', sans-serif;
        font-size: 12px;
        font-weight: 300;
        color: #1a1c1c;
        outline: none;
        width: 140px;
        transition: width 0.3s ease;
    }
    .aura-search input:focus {
        width: 200px;
    }
    .aura-search input::placeholder {
        color: #b0b0b0;
        font-weight: 300;
        letter-spacing: 0.05em;
    }
    .aura-search button {
        background: none;
        border: none;
        cursor: pointer;
        color: #5d5e5f;
        padding: 4px;
    }
    .aura-search button:hover {
        color: #000000;
    }
    /* Mobile Toggle */
    .aura-mobile-toggle {
        display: none;
        background: none;
        border: none;
        cursor: pointer;
        color: #1a1c1c;
        padding: 8px;
    }
    /* Responsive */
    @media (max-width: 992px) {
        .aura-header {
            padding: 0 20px;
        }
        .aura-nav {
            display: none;
            position: absolute;
            top: 72px;
            left: 0;
            right: 0;
            background: #ffffff;
            flex-direction: column;
            padding: 20px;
            gap: 16px;
            border-bottom: 0.5px solid rgba(207, 196, 197, 0.3);
            box-shadow: 0 12px 40px rgba(0, 0, 0, 0.06);
        }
        .aura-nav.open {
            display: flex;
        }
        .aura-mobile-toggle {
            display: block;
        }
        .aura-dropdown-menu {
            position: static;
            transform: none;
            box-shadow: none;
            border: none;
            padding-left: 16px;
            margin-top: 4px;
        }
        .aura-search input {
            width: 100px;
        }
        .aura-search input:focus {
            width: 140px;
        }
        .aura-actions .user-name,
        .aura-actions .btn-outline,
        .aura-actions .btn-primary-hdr {
            display: none;
        }
    }
    @media (max-width: 576px) {
        .aura-brand {
            font-size: 18px;
        }
        .aura-brand .sub {
            display: none;
        }
        .aura-brand .divider {
            display: none;
        }
        .aura-search input {
            width: 80px;
            font-size: 11px;
        }
        .aura-search input:focus {
            width: 120px;
        }
    }
</style>

<!-- ===== HEADER AURA ===== -->
<header class="aura-header" id="auraHeader">
    <!-- Brand -->
    <a href="index.jsp" class="aura-brand">
        AURA
        <span class="divider"></span>
        <span class="sub">SILVER EDITION</span>
    </a>

    <!-- Navigation -->
    <ul class="aura-nav" id="auraNav">
        <li><a href="index.jsp" class="active">Trang chủ</a></li>
        <li class="aura-dropdown">
            <a href="sanpham.jsp">Sản phẩm ▼</a>
            <ul class="aura-dropdown-menu">
                <%
                    Connection connMenu = null;
                    Statement stMenu = null;
                    ResultSet rsMenu = null;
                    try {
                        connMenu = dbconnect.getConnection();
                        stMenu = connMenu.createStatement();
                        String sqlMenu = "SELECT * FROM danhmuc ORDER BY thu_tu";
                        rsMenu = stMenu.executeQuery(sqlMenu);
                        while (rsMenu.next()) {
                            String slug = rsMenu.getString("slug");
                            String ten = rsMenu.getString("ten_danhmuc");
                %>
                <li><a href="sanpham.jsp?cat=<%= slug %>"><%= ten %></a></li>
                <%
                        }
                    } catch (Exception e) {
                        e.printStackTrace();
                    } finally {
                        if (rsMenu != null) try { rsMenu.close(); } catch(Exception e) {}
                        if (stMenu != null) try { stMenu.close(); } catch(Exception e) {}
                        if (connMenu != null) try { connMenu.close(); } catch(Exception e) {}
                    }
                %>
            </ul>
        </li>
        <li><a href="lienhe.jsp">Liên hệ</a></li>
        <li><a href="sanpham.jsp">Bộ sưu tập</a></li>
    </ul>

    <!-- Right Actions -->
    <div class="aura-actions">
        <!-- Search -->
        <form action="sanpham.jsp" method="get" class="aura-search">
            <input type="text" name="keyword" placeholder="Tìm kiếm..." />
            <button type="submit">
                <span class="material-symbols-outlined" style="font-size:20px;">search</span>
            </button>
        </form>

        <!-- Cart -->
        <a href="giohang.jsp" class="aura-cart">
            <span class="material-symbols-outlined">shopping_bag</span>
            <% if (count > 0) { %>
            <span class="badge"><%= count %></span>
            <% } %>
        </a>

        <!-- User -->
        <% if (user != null) { %>
    <a href="thongtincanhan.jsp" class="user-name hover:text-primary transition-colors">
        <span class="material-symbols-outlined" style="font-size:18px;">person</span>
        <%= fullname != null ? fullname : user %>
    </a>
    <a href="logout" class="btn-outline">Đăng xuất</a>
<% } else { %>
    <a href="login.jsp" class="btn-outline">Đăng nhập</a>
    <a href="dangky.jsp" class="btn-primary-hdr">Đăng ký</a>
<% } %>

        <!-- Mobile Toggle -->
        <button class="aura-mobile-toggle" id="auraMobileToggle" aria-label="Menu">
            <span class="material-symbols-outlined">menu</span>
        </button>
    </div>
</header>

<!-- Spacer để tránh nội dung bị che -->
<div style="height: 72px;"></div>

<script>
    // Mobile menu toggle
    document.getElementById('auraMobileToggle').addEventListener('click', function() {
        document.getElementById('auraNav').classList.toggle('open');
    });

    // Close mobile menu on link click
    document.querySelectorAll('.aura-nav a').forEach(function(link) {
        link.addEventListener('click', function() {
            document.getElementById('auraNav').classList.remove('open');
        });
    });

    // Scroll effect
    window.addEventListener('scroll', function() {
        var header = document.getElementById('auraHeader');
        if (window.scrollY > 50) {
            header.classList.add('scrolled');
        } else {
            header.classList.remove('scrolled');
        }
    });

    // Active link highlight
    var currentPath = window.location.pathname;
    document.querySelectorAll('.aura-nav a').forEach(function(link) {
        var href = link.getAttribute('href');
        if (href && currentPath.includes(href.replace('.jsp', ''))) {
            link.classList.add('active');
        } else if (href === 'index.jsp' && (currentPath === '/' || currentPath === '/AuraStore/')) {
            link.classList.add('active');
        }
    });
</script>