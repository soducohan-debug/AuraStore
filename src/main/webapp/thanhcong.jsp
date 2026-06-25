<%-- 
    Document   : thanhcong
    Created on : Mar 25, 2026
    Author     : Ma
--%>
<%@ page contentType="text/html;charset=UTF-8" %>
<%@ page import="java.sql.*, DAO.dbconnect, java.text.NumberFormat, java.util.Locale" %>

<%
    NumberFormat formatter = NumberFormat.getNumberInstance(new Locale("vi", "VN"));
    String msg = (String) session.getAttribute("success");
    if (msg == null) {
        msg = "Đặt hàng thành công! Cảm ơn bạn đã mua sắm tại AURA.";
    }
    session.removeAttribute("success");
    
    int orderId = 0;
    int orderTotal = 0;
    try {
        orderId = (int) session.getAttribute("orderId");
        orderTotal = (int) session.getAttribute("orderTotal");
    } catch (Exception e) {
        // Nếu không có orderId, tạo mã ngẫu nhiên
        orderId = (int) (System.currentTimeMillis() % 1000000);
    }
    session.removeAttribute("orderId");
    session.removeAttribute("orderTotal");
    
    // Tạo mã đơn hàng dạng chuỗi
    String orderCode = "AURA" + String.format("%06d", orderId);
    
    // Lấy thông tin thanh toán từ session
    String paymentMethod = (String) session.getAttribute("paymentMethod");
    if (paymentMethod == null) paymentMethod = "cod";
    session.removeAttribute("paymentMethod");
%>

