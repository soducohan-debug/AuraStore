<%-- 
    Document   : giohang
    Created on : Mar 17, 2026
    Author     : Ma
--%>
<%@ page contentType="text/html;charset=UTF-8" %>
<%@ page import="java.util.*, model.giohang, java.text.NumberFormat, java.util.Locale, java.sql.*, DAO.dbconnect" %>

<%
    NumberFormat formatter = NumberFormat.getNumberInstance(new Locale("vi", "VN"));
    List<giohang> cart = (List<giohang>) session.getAttribute("cart");
    int tongTien = 0;
    int tongSoLuong = 0;

    if (cart != null) {
        for (giohang item : cart) {
            tongTien += item.getTongTien();
            tongSoLuong += item.getSoluong();
        }
    }

    int phiShip = (tongTien > 500000) ? 0 : 35000;
    int thanhToan = tongTien + phiShip;
    
    // Lấy thông báo lỗi
    String error = (String) session.getAttribute("error");
    String success = (String) session.getAttribute("success");
    if (error != null) {
        session.removeAttribute("error");
    }
    if (success != null) {
        session.removeAttribute("success");
    }
%>

<!DOCTYPE html>
<html class="scroll-smooth" lang="vi">
    <head>
        <meta charset="UTF-8">
        <meta name="viewport" content="width=device-width, initial-scale=1.0">
        <title>Giỏ hàng - AURA</title>
        <script src="https://cdn.tailwindcss.com?plugins=forms,container-queries"></script>
        <link href="https://fonts.googleapis.com/css2?family=Playfair+Display:wght@400;500;600;700&family=Montserrat:wght@300;400;500;600&display=swap" rel="stylesheet">
        <link href="https://fonts.googleapis.com/css2?family=Material+Symbols+Outlined:wght,FILL@100..700,0..1&display=swap" rel="stylesheet">
        <script>
            tailwind.config = {
                theme: {
                    extend: {
                        colors: {
                            "surface": "#f9f9f9",
                            "on-surface": "#1a1c1c",
                            "on-surface-variant": "#4c4546",
                            "primary": "#000000",
                            "secondary": "#5d5e5f",
                            "outline": "#7e7576",
                            "outline-variant": "#cfc4c5",
                            "surface-container": "#eeeeee",
                            "error": "#ba1a1a",
                        },
                        fontFamily: {
                            "headline-display": ["Playfair Display", "serif"],
                            "headline-md": ["Playfair Display", "serif"],
                            "body-md": ["Montserrat", "sans-serif"],
                            "label-sm": ["Montserrat", "sans-serif"],
                        }
                    }
                }
            }
        </script>
        <style>
            .material-symbols-outlined {
                font-variation-settings: 'FILL' 0, 'wght' 300, 'GRAD' 0, 'opsz' 24;
            }
            .cart-item:hover .remove-btn {
                opacity: 1;
            }
            .remove-btn {
                opacity: 0;
                transition: opacity 0.3s ease;
            }
            .quantity-btn {
                width: 32px;
                height: 32px;
                display: flex;
                align-items: center;
                justify-content: center;
                border: none;
                background: transparent;
                cursor: pointer;
                transition: all 0.2s;
                border-radius: 50%;
                color: #5d5e5f;
            }
            .quantity-btn:hover {
                background: #eeeeee;
                color: #000000;
            }
            .quantity-btn:disabled {
                opacity: 0.3;
                cursor: not-allowed;
            }
            .quantity-input {
                width: 48px;
                text-align: center;
                border: none;
                outline: none;
                font-size: 14px;
                font-weight: 500;
                background: transparent;
            }
            .alert-error {
                background: #f8d7da;
                color: #721c24;
                padding: 12px 16px;
                border-radius: 8px;
                border: 1px solid #f5c6cb;
                margin-bottom: 16px;
                display: flex;
                align-items: center;
                gap: 10px;
            }
            .alert-success {
                background: #d4edda;
                color: #155724;
                padding: 12px 16px;
                border-radius: 8px;
                border: 1px solid #c3e6cb;
                margin-bottom: 16px;
                display: flex;
                align-items: center;
                gap: 10px;
            }
        </style>
    </head>
    <body class="bg-surface text-on-surface font-body-md">

        <jsp:include page="header.jsp" />

        <main class="pt-28 pb-16 px-4 md:px-8 max-w-6xl mx-auto">
            <div class="mb-8">
                <h1 class="font-playfair text-3xl font-bold text-primary">Giỏ hàng</h1>
                <p class="text-secondary text-sm mt-1"><%= tongSoLuong %> sản phẩm</p>
            </div>

            <!-- Thông báo -->
            <% if (error != null) { %>
            <div class="alert-error">
                <span class="material-symbols-outlined text-error">error</span>
                <%= error %>
            </div>
            <% } %>
            
            <% if (success != null) { %>
            <div class="alert-success">
                <span class="material-symbols-outlined text-green-600">check_circle</span>
                <%= success %>
            </div>
            <% } %>

            <div class="grid grid-cols-1 lg:grid-cols-3 gap-8">
                <!-- Cart Items -->
                <div class="lg:col-span-2 space-y-4">
                    <% if (cart == null || cart.isEmpty()) { %>
                    <div class="bg-white rounded-xl p-12 text-center border border-outline-variant/30">
                        <span class="material-symbols-outlined text-6xl text-outline mb-4">shopping_bag</span>
                        <h3 class="text-xl font-medium mb-2">Giỏ hàng trống</h3>
                        <a href="sanpham.jsp" class="inline-block mt-4 px-6 py-2 bg-primary text-white text-sm font-label-sm tracking-wider hover:bg-on-surface-variant transition-colors">
                            Tiếp tục mua sắm
                        </a>
                    </div>
                    <% } else { 
                        // Lấy tồn kho cho từng sản phẩm
                        for (giohang item : cart) {
                            int tonKho = 0;
                            try {
                                Connection conn = dbconnect.getConnection();
                                if (item.getSize() != null && item.getSize().getId() > 0) {
                                    String sql = "SELECT soluong FROM sanpham_size WHERE sanpham_id = ? AND size_id = ?";
                                    PreparedStatement ps = conn.prepareStatement(sql);
                                    ps.setInt(1, item.getSp().getId());
                                    ps.setInt(2, item.getSize().getId());
                                    ResultSet rs = ps.executeQuery();
                                    if (rs.next()) {
                                        tonKho = rs.getInt("soluong");
                                    }
                                    rs.close();
                                    ps.close();
                                } else {
                                    String sql = "SELECT soluong FROM sanpham WHERE id = ?";
                                    PreparedStatement ps = conn.prepareStatement(sql);
                                    ps.setInt(1, item.getSp().getId());
                                    ResultSet rs = ps.executeQuery();
                                    if (rs.next()) {
                                        tonKho = rs.getInt("soluong");
                                    }
                                    rs.close();
                                    ps.close();
                                }
                                conn.close();
                            } catch (Exception e) {
                                e.printStackTrace();
                            }
                    %>
                    <form action="capnhatgiohang" method="post" id="cartForm">
                        <% 
                            // Vòng lặp lại để hiển thị
                            for (giohang item2 : cart) {
                                int thanhTien = item2.getTongTien();
                                String anh = item2.getSp().getAnh();
                                boolean isLink = (anh != null && (anh.startsWith("http://") || anh.startsWith("https://")));
                                String src = isLink ? anh : "img/" + anh;
                                
                                // Lấy tồn kho cho item này
                                int stock = 0;
                                try {
                                    Connection conn = dbconnect.getConnection();
                                    if (item2.getSize() != null && item2.getSize().getId() > 0) {
                                        String sql = "SELECT soluong FROM sanpham_size WHERE sanpham_id = ? AND size_id = ?";
                                        PreparedStatement ps = conn.prepareStatement(sql);
                                        ps.setInt(1, item2.getSp().getId());
                                        ps.setInt(2, item2.getSize().getId());
                                        ResultSet rs = ps.executeQuery();
                                        if (rs.next()) {
                                            stock = rs.getInt("soluong");
                                        }
                                        rs.close();
                                        ps.close();
                                    } else {
                                        String sql = "SELECT soluong FROM sanpham WHERE id = ?";
                                        PreparedStatement ps = conn.prepareStatement(sql);
                                        ps.setInt(1, item2.getSp().getId());
                                        ResultSet rs = ps.executeQuery();
                                        if (rs.next()) {
                                            stock = rs.getInt("soluong");
                                        }
                                        rs.close();
                                        ps.close();
                                    }
                                    conn.close();
                                } catch (Exception e) {
                                    e.printStackTrace();
                                }
                        %>
                        <div class="cart-item bg-white rounded-xl p-4 flex flex-col sm:flex-row gap-4 items-center border border-outline-variant/30">
                            <div class="w-24 h-24 rounded-lg overflow-hidden bg-surface-container flex-shrink-0">
                                <img src="<%= src %>" 
                                     class="w-full h-full object-cover" 
                                     onerror="this.src='img/default.jpg'">
                            </div>
                            <div class="flex-grow">
                                <h3 class="font-medium"><%= item2.getSp().getTen() %></h3>
                                <p class="text-sm text-secondary">
                                    <%= item2.getSp().getTenDanhMuc() %>
                                    <% if (item2.getSize() != null) { %>
                                    • Size: <span class="font-medium"><%= item2.getSize().getTenSize() %></span>
                                    <% } %>
                                </p>
                                <p class="text-primary font-semibold mt-1"><%= formatter.format(item2.getSp().getGiaHienTai()) %>đ</p>
                                <p class="text-xs text-secondary mt-1">Tồn kho: <strong><%= stock %></strong></p>
                            </div>
                            <div class="flex items-center gap-4">
                                <div class="flex items-center border border-outline-variant/50 rounded-full">
                                    <button type="button" onclick="updateQuantity(this, -1, <%= item2.getSp().getId() %>, '<%= item2.getSize() != null ? item2.getSize().getId() : "" %>', <%= stock %>)" 
                                            class="quantity-btn">−</button>
                                    <input type="number" name="soluong_<%= item2.getSp().getId() %><%= item2.getSize() != null ? "_" + item2.getSize().getId() : "" %>" 
                                           value="<%= item2.getSoluong() %>" min="1" max="<%= stock %>"
                                           data-max-stock="<%= stock %>"
                                           class="quantity-input" id="qty_<%= item2.getSp().getId() %><%= item2.getSize() != null ? "_" + item2.getSize().getId() : "" %>"
                                           onchange="updateQuantityInput(this, <%= item2.getSp().getId() %>, '<%= item2.getSize() != null ? item2.getSize().getId() : "" %>', <%= stock %>)">
                                    <button type="button" onclick="updateQuantity(this, 1, <%= item2.getSp().getId() %>, '<%= item2.getSize() != null ? item2.getSize().getId() : "" %>', <%= stock %>)" 
                                            class="quantity-btn" <%= item2.getSoluong() >= stock ? "disabled" : "" %>>+</button>
                                </div>
                                <p class="font-semibold w-24 text-right"><%= formatter.format(thanhTien) %>đ</p>
                                <a href="xoagiohang?id=<%= item2.getSp().getId() %><%= item2.getSize() != null ? "&sizeId=" + item2.getSize().getId() : "" %>" 
                                   onclick="return confirm('Xóa sản phẩm này?')"
                                   class="remove-btn text-secondary hover:text-error transition-colors">
                                    <span class="material-symbols-outlined">delete</span>
                                </a>
                            </div>
                        </div>
                        <% } } %>
                    </form>

                    <div class="flex justify-end mt-4">
                        <button type="submit" form="cartForm" class="px-6 py-2 border border-outline-variant text-secondary text-sm font-label-sm tracking-wider hover:border-primary hover:text-primary transition-colors">
                            Cập nhật giỏ hàng
                        </button>
                    </div>
                    <% } %>
                </div>

                <!-- Order Summary -->
                <div class="lg:col-span-1">
                    <div class="bg-white rounded-xl p-6 sticky top-24 border border-outline-variant/30">
                        <h3 class="font-playfair text-xl font-bold text-primary mb-6">Tổng đơn hàng</h3>
                        <div class="space-y-3 mb-6">
                            <div class="flex justify-between text-sm">
                                <span class="text-secondary">Tạm tính</span>
                                <span><%= formatter.format(tongTien) %>đ</span>
                            </div>
                            <div class="flex justify-between text-sm">
                                <span class="text-secondary">Phí vận chuyển</span>
                                <% if (phiShip == 0) { %>
                                <span class="text-primary">Miễn phí</span>
                                <% } else { %>
                                <span><%= formatter.format(phiShip) %>đ</span>
                                <% } %>
                            </div>
                            <div class="border-t border-outline-variant/30 pt-3 flex justify-between font-semibold text-lg">
                                <span>Tổng cộng</span>
                                <span class="text-primary"><%= formatter.format(thanhToan) %>đ</span>
                            </div>
                        </div>
                        <a href="thongtin.jsp" class="block w-full py-3 bg-primary text-white text-center font-label-sm text-label-sm tracking-widest hover:bg-on-surface-variant transition-colors">
                            Tiến hành thanh toán
                        </a>
                        <a href="sanpham.jsp" class="block w-full py-3 text-center text-secondary text-sm mt-3 hover:text-primary transition-colors">
                            ← Tiếp tục mua sắm
                        </a>
                    </div>
                </div>
            </div>
        </main>

        <jsp:include page="footer.jsp" />

        <script>
            function updateQuantity(btn, delta, productId, sizeId, tonKho) {
                var inputId = 'qty_' + productId + (sizeId ? '_' + sizeId : '');
                var input = document.getElementById(inputId);
                if (!input) return;
                
                var newVal = parseInt(input.value) + delta;
                
                // Kiểm tra giới hạn
                if (newVal < 1) newVal = 1;
                if (newVal > tonKho) {
                    alert('️ Số lượng không được vượt quá tồn kho (' + tonKho + ' sản phẩm)');
                    input.value = tonKho;
                    return;
                }
                
                input.value = newVal;
                
                // Cập nhật trạng thái nút +
                var container = input.parentElement;
                var plusBtn = container.querySelector('button:last-child');
                if (plusBtn) {
                    plusBtn.disabled = (newVal >= tonKho);
                }
                
                document.getElementById('cartForm').submit();
            }
            
            function updateQuantityInput(input, productId, sizeId, tonKho) {
                var val = parseInt(input.value);
                if (isNaN(val) || val < 1) val = 1;
                if (val > tonKho) {
                    alert('Số lượng không được vượt quá tồn kho (' + tonKho + ' sản phẩm)');
                    val = tonKho;
                }
                input.value = val;
                
                var container = input.parentElement;
                var plusBtn = container.querySelector('button:last-child');
                if (plusBtn) {
                    plusBtn.disabled = (val >= tonKho);
                }
            }
        </script>

    </body>
</html>