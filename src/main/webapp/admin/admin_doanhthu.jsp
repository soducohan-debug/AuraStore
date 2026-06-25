<%-- 
    Document   : admin_doanhthu
    Created on : Jun 25, 2026
    Author     : Ma
    Description: Thống kê doanh thu - AURA Admin
--%>

<%@page import="java.util.LinkedHashMap"%>
<%@page import="java.util.ArrayList"%>
<%@page import="java.util.List"%>
<%@page import="java.util.HashMap"%>
<%@page import="java.util.Map"%>
<%@page import="java.sql.*, DAO.dbconnect, java.text.NumberFormat, java.util.Locale"%>
<%@ page contentType="text/html;charset=UTF-8" %>

<jsp:include page="sidebar.jsp" />

<%
    // Kiểm tra đăng nhập admin
    String user = (String) session.getAttribute("user");
    String role = (String) session.getAttribute("role");

    if (user == null || !"admin".equals(role)) {
        response.sendRedirect("../login.jsp");
        return;
    }

    NumberFormat formatter = NumberFormat.getNumberInstance(new Locale("vi", "VN"));
    Connection conn = null;

    // ===== DOANH THU THÁNG NÀY =====
    long doanhThuThangNay = 0;
    int soDonThangNay = 0;

    // ===== DOANH THU 6 THÁNG (cho biểu đồ sóng) =====
    Map<String, Long> doanhThu6Thang = new LinkedHashMap<>();
    Map<String, Integer> soDon6Thang = new LinkedHashMap<>();

    // ===== DANH MỤC BÁN CHẠY =====
    List<Map<String, Object>> danhMucBanChay = new ArrayList<>();

    // ===== SẢN PHẨM BÁN CHẠY NHẤT =====
    List<Map<String, Object>> sanPhamBanChay = new ArrayList<>();

    try {
        conn = dbconnect.getConnection();

        // 1. Doanh thu tháng này
        java.util.Calendar cal = java.util.Calendar.getInstance();
        int thangHienTai = cal.get(java.util.Calendar.MONTH) + 1;
        int namHienTai = cal.get(java.util.Calendar.YEAR);

        String sqlDTThang = "SELECT SUM(tongtien) as tong, COUNT(*) as so_luong FROM donhang "
                + "WHERE trangthai='Đã giao' AND MONTH(ngay)=? AND YEAR(ngay)=?";
        PreparedStatement psDTThang = conn.prepareStatement(sqlDTThang);
        psDTThang.setInt(1, thangHienTai);
        psDTThang.setInt(2, namHienTai);
        ResultSet rsDTThang = psDTThang.executeQuery();
        if (rsDTThang.next()) {
            doanhThuThangNay = rsDTThang.getLong("tong");
            soDonThangNay = rsDTThang.getInt("so_luong");
        }
        rsDTThang.close();
        psDTThang.close();

        // 2. Doanh thu 6 tháng (cho biểu đồ sóng)
        String[] thangNames = {"T1", "T2", "T3", "T4", "T5", "T6", "T7", "T8", "T9", "T10", "T11", "T12"};

        for (int i = 5; i >= 0; i--) {
            cal = java.util.Calendar.getInstance();
            cal.add(java.util.Calendar.MONTH, -i);
            int thang = cal.get(java.util.Calendar.MONTH) + 1;
            int nam = cal.get(java.util.Calendar.YEAR);

            String sqlDT = "SELECT SUM(tongtien) as tong, COUNT(*) as so_luong FROM donhang "
                    + "WHERE trangthai='Đã giao' AND MONTH(ngay)=? AND YEAR(ngay)=?";
            PreparedStatement psDT = conn.prepareStatement(sqlDT);
            psDT.setInt(1, thang);
            psDT.setInt(2, nam);
            ResultSet rsDT = psDT.executeQuery();
            long dt = 0;
            int soDon = 0;
            if (rsDT.next()) {
                dt = rsDT.getLong("tong");
                soDon = rsDT.getInt("so_luong");
            }
            rsDT.close();
            psDT.close();

            String key = thangNames[thang - 1] + "/" + nam;
            doanhThu6Thang.put(key, dt);
            soDon6Thang.put(key, soDon);
        }

        // 3. Danh mục bán chạy
        String sqlDanhMuc = "SELECT dm.ten_danhmuc, SUM(ct.soluong) as so_luong_ban, SUM(ct.soluong * ct.gia) as doanh_thu "
                + "FROM chitietdonhang ct "
                + "JOIN sanpham sp ON ct.sanpham_id = sp.id "
                + "JOIN danhmuc dm ON sp.danhmuc_id = dm.id "
                + "JOIN donhang dh ON ct.donhang_id = dh.id "
                + "WHERE dh.trangthai='Đã giao' "
                + "GROUP BY dm.id, dm.ten_danhmuc "
                + "ORDER BY so_luong_ban DESC LIMIT 5";
        Statement stDanhMuc = conn.createStatement();
        ResultSet rsDanhMuc = stDanhMuc.executeQuery(sqlDanhMuc);
        int tongDanhMuc = 0;
        while (rsDanhMuc.next()) {
            Map<String, Object> item = new HashMap<>();
            item.put("ten", rsDanhMuc.getString("ten_danhmuc"));
            item.put("so_luong", rsDanhMuc.getInt("so_luong_ban"));
            item.put("doanh_thu", rsDanhMuc.getLong("doanh_thu"));
            danhMucBanChay.add(item);
            tongDanhMuc += rsDanhMuc.getInt("so_luong_ban");
        }
        rsDanhMuc.close();
        stDanhMuc.close();

        // 4. Sản phẩm bán chạy nhất
        String sqlSP = "SELECT sp.id, sp.ten, sp.anh, SUM(ct.soluong) as so_luong_ban, SUM(ct.soluong * ct.gia) as doanh_thu "
                + "FROM chitietdonhang ct "
                + "JOIN sanpham sp ON ct.sanpham_id = sp.id "
                + "JOIN donhang dh ON ct.donhang_id = dh.id "
                + "WHERE dh.trangthai='Đã giao' "
                + "GROUP BY sp.id, sp.ten, sp.anh "
                + "ORDER BY so_luong_ban DESC LIMIT 5";
        Statement stSP = conn.createStatement();
        ResultSet rsSP = stSP.executeQuery(sqlSP);
        while (rsSP.next()) {
            Map<String, Object> item = new HashMap<>();
            item.put("id", rsSP.getInt("id"));
            item.put("ten", rsSP.getString("ten"));
            item.put("anh", rsSP.getString("anh"));
            item.put("so_luong", rsSP.getInt("so_luong_ban"));
            item.put("doanh_thu", rsSP.getLong("doanh_thu"));
            sanPhamBanChay.add(item);
        }
        rsSP.close();
        stSP.close();

    } catch (Exception e) {
        e.printStackTrace();
    } finally {
        if (conn != null) try {
            conn.close();
        } catch (Exception e) {
        }
    }