<!DOCTYPE html>
<html class="scroll-smooth" lang="vi">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>Đặt hàng thành công - AURA</title>
    <script src="https://cdn.tailwindcss.com?plugins=forms,container-queries"></script>
    <link href="https://fonts.googleapis.com/css2?family=Playfair+Display:wght@400;500;600;700&family=Montserrat:wght@300;400;500;600&display=swap" rel="stylesheet">
    <link href="https://fonts.googleapis.com/css2?family=Material+Symbols+Outlined:wght,FILL@100..700,0..1&display=swap" rel="stylesheet">
    <style>
        body { font-family: 'Montserrat', sans-serif; background: #f9f9f9; }
        .success-icon {
            width: 80px; height: 80px;
            border-radius: 50%;
            background: #000000;
            color: #ffffff;
            display: flex;
            align-items: center;
            justify-content: center;
            font-size: 40px;
            margin: 0 auto 24px;
        }
        .qr-container {
            background: white;
            padding: 20px;
            border-radius: 12px;
            display: inline-block;
            box-shadow: 0 4px 12px rgba(0,0,0,0.06);
            margin: 10px 0;
        }
        .qr-container img {
            max-width: 250px;
            height: auto;
        }
        .order-code {
            font-family: 'Montserrat', monospace;
            font-size: 20px;
            font-weight: 700;
            letter-spacing: 2px;
            color: #000000;
            background: #f3f3f4;
            padding: 8px 20px;
            border-radius: 8px;
            display: inline-block;
        }
        .copy-btn {
            background: none;
            border: none;
            cursor: pointer;
            color: #5d5e5f;
            transition: color 0.3s ease;
        }
        .copy-btn:hover {
            color: #000000;
        }
    </style>
</head>
<body>

<jsp:include page="header.jsp" />

<main class="pt-28 pb-16 px-4 md:px-8 max-w-4xl mx-auto">
    <div class="bg-white rounded-xl p-8 md:p-12 text-center border border-outline-variant/30">
        <!-- Icon thành công -->
        <div class="success-icon">
            <span class="material-symbols-outlined">check</span>
        </div>
        
        <h1 class="font-playfair text-3xl font-bold text-primary mb-4">🎉 Đặt hàng thành công!</h1>
        <p class="text-secondary text-sm mb-6"><%= msg %></p>
        
        <!-- Mã đơn hàng -->
        <div class="mb-6">
            <p class="text-secondary text-sm mb-2">Mã đơn hàng của bạn:</p>
            <div class="flex items-center justify-center gap-3">
                <span class="order-code"><%= orderCode %></span>
                <button class="copy-btn" onclick="copyOrderCode()" title="Sao chép mã đơn hàng">
                    <span class="material-symbols-outlined text-sm">content_copy</span>
                </button>
            </div>
            <p class="text-xs text-secondary mt-2">Vui lòng giữ mã đơn hàng để tra cứu khi cần</p>
        </div>
        
        <!-- Thông tin đơn hàng -->
        <div class="bg-surface rounded-xl p-6 mb-8 text-left">
            <h3 class="font-playfair text-lg font-bold text-primary mb-4">Thông tin đơn hàng</h3>
            <ul class="space-y-2 text-sm">
                <li class="flex justify-between">
                    <span class="text-secondary">Mã đơn hàng:</span>
                    <span class="font-medium"><%= orderCode %></span>
                </li>
                <li class="flex justify-between">
                    <span class="text-secondary">Trạng thái:</span>
                    <span class="text-primary font-medium">✅ Chờ xử lý</span>
                </li>
                <li class="flex justify-between">
                    <span class="text-secondary">Phương thức thanh toán:</span>
                    <span class="font-medium">
                        <% if ("cod".equals(paymentMethod)) { %>
                            Thanh toán khi nhận hàng (COD)
                        <% } else if ("bank".equals(paymentMethod)) { %>
                            Chuyển khoản ngân hàng
                        <% } else if ("momo".equals(paymentMethod)) { %>
                            Ví Momo / ZaloPay
                        <% } else { %>
                            Thanh toán khi nhận hàng (COD)
                        <% } %>
                    </span>
                </li>
                <% if (orderTotal > 0) { %>
                <li class="flex justify-between">
                    <span class="text-secondary">Tổng tiền:</span>
                    <span class="font-bold text-primary"><%= formatter.format(orderTotal) %>đ</span>
                </li>
                <% } %>
            </ul>
        </div>
        
        <!-- ===== QR THANH TOÁN (CHỈ HIỂN THỊ CHO CHUYỂN KHOẢN) ===== -->
        <% if ("bank".equals(paymentMethod) || "momo".equals(paymentMethod)) { %>
        <div class="bg-surface rounded-xl p-6 mb-8 text-center">
            <h3 class="font-playfair text-lg font-bold text-primary mb-4">
                <% if ("bank".equals(paymentMethod)) { %>
                    Thanh toán qua VietQR
                <% } else { %>
                    Thanh toán qua Momo
                <% } %>
            </h3>
            <p class="text-sm text-secondary mb-4">
                Quét mã QR để thanh toán nhanh chóng
            </p>
            
            <div class="qr-container">
                <% if ("bank".equals(paymentMethod)) { %>
                <img src="https://qr.sepay.vn/img?acc=0916513275&bank=MB&amount=<%= orderTotal > 0 ? orderTotal : 0 %>&des=<%= orderCode %>&template=compact&showinfo=true&fullacc=true&holder=MA THI THANH" 
                     alt="QR thanh toán VietQR"
                     onerror="this.onerror=null; this.src='https://placehold.co/250x250/f5faff/000000?text=QR+Thanh+Toan';">
                <% } else { %>
                <img src="https://qr.sepay.vn/img?acc=0916513275&bank=MB&amount=<%= orderTotal > 0 ? orderTotal : 0 %>&des=<%= orderCode %>&template=compact&showinfo=true&fullacc=true&holder=MA THI THANH" 
                     alt="QR thanh toán Momo"
                     onerror="this.onerror=null; this.src='https://placehold.co/250x250/f5faff/000000?text=QR+Thanh+Toan';">
                <% } %>
            </div>
            
            <div class="text-sm text-secondary mt-4">
                <p><strong>Ngân hàng:</strong> MB Bank</p>
                <p><strong>Số tài khoản:</strong> 0688207356</p>
                <p><strong>Chủ tài khoản:</strong> AURA</p>
                <p><strong>Nội dung chuyển:</strong> <code><%= orderCode %></code></p>
            </div>
            
            <div class="mt-4 p-3 bg-yellow-50 rounded-lg text-sm text-yellow-800 border border-yellow-200">
                ⚠️ <strong>Lưu ý:</strong> Vui lòng nhập đúng nội dung chuyển khoản <code><%= orderCode %></code> để chúng tôi xác nhận đơn hàng của bạn.
            </div>
        </div>
        <% } %>
        
        <!-- Thông báo COD -->
        <% if ("cod".equals(paymentMethod)) { %>
        <div class="bg-green-50 rounded-xl p-4 mb-8 text-left border border-green-200">
            <div class="flex items-start gap-3">
                <span class="material-symbols-outlined text-green-600">info</span>
                <div>
                    <p class="text-sm text-green-800 font-medium">Thanh toán khi nhận hàng (COD)</p>
                    <p class="text-sm text-green-700 mt-1">Bạn sẽ thanh toán bằng tiền mặt khi nhận hàng. Vui lòng chuẩn bị sẵn số tiền <strong><%= formatter.format(orderTotal) %>đ</strong>.</p>
                </div>
            </div>
        </div>
        <% } %>
        
        <p class="text-sm text-secondary mb-8">
            Chúng tôi sẽ liên hệ với bạn trong thời gian sớm nhất để xác nhận đơn hàng.<br>
            Mọi thắc mắc vui lòng liên hệ hotline: <strong class="text-primary">1900 1234</strong>
        </p>
        
        <div class="flex flex-col sm:flex-row gap-4 justify-center">
            <a href="sanpham.jsp" class="inline-flex items-center justify-center gap-2 px-6 py-3 bg-primary text-white font-label-sm text-label-sm tracking-widest hover:bg-on-surface-variant transition-colors rounded-lg">
                Tiếp tục mua sắm
            </a>
            <a href="thongtincanhan.jsp" class="inline-flex items-center justify-center gap-2 px-6 py-3 border border-outline-variant text-secondary font-label-sm text-label-sm tracking-widest hover:border-primary hover:text-primary transition-colors rounded-lg">
                Xem đơn hàng
            </a>
            <a href="index.jsp" class="inline-flex items-center justify-center gap-2 px-6 py-3 border border-outline-variant text-secondary font-label-sm text-label-sm tracking-widest hover:border-primary hover:text-primary transition-colors rounded-lg">
                Về trang chủ
            </a>
        </div>
    </div>
    
    <!-- ===== SẢN PHẨM GỢI Ý ===== -->
    <div class="mt-12">
        <h2 class="font-playfair text-2xl font-bold text-center text-primary mb-8">Có thể bạn cũng thích</h2>
        <div class="grid grid-cols-2 md:grid-cols-4 gap-4">
            <%
                Connection conn = null;
                Statement st = null;
                ResultSet rs = null;
                try {
                    conn = dbconnect.getConnection();
                    String sql = "SELECT * FROM sanpham ORDER BY RAND() LIMIT 4";
                    st = conn.createStatement();
                    rs = st.executeQuery(sql);
                    while (rs.next()) {
                        int id = rs.getInt("id");
                        String ten = rs.getString("ten");
                        int gia = rs.getInt("gia");
                        String anh = rs.getString("anh");
                        boolean isLink = (anh != null && (anh.startsWith("http://") || anh.startsWith("https://")));
                        String src = isLink ? anh : "img/" + anh;
            %>
            <a href="chitiet?id=<%= id %>" class="related-item group bg-white rounded-xl overflow-hidden border border-outline-variant/30 hover:shadow-lg transition-all">
                <div class="aspect-square overflow-hidden bg-surface">
                    <img class="w-full h-full object-cover group-hover:scale-110 transition-transform duration-500" 
                         src="<%= src %>" 
                         alt="<%= ten %>"
                         onerror="this.src='img/default.jpg'">
                </div>
                <div class="p-3">
                    <h3 class="font-medium text-sm line-clamp-2 group-hover:text-primary transition-colors"><%= ten %></h3>
                    <p class="text-primary font-semibold text-sm mt-1"><%= formatter.format(gia) %>đ</p>
                </div>
            </a>
            <%
                    }
                } catch (Exception e) {
                    e.printStackTrace();
                } finally {
                    if (rs != null) try { rs.close(); } catch(Exception e) {}
                    if (st != null) try { st.close(); } catch(Exception e) {}
                    if (conn != null) try { conn.close(); } catch(Exception e) {}
                }
            %>
        </div>
    </div>
</main>

<jsp:include page="footer.jsp" />

<script>
    // Sao chép mã đơn hàng
    function copyOrderCode() {
        var orderCode = document.querySelector('.order-code');
        if (orderCode) {
            var text = orderCode.textContent;
            navigator.clipboard.writeText(text).then(function() {
                var btn = document.querySelector('.copy-btn');
                var originalText = btn.innerHTML;
                btn.innerHTML = '<span class="material-symbols-outlined text-sm text-green-600">check</span>';
                setTimeout(function() {
                    btn.innerHTML = originalText;
                }, 2000);
            });
        }
    }
</script>

</body>
</html>