<%-- Document : admin_dashboard --%>
<%@page import="java.util.*"%>
<%@page import="java.sql.*, DAO.dbconnect, java.text.NumberFormat, java.util.Locale"%>
<%@ page contentType="text/html;charset=UTF-8" %>
<jsp:include page="sidebar.jsp" />

<%
    String user = (String) session.getAttribute("user");
    String role = (String) session.getAttribute("role");
    if (user == null || !"admin".equals(role)) {
        response.sendRedirect("../login.jsp");
        return;
    }

    NumberFormat formatter = NumberFormat.getNumberInstance(new Locale("vi", "VN"));
    Connection conn = null;
    
    // ===== THỐNG KÊ =====
    int tongDon = 0;
    int tongDonDaGiao = 0;
    int tongUser = 0;
    int tongSP = 0;
    int tongDonChoXacNhan = 0;
    long doanhThu = 0;
    
    // ===== ĐƠN HÀNG CHỜ XÁC NHẬN =====
    List<Map<String, Object>> donChoXacNhan = new ArrayList<>();
    
    // ===== SẢN PHẨM SẮP HẾT HÀNG =====
    List<Map<String, Object>> spSapHet = new ArrayList<>();
    
    // ===== DOANH THU 6 THÁNG =====
    Map<String, Long> doanhThuThang = new LinkedHashMap<>();
    
    try {
        conn = dbconnect.getConnection();
        
        ResultSet rs1 = conn.createStatement().executeQuery("SELECT COUNT(*) FROM donhang");
        if (rs1.next()) tongDon = rs1.getInt(1);
        rs1.close();
        
        ResultSet rs2 = conn.createStatement().executeQuery("SELECT COUNT(*) FROM donhang WHERE trangthai='Đã giao'");
        if (rs2.next()) tongDonDaGiao = rs2.getInt(1);
        rs2.close();
        
        ResultSet rs3 = conn.createStatement().executeQuery("SELECT COUNT(*) FROM user WHERE role='user'");
        if (rs3.next()) tongUser = rs3.getInt(1);
        rs3.close();
        
        ResultSet rs4 = conn.createStatement().executeQuery("SELECT COUNT(*) FROM sanpham");
        if (rs4.next()) tongSP = rs4.getInt(1);
        rs4.close();
        
        ResultSet rs5 = conn.createStatement().executeQuery("SELECT SUM(tongtien) FROM donhang WHERE trangthai='Đã giao'");
        if (rs5.next()) doanhThu = rs5.getLong(1);
        rs5.close();
        
        String sqlCho = "SELECT * FROM donhang WHERE trangthai='Chờ xử lý' ORDER BY id DESC LIMIT 5";
        PreparedStatement psCho = conn.prepareStatement(sqlCho);
        ResultSet rsCho = psCho.executeQuery();
        while (rsCho.next()) {
            Map<String, Object> item = new HashMap<>();
            item.put("id", rsCho.getInt("id"));
            item.put("tenkhach", rsCho.getString("tenkhach"));
            item.put("tongtien", rsCho.getInt("tongtien"));
            item.put("ngay", rsCho.getTimestamp("ngay"));
            donChoXacNhan.add(item);
            tongDonChoXacNhan++;
        }
        rsCho.close();
        psCho.close();
        
        String sqlSP1 = "SELECT sp.id, sp.ten, sp.anh, SUM(ps.soluong) as tong_ton " +
                       "FROM sanpham sp " +
                       "JOIN sanpham_size ps ON sp.id = ps.sanpham_id " +
                       "GROUP BY sp.id, sp.ten, sp.anh " +
                       "HAVING SUM(ps.soluong) <= 5 AND SUM(ps.soluong) > 0 " +
                       "ORDER BY tong_ton ASC LIMIT 5";
        PreparedStatement psSP1 = conn.prepareStatement(sqlSP1);
        ResultSet rsSP1 = psSP1.executeQuery();
        while (rsSP1.next()) {
            Map<String, Object> item = new HashMap<>();
            item.put("id", rsSP1.getInt("id"));
            item.put("ten", rsSP1.getString("ten"));
            item.put("anh", rsSP1.getString("anh"));
            item.put("ton", rsSP1.getInt("tong_ton"));
            spSapHet.add(item);
        }
        rsSP1.close();
        psSP1.close();
        
        String sqlSP2 = "SELECT id, ten, anh, soluong as ton FROM sanpham " +
                       "WHERE soluong <= 5 AND soluong > 0 " +
                       "AND id NOT IN (SELECT DISTINCT sanpham_id FROM sanpham_size) " +
                       "ORDER BY soluong ASC LIMIT 5";
        PreparedStatement psSP2 = conn.prepareStatement(sqlSP2);
        ResultSet rsSP2 = psSP2.executeQuery();
        while (rsSP2.next()) {
            Map<String, Object> item = new HashMap<>();
            item.put("id", rsSP2.getInt("id"));
            item.put("ten", rsSP2.getString("ten"));
            item.put("anh", rsSP2.getString("anh"));
            item.put("ton", rsSP2.getInt("ton"));
            spSapHet.add(item);
        }
        rsSP2.close();
        psSP2.close();
        
        String[] thangNames = {"T1", "T2", "T3", "T4", "T5", "T6", "T7", "T8", "T9", "T10", "T11", "T12"};
        
        for (int i = 5; i >= 0; i--) {
            java.util.Calendar cal = java.util.Calendar.getInstance();
            cal.add(java.util.Calendar.MONTH, -i);
            int thang = cal.get(java.util.Calendar.MONTH) + 1;
            int nam = cal.get(java.util.Calendar.YEAR);
            
            String sqlDT = "SELECT SUM(tongtien) FROM donhang " +
                          "WHERE trangthai='Đã giao' AND MONTH(ngay)=? AND YEAR(ngay)=?";
            PreparedStatement psDT = conn.prepareStatement(sqlDT);
            psDT.setInt(1, thang);
            psDT.setInt(2, nam);
            ResultSet rsDT = psDT.executeQuery();
            long dt = 0;
            if (rsDT.next()) {
                dt = rsDT.getLong(1);
            }
            rsDT.close();
            psDT.close();
            
            String key = thangNames[thang - 1] + "/" + nam;
            doanhThuThang.put(key, dt);
        }
        
    } catch (Exception e) {
        e.printStackTrace();
    } finally {
        if (conn != null) try { conn.close(); } catch(Exception e) {}
    }
