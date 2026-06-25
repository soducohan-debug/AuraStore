<%-- 
    Document   : thongtincanhan
    Created on : Jun 24, 2026
    Author     : Ma
    Description: Trang thông tin cá nhân người dùng
--%>
<%@ page contentType="text/html;charset=UTF-8" %>
<%@ page import="java.sql.*, DAO.dbconnect, java.text.NumberFormat, java.util.Locale" %>
<%@ page import="java.util.*" %>

<%
    // Kiểm tra đăng nhập
    String user = (String) session.getAttribute("user");
    if (user == null) {
        session.setAttribute("redirectAfterLogin", "thongtincanhan.jsp");
        response.sendRedirect("login.jsp");
        return;
    }
    
    NumberFormat formatter = NumberFormat.getNumberInstance(new Locale("vi", "VN"));
    
    // Lấy thông tin user từ database
    Connection conn = null;
    PreparedStatement ps = null;
    ResultSet rs = null;
    
    String username = "";
    String fullname = "";
    String email = "";
    String phone = "";
    String address = "";
    String role = "";
    String status = "";
    
    try {
        conn = dbconnect.getConnection();
        String sql = "SELECT * FROM user WHERE username = ?";
        ps = conn.prepareStatement(sql);
        ps.setString(1, user);
        rs = ps.executeQuery();
        if (rs.next()) {
            username = rs.getString("username");
            fullname = rs.getString("fullname") != null ? rs.getString("fullname") : "";
            email = rs.getString("email") != null ? rs.getString("email") : "";
            phone = rs.getString("phone") != null ? rs.getString("phone") : "";
            address = rs.getString("address") != null ? rs.getString("address") : "";
            role = rs.getString("role");
            status = rs.getString("status");
        }
    } catch (Exception e) {
        e.printStackTrace();
    } finally {
        if (rs != null) try { rs.close(); } catch(Exception e) {}
        if (ps != null) try { ps.close(); } catch(Exception e) {}
        if (conn != null) try { conn.close(); } catch(Exception e) {}
    }
    
    // Lấy danh sách đơn hàng của user
    List<Map<String, Object>> orders = new ArrayList<>();
    try {
        conn = dbconnect.getConnection();
        String sql = "SELECT * FROM donhang WHERE username = ? ORDER BY id DESC";
        ps = conn.prepareStatement(sql);
        ps.setString(1, user);
        rs = ps.executeQuery();
        while (rs.next()) {
            Map<String, Object> order = new HashMap<>();
            order.put("id", rs.getInt("id"));
            order.put("tenkhach", rs.getString("tenkhach"));
            order.put("sdt", rs.getString("sdt"));
            order.put("diachi", rs.getString("diachi"));
            order.put("tongtien", rs.getInt("tongtien"));
            order.put("trangthai", rs.getString("trangthai"));
            order.put("ngay", rs.getTimestamp("ngay"));
            orders.add(order);
        }
    } catch (Exception e) {
        e.printStackTrace();
    } finally {
        if (rs != null) try { rs.close(); } catch(Exception e) {}
        if (ps != null) try { ps.close(); } catch(Exception e) {}
        if (conn != null) try { conn.close(); } catch(Exception e) {}
    }
    
    // Xử lý cập nhật thông tin
    String updateMsg = null;
    String updateError = null;
    String action = request.getParameter("action");
    if ("update".equals(action)) {
        String newFullname = request.getParameter("fullname");
        String newEmail = request.getParameter("email");
        String newPhone = request.getParameter("phone");
        String newAddress = request.getParameter("address");
        
        try {
            conn = dbconnect.getConnection();
            String sql = "UPDATE user SET fullname = ?, email = ?, phone = ?, address = ? WHERE username = ?";
            ps = conn.prepareStatement(sql);
            ps.setString(1, newFullname);
            ps.setString(2, newEmail);
            ps.setString(3, newPhone);
            ps.setString(4, newAddress);
            ps.setString(5, user);
            int result = ps.executeUpdate();
            if (result > 0) {
                session.setAttribute("fullname", newFullname);
                updateMsg = "Cập nhật thông tin thành công!";
                fullname = newFullname;
                email = newEmail;
                phone = newPhone;
                address = newAddress;
            } else {
                updateError = "Không thể cập nhật thông tin!";
            }
        } catch (Exception e) {
            e.printStackTrace();
            updateError = "Có lỗi xảy ra: " + e.getMessage();
        } finally {
            if (ps != null) try { ps.close(); } catch(Exception e) {}
            if (conn != null) try { conn.close(); } catch(Exception e) {}
        }
    }
    
    // Lấy thông báo từ session (hủy đơn hàng)
    String successMsg = request.getParameter("success");
    String errorMsg = request.getParameter("error");
    if (successMsg != null) {
        try {
            successMsg = java.net.URLDecoder.decode(successMsg, "UTF-8");
        } catch (Exception e) {}
    }
    if (errorMsg != null) {
        try {
            errorMsg = java.net.URLDecoder.decode(errorMsg, "UTF-8");
        } catch (Exception e) {}
    }
