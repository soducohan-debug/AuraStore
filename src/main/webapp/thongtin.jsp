<%-- 
    Document   : thongtin
    Created on : Mar 25, 2026
    Author     : Ma
--%>
<%@page import="java.util.List, model.giohang, java.text.NumberFormat, java.util.Locale, java.sql.*, DAO.dbconnect"%>
<%@ page contentType="text/html;charset=UTF-8" %>

<%
    NumberFormat formatter = NumberFormat.getNumberInstance(new Locale("vi", "VN"));
    List<giohang> cart = (List<giohang>) session.getAttribute("cart");

    if (cart == null || cart.isEmpty()) {
        response.sendRedirect("giohang.jsp");
        return;
    }

    String user = (String) session.getAttribute("user");
    if (user == null) {
        session.setAttribute("redirectAfterLogin", "thongtin.jsp");
        response.sendRedirect("login.jsp");
        return;
    }

    // ===== LẤY THÔNG TIN USER TỪ DATABASE =====
    String userFullname = "";
    String userEmail = "";
    String userPhone = "";
    String userAddress = "";

    Connection conn = null;
    PreparedStatement ps = null;
    ResultSet rs = null;
    try {
        conn = dbconnect.getConnection();
        String sql = "SELECT * FROM user WHERE username = ?";
        ps = conn.prepareStatement(sql);
        ps.setString(1, user);
        rs = ps.executeQuery();
        if (rs.next()) {
            userFullname = rs.getString("fullname") != null ? rs.getString("fullname") : "";
            userEmail = rs.getString("email") != null ? rs.getString("email") : "";
            userPhone = rs.getString("phone") != null ? rs.getString("phone") : "";
            userAddress = rs.getString("address") != null ? rs.getString("address") : "";
        }
    } catch (Exception e) {
        e.printStackTrace();
    } finally {
        if (rs != null) try {
            rs.close();
        } catch (Exception e) {
        }
        if (ps != null) try {
            ps.close();
        } catch (Exception e) {
        }
        if (conn != null) try {
            conn.close();
        } catch (Exception e) {
        }
    }

    int tongTien = 0;
    int phiShip = 35000;

    for (giohang item : cart) {
        tongTien += item.getTongTien();
    }

    if (tongTien > 500000) {
        phiShip = 0;
    }

    int thanhToan = tongTien + phiShip;
%>

