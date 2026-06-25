<%@page import="java.sql.*"%>
<%@page import="DAO.dbconnect"%>
<%@ page contentType="text/html;charset=UTF-8" %>

<jsp:include page="sidebar.jsp" />

<%
    String id = request.getParameter("id");
    if (id == null || !id.matches("\\d+")) {
        response.sendRedirect("admin_donhang.jsp");
        return;
    }

    Connection conn = null;
    try {
        conn = dbconnect.getConnection();

        // ===== XỬ LÝ HỦY ĐƠN (TỪ NÚT HỦY HOẶC DROPDOWN) =====
        String huy = request.getParameter("huy");
        String capNhatTrangThai = request.getParameter("capnhat");
        
        // Trường hợp 1: Nút "Hủy đơn hàng"
        if (huy != null && huy.matches("\\d+")) {
            int idHuy = Integer.parseInt(huy);
            
            try {
                conn.setAutoCommit(false);
                
                // 1. Kiểm tra trạng thái
                PreparedStatement checkStt = conn.prepareStatement(
                    "SELECT trangthai FROM donhang WHERE id=? FOR UPDATE");
                checkStt.setInt(1, idHuy);
                ResultSet rsStt = checkStt.executeQuery();
                if (rsStt.next()) {
                    String trangThai = rsStt.getString("trangthai");
                    if ("Đã hủy".equals(trangThai) || "Đã giao".equals(trangThai)) {
                        conn.rollback();
                        response.sendRedirect("chitietdonhang.jsp?id=" + idHuy + "&error=khong_the_huy");
                        return;
                    }
                }
                rsStt.close();
                checkStt.close();
                
                // 2. Hoàn kho
                PreparedStatement psCT = conn.prepareStatement(
                    "SELECT sanpham_id, size_id, soluong FROM chitietdonhang WHERE donhang_id=?");
                psCT.setInt(1, idHuy);
                ResultSet rsCT = psCT.executeQuery();
                
                while (rsCT.next()) {
                    int sanphamId = rsCT.getInt("sanpham_id");
                    int sizeId = rsCT.getInt("size_id");
                    int soLuong = rsCT.getInt("soluong");
                    
                    System.out.println("=== HOAN KHO (CHI TIET DON HANG) ===");
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
                
                // 3. Cập nhật trạng thái
                PreparedStatement psDon = conn.prepareStatement(
                    "UPDATE donhang SET trangthai='Đã hủy' WHERE id=?");
                psDon.setInt(1, idHuy);
                psDon.executeUpdate();
                psDon.close();
                
                conn.commit();
                response.sendRedirect("chitietdonhang.jsp?id=" + idHuy + "&success=huy_thanh_cong");
                
            } catch (Exception e) {
                conn.rollback();
                e.printStackTrace();
                response.sendRedirect("chitietdonhang.jsp?id=" + idHuy + "&error=loi_he_thong");
            } finally {
                conn.setAutoCommit(true);
            }
            return;
        }
        
        // Trường hợp 2: Cập nhật trạng thái từ dropdown
        if (capNhatTrangThai != null) {
            String newStatus = request.getParameter("trangthai");
            int orderId = Integer.parseInt(id);
            
            if (newStatus != null && !newStatus.isEmpty()) {
                try {
                    conn.setAutoCommit(false);
                    
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
                    
                    // 2. Nếu chuyển sang "Đã hủy" thì hoàn kho
                    if ("Đã hủy".equals(newStatus) && !"Đã hủy".equals(oldStatus)) {
                        System.out.println("=== HOAN KHO (DROPDOWN CHI TIET) ===");
                        
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
                    ps.setString(1, newStatus);
                    ps.setInt(2, orderId);
                    ps.executeUpdate();
                    ps.close();
                    
                    conn.commit();
                    response.sendRedirect("chitietdonhang.jsp?id=" + orderId + "&success=cap_nhat_thanh_cong");
                    
                } catch (Exception e) {
                    conn.rollback();
                    e.printStackTrace();
                    response.sendRedirect("chitietdonhang.jsp?id=" + orderId + "&error=loi_cap_nhat");
                } finally {
                    conn.setAutoCommit(true);
                }
                return;
            }
        }

        // ===== LẤY THÔNG TIN ĐƠN HÀNG =====
        String sql = "SELECT * FROM donhang WHERE id = ?";
        PreparedStatement ps = conn.prepareStatement(sql);
        ps.setInt(1, Integer.parseInt(id));
        ResultSet rs = ps.executeQuery();
        
        if (!rs.next()) {
            response.sendRedirect("admin_donhang.jsp");
            return;
        }
        
        String trangThai = rs.getString("trangthai");
        int tongTien = rs.getInt("tongtien");
        String thanhToan = rs.getString("thanh_toan");
        if (thanhToan == null || thanhToan.isEmpty()) {
            thanhToan = "cod";
        }
        
        // ===== LẤY CHI TIẾT SẢN PHẨM =====
        String sqlDetail = "SELECT ct.*, sp.ten, sp.anh FROM chitietdonhang ct "
                         + "JOIN sanpham sp ON ct.sanpham_id = sp.id "
                         + "WHERE ct.donhang_id = ?";
        PreparedStatement psDetail = conn.prepareStatement(sqlDetail);
        psDetail.setInt(1, Integer.parseInt(id));
        ResultSet rsDetail = psDetail.executeQuery();
        
        String successMsg = request.getParameter("success");
        String errorMsg = request.getParameter("error");
        
        boolean isCanceled = "Đã hủy".equals(trangThai);
        boolean isDelivered = "Đã giao".equals(trangThai);
%>

<!DOCTYPE html>
<html>
    <head>
        <title>Chi tiết đơn hàng #<%= id %> - AURA Admin</title>
        <link href="https://fonts.googleapis.com/css2?family=Quicksand:wght@300;400;500;600;700&display=swap" rel="stylesheet">
        <link href="https://fonts.googleapis.com/css2?family=Material+Symbols+Outlined:wght@100..700&display=swap" rel="stylesheet">
        <style>
            /* ... CSS giữ nguyên như cũ ... */
            * { box-sizing: border-box; margin: 0; padding: 0; }
            body {
                font-family: 'Quicksand', sans-serif;
                background: #f8f7f4;
                min-height: 100vh;
                padding-left: 240px;
                color: #2d2d2d;
            }
            .container {
                max-width: 1200px;
                margin: 0 auto;
                padding: 24px 28px 40px;
            }
            .page-header {
                display: flex;
                justify-content: space-between;
                align-items: center;
                flex-wrap: wrap;
                gap: 12px;
                margin-bottom: 20px;
            }
            .page-title {
                font-size: 22px;
                font-weight: 600;
                color: #2d2d2d;
            }
            .back-link {
                color: #8a8a8a;
                text-decoration: none;
                font-size: 14px;
                display: flex;
                align-items: center;
                gap: 6px;
                transition: color 0.3s ease;
            }
            .back-link:hover { color: #2d2d2d; }
            
            .grid-2 {
                display: grid;
                grid-template-columns: 1fr 1fr;
                gap: 20px;
                margin-bottom: 20px;
            }
            
            .card {
                background: #ffffff;
                border-radius: 12px;
                padding: 24px;
                border: 1px solid #e8e5e0;
            }
            .card-title {
                font-size: 15px;
                font-weight: 600;
                margin-bottom: 14px;
                padding-bottom: 10px;
                border-bottom: 1px solid #f0eeeb;
                display: flex;
                align-items: center;
                gap: 8px;
                color: #2d2d2d;
            }
            .card-title .material-symbols-outlined {
                font-size: 20px;
                color: #c9a96e;
            }
            
            .info-row {
                display: flex;
                padding: 6px 0;
                font-size: 14px;
            }
            .info-row .label {
                color: #8a8a8a;
                min-width: 120px;
                font-weight: 400;
            }
            .info-row .value {
                font-weight: 500;
                color: #2d2d2d;
            }
            
            .badge-status {
                padding: 6px 16px;
                border-radius: 20px;
                font-size: 14px;
                font-weight: 500;
                display: inline-block;
            }
            .badge-cho { background: #fff3cd; color: #856404; }
            .badge-dang-giao { background: #cce5ff; color: #004085; }
            .badge-da-giao { background: #d4edda; color: #155724; }
            .badge-da-huy { background: #f8d7da; color: #721c24; }
            
            .disabled-section {
                opacity: 0.5;
                pointer-events: none;
                cursor: not-allowed;
            }
            .disabled-section select,
            .disabled-section button,
            .disabled-section a {
                opacity: 0.5;
                cursor: not-allowed;
            }
            .disabled-badge {
                background: #e8e5e0;
                color: #8a8a8a;
                padding: 6px 16px;
                border-radius: 20px;
                font-size: 14px;
                font-weight: 500;
                display: inline-block;
            }
            .alert-info {
                background: #cce5ff;
                color: #004085;
                padding: 12px 20px;
                border-radius: 8px;
                margin-bottom: 16px;
                border: 1px solid #b8d4e8;
            }
            
            .product-item {
                display: flex;
                align-items: center;
                gap: 16px;
                padding: 10px 0;
                border-bottom: 1px solid #f0eeeb;
            }
            .product-item:last-child { border-bottom: none; }
            .product-item .thumb {
                width: 50px;
                height: 50px;
                border-radius: 8px;
                object-fit: cover;
                background: #f7f6f4;
                border: 1px solid #e8e5e0;
            }
            .product-item .info { flex: 1; }
            .product-item .name { font-weight: 500; font-size: 14px; }
            .product-item .meta { font-size: 13px; color: #8a8a8a; }
            .product-item .price { font-weight: 600; font-size: 14px; color: #2d2d2d; }
            
            .total-row {
                display: flex;
                justify-content: flex-end;
                padding-top: 12px;
                margin-top: 8px;
                border-top: 1px solid #e8e5e0;
                font-size: 18px;
                font-weight: 700;
                color: #2d2d2d;
            }
            
            .btn-action {
                padding: 10px 20px;
                border: none;
                border-radius: 8px;
                font-family: 'Quicksand', sans-serif;
                font-size: 13px;
                font-weight: 500;
                cursor: pointer;
                transition: all 0.3s ease;
                text-decoration: none;
                display: inline-flex;
                align-items: center;
                gap: 6px;
            }
            .btn-action:hover {
                transform: translateY(-2px);
                box-shadow: 0 4px 16px rgba(0,0,0,0.1);
            }
            .btn-action:disabled {
                opacity: 0.5;
                cursor: not-allowed;
                transform: none !important;
                box-shadow: none !important;
            }
            .btn-primary {
                background: linear-gradient(135deg, #1a1a2e 0%, #16213e 50%, #0f3460 100%);
                color: #ffffff;
            }
            .btn-danger {
                background: #dc3545;
                color: #ffffff;
            }
            .btn-danger:hover {
                background: #c0392b;
            }
            
            .action-group {
                display: flex;
                gap: 10px;
                flex-wrap: wrap;
                margin-top: 4px;
            }
            
            .status-select {
                padding: 10px 16px;
                border-radius: 8px;
                border: 1px solid #e8e5e0;
                font-family: 'Quicksand', sans-serif;
                font-size: 14px;
                background: #faf9f8;
                color: #2d2d2d;
                min-width: 160px;
            }
            .status-select:focus {
                border-color: #c9a96e;
                outline: none;
            }
            .status-select:disabled {
                opacity: 0.5;
                cursor: not-allowed;
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
                .grid-2 { grid-template-columns: 1fr; }
            }
            @media (max-width: 600px) {
                .info-row { flex-direction: column; gap: 2px; }
                .info-row .label { min-width: unset; }
                .action-group { flex-direction: column; }
                .btn-action { width: 100%; justify-content: center; }
                .status-select { width: 100%; }
            }
        </style>
    </head>
    <body>
        <div class="container">
            <!-- Header -->
            <div class="page-header">
                <div>
                    <a href="admin_donhang.jsp" class="back-link">
                        <span class="material-symbols-outlined" style="font-size:20px;">arrow_back</span>
                        Quay lại
                    </a>
                    <div class="page-title">Chi tiết đơn hàng #<%= id %></div>
                </div>
                <div style="display:flex;gap:10px;align-items:center;flex-wrap:wrap;">
                    <span class="badge-status <%= 
                        "Chờ xử lý".equals(trangThai) ? "badge-cho" :
                        "Đang giao".equals(trangThai) ? "badge-dang-giao" :
                        "Đã giao".equals(trangThai) ? "badge-da-giao" :
                        "badge-da-huy"
                    %>"><%= trangThai %></span>
                    
                    <!-- Nút xuất hóa đơn -->
                    <a href="xuat_hoadon_simple.jsp?id=<%= id %>" target="_blank" 
                       style="background:#28a745;color:#ffffff;padding:8px 16px;border-radius:6px;text-decoration:none;font-family:'Quicksand',sans-serif;font-size:13px;display:inline-flex;align-items:center;gap:6px;transition:all 0.3s ease;">
                        <span class="material-symbols-outlined" style="font-size:18px;">description</span>
                        Xuất hóa đơn
                    </a>
                </div>
            </div>

            <!-- Thông báo -->
            <% if (successMsg != null) { %>
                <div class="alert-success">✅ Đã cập nhật đơn hàng thành công!</div>
            <% } %>
            <% if (errorMsg != null) { %>
                <div class="alert-error">❌ <%= errorMsg %></div>
            <% } %>
            
            <!-- Thông báo đơn đã hủy -->
            <% if (isCanceled) { %>
                <div class="alert-info">
                    <span class="material-symbols-outlined" style="font-size:18px;vertical-align:middle;">info</span>
                    Đơn hàng này đã bị hủy. Không thể thực hiện thao tác nào.
                </div>
            <% } %>

            <!-- Grid 2 cột -->
            <div class="grid-2">
                <!-- Ô 1: Thông tin khách hàng -->
                <div class="card">
                    <div class="card-title">
                        <span class="material-symbols-outlined">person</span>
                        Thông tin khách hàng
                    </div>
                    <div class="info-row">
                        <span class="label">Mã đơn hàng</span>
                        <span class="value">#<%= id %></span>
                    </div>
                    <div class="info-row">
                        <span class="label">Ngày đặt</span>
                        <span class="value"><%= rs.getTimestamp("ngay") != null ? rs.getTimestamp("ngay").toString() : "" %></span>
                    </div>
                    <div class="info-row">
                        <span class="label">Khách hàng</span>
                        <span class="value"><%= rs.getString("tenkhach") %></span>
                    </div>
                    <div class="info-row">
                        <span class="label">Số điện thoại</span>
                        <span class="value"><%= rs.getString("sdt") %></span>
                    </div>
                    <div class="info-row">
                        <span class="label">Email</span>
                        <span class="value"><%= rs.getString("email") != null && !rs.getString("email").isEmpty() ? rs.getString("email") : "Chưa cập nhật" %></span>
                    </div>
                    <div class="info-row">
                        <span class="label">Địa chỉ</span>
                        <span class="value"><%= rs.getString("diachi") %></span>
                    </div>
                    <div class="info-row">
                        <span class="label">Ghi chú</span>
                        <span class="value"><%= rs.getString("ghichu") != null && !rs.getString("ghichu").isEmpty() ? rs.getString("ghichu") : "Không có ghi chú" %></span>
                    </div>
                </div>

                <!-- Ô 2: Thanh toán và giao hàng -->
                <div class="card">
                    <div class="card-title">
                        <span class="material-symbols-outlined">payments</span>
                        Thanh toán &amp; Giao hàng
                    </div>
                    <div class="info-row">
                        <span class="label">Phương thức thanh toán :</span>
                        <span class="value">
                            <% if ("cod".equals(thanhToan)) { %>
                                Thanh toán khi nhận hàng (COD)
                            <% } else if ("bank".equals(thanhToan)) { %>
                                Chuyển khoản ngân hàng
                            <% } else if ("momo".equals(thanhToan)) { %>
                                Ví Momo / ZaloPay
                            <% } else { %>
                                Thanh toán khi nhận hàng (COD)
                            <% } %>
                        </span>
                    </div>
                    <div class="info-row">
                        <span class="label">Trạng thái thanh toán :</span>
                        <span class="value">
                            <% if ("Đã giao".equals(trangThai)) { %>
                                Đã thanh toán
                            <% } else if ("Đã hủy".equals(trangThai)) { %>
                                Đã hủy
                            <% } else { %>
                                Chưa thanh toán
                            <% } %>
                        </span>
                    </div>
                    <div class="info-row">
                        <span class="label">Trạng thái đơn hàng</span>
                        <span class="value">
                            <span class="badge-status <%= 
                                "Chờ xử lý".equals(trangThai) ? "badge-cho" :
                                "Đang giao".equals(trangThai) ? "badge-dang-giao" :
                                "Đã giao".equals(trangThai) ? "badge-da-giao" :
                                "badge-da-huy"
                            %>"><%= trangThai %></span>
                        </span>
                    </div>
                    <div class="info-row">
                        <span class="label">Tổng tiền</span>
                        <span class="value" style="font-size:18px;font-weight:700;color:#c9a96e;">
                            <%= String.format("%,d", rs.getInt("tongtien")) %>đ
                        </span>
                    </div>
                </div>
            </div>

            <!-- Ô 3: Sản phẩm trong đơn -->
            <div class="card" style="margin-bottom:20px;">
                <div class="card-title">
                    <span class="material-symbols-outlined">shopping_bag</span>
                    Sản phẩm trong đơn
                </div>
                <% 
                    int tong = 0;
                    boolean hasProduct = false;
                    while (rsDetail.next()) {
                        hasProduct = true;
                        int gia = rsDetail.getInt("gia");
                        int soluong = rsDetail.getInt("soluong");
                        int thanhTien = gia * soluong;
                        tong += thanhTien;
                        String anh = rsDetail.getString("anh");
                        boolean isLink = (anh != null && (anh.startsWith("http://") || anh.startsWith("https://")));
                        String src = isLink ? anh : "../img/" + anh;
                %>
                <div class="product-item">
                    <img class="thumb" src="<%= src %>" onerror="this.src='../img/default.jpg'" alt="<%= rsDetail.getString("ten") %>">
                    <div class="info">
                        <div class="name"><%= rsDetail.getString("ten") %></div>
                        <div class="meta">
                            SL: <%= soluong %> × <%= String.format("%,d", gia) %>đ
                            <% if (rsDetail.getInt("size_id") > 0) { %>
                            • Size: <%= rsDetail.getInt("size_id") %>
                            <% } %>
                        </div>
                    </div>
                    <div class="price"><%= String.format("%,d", thanhTien) %>đ</div>
                </div>
                <% } 
                if (!hasProduct) { %>
                    <div style="text-align:center;padding:20px;color:#8a8a8a;">
                        Không có sản phẩm trong đơn hàng này
                    </div>
                <% } %>
                <div class="total-row">
                    Tổng cộng: <%= String.format("%,d", tong) %>đ
                </div>
            </div>

            <!-- ===== Ô 4: Cập nhật trạng thái ===== -->
            <div class="card <%= isCanceled ? "disabled-section" : "" %>">
                <div class="card-title">
                    <span class="material-symbols-outlined">settings</span>
                    Cập nhật trạng thái
                    <% if (isCanceled) { %>
                        <span class="disabled-badge">Đã khóa</span>
                    <% } %>
                </div>
                <div class="action-group">
                    <!-- ===== DROPDOWN CẬP NHẬT TRẠNG THÁI ===== -->
                    <form method="post" style="display:flex;gap:10px;flex-wrap:wrap;align-items:center;">
                        <input type="hidden" name="capnhat" value="1">
                        <input type="hidden" name="id" value="<%= id %>">
                        <select name="trangthai" class="status-select" <%= isCanceled ? "disabled" : "" %>>
                            <option value="Chờ xử lý" <%= "Chờ xử lý".equals(trangThai) ? "selected" : "" %>>Chờ xử lý</option>
                            <option value="Đang giao" <%= "Đang giao".equals(trangThai) ? "selected" : "" %>>Đang giao</option>
                            <option value="Đã giao" <%= "Đã giao".equals(trangThai) ? "selected" : "" %>>Đã giao</option>
                            <option value="Đã hủy" <%= "Đã hủy".equals(trangThai) ? "selected" : "" %>>Đã hủy</option>
                        </select>
                        <button type="submit" class="btn-action btn-primary" <%= isCanceled ? "disabled" : "" %>>
                            <span class="material-symbols-outlined" style="font-size:18px;">save</span>
                            Cập nhật
                        </button>
                    </form>

                    
                </div>
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