%>

<!DOCTYPE html>
<html>
<head>
    <title>Dashboard - AURA Admin</title>
    <link href="https://fonts.googleapis.com/css2?family=Playfair+Display:wght@400;500;600;700&family=Quicksand:wght@300;400;500;600;700&display=swap" rel="stylesheet">
    <link href="https://fonts.googleapis.com/css2?family=Material+Symbols+Outlined:wght@100..700&display=swap" rel="stylesheet">
    <script src="https://cdn.jsdelivr.net/npm/chart.js"></script>
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

        /* ===== WELCOME ===== */
        .welcome-card {
            background: linear-gradient(135deg, #1a1a2e 0%, #16213e 50%, #0f3460 100%);
            border-radius: 16px;
            padding: 32px 40px;
            margin-bottom: 28px;
            display: flex;
            justify-content: space-between;
            align-items: center;
            flex-wrap: wrap;
            gap: 16px;
            position: relative;
            overflow: hidden;
            box-shadow: 0 8px 32px rgba(15, 52, 96, 0.15);
        }
        .welcome-card::before {
            content: '';
            position: absolute;
            top: -50%;
            right: -10%;
            width: 300px;
            height: 300px;
            border-radius: 50%;
            background: rgba(201, 169, 110, 0.08);
            pointer-events: none;
        }
        .welcome-card::after {
            content: '';
            position: absolute;
            bottom: -30%;
            left: 20%;
            width: 200px;
            height: 200px;
            border-radius: 50%;
            background: rgba(201, 169, 110, 0.05);
            pointer-events: none;
        }
        .welcome-card .welcome-text {
            position: relative;
            z-index: 1;
        }
        .welcome-card h1 {
            font-family: 'Quicksand', serif;
            font-size: 26px;
            font-weight: 600;
            color: #ffffff;
            letter-spacing: 0.5px;
        }
        .welcome-card h1 span { 
            color: #e8c87a;
            position: relative;
        }
        .welcome-card h1 span::after {
            content: '';
            position: absolute;
            bottom: -4px;
            left: 0;
            width: 100%;
            height: 2px;
            background: linear-gradient(90deg, #e8c87a, transparent);
        }
        .welcome-card p {
            color: rgba(255,255,255,0.6);
            font-size: 14px;
            font-weight: 300;
            margin-top: 4px;
            letter-spacing: 0.3px;
        }
        .welcome-card .date {
            font-size: 13px;
            color: rgba(255,255,255,0.5);
            padding: 8px 20px;
            border: 1px solid rgba(255,255,255,0.1);
            border-radius: 20px;
            background: rgba(255,255,255,0.05);
            position: relative;
            z-index: 1;
            font-weight: 300;
            backdrop-filter: blur(4px);
        }
        .welcome-card .date span {
            color: #e8c87a;
        }

        /* ===== STATS ===== */
        .stats-grid {
            display: grid;
            grid-template-columns: repeat(4, 1fr);
            gap: 20px;
            margin-bottom: 28px;
        }
        .stat-card {
            background: #ffffff;
            border-radius: 16px;
            padding: 24px;
            border: 1px solid #e8e5e0;
            transition: all 0.3s ease;
            position: relative;
            overflow: hidden;
        }
        .stat-card:nth-child(1) { border-left: 3px solid #e8c87a; }
        .stat-card:nth-child(2) { border-left: 3px solid #7eb8d0; }
        .stat-card:nth-child(3) { border-left: 3px solid #d4a0a0; }
        .stat-card:nth-child(4) { border-left: 3px solid #9cb87a; }
        
        .stat-card:hover {
            transform: translateY(-4px);
            box-shadow: 0 10px 30px rgba(0,0,0,0.07);
        }
        .stat-icon {
            font-size: 32px;
            margin-bottom: 12px;
            display: block;
        }
        .stat-card:nth-child(1) .stat-icon { color: #e8c87a; }
        .stat-card:nth-child(2) .stat-icon { color: #7eb8d0; }
        .stat-card:nth-child(3) .stat-icon { color: #d4a0a0; }
        .stat-card:nth-child(4) .stat-icon { color: #9cb87a; }
        
        .stat-label {
            font-size: 12px;
            font-weight: 500;
            text-transform: uppercase;
            letter-spacing: 1px;
            color: #8a8a8a;
        }
        .stat-value {
            font-family: 'Quicksand', serif;
            font-size: 32px;
            font-weight: 600;
            margin: 8px 0 4px;
        }
        .stat-sub {
            font-size: 13px;
            color: #a8a4a0;
            font-weight: 300;
        }

        /* ===== MAIN GRID ===== */
        .main-grid {
            display: grid;
            grid-template-columns: 2fr 1fr;
            gap: 20px;
            margin-bottom: 28px;
        }

        /* ===== BOTTOM GRID ===== */
        .bottom-grid {
            display: grid;
            grid-template-columns: 1fr 1fr;
            gap: 20px;
        }

        /* ===== CARDS ===== */
        .card {
            background: #ffffff;
            border-radius: 16px;
            padding: 24px;
            border: 1px solid #e8e5e0;
        }
        .card-title {
            font-family: 'Quicksand', serif;
            font-size: 18px;
            font-weight: 600;
            margin-bottom: 16px;
            display: flex;
            justify-content: space-between;
            align-items: center;
        }
        .badge {
            font-size: 12px;
            padding: 4px 14px;
            border-radius: 20px;
            font-family: 'Quicksand', sans-serif;
            font-weight: 500;
        }
        .badge-gold { background: #fff9e6; color: #c9a96e; border: 1px solid #e8d9a8; }
        .badge-blue { background: #e8f2f7; color: #7eb8d0; border: 1px solid #c5dce8; }
        .badge-pink { background: #f7ecec; color: #d4a0a0; border: 1px solid #e8d5d5; }
        .badge-green { background: #edf3e8; color: #9cb87a; border: 1px solid #d4e0c8; }

        /* ===== CHART ===== */
        .chart-container {
            height: 260px;
            position: relative;
        }

        /* ===== ORDER ITEMS ===== */
        .order-item {
            display: flex;
            justify-content: space-between;
            align-items: center;
            padding: 10px 0;
            border-bottom: 1px solid #f0eeeb;
        }
        .order-item:last-child { border-bottom: none; }
        .order-item .name {
            font-size: 14px;
            font-weight: 500;
            color: #2d2d2d;
        }
        .order-item .order-id {
            font-size: 12px;
            color: #a8a4a0;
        }
        .order-item .amount {
            font-weight: 600;
            font-size: 14px;
            color: #2d2d2d;
        }
        .order-item .date {
            font-size: 12px;
            color: #a8a4a0;
        }
        .empty-state {
            text-align: center;
            padding: 30px 20px;
            color: #a8a4a0;
        }
        .empty-state .material-symbols-outlined {
            font-size: 48px;
            opacity: 0.2;
            display: block;
            margin-bottom: 8px;
        }

        /* ===== STOCK ITEMS ===== */
        .stock-item {
            display: flex;
            align-items: center;
            gap: 12px;
            padding: 8px 0;
            border-bottom: 1px solid #f0eeeb;
        }
        .stock-item:last-child { border-bottom: none; }
        .stock-item .thumb {
            width: 40px;
            height: 40px;
            border-radius: 8px;
            object-fit: cover;
            background: #f7f6f4;
            border: 1px solid #e8e5e0;
        }
        .stock-item .name {
            flex: 1;
            font-size: 13px;
            color: #2d2d2d;
        }
        .stock-item .qty {
            font-size: 12px;
            padding: 2px 12px;
            background: #f7f6f4;
            border-radius: 12px;
            border: 1px solid #e8e5e0;
            color: #8a8a8a;
        }
        .stock-item .qty.low { color: #d4a0a0; border-color: #e8d5d5; background: #f7ecec; }
        .stock-item .qty.critical { color: #c0392b; border-color: #f0d5d5; background: #fdf0f0; }

        /* ===== QUICK ACTIONS ===== */
        .quick-grid {
            display: grid;
            grid-template-columns: 1fr 1fr;
            gap: 12px;
        }
        .quick-action {
            display: flex;
            align-items: center;
            gap: 14px;
            padding: 14px 18px;
            border-radius: 12px;
            text-decoration: none;
            color: #ffffff;
            transition: all 0.3s ease;
            border: none;
            position: relative;
            overflow: hidden;
        }
        .quick-action::before {
            content: '';
            position: absolute;
            top: 0;
            left: 0;
            right: 0;
            bottom: 0;
            background: rgba(255,255,255,0.05);
            opacity: 0;
            transition: all 0.3s ease;
        }
        .quick-action:hover::before {
            opacity: 1;
        }
        .quick-action:hover {
            transform: translateY(-3px);
            box-shadow: 0 8px 24px rgba(0,0,0,0.15);
        }
        .quick-action:nth-child(1) { background: linear-gradient(135deg, #c9a96e, #b8955a); }
        .quick-action:nth-child(2) { background: linear-gradient(135deg, #7eb8d0, #5a9bb5); }
        .quick-action:nth-child(3) { background: linear-gradient(135deg, #d4a0a0, #c08080); }
        .quick-action:nth-child(4) { background: linear-gradient(135deg, #9cb87a, #7da05a); }
        
        .quick-action .material-symbols-outlined {
            font-size: 26px;
            color: rgba(255,255,255,0.8);
            position: relative;
            z-index: 1;
        }
        .quick-action .action-text {
            position: relative;
            z-index: 1;
        }
        .quick-action .action-title { 
            font-weight: 600; 
            font-size: 14px;
            color: #ffffff;
        }
        .quick-action .action-desc { 
            font-size: 12px; 
            color: rgba(255,255,255,0.6);
            font-weight: 300;
        }

        /* ===== LINK ===== */
        .link-more {
            font-size: 13px;
            color: #a8a4a0;
            text-decoration: none;
            border-bottom: 1px solid #d4d4d4;
            padding-bottom: 2px;
            transition: all 0.3s ease;
            font-weight: 400;
        }
        .link-more:hover {
            color: #c9a96e;
            border-color: #c9a96e;
        }

        /* ===== RESPONSIVE ===== */
        @media (max-width: 1200px) {
            .stats-grid { grid-template-columns: repeat(2, 1fr); }
        }
        @media (max-width: 992px) {
            body { padding-left: 0; padding-top: 70px; }
            .main-grid { grid-template-columns: 1fr; }
            .bottom-grid { grid-template-columns: 1fr; }
            .quick-grid { grid-template-columns: 1fr 1fr; }
        }
        @media (max-width: 600px) {
            .stats-grid { grid-template-columns: 1fr; }
            .welcome-card {
                flex-direction: column;
                text-align: center;
                padding: 24px 20px;
            }
            .container { padding: 12px 16px; }
            .quick-grid { grid-template-columns: 1fr; }
            .quick-action { padding: 12px 16px; }
        }
    </style>
</head>
<body>
    <div class="container">
        <!-- ===== WELCOME ===== -->
        <div class="welcome-card">
            <div class="welcome-text">
                <h1>Chào mừng, <span><%= session.getAttribute("fullname") != null ? session.getAttribute("fullname") : "Admin" %></span></h1>
                <p>Tổng quan hoạt động cửa hàng</p>
            </div>
            <div class="date">
                <span>📅</span> <%= new java.text.SimpleDateFormat("dd/MM/yyyy").format(new java.util.Date()) %>
            </div>
        </div>

        <!-- ===== STATS ===== -->
        <div class="stats-grid">
            <div class="stat-card">
                <span class="material-symbols-outlined stat-icon">attach_money</span>
                <div class="stat-label">Doanh thu</div>
                <div class="stat-value"><%= formatter.format(doanhThu) %>đ</div>
                <div class="stat-sub">Đơn hàng đã giao</div>
            </div>
            <div class="stat-card">
                <span class="material-symbols-outlined stat-icon">shopping_cart</span>
                <div class="stat-label">Đơn hàng</div>
                <div class="stat-value"><%= tongDon %></div>
                <div class="stat-sub"><%= tongDonDaGiao %> đã giao</div>
            </div>
            <div class="stat-card">
                <span class="material-symbols-outlined stat-icon">group</span>
                <div class="stat-label">Khách hàng</div>
                <div class="stat-value"><%= tongUser %></div>
                <div class="stat-sub">Đã đăng ký</div>
            </div>
            <div class="stat-card">
                <span class="material-symbols-outlined stat-icon">inventory_2</span>
                <div class="stat-label">Sản phẩm</div>
                <div class="stat-value"><%= tongSP %></div>
                <div class="stat-sub"><%= spSapHet.size() %> sắp hết hàng</div>
            </div>
        </div>

        <!-- ===== MAIN GRID ===== -->
        <div class="main-grid">
            <!-- CHART -->
            <div class="card">
                <div class="card-title">
                    Doanh thu 6 tháng qua
                    <span style="font-family:'Quicksand';font-size:13px;font-weight:300;color:#a8a4a0;">
                        <span class="material-symbols-outlined" style="font-size:16px;vertical-align:middle;color:#c9a96e;">trending_up</span>
                    </span>
                </div>
                <div class="chart-container">
                    <canvas id="revenueChart"></canvas>
                </div>
            </div>

            <!-- ORDERS PENDING -->
            <div class="card">
                <div class="card-title">
                    Đơn hàng chờ xác nhận
                    <span class="badge badge-gold"><%= tongDonChoXacNhan %></span>
                </div>
                <% if (donChoXacNhan.isEmpty()) { %>
                    <div class="empty-state">
                        <span class="material-symbols-outlined" style="color:#c9a96e;">inbox</span>
                        Không có đơn hàng chờ xử lý
                    </div>
                <% } else { 
                    for (Map<String, Object> item : donChoXacNhan) { %>
                        <div class="order-item">
                            <div>
                                <div class="name"><%= item.get("tenkhach") %></div>
                                <div class="order-id">#<%= item.get("id") %></div>
                            </div>
                            <div style="text-align:right;">
                                <div class="amount"><%= formatter.format(item.get("tongtien")) %>đ</div>
                                <div class="date"><%= item.get("ngay") != null ? item.get("ngay").toString().substring(0, 16) : "" %></div>
                            </div>
                        </div>
                <% }
                } %>
                <% if (!donChoXacNhan.isEmpty()) { %>
                    <div style="margin-top:12px;text-align:right;">
                        <a href="admin_donhang.jsp" class="link-more">Xem tất cả →</a>
                    </div>
                <% } %>
            </div>
        </div>

        <!-- ===== BOTTOM GRID ===== -->
        <div class="bottom-grid">
            <!-- LOW STOCK -->
            <div class="card">
                <div class="card-title">
                    Sản phẩm sắp hết hàng
                    <span class="badge badge-pink"><%= spSapHet.size() %></span>
                </div>
                <% if (spSapHet.isEmpty()) { %>
                    <div class="empty-state">
                        <span class="material-symbols-outlined" style="color:#9cb87a;">check_circle</span>
                        Tất cả sản phẩm đều có đủ hàng
                    </div>
                <% } else { 
                    for (Map<String, Object> item : spSapHet) {
                        String anh = (String) item.get("anh");
                        boolean isLink = (anh != null && (anh.startsWith("http://") || anh.startsWith("https://")));
                        String src = isLink ? anh : "../img/" + anh;
                        int ton = (int) item.get("ton");
                        String qtyClass = ton <= 1 ? "critical" : "low";
                %>
                    <div class="stock-item">
                        <img class="thumb" src="<%= src %>" onerror="this.src='../img/default.jpg'" alt="<%= item.get("ten") %>">
                        <span class="name"><%= item.get("ten") %></span>
                        <span class="qty <%= qtyClass %>"><%= ton %></span>
                    </div>
                <% }
                } %>
                <% if (!spSapHet.isEmpty()) { %>
                    <div style="margin-top:12px;text-align:right;">
                        <a href="admin_sanpham.jsp?stock_filter=low" class="link-more">Xem tất cả →</a>
                    </div>
                <% } %>
            </div>

            <!-- QUICK ACTIONS -->
            <div class="card">
                <div class="card-title">Thao tác nhanh</div>
                <div class="quick-grid">
                    <a href="admin_sanpham.jsp" class="quick-action">
                        <span class="material-symbols-outlined">inventory_2</span>
                        <div class="action-text">
                            <div class="action-title">Sản phẩm</div>
                            <div class="action-desc">Quản lý kho</div>
                        </div>
                    </a>
                    <a href="admin_donhang.jsp" class="quick-action">
                        <span class="material-symbols-outlined">receipt_long</span>
                        <div class="action-text">
                            <div class="action-title">Đơn hàng</div>
                            <div class="action-desc">Quản lý</div>
                        </div>
                    </a>
                    <a href="admin_user.jsp" class="quick-action">
                        <span class="material-symbols-outlined">manage_accounts</span>
                        <div class="action-text">
                            <div class="action-title">Người dùng</div>
                            <div class="action-desc">Quản lý</div>
                        </div>
                    </a>
                    <a href="../index.jsp" target="_blank" class="quick-action">
                        <span class="material-symbols-outlined">storefront</span>
                        <div class="action-text">
                            <div class="action-title">Cửa hàng</div>
                            <div class="action-desc">Xem website</div>
                        </div>
                    </a>
                </div>
            </div>
        </div>

        <!-- FOOTER -->
        <div style="margin-top:32px;text-align:center;font-size:11px;color:#c0bdb8;letter-spacing:1px;border-top:1px solid #e8e5e0;padding-top:20px;font-weight:300;">
            AURA ADMIN PANEL
        </div>
    </div>

    <!-- CHART SCRIPT -->
    <script>
        document.addEventListener('DOMContentLoaded', function() {
            var ctx = document.getElementById('revenueChart').getContext('2d');
            
            var labels = [];
            var data = [];
            
            <%
                for (Map.Entry<String, Long> entry : doanhThuThang.entrySet()) {
            %>
                labels.push('<%= entry.getKey() %>');
                data.push(<%= entry.getValue() %>);
            <%
                }
            %>
            
            new Chart(ctx, {
                type: 'bar',
                data: {
                    labels: labels,
                    datasets: [{
                        label: 'Doanh thu',
                        data: data,
                        backgroundColor: [
                            'rgba(201, 169, 110, 0.65)',
                            'rgba(201, 169, 110, 0.55)',
                            'rgba(201, 169, 110, 0.45)',
                            'rgba(201, 169, 110, 0.35)',
                            'rgba(201, 169, 110, 0.25)',
                            'rgba(201, 169, 110, 0.2)'
                        ],
                        borderColor: '#c9a96e',
                        borderWidth: 1.5,
                        borderRadius: 4,
                        hoverBackgroundColor: 'rgba(201, 169, 110, 0.8)'
                    }]
                },
                options: {
                    responsive: true,
                    maintainAspectRatio: false,
                    plugins: {
                        legend: {
                            display: false
                        },
                        tooltip: {
                            backgroundColor: 'rgba(255,255,255,0.95)',
                            titleColor: '#2d2d2d',
                            bodyColor: '#2d2d2d',
                            borderColor: '#e8e5e0',
                            borderWidth: 1,
                            cornerRadius: 8,
                            padding: 12,
                            callbacks: {
                                label: function(context) {
                                    return context.parsed.y.toLocaleString('vi-VN') + ' VNĐ';
                                }
                            }
                        }
                    },
                    scales: {
                        y: {
                            beginAtZero: true,
                            grid: {
                                color: 'rgba(0,0,0,0.04)',
                                drawBorder: false
                            },
                            ticks: {
                                font: {
                                    family: 'Quicksand',
                                    size: 10,
                                    weight: '400'
                                },
                                color: '#a8a4a0',
                                callback: function(value) {
                                    if (value >= 1000000) return (value / 1000000) + 'M';
                                    if (value >= 1000) return (value / 1000) + 'K';
                                    return value;
                                }
                            }
                        },
                        x: {
                            grid: {
                                display: false
                            },
                            ticks: {
                                font: {
                                    family: 'Quicksand',
                                    size: 10,
                                    weight: '400'
                                },
                                color: '#a8a4a0'
                            }
                        }
                    },
                    animation: {
                        duration: 800,
                        easing: 'easeOutQuart'
                    }
                }
            });
        });
    </script>
</body>
</html>