<!DOCTYPE html>
<html class="scroll-smooth" lang="vi">
    <head>
        <meta charset="UTF-8">
        <meta name="viewport" content="width=device-width, initial-scale=1.0">
        <title>Thanh toán - AURA</title>
        <script src="https://cdn.tailwindcss.com?plugins=forms,container-queries"></script>
        <link href="https://fonts.googleapis.com/css2?family=Playfair+Display:wght@400;500;600;700&family=Montserrat:wght@300;400;500;600&display=swap" rel="stylesheet">
        <link href="https://fonts.googleapis.com/css2?family=Material+Symbols+Outlined:wght,FILL@100..700,0..1&display=swap" rel="stylesheet">
        <style>
            body {
                font-family: 'Montserrat', sans-serif;
                background: #f9f9f9;
            }
            .step-dot {
                width: 32px;
                height: 32px;
                border-radius: 50%;
                display: flex;
                align-items: center;
                justify-content: center;
                font-size: 13px;
                font-weight: 600;
            }
            .step-dot.active {
                background: #000000;
                color: #ffffff;
            }
            .step-dot.done {
                background: #000000;
                color: #ffffff;
            }
            .step-dot.inactive {
                background: #eeeeee;
                color: #999999;
            }
            .step-line {
                flex: 1;
                height: 1px;
                background: #cfc4c5;
            }
            .step-line.done {
                background: #000000;
            }
            .btn-checkout {
                background: #000000;
                color: #ffffff;
                padding: 14px;
                border-radius: 8px;
                font-family: 'Montserrat', sans-serif;
                font-size: 12px;
                font-weight: 600;
                letter-spacing: 0.15em;
                text-transform: uppercase;
                width: 100%;
                border: none;
                cursor: pointer;
                transition: background 0.3s ease;
                margin-top: 24px;
            }
            .btn-checkout:hover {
                background: #333333;
            }
            .payment-option {
                transition: all 0.3s ease;
            }
            .payment-option:hover {
                background: #f3f3f4;
            }
            .payment-option.active {
                border-color: #000000;
                background: #f3f3f4;
            }
        </style>
    </head>
    <body>

        <jsp:include page="header.jsp" />

        <main class="pt-28 pb-16 px-4 md:px-8 max-w-6xl mx-auto">
            <!-- Steps -->
            <div class="flex items-center justify-center gap-4 mb-12 max-w-md mx-auto">
                <div class="step-dot done">1</div>
                <div class="step-line done"></div>
                <div class="step-dot active">2</div>
                <div class="step-line"></div>
                <div class="step-dot inactive">3</div>
            </div>

            <div class="grid grid-cols-1 lg:grid-cols-3 gap-8">
                <!-- Form -->
                <div class="lg:col-span-2 space-y-6">
                    <div class="bg-white rounded-xl p-6 border border-outline-variant/30">
                        <div class="flex justify-between items-center mb-6">
                            <h2 class="font-playfair text-xl font-bold text-primary">Thông tin giao hàng</h2>
                            <a href="thongtincanhan.jsp" class="text-xs text-secondary hover:text-primary transition-colors">
                                Quản lý thông tin
                            </a>
                        </div>

                        <form action="thanhtoan" method="post" id="checkoutForm" class="space-y-4">
                            <!-- Thông tin cá nhân -->
                            <div class="grid grid-cols-1 md:grid-cols-2 gap-4">
                                <div>
                                    <label class="block text-xs font-medium text-secondary uppercase tracking-wider mb-2">Họ và tên *</label>
                                    <input type="text" name="tenkhach" value="<%= userFullname%>" required
                                           class="w-full px-4 py-3 bg-surface border-0 border-b border-outline-variant focus:border-primary focus:ring-0 outline-none transition-colors text-sm">
                                </div>
                                <div>
                                    <label class="block text-xs font-medium text-secondary uppercase tracking-wider mb-2">Số điện thoại *</label>
                                    <input type="tel" name="sdt" value="<%= userPhone%>" required
                                           class="w-full px-4 py-3 bg-surface border-0 border-b border-outline-variant focus:border-primary focus:ring-0 outline-none transition-colors text-sm">
                                </div>
                            </div>

                            <div>
                                <label class="block text-xs font-medium text-secondary uppercase tracking-wider mb-2">Email</label>
                                <input type="email" name="email" value="<%= userEmail%>"
                                       class="w-full px-4 py-3 bg-surface border-0 border-b border-outline-variant focus:border-primary focus:ring-0 outline-none transition-colors text-sm">
                            </div>

                            <div>
                                <label class="block text-xs font-medium text-secondary uppercase tracking-wider mb-2">Địa chỉ *</label>
                                <textarea name="diachi" required rows="3"
                                          class="w-full px-4 py-3 bg-surface border-0 border-b border-outline-variant focus:border-primary focus:ring-0 outline-none transition-colors text-sm resize-none"><%= userAddress%></textarea>
                            </div>

                            <div>
                                <label class="block text-xs font-medium text-secondary uppercase tracking-wider mb-2">Ghi chú</label>
                                <textarea name="ghichu" rows="2"
                                          class="w-full px-4 py-3 bg-surface border-0 border-b border-outline-variant focus:border-primary focus:ring-0 outline-none transition-colors text-sm resize-none"
                                          placeholder="Ghi chú về đơn hàng..."></textarea>
                            </div>

                            <!-- ===== PHƯƠNG THỨC THANH TOÁN ===== -->
                            <div class="bg-white rounded-xl p-6 border border-outline-variant/30">
                                <h2 class="font-playfair text-xl font-bold text-primary mb-4">Phương thức thanh toán</h2>
                                <div class="space-y-3">
                                    <label class="flex items-center gap-3 p-3 border border-outline-variant/30 rounded-lg cursor-pointer hover:bg-surface transition-colors">
                                        <input type="radio" name="payment" value="cod" checked class="accent-primary w-4 h-4">
                                        <span class="font-medium text-sm">Thanh toán khi nhận hàng (COD)</span>
                                    </label>
                                    <label class="flex items-center gap-3 p-3 border border-outline-variant/30 rounded-lg cursor-pointer hover:bg-surface transition-colors">
                                        <input type="radio" name="payment" value="bank" class="accent-primary w-4 h-4">
                                        <span class="font-medium text-sm">Chuyển khoản ngân hàng</span>
                                    </label>
                                    <label class="flex items-center gap-3 p-3 border border-outline-variant/30 rounded-lg cursor-pointer hover:bg-surface transition-colors">
                                        <input type="radio" name="payment" value="momo" class="accent-primary w-4 h-4">
                                        <span class="font-medium text-sm">Ví Momo / ZaloPay</span>
                                    </label>
                                </div>
                            </div>
                        </form>
                    </div>
                </div>

                <!-- Summary -->
                <div class="lg:col-span-1">
                    <div class="bg-white rounded-xl p-6 sticky top-24 border border-outline-variant/30">
                        <h3 class="font-playfair text-xl font-bold text-primary mb-6">Đơn hàng</h3>

                        <div class="space-y-4 max-h-80 overflow-y-auto mb-6">
                            <% for (giohang item : cart) {
                                    String anh = item.getSp().getAnh();
                                    boolean isLink = (anh != null && (anh.startsWith("http://") || anh.startsWith("https://")));
                                    String src = isLink ? anh : "img/" + anh;
                            %>
                            <div class="flex gap-3">
                                <div class="w-16 h-16 rounded-lg overflow-hidden bg-surface flex-shrink-0">
                                    <img src="<%= src%>" class="w-full h-full object-cover" onerror="this.src='img/default.jpg'">
                                </div>
                                <div class="flex-1">
                                    <p class="font-medium text-sm"><%= item.getSp().getTen()%></p>
                                    <p class="text-xs text-secondary">
                                        SL: x<%= item.getSoluong()%>
                                        <% if (item.getSize() != null) {%> • Size: <%= item.getSize().getTenSize()%><% }%>
                                    </p>
                                    <p class="text-primary font-semibold text-sm mt-1"><%= formatter.format(item.getTongTien())%>đ</p>
                                </div>
                            </div>
                            <% }%>
                        </div>

                        <div class="border-t border-outline-variant/30 pt-4 space-y-3">
                            <div class="flex justify-between text-sm">
                                <span class="text-secondary">Tạm tính</span>
                                <span><%= formatter.format(tongTien)%>đ</span>
                            </div>
                            <div class="flex justify-between text-sm">
                                <span class="text-secondary">Phí vận chuyển</span>
                                <% if (phiShip == 0) { %>
                                <span class="text-primary">Miễn phí</span>
                                <% } else {%>
                                <span><%= formatter.format(phiShip)%>đ</span>
                                <% }%>
                            </div>
                            <div class="border-t border-outline-variant/30 pt-3 flex justify-between font-semibold text-lg">
                                <span>Tổng cộng</span>
                                <span class="text-primary"><%= formatter.format(thanhToan)%>đ</span>
                            </div>
                        </div>

                        <button type="submit" form="checkoutForm" class="btn-checkout" id="submitBtn">
                            Xác nhận đặt hàng
                        </button>
                    </div>
                </div>
            </div>
        </main>

        <jsp:include page="footer.jsp" />

        <script>
            // ===== Highlight payment option khi chọn =====
            document.querySelectorAll('input[name="payment"]').forEach(function (radio) {
                radio.addEventListener('change', function () {
                    // Xóa active khỏi tất cả
                    document.querySelectorAll('.payment-option').forEach(function (opt) {
                        opt.classList.remove('active');
                    });
                    // Thêm active cho option được chọn
                    if (this.checked) {
                        this.closest('.payment-option').classList.add('active');
                    }
                });
            });

            // ===== SUBMIT FORM =====
            document.getElementById('checkoutForm').addEventListener('submit', function (e) {
                // Lấy payment được chọn
                var payment = document.querySelector('input[name="payment"]:checked');
                console.log('Selected payment:', payment ? payment.value : 'NONE');

                if (!payment) {
                    e.preventDefault();
                    alert('Vui lòng chọn phương thức thanh toán!');
                    return false;
                }

                // Validate phone
                var phone = this.querySelector('input[name="sdt"]').value;
                if (phone && !/^[0-9]{9,11}$/.test(phone)) {
                    e.preventDefault();
                    alert('Số điện thoại không hợp lệ! Vui lòng nhập 9-11 số.');
                    return false;
                }

                var name = this.querySelector('input[name="tenkhach"]').value;
                if (name && name.trim().length < 2) {
                    e.preventDefault();
                    alert('Vui lòng nhập họ tên đầy đủ!');
                    return false;
                }

                var address = this.querySelector('textarea[name="diachi"]').value;
                if (address && address.trim().length < 5) {
                    e.preventDefault();
                    alert('Vui lòng nhập địa chỉ chi tiết!');
                    return false;
                }

                console.log('Form submitted with payment:', payment.value);
                return true;
            });

            // ===== Mặc định active cho COD =====
            document.querySelector('.payment-option.active')?.classList.remove('active');
            document.querySelector('input[name="payment"][value="cod"]')?.closest('.payment-option')?.classList.add('active');
        </script>

    </body>
</html>