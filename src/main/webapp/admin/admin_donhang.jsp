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
    Connection conn = null;

    try {
        conn = dbconnect.getConnection();

        // ===== XỬ LÝ HỦY ĐƠN TỪ NÚT "Hủy" =====
        String huy = request.getParameter("huy");
        if (huy != null && huy.matches("\\d+")) {
            int idHuy = Integer.parseInt(huy);
            
            try {
                conn.setAutoCommit(false);
                
                // 1. Kiểm tra trạng thái đơn hàng
                PreparedStatement checkStt = conn.prepareStatement(
                    "SELECT trangthai FROM donhang WHERE id=? FOR UPDATE");
                checkStt.setInt(1, idHuy);
                ResultSet rsStt = checkStt.executeQuery();
                
                if (rsStt.next()) {
                    String trangThaiHienTai = rsStt.getString("trangthai");
                    if ("Đã hủy".equals(trangThaiHienTai) || "Đã giao".equals(trangThaiHienTai)) {
                        conn.rollback();
                        response.sendRedirect("admin_donhang.jsp?error=khong_the_huy");
                        return;
                    }
                }
                rsStt.close();
                checkStt.close();
                
                // 2. Lấy chi tiết đơn hàng để hoàn kho
                PreparedStatement psCT = conn.prepareStatement(
                    "SELECT sanpham_id, size_id, soluong FROM chitietdonhang WHERE donhang_id=?");
                psCT.setInt(1, idHuy);
                ResultSet rsCT = psCT.executeQuery();
                
                // 3. Hoàn kho
                while (rsCT.next()) {
                    int sanphamId = rsCT.getInt("sanpham_id");
                    int sizeId = rsCT.getInt("size_id");
                    int soLuongHoan = rsCT.getInt("soluong");
                    
                    System.out.println("=== HOAN KHO (NUY HUY) ===");
                    System.out.println("San pham ID: " + sanphamId + ", Size: " + sizeId + ", SL: " + soLuongHoan);
                    
                    if (sizeId > 0) {
                        String sqlUpdate = "UPDATE sanpham_size SET soluong = soluong + ? WHERE sanpham_id = ? AND size_id = ?";
                        PreparedStatement psUpdate = conn.prepareStatement(sqlUpdate);
                        psUpdate.setInt(1, soLuongHoan);
                        psUpdate.setInt(2, sanphamId);
                        psUpdate.setInt(3, sizeId);
                        psUpdate.executeUpdate();
                        psUpdate.close();
                    } else {
                        String sqlUpdate = "UPDATE sanpham SET soluong = soluong + ? WHERE id = ?";
                        PreparedStatement psUpdate = conn.prepareStatement(sqlUpdate);
                        psUpdate.setInt(1, soLuongHoan);
                        psUpdate.setInt(2, sanphamId);
                        psUpdate.executeUpdate();
                        psUpdate.close();
                    }
                }
                rsCT.close();
                psCT.close();
                
                // 4. Cập nhật trạng thái đơn hàng
                PreparedStatement psDon = conn.prepareStatement(
                    "UPDATE donhang SET trangthai='Đã hủy' WHERE id=?");
                psDon.setInt(1, idHuy);
                psDon.executeUpdate();
                psDon.close();
                
                conn.commit();
                System.out.println("Da huy don hang #" + idHuy + " thanh cong!");
                response.sendRedirect("admin_donhang.jsp?success=huy_thanh_cong");
                
            } catch (Exception e) {
                conn.rollback();
                e.printStackTrace();
                response.sendRedirect("admin_donhang.jsp?error=loi_he_thong");
            } finally {
                conn.setAutoCommit(true);
            }
            return;
        }

        // ===== XỬ LÝ CẬP NHẬT TRẠNG THÁI TỪ DROPDOWN =====
        String idUpdate = request.getParameter("id");
        String trangthai = request.getParameter("trangthai");

        if (idUpdate != null && trangthai != null && idUpdate.matches("\\d+")) {
            try {
                conn.setAutoCommit(false);
                
                int orderId = Integer.parseInt(idUpdate);
                
                // 1. Lấy trạng thái cũ
                PreparedStatement psOld = conn.prepareStatement(
                    "SELECT trangthai FROM donhang WHERE id=? FOR UPDATE");
                psOld.setInt(1, orderId);
                ResultSet rsOld = psOld.executeQuery();
                String oldStatus = "";
                if (rsOld.next()) {
                    oldStatus = rsOld.getString("trangthai");
                }
                rsOld.close();
                psOld.close();
                
                // 2. Nếu chuyển sang "Đã hủy" và chưa phải "Đã hủy" thì hoàn kho
                if ("Đã hủy".equals(trangthai) && !"Đã hủy".equals(oldStatus)) {
                    System.out.println("=== HOAN KHO (DROPDOWN) ===");
                    
                    // Lấy chi tiết đơn hàng
                    PreparedStatement psCT = conn.prepareStatement(
                        "SELECT sanpham_id, size_id, soluong FROM chitietdonhang WHERE donhang_id=?");
                    psCT.setInt(1, orderId);
                    ResultSet rsCT = psCT.executeQuery();
                    
                    while (rsCT.next()) {
                        int sanphamId = rsCT.getInt("sanpham_id");
                        int sizeId = rsCT.getInt("size_id");
                        int soLuong = rsCT.getInt("soluong");
                        
                        System.out.println("San pham ID: " + sanphamId + ", Size: " + sizeId + ", SL: " + soLuong);
                        
                        if (sizeId > 0) {
                            String sqlUpdate = "UPDATE sanpham_size SET soluong = soluong + ? WHERE sanpham_id = ? AND size_id = ?";
                            PreparedStatement psUpdate = conn.prepareStatement(sqlUpdate);
                            psUpdate.setInt(1, soLuong);
                            psUpdate.setInt(2, sanphamId);
                            psUpdate.setInt(3, sizeId);
                            psUpdate.executeUpdate();
                            psUpdate.close();
                        } else {
                            String sqlUpdate = "UPDATE sanpham SET soluong = soluong + ? WHERE id = ?";
                            PreparedStatement psUpdate = conn.prepareStatement(sqlUpdate);
                            psUpdate.setInt(1, soLuong);
                            psUpdate.setInt(2, sanphamId);
                            psUpdate.executeUpdate();
                            psUpdate.close();
                        }
                    }
                    rsCT.close();
                    psCT.close();
                    
                    System.out.println("Da hoan kho thanh cong!");
                }
                
                // 3. Cập nhật trạng thái mới
                PreparedStatement ps = conn.prepareStatement(
                    "UPDATE donhang SET trangthai=? WHERE id=?");
                ps.setString(1, trangthai);
                ps.setInt(2, orderId);
                ps.executeUpdate();
                ps.close();
                
                conn.commit();
                response.sendRedirect("admin_donhang.jsp?success=cap_nhat_thanh_cong");
                
            } catch (Exception e) {
                conn.rollback();
                e.printStackTrace();
                response.sendRedirect("admin_donhang.jsp?error=loi_cap_nhat");
            } finally {
                conn.setAutoCommit(true);
            }
            return;
        }

        // ===== LẤY DỮ LIỆU HIỂN THỊ =====
        String fromDate = request.getParameter("fromDate");
        String toDate = request.getParameter("toDate");
        String statusFilter = request.getParameter("status");
        String searchKeyword = request.getParameter("search");
        String tabActive = request.getParameter("tab");
        if (tabActive == null || tabActive.isEmpty()) {
            tabActive = "tat-ca";
        }

        String sql = "SELECT * FROM donhang WHERE 1=1";
        
        if ("cho-xu-ly".equals(tabActive)) {
            sql += " AND trangthai = 'Chờ xử lý'";
        } else if ("dang-giao".equals(tabActive)) {
            sql += " AND trangthai = 'Đang giao'";
        } else if ("da-giao".equals(tabActive)) {
            sql += " AND trangthai = 'Đã giao'";
        } else if ("da-huy".equals(tabActive)) {
            sql += " AND trangthai = 'Đã hủy'";
        }
        
        if (fromDate != null && !fromDate.isEmpty()) {
            sql += " AND DATE(ngay) >= ?";
        }
        if (toDate != null && !toDate.isEmpty()) {
            sql += " AND DATE(ngay) <= ?";
        }
        if (statusFilter != null && !statusFilter.isEmpty()) {
            sql += " AND trangthai = ?";
        }
        if (searchKeyword != null && !searchKeyword.trim().isEmpty()) {
            sql += " AND (tenkhach LIKE ? OR id LIKE ? OR sdt LIKE ?)";
        }
        
        sql += " ORDER BY id DESC";

        PreparedStatement st = conn.prepareStatement(sql);
        int i = 1;
        
        if (fromDate != null && !fromDate.isEmpty()) {
            st.setString(i++, fromDate);
        }
        if (toDate != null && !toDate.isEmpty()) {
            st.setString(i++, toDate);
        }
        if (statusFilter != null && !statusFilter.isEmpty()) {
            st.setString(i++, statusFilter);
        }
        if (searchKeyword != null && !searchKeyword.trim().isEmpty()) {
            String keyword = "%" + searchKeyword.trim() + "%";
            st.setString(i++, keyword);
            st.setString(i++, keyword);
            st.setString(i++, keyword);
        }

        ResultSet rs = st.executeQuery();
        
        int countAll = 0, countCho = 0, countDangGiao = 0, countDaGiao = 0, countDaHuy = 0;
        PreparedStatement stCount = conn.prepareStatement(
            "SELECT trangthai, COUNT(*) as count FROM donhang GROUP BY trangthai");
        ResultSet rsCount = stCount.executeQuery();
        while (rsCount.next()) {
            String status = rsCount.getString("trangthai");
            int count = rsCount.getInt("count");
            if ("Chờ xử lý".equals(status)) countCho = count;
            else if ("Đang giao".equals(status)) countDangGiao = count;
            else if ("Đã giao".equals(status)) countDaGiao = count;
            else if ("Đã hủy".equals(status)) countDaHuy = count;
            countAll += count;
        }
        rsCount.close();
        stCount.close();
        
        String successMsg = request.getParameter("success");
        String errorMsg = request.getParameter("error");
%>


<!DOCTYPE html>
<html>
    <head>
        <title>Admin - Don hang</title>
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
                justify-content: space-between;
                align-items: center;
                margin-bottom: 24px;
                flex-wrap: wrap;
                gap: 12px;
            }
            .page-title {
                font-size: 22px;
                font-weight: 600;
                color: #2d2d2d;
            }
            
            .tabs {
                display: flex;
                gap: 4px;
                background: #ffffff;
                padding: 6px;
                border-radius: 12px;
                border: 1px solid #e8e5e0;
                margin-bottom: 24px;
                flex-wrap: wrap;
            }
            .tab-btn {
                padding: 10px 24px;
                border: none;
                background: transparent;
                border-radius: 8px;
                font-family: 'Quicksand', sans-serif;
                font-size: 14px;
                font-weight: 500;
                color: #8a8a8a;
                cursor: pointer;
                transition: all 0.3s ease;
                display: flex;
                align-items: center;
                gap: 8px;
                text-decoration: none;
            }
            .tab-btn:hover {
                background: #f7f6f4;
                color: #2d2d2d;
            }
            .tab-btn.active {
                background: linear-gradient(135deg, #1a1a2e 0%, #16213e 50%, #0f3460 100%);
                color: #ffffff;
                box-shadow: 0 4px 16px rgba(15, 52, 96, 0.2);
            }
            .tab-btn .count {
                font-size: 11px;
                padding: 2px 10px;
                border-radius: 12px;
                background: rgba(0,0,0,0.08);
                font-weight: 400;
            }
            .tab-btn.active .count {
                background: rgba(255,255,255,0.2);
            }
            
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
            .filter-group input, .filter-group select {
                padding: 8px 14px;
                border-radius: 8px;
                border: 1px solid #e8e5e0;
                font-family: 'Quicksand', sans-serif;
                font-size: 13px;
                background: #faf9f8;
                min-width: 160px;
                transition: all 0.3s ease;
                color: #2d2d2d;
            }
            .filter-group input:focus, .filter-group select:focus {
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
                transform: translateY(-2px);
            }
            
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
            .badge {
                padding: 4px 12px;
                border-radius: 12px;
                font-size: 12px;
                font-weight: 500;
            }
            .badge-cho { background: #fff3cd; color: #856404; }
            .badge-dang-giao { background: #cce5ff; color: #004085; }
            .badge-da-giao { background: #d4edda; color: #155724; }
            .badge-da-huy { background: #f8d7da; color: #721c24; }
            
            .btn-view {
                padding: 6px 16px;
                border: none;
                border-radius: 6px;
                font-family: 'Quicksand', sans-serif;
                font-size: 12px;
                font-weight: 500;
                cursor: pointer;
                transition: all 0.3s ease;
                text-decoration: none;
                display: inline-block;
                background: linear-gradient(135deg, #1a1a2e 0%, #16213e 50%, #0f3460 100%);
                color: #ffffff;
            }
            .btn-view:hover {
                transform: translateY(-1px);
                box-shadow: 0 4px 12px rgba(15, 52, 96, 0.2);
            }
            
            .empty-state {
                text-align: center;
                padding: 60px 20px;
                color: #a8a4a0;
            }
            .empty-state .material-symbols-outlined {
                font-size: 56px;
                opacity: 0.3;
                display: block;
                margin-bottom: 12px;
            }
            
            .alert-success {
                background: #d4edda;
                color: #155724;
                padding: 12px 20px;
                border-radius: 8px;
                margin-bottom: 16px;
                border: 1px solid #c3e6cb;
            }
            .alert-error {
                background: #f8d7da;
                color: #721c24;
                padding: 12px 20px;
                border-radius: 8px;
                margin-bottom: 16px;
                border: 1px solid #f5c6cb;
            }
            
            @media (max-width: 992px) {
                body { padding-left: 0; padding-top: 70px; }
                .container { padding: 16px; }
            }
            @media (max-width: 600px) {
                .filter-bar { flex-direction: column; }
                .filter-group { width: 100%; }
                .filter-group input, .filter-group select { min-width: 100%; }
                .tabs { flex-direction: column; }
                .tab-btn { justify-content: center; }
            }
        </style>
    </head>
    <body>
        <div class="container">
            <!-- Header -->
            <div class="page-header">
                <div class="page-title">Quản lý đơn hàng</div>
            </div>

            <!-- Thong bao -->
            <% if (successMsg != null) { %>
                <div class="alert-success">
                    <% if ("huy_thanh_cong".equals(successMsg)) { %>
                        Da huy don hang thanh cong!
                    <% } %>
                </div>
            <% } %>
            <% if (errorMsg != null) { %>
                <div class="alert-error">
                    <% if ("khong_the_huy".equals(errorMsg)) { %>
                        Khong the huy don hang nay!
                    <% } else { %>
                        Co loi xay ra: <%= errorMsg %>
                    <% } %>
                </div>
            <% } %>

            <!-- Tabs -->
            <div class="tabs">
                <a href="?tab=tat-ca<%= fromDate != null ? "&fromDate=" + fromDate : "" %><%= toDate != null ? "&toDate=" + toDate : "" %><%= searchKeyword != null ? "&search=" + searchKeyword : "" %>" 
                   class="tab-btn <%= "tat-ca".equals(tabActive) ? "active" : "" %>">
                    Tất cả <span class="count"><%= countAll %></span>
                </a>
                <a href="?tab=cho-xu-ly<%= fromDate != null ? "&fromDate=" + fromDate : "" %><%= toDate != null ? "&toDate=" + toDate : "" %><%= searchKeyword != null ? "&search=" + searchKeyword : "" %>" 
                   class="tab-btn <%= "cho-xu-ly".equals(tabActive) ? "active" : "" %>">
                    Chờ xử lý <span class="count"><%= countCho %></span>
                </a>
                <a href="?tab=dang-giao<%= fromDate != null ? "&fromDate=" + fromDate : "" %><%= toDate != null ? "&toDate=" + toDate : "" %><%= searchKeyword != null ? "&search=" + searchKeyword : "" %>" 
                   class="tab-btn <%= "dang-giao".equals(tabActive) ? "active" : "" %>">
                    Đang giao <span class="count"><%= countDangGiao %></span>
                </a>
                <a href="?tab=da-giao<%= fromDate != null ? "&fromDate=" + fromDate : "" %><%= toDate != null ? "&toDate=" + toDate : "" %><%= searchKeyword != null ? "&search=" + searchKeyword : "" %>" 
                   class="tab-btn <%= "da-giao".equals(tabActive) ? "active" : "" %>">
                    Đã giao <span class="count"><%= countDaGiao %></span>
                </a>
                <a href="?tab=da-huy<%= fromDate != null ? "&fromDate=" + fromDate : "" %><%= toDate != null ? "&toDate=" + toDate : "" %><%= searchKeyword != null ? "&search=" + searchKeyword : "" %>" 
                   class="tab-btn <%= "da-huy".equals(tabActive) ? "active" : "" %>">
                    Đã hủy <span class="count"><%= countDaHuy %></span>
                </a>
            </div>

            <!-- Filter -->
            <div class="filter-bar">
                <form method="get" style="display: flex; gap: 16px; flex-wrap: wrap; align-items: flex-end; width: 100%;">
                    <input type="hidden" name="tab" value="<%= tabActive %>">
                    
                    <div class="filter-group">
                        <label>Tìm kiếm</label>
                        <input type="text" name="search" placeholder="Ten, ma don, SDT..." 
                               value="<%= searchKeyword != null ? searchKeyword : "" %>">
                    </div>
                    <div class="filter-group">
                        <label>Từ ngày</label>
                        <input type="date" name="fromDate" value="<%= fromDate != null ? fromDate : "" %>">
                    </div>
                    <div class="filter-group">
                        <label>Đến ngày</label>
                        <input type="date" name="toDate" value="<%= toDate != null ? toDate : "" %>">
                    </div>
                    <button type="submit" class="btn-filter">Loc</button>
                    <a href="admin_donhang.jsp?tab=<%= tabActive %>" class="btn-filter reset">Xóa lọc</a>
                </form>
            </div>

            <!-- Table -->
            <!-- Table -->
            <div class="table-card">
                <table>
                    <thead>
                        <tr>
                            <th style="width:70px;">Mã đơn</th>
                            <th>Khách hàng</th>
                            <th>SĐT</th>
                            <th>Ngày đặt</th>
                            <th style="width:120px;">Tổng tiền</th>
                            <th style="width:130px;">Trạng thái</th>
                            <th style="width:200px;text-align:center;">Thao tác</th>
                        </tr>
                    </thead>
                    <tbody>
                        <% 
                            boolean hasData = false;
                            while (rs.next()) {
                                hasData = true;
                                int orderId = rs.getInt("id");
                                String trangThai = rs.getString("trangthai");
                                String statusClass = "";
                                if ("Chờ xử lý".equals(trangThai)) statusClass = "badge-cho";
                                else if ("Đang giao".equals(trangThai)) statusClass = "badge-dang-giao";
                                else if ("Đã giao".equals(trangThai)) statusClass = "badge-da-giao";
                                else if ("Đã hủy".equals(trangThai)) statusClass = "badge-da-huy";
                                boolean isCanceled = "Đã hủy".equals(trangThai);
                        %>
                        <tr>
                            <td><strong>#<%= orderId %></strong></td>
                            <td><%= rs.getString("tenkhach") %></td>
                            <td><%= rs.getString("sdt") %></td>
                            <td><%= rs.getTimestamp("ngay") != null ? rs.getTimestamp("ngay").toString().substring(0, 16) : "" %></td>
                            <td><strong><%= String.format("%,d", rs.getInt("tongtien")) %>đ</strong></td>
                            <td><span class="badge <%= statusClass %>"><%= trangThai %></span></td>
                            <td>
                                <div style="display:flex;gap:6px;justify-content:center;flex-wrap:wrap;">
                                    
                                    
                                    <!-- Nút Xem -->
                                    <a href="chitietdonhang.jsp?id=<%= orderId %>" class="btn-view">👁 Xem</a>
                                    
                                    <!-- Nút Hủy đơn -->
                                    <% if (!isCanceled && !"Đã giao".equals(trangThai)) { %>
                                        <a href="?huy=<%= orderId %>" 
                                           class="btn-cancel"
                                           onclick="return confirm('Bạn có chắc muốn hủy đơn hàng #<%= orderId %>?\nSố lượng sản phẩm sẽ được hoàn lại vào kho.')"
                                           style="padding:5px 10px;border-radius:6px;border:1px solid #f0d5d5;color:#c0392b;background:white;text-decoration:none;font-size:12px;font-family:'Quicksand',sans-serif;cursor:pointer;">
                                            Hủy
                                        </a>
                                    <% } %>
                                </div>
                            </td>
                        </tr>
                        <% } 
                        if (!hasData) { %>
                        <tr>
                            <td colspan="7">
                                <div class="empty-state">
                                    <span class="material-symbols-outlined">inbox</span>
                                    <h3>Không có đơn hàng nào</h3>
                                </div>
                            </td>
                        </tr>
                        <% } %>
                    </tbody>
                </table>
            </div>

            <!-- Footer -->
            <div style="margin-top:20px;text-align:center;font-size:12px;color:#c0bdb8;letter-spacing:0.5px;">
                AURA Admin Panel
            </div>
        </div>
    </body>
</html>

<%
    } catch (Exception e) {
        e.printStackTrace();
    } finally {
        if (conn != null) try { conn.close(); } catch(Exception e) {}
    }
%>