%>

<!DOCTYPE html>
<html>
    <head>
        <title>Doanh thu - AURA Admin</title>
        <link href="https://fonts.googleapis.com/css2?family=Quicksand:wght@300;400;500;600;700&display=swap" rel="stylesheet">
        <link href="https://fonts.googleapis.com/css2?family=Material+Symbols+Outlined:wght@100..700&display=swap" rel="stylesheet">
        <script src="https://cdn.jsdelivr.net/npm/chart.js"></script>
        <style>
            * {
                box-sizing: border-box;
                margin: 0;
                padding: 0;
            }
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
            .page-title span {
                color: #c9a96e;
            }

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
                padding: 20px 24px;
                border: 1px solid #e8e5e0;
                transition: all 0.3s ease;
            }
            .stat-card:hover {
                transform: translateY(-2px);
                box-shadow: 0 8px 24px rgba(0,0,0,0.04);
            }
            .stat-card .stat-icon {
                font-size: 24px;
                color: #c9a96e;
                margin-bottom: 4px;
                display: block;
            }
            .stat-card .stat-label {
                font-size: 11px;
                font-weight: 500;
                text-transform: uppercase;
                letter-spacing: 0.5px;
                color: #8a8a8a;
            }
            .stat-card .stat-value {
                font-size: 26px;
                font-weight: 600;
                margin-top: 2px;
            }
            .stat-card .stat-value.gold {
                color: #c9a96e;
            }
            .stat-card .stat-sub {
                font-size: 13px;
                color: #a8a4a0;
                font-weight: 300;
            }

            /* ===== CHARTS ===== */
            .chart-grid {
                display: grid;
                grid-template-columns: 2fr 1fr;
                gap: 20px;
                margin-bottom: 24px;
            }
            .chart-card {
                background: #ffffff;
                border-radius: 12px;
                padding: 24px;
                border: 1px solid #e8e5e0;
            }
            .chart-card .card-title {
                font-size: 15px;
                font-weight: 600;
                margin-bottom: 12px;
                display: flex;
                justify-content: space-between;
                align-items: center;
            }
            .chart-card .card-title span {
                color: #c9a96e;
            }
            .chart-container {
                position: relative;
                height: 260px;
            }
            .chart-container.pie {
                height: 280px;
            }

            /* ===== TOP PRODUCTS ===== */
            .bottom-grid {
                display: grid;
                grid-template-columns: 1fr 1fr;
                gap: 20px;
            }
            .top-item {
                display: flex;
                align-items: center;
                gap: 12px;
                padding: 8px 0;
                border-bottom: 1px solid #f0eeeb;
            }
            .top-item:last-child {
                border-bottom: none;
            }
            .top-item .rank {
                font-size: 14px;
                font-weight: 700;
                color: #c9a96e;
                min-width: 24px;
            }
            .top-item .thumb {
                width: 40px;
                height: 40px;
                border-radius: 6px;
                object-fit: cover;
                background: #f7f6f4;
                border: 1px solid #e8e5e0;
            }
            .top-item .info {
                flex: 1;
            }
            .top-item .info .name {
                font-size: 13px;
                font-weight: 500;
            }
            .top-item .info .meta {
                font-size: 12px;
                color: #a8a4a0;
            }
            .top-item .amount {
                font-weight: 600;
                font-size: 13px;
                color: #2d2d2d;
                text-align: right;
            }
            .top-item .amount .small {
                font-size: 11px;
                color: #a8a4a0;
                font-weight: 300;
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

            @media (max-width: 1200px) {
                .stats-grid {
                    grid-template-columns: repeat(2, 1fr);
                }
                .chart-grid {
                    grid-template-columns: 1fr;
                }
                .bottom-grid {
                    grid-template-columns: 1fr;
                }
            }
            @media (max-width: 992px) {
                body {
                    padding-left: 0;
                    padding-top: 70px;
                }
                .container {
                    padding: 16px;
                }
            }
            @media (max-width: 600px) {
                .stats-grid {
                    grid-template-columns: 1fr;
                }
            }
        </style>
    </head>
    <body>
        <div class="container">
            <!-- ===== HEADER ===== -->
            <div class="page-header">
                <div>
                    <div class="page-title">Thống kê <span>doanh thu</span></div>
                </div>
                <div style="font-size:13px;color:#a8a4a0;">
                    Cập nhật: <%= new java.text.SimpleDateFormat("dd/MM/yyyy HH:mm").format(new java.util.Date())%>
                </div>
            </div>
          
            <!-- ===== STATS ===== -->
            <div class="stats-grid">
                <div class="stat-card">
                    <span class="stat-icon"></span>
                    <div class="stat-label">Doanh thu tháng này</div>
                    <div class="stat-value gold"><%= formatter.format(doanhThuThangNay)%>đ</div>
                    <div class="stat-sub">Từ đơn hàng đã giao</div>
                </div>
                <div class="stat-card">
                    <span class="stat-icon"></span>
                    <div class="stat-label">Đơn bán tháng này</div>
                    <div class="stat-value"><%= soDonThangNay%></div>
                    <div class="stat-sub">Đơn hàng đã hoàn thành</div>
                </div>
                <div class="stat-card">
                    
                    <div class="stat-label">Danh mục bán chạy</div>
                    <div class="stat-value" style="font-size:20px;">
                        <% if (!danhMucBanChay.isEmpty()) {%>
                        <%= danhMucBanChay.get(0).get("ten")%>
                        <% } else { %>
                        Chưa có dữ liệu
                        <% } %>
                    </div>
                    <div class="stat-sub">
                        <% if (!danhMucBanChay.isEmpty()) {%>
                        <%= danhMucBanChay.get(0).get("so_luong")%> sản phẩm đã bán
                        <% } %>
                    </div>
                </div>
                <div class="stat-card">
                    <span class="stat-icon"></span>
                    <div class="stat-label">Sản phẩm bán chạy</div>
                    <div class="stat-value" style="font-size:20px;">
                        <% if (!sanPhamBanChay.isEmpty()) {%>
                        <%= sanPhamBanChay.get(0).get("ten")%>
                        <% } else { %>
                        Chưa có dữ liệu
                        <% } %>
                    </div>
                    <div class="stat-sub">
                        <% if (!sanPhamBanChay.isEmpty()) {%>
                        <%= sanPhamBanChay.get(0).get("so_luong")%> sản phẩm đã bán
                        <% } %>
                    </div>
                </div>
            </div>

            <!-- ===== CHARTS ===== -->
            <div class="chart-grid">
                <!-- Biểu đồ sóng doanh thu 6 tháng -->
                <div class="chart-card">
                    <div class="card-title">
                        Doanh thu <span>6 tháng</span>
                    </div>
                    <div class="chart-container">
                        <canvas id="revenueChart"></canvas>
                    </div>
                </div>

                <!-- Biểu đồ tròn danh mục -->
                <div class="chart-card">
                    <div class="card-title">
                        Danh mục <span>bán chạy</span>
                    </div>
                    <div class="chart-container pie">
                        <canvas id="categoryChart"></canvas>
                    </div>
                </div>
            </div>

            <!-- ===== BOTTOM ===== -->
            <div class="bottom-grid">
                <!-- Top sản phẩm -->
                <div class="chart-card">
                    <div class="card-title">
                        Sản phẩm <span>bán chạy nhất</span>
                    </div>
                    <% if (sanPhamBanChay.isEmpty()) { %>
                    <div class="empty-state">
                        <span class="material-symbols-outlined">inbox</span>
                        Chưa có sản phẩm nào được bán
                    </div>
                    <% } else {
                        for (int i = 0; i < sanPhamBanChay.size(); i++) {
                            Map<String, Object> item = sanPhamBanChay.get(i);
                            String anh = (String) item.get("anh");
                            boolean isLink = (anh != null && (anh.startsWith("http://") || anh.startsWith("https://")));
                            String src = isLink ? anh : "../img/" + anh;
                    %>
                    <div class="top-item">
                        <span class="rank">#<%= i + 1%></span>
                        <img class="thumb" src="<%= src%>" onerror="this.src='../img/default.jpg'" alt="<%= item.get("ten")%>">
                        <div class="info">
                            <div class="name"><%= item.get("ten")%></div>
                            <div class="meta">Đã bán: <%= item.get("so_luong")%> sản phẩm</div>
                        </div>
                        <div class="amount">
                            <%= formatter.format(item.get("doanh_thu"))%>đ
                            <div class="small">doanh thu</div>
                        </div>
                    </div>
                    <% }
                        } %>
                </div>

                <!-- Danh mục bán chạy -->
                <div class="chart-card">
                    <div class="card-title">
                        Danh mục <span>bán chạy</span>
                    </div>
                    <% if (danhMucBanChay.isEmpty()) { %>
                    <div class="empty-state">
                        <span class="material-symbols-outlined">inbox</span>
                        Chưa có danh mục nào được bán
                    </div>
                    <% } else {
                        for (int i = 0; i < danhMucBanChay.size(); i++) {
                            Map<String, Object> item = danhMucBanChay.get(i);
                    %>
                    <div class="top-item">
                        <span class="rank">#<%= i + 1%></span>
                        <div style="width:40px;height:40px;border-radius:6px;background:#f7f6f4;border:1px solid #e8e5e0;display:flex;align-items:center;justify-content:center;font-size:20px;color:#c9a96e;">

                        </div>
                        <div class="info">
                            <div class="name"><%= item.get("ten")%></div>
                            <div class="meta">Đã bán: <%= item.get("so_luong")%> sản phẩm</div>
                        </div>
                        <div class="amount">
                            <%= formatter.format(item.get("doanh_thu"))%>đ
                            <div class="small">doanh thu</div>
                        </div>
                    </div>
                    <% }
                        } %>
                </div>
            </div>
            <div style="display:flex;justify-content:center;gap:12px;margin-top:24px;flex-wrap:wrap;">
                <a href="xuat_doanhthu_excel.jsp" 
                   style="background:linear-gradient(135deg, #1a1a2e 0%, #16213e 50%, #0f3460 100%);color:#ffffff;padding:10px 28px;border:none;border-radius:8px;font-family:'Quicksand',sans-serif;font-size:14px;font-weight:500;cursor:pointer;text-decoration:none;display:inline-flex;align-items:center;gap:8px;transition:all 0.3s ease;">
                    <span class="material-symbols-outlined" style="font-size:20px;">description</span>
                    Xuất Excel
                </a>
                
            </div>
            <!-- Footer -->
            <div style="margin-top:24px;text-align:center;font-size:12px;color:#c0bdb8;letter-spacing:0.5px;">
                AURA Admin Panel
            </div>
        </div>

        <script>
            document.addEventListener('DOMContentLoaded', function () {
                // ===== BIỂU ĐỒ SÓNG DOANH THU =====
                var ctxRevenue = document.getElementById('revenueChart').getContext('2d');
                var revenueLabels = [];
                var revenueData = [];
                var orderCounts = [];

            <%
                for (Map.Entry<String, Long> entry : doanhThu6Thang.entrySet()) {
            %>
                revenueLabels.push('<%= entry.getKey()%>');
                revenueData.push(<%= entry.getValue()%>);
                orderCounts.push(<%= soDon6Thang.get(entry.getKey())%>);
            <%
                }
            %>

                new Chart(ctxRevenue, {
                    type: 'line',
                    data: {
                        labels: revenueLabels,
                        datasets: [
                            {
                                label: 'Doanh thu',
                                data: revenueData,
                                borderColor: '#c9a96e',
                                backgroundColor: 'rgba(201, 169, 110, 0.1)',
                                fill: true,
                                tension: 0.4,
                                pointBackgroundColor: '#c9a96e',
                                pointBorderColor: '#ffffff',
                                pointBorderWidth: 2,
                                pointRadius: 4,
                                yAxisID: 'y',
                                order: 0
                            },
                            {
                                label: 'Số đơn hàng',
                                data: orderCounts,
                                borderColor: '#00639c',
                                backgroundColor: 'rgba(0, 99, 156, 0.1)',
                                fill: true,
                                tension: 0.4,
                                pointBackgroundColor: '#00639c',
                                pointBorderColor: '#ffffff',
                                pointBorderWidth: 2,
                                pointRadius: 4,
                                yAxisID: 'y1',
                                order: 1
                            }
                        ]
                    },
                    options: {
                        responsive: true,
                        maintainAspectRatio: false,
                        interaction: {
                            mode: 'index',
                            intersect: false
                        },
                        plugins: {
                            legend: {
                                position: 'top',
                                labels: {
                                    font: {
                                        family: 'Quicksand',
                                        size: 11
                                    },
                                    boxWidth: 12,
                                    padding: 12
                                }
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
                                    label: function (context) {
                                        if (context.dataset.label === 'Doanh thu') {
                                            return context.dataset.label + ': ' + context.parsed.y.toLocaleString('vi-VN') + ' VNĐ';
                                        }
                                        return context.dataset.label + ': ' + context.parsed.y + ' đơn';
                                    }
                                }
                            }
                        },
                        scales: {
                            y: {
                                type: 'linear',
                                display: true,
                                position: 'left',
                                beginAtZero: true,
                                grid: {
                                    color: 'rgba(0,0,0,0.04)',
                                    drawBorder: false
                                },
                                ticks: {
                                    font: {
                                        family: 'Quicksand',
                                        size: 10
                                    },
                                    color: '#a8a4a0',
                                    callback: function (value) {
                                        if (value >= 1000000)
                                            return (value / 1000000) + 'M';
                                        if (value >= 1000)
                                            return (value / 1000) + 'K';
                                        return value;
                                    }
                                }
                            },
                            y1: {
                                type: 'linear',
                                display: true,
                                position: 'right',
                                beginAtZero: true,
                                grid: {
                                    drawOnChartArea: false
                                },
                                ticks: {
                                    font: {
                                        family: 'Quicksand',
                                        size: 10
                                    },
                                    color: '#00639c'
                                }
                            },
                            x: {
                                grid: {
                                    display: false
                                },
                                ticks: {
                                    font: {
                                        family: 'Quicksand',
                                        size: 10
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

                // ===== BIỂU ĐỒ TRÒN DANH MỤC =====
                var ctxCategory = document.getElementById('categoryChart').getContext('2d');
                var categoryLabels = [];
                var categoryData = [];
                var categoryColors = [
                    'rgba(201, 169, 110, 0.8)',
                    'rgba(0, 99, 156, 0.8)',
                    'rgba(46, 99, 133, 0.8)',
                    'rgba(212, 160, 160, 0.8)',
                    'rgba(156, 184, 122, 0.8)'
                ];

            <%
                int idx = 0;
                for (Map<String, Object> item : danhMucBanChay) {
            %>
                categoryLabels.push('<%= item.get("ten")%>');
                categoryData.push(<%= item.get("so_luong")%>);
            <%
                    idx++;
                }
            %>

                new Chart(ctxCategory, {
                    type: 'doughnut',
                    data: {
                        labels: categoryLabels,
                        datasets: [{
                                data: categoryData,
                                backgroundColor: categoryColors.slice(0, categoryData.length),
                                borderColor: '#ffffff',
                                borderWidth: 2
                            }]
                    },
                    options: {
                        responsive: true,
                        maintainAspectRatio: false,
                        plugins: {
                            legend: {
                                position: 'right',
                                labels: {
                                    font: {
                                        family: 'Quicksand',
                                        size: 11
                                    },
                                    boxWidth: 12,
                                    padding: 10,
                                    usePointStyle: true,
                                    pointStyle: 'circle'
                                }
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
                                    label: function (context) {
                                        var total = context.dataset.data.reduce(function (a, b) {
                                            return a + b;
                                        }, 0);
                                        var percentage = ((context.parsed / total) * 100).toFixed(1);
                                        return context.label + ': ' + context.parsed + ' sản phẩm (' + percentage + '%)';
                                    }
                                }
                            }
                        },
                        cutout: '55%',
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