%>

<!DOCTYPE html>
<html class="scroll-smooth" lang="vi">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>Thông tin cá nhân - AURA</title>
    <script src="https://cdn.tailwindcss.com?plugins=forms,container-queries"></script>
    <link href="https://fonts.googleapis.com/css2?family=Playfair+Display:wght@400;500;600;700&family=Montserrat:wght@300;400;500;600&display=swap" rel="stylesheet">
    <link href="https://fonts.googleapis.com/css2?family=Material+Symbols+Outlined:wght,FILL@100..700,0..1&display=swap" rel="stylesheet">
    <style>
        body { 
            font-family: 'Montserrat', sans-serif; 
            background: #f9f9f9;
            background-image: url('https://images.pexels.com/photos/26570970/pexels-photo-26570970.jpeg');
        background-size: cover;
        background-position: center;
        background-attachment: fixed;
        background-repeat: no-repeat;
        }
        .profile-card {
            background: #ffffff;
            border-radius: 12px;
            border: 0.5px solid rgba(207,196,197,0.3);
            box-shadow: 0 20px 60px rgba(0,0,0,0.06);
        }
        .status-badge {
            padding: 4px 12px;
            border-radius: 20px;
            font-size: 11px;
            font-weight: 500;
        }
        .status-active { background: #d4edda; color: #155724; }
        .status-blocked { background: #f8d7da; color: #721c24; }
        .order-status {
            padding: 4px 12px;
            border-radius: 20px;
            font-size: 11px;
            font-weight: 500;
        }
        .order-status-cho { background: #fff3cd; color: #856404; }
        .order-status-dang-giao { background: #cce5ff; color: #004085; }
        .order-status-da-giao { background: #d4edda; color: #155724; }
        .order-status-da-huy { background: #f8d7da; color: #721c24; }
        .btn-save {
            background: #000000;
            color: #ffffff;
            padding: 12px 32px;
            border-radius: 8px;
            font-family: 'Montserrat', sans-serif;
            font-size: 12px;
            font-weight: 600;
            letter-spacing: 0.15em;
            text-transform: uppercase;
            border: none;
            cursor: pointer;
            transition: background 0.3s ease;
        }
        .btn-save:hover { background: #333333; }
        .btn-edit {
            background: transparent;
            color: #000000;
            padding: 10px 24px;
            border-radius: 8px;
            font-family: 'Montserrat', sans-serif;
            font-size: 12px;
            font-weight: 600;
            letter-spacing: 0.15em;
            text-transform: uppercase;
            border: 1px solid #000000;
            cursor: pointer;
            transition: all 0.3s ease;
        }
        .btn-edit:hover { background: #000000; color: #ffffff; }
        .btn-cancel-order {
            background: #dc3545;
            color: #ffffff;
            padding: 4px 12px;
            border-radius: 6px;
            font-family: 'Montserrat', sans-serif;
            font-size: 11px;
            font-weight: 500;
            border: none;
            cursor: pointer;
            transition: background 0.3s ease;
        }
        .btn-cancel-order:hover { background: #c82333; }
        .btn-cancel-order:disabled {
            background: #6c757d;
            cursor: not-allowed;
        }
        .tab-btn {
            padding: 10px 24px;
            border: none;
            background: transparent;
            font-family: 'Montserrat', sans-serif;
            font-size: 13px;
            font-weight: 500;
            color: #5d5e5f;
            cursor: pointer;
            transition: all 0.3s ease;
            border-bottom: 2px solid transparent;
        }
        .tab-btn:hover { color: #000000; }
        .tab-btn.active {
            color: #000000;
            border-bottom-color: #000000;
        }
        .tab-content { display: none; }
        .tab-content.active { display: block; }
        .alert-success {
            background: #d4edda;
            color: #155724;
            padding: 12px 16px;
            border-radius: 8px;
            border: 1px solid #c3e6cb;
            margin-bottom: 16px;
        }
        .alert-error {
            background: #f8d7da;
            color: #721c24;
            padding: 12px 16px;
            border-radius: 8px;
            border: 1px solid #f5c6cb;
            margin-bottom: 16px;
        }
    </style>
</head>
<body>

    <jsp:include page="header.jsp" />

    <main class="pt-28 pb-16 px-4 md:px-8 max-w-6xl mx-auto">
        <div class="flex items-center gap-3 mb-8">
            <h1 class="font-playfair text-3xl font-bold text-primary">Thông tin cá nhân</h1>
            <span class="text-sm text-secondary">| <%= username %></span>
        </div>

        <!-- Thông báo -->
        <% if (successMsg != null) { %>
            <div class="alert-success"><%= successMsg %></div>
        <% } %>
        <% if (errorMsg != null) { %>
            <div class="alert-error"><%= errorMsg %></div>
        <% } %>

        <!-- Tabs -->
        <div class="flex gap-4 border-b border-outline-variant/30 mb-8">
            <button class="tab-btn active" onclick="switchTab('info')">Thông tin</button>
            <button class="tab-btn" onclick="switchTab('orders')">Đơn hàng</button>
        </div>

        <!-- Tab: Thông tin -->
        <div id="tab-info" class="tab-content active">
            <div class="profile-card p-6 md:p-8 max-w-2xl">
                <div class="flex justify-between items-start mb-6">
                    <h2 class="font-playfair text-xl font-bold text-primary">Thông tin tài khoản</h2>
                    
                </div>

                <% if (updateMsg != null) { %>
                    <div class="alert-success"><%= updateMsg %></div>
                <% } %>
                <% if (updateError != null) { %>
                    <div class="alert-error"><%= updateError %></div>
                <% } %>

                <form action="thongtincanhan.jsp?action=update" method="post" class="space-y-5">
                    <div>
                        <label class="block text-xs font-medium text-secondary uppercase tracking-wider mb-2">Tên đăng nhập</label>
                        <input type="text" value="<%= username %>" disabled
                               class="w-full px-4 py-3 bg-surface border-0 border-b border-outline-variant text-sm text-secondary cursor-not-allowed">
                    </div>

                    <div>
                        <label class="block text-xs font-medium text-secondary uppercase tracking-wider mb-2">Họ và tên</label>
                        <input type="text" name="fullname" value="<%= fullname %>" required
                               class="w-full px-4 py-3 bg-surface border-0 border-b border-outline-variant focus:border-primary focus:ring-0 outline-none transition-colors text-sm">
                    </div>

                    <div>
                        <label class="block text-xs font-medium text-secondary uppercase tracking-wider mb-2">Email</label>
                        <input type="email" name="email" value="<%= email %>"
                               class="w-full px-4 py-3 bg-surface border-0 border-b border-outline-variant focus:border-primary focus:ring-0 outline-none transition-colors text-sm">
                    </div>

                    <div>
                        <label class="block text-xs font-medium text-secondary uppercase tracking-wider mb-2">Số điện thoại</label>
                        <input type="tel" name="phone" value="<%= phone %>"
                               class="w-full px-4 py-3 bg-surface border-0 border-b border-outline-variant focus:border-primary focus:ring-0 outline-none transition-colors text-sm">
                    </div>

                    <div>
                        <label class="block text-xs font-medium text-secondary uppercase tracking-wider mb-2">Địa chỉ</label>
                        <textarea name="address" rows="3"
                                  class="w-full px-4 py-3 bg-surface border-0 border-b border-outline-variant focus:border-primary focus:ring-0 outline-none transition-colors text-sm resize-none"><%= address %></textarea>
                    </div>

                    <div class="flex gap-4 pt-2">
                        <button type="submit" class="btn-save">Cập nhật</button>
                        <a href="doimatkhau.jsp" class="btn-edit">Đổi mật khẩu</a>
                    </div>
                </form>
            </div>
        </div>

        <!-- Tab: Đơn hàng -->
        <div id="tab-orders" class="tab-content">
            <div class="profile-card p-6 md:p-8">
                <h2 class="font-playfair text-xl font-bold text-primary mb-6">Lịch sử đơn hàng</h2>

                <% if (orders.isEmpty()) { %>
                    <div class="text-center py-12">
                        <span class="material-symbols-outlined text-5xl text-outline mb-4">receipt_long</span>
                        <p class="text-secondary">Bạn chưa có đơn hàng nào.</p>
                        <a href="sanpham.jsp" class="inline-block mt-4 px-6 py-2 bg-primary text-white text-sm font-label-sm tracking-wider hover:bg-on-surface-variant transition-colors rounded-lg">
                            Bắt đầu mua sắm
                        </a>
                    </div>
                <% } else { %>
                    <div class="overflow-x-auto">
                        <table class="w-full text-sm">
                            <thead>
                                <tr class="border-b border-outline-variant/30">
                                    <th class="text-left py-3 px-4 font-label-sm text-[10px] tracking-wider text-secondary uppercase">Mã đơn</th>
                                    <th class="text-left py-3 px-4 font-label-sm text-[10px] tracking-wider text-secondary uppercase">Ngày đặt</th>
                                    <th class="text-left py-3 px-4 font-label-sm text-[10px] tracking-wider text-secondary uppercase">Tổng tiền</th>
                                    <th class="text-left py-3 px-4 font-label-sm text-[10px] tracking-wider text-secondary uppercase">Trạng thái</th>
                                    <th class="text-left py-3 px-4 font-label-sm text-[10px] tracking-wider text-secondary uppercase">Thao tác</th>
                                </tr>
                            </thead>
                            <tbody>
                                <% for (Map<String, Object> order : orders) {
                                    String trangThai = (String) order.get("trangthai");
                                    String statusClass = "";
                                    if ("Chờ xử lý".equals(trangThai)) statusClass = "order-status-cho";
                                    else if ("Đang giao".equals(trangThai)) statusClass = "order-status-dang-giao";
                                    else if ("Đã giao".equals(trangThai)) statusClass = "order-status-da-giao";
                                    else if ("Đã hủy".equals(trangThai)) statusClass = "order-status-da-huy";
                                    
                                    // Chỉ cho phép hủy khi đơn ở trạng thái "Chờ xử lý"
                                    boolean canCancel = "Chờ xử lý".equals(trangThai);
                                %>
                                <tr class="border-b border-outline-variant/20 hover:bg-surface transition-colors">
                                    <td class="py-3 px-4 font-medium">#<%= order.get("id") %></td>
                                    <td class="py-3 px-4 text-secondary"><%= order.get("ngay") != null ? order.get("ngay").toString().substring(0, 16) : "" %></td>
                                    <td class="py-3 px-4 font-semibold text-primary"><%= formatter.format(order.get("tongtien")) %>đ</td>
                                    <td class="py-3 px-4">
                                        <span class="order-status <%= statusClass %>"><%= trangThai %></span>
                                    </td>
                                    <td class="py-3 px-4">
                                        <div class="flex items-center gap-2">
                                            <a href="chitietdonhang_user.jsp?id=<%= order.get("id") %>" 
                                               class="text-primary hover:underline text-sm">Xem</a>
                                            <% if (canCancel) { %>
                                                <button onclick="confirmCancel(<%= order.get("id") %>)" 
                                                        class="btn-cancel-order">
                                                    Hủy đơn
                                                </button>
                                            <% } %>
                                        </div>
                                    </td>
                                </tr>
                                <% } %>
                            </tbody>
                        </table>
                    </div>
                <% } %>
            </div>
        </div>
    </main>

    <jsp:include page="footer.jsp" />

    <script>
        function switchTab(tab) {
            document.querySelectorAll('.tab-content').forEach(el => {
                el.classList.remove('active');
            });
            document.querySelectorAll('.tab-btn').forEach(el => {
                el.classList.remove('active');
            });
            
            document.getElementById('tab-' + tab).classList.add('active');
            document.querySelectorAll('.tab-btn').forEach(el => {
                if (el.textContent.trim().toLowerCase().includes(tab === 'info' ? 'thông tin' : 'đơn hàng')) {
                    el.classList.add('active');
                }
            });
        }
        
        function confirmCancel(orderId) {
            if (confirm('Bạn có chắc chắn muốn hủy đơn hàng #' + orderId + '?\n\nSau khi hủy, số lượng sản phẩm sẽ được hoàn lại vào kho.')) {
                window.location.href = 'huy_donhang.jsp?id=' + orderId;
            }
        }
    </script>
</body>
</html>