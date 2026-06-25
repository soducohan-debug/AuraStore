<%-- 
    Document   : chitietdonhang_user
    Created on : Jun 24, 2026
    Author     : Ma
--%>
<%@page import="java.util.ArrayList"%>
<%@page import="java.util.HashMap"%>
<%@page import="java.util.List"%>
<%@page import="java.util.Map"%>
<%@ page contentType="text/html;charset=UTF-8" %>
<%@ page import="java.sql.*, DAO.dbconnect, java.text.NumberFormat, java.util.Locale" %>

<%
    NumberFormat formatter = NumberFormat.getNumberInstance(new Locale("vi", "VN"));
    String user = (String) session.getAttribute("user");
    if (user == null) {
        session.setAttribute("redirectAfterLogin", "thongtincanhan.jsp");
        response.sendRedirect("login.jsp");
        return;
    }

    String id = request.getParameter("id");
    if (id == null || !id.matches("\\d+")) {
        response.sendRedirect("thongtincanhan.jsp");
        return;
    }

    int orderId = Integer.parseInt(id);
    Connection conn = null;
    PreparedStatement ps = null;
    ResultSet rs = null;

    String tenkhach = "";
    String sdt = "";
    String diachi = "";
    int tongtien = 0;
    String trangthai = "";
    Timestamp ngay = null;

    // Lấy thông tin đơn hàng
    try {
        conn = dbconnect.getConnection();
        String sql = "SELECT * FROM donhang WHERE id = ? AND username = ?";
        ps = conn.prepareStatement(sql);
        ps.setInt(1, orderId);
        ps.setString(2, user);
        rs = ps.executeQuery();
        if (rs.next()) {
            tenkhach = rs.getString("tenkhach");
            sdt = rs.getString("sdt");
            diachi = rs.getString("diachi");
            tongtien = rs.getInt("tongtien");
            trangthai = rs.getString("trangthai");
            ngay = rs.getTimestamp("ngay");
        } else {
            response.sendRedirect("thongtincanhan.jsp");
            return;
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

    // Lấy chi tiết đơn hàng
    List<Map<String, Object>> details = new ArrayList<>();
    try {
        conn = dbconnect.getConnection();
        String sql = "SELECT ct.*, sp.ten, sp.anh FROM chitietdonhang ct "
                + "JOIN sanpham sp ON ct.sanpham_id = sp.id "
                + "WHERE ct.donhang_id = ?";
        ps = conn.prepareStatement(sql);
        ps.setInt(1, orderId);
        rs = ps.executeQuery();
        while (rs.next()) {
            Map<String, Object> item = new HashMap<>();
            item.put("sanpham_id", rs.getInt("sanpham_id"));
            item.put("ten", rs.getString("ten"));
            item.put("anh", rs.getString("anh"));
            item.put("soluong", rs.getInt("soluong"));
            item.put("gia", rs.getInt("gia"));
            details.add(item);
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
%>

<!DOCTYPE html>
<html class="scroll-smooth" lang="vi">
    <head>
        <meta charset="UTF-8">
        <meta name="viewport" content="width=device-width, initial-scale=1.0">
        <title>Chi tiết đơn hàng #<%= orderId%> - AURA</title>
        <script src="https://cdn.tailwindcss.com?plugins=forms,container-queries"></script>
        <link href="https://fonts.googleapis.com/css2?family=Playfair+Display:wght@400;500;600;700&family=Montserrat:wght@300;400;500;600&display=swap" rel="stylesheet">
        <link href="https://fonts.googleapis.com/css2?family=Material+Symbols+Outlined:wght,FILL@100..700,0..1&display=swap" rel="stylesheet">
        <style>
            body {
                font-family: 'Montserrat', sans-serif;
                background: #f9f9f9;
            }
            .card {
                background: #ffffff;
                border-radius: 12px;
                border: 0.5px solid rgba(207,196,197,0.3);
                box-shadow: 0 20px 60px rgba(0,0,0,0.06);
            }
            .order-status {
                padding: 4px 16px;
                border-radius: 20px;
                font-size: 12px;
                font-weight: 500;
            }
            .order-status-cho {
                background: #fff3cd;
                color: #856404;
            }
            .order-status-dang-giao {
                background: #cce5ff;
                color: #004085;
            }
            .order-status-da-giao {
                background: #d4edda;
                color: #155724;
            }
            .order-status-da-huy {
                background: #f8d7da;
                color: #721c24;
            }
        </style>
    </head>
    <body>

        <jsp:include page="header.jsp" />

        <main class="pt-28 pb-16 px-4 md:px-8 max-w-4xl mx-auto">
            <div class="flex items-center gap-3 mb-6">
                <a href="thongtincanhan.jsp" class="text-secondary hover:text-primary transition-colors">
                    <span class="material-symbols-outlined">arrow_back</span>
                </a>
                <h1 class="font-playfair text-2xl font-bold text-primary">Chi tiết đơn hàng #<%= orderId%></h1>
            </div>

            <div class="card p-6 md:p-8">
                <!-- Thông tin đơn hàng -->
                <div class="flex justify-between items-start mb-6">
                    <div>
                        <p class="text-secondary text-sm">Ngày đặt: <span class="text-primary"><%= ngay != null ? ngay.toString().substring(0, 16) : ""%></span></p>
                        <p class="text-secondary text-sm mt-1">Khách hàng: <span class="text-primary"><%= tenkhach%></span></p>
                        <p class="text-secondary text-sm mt-1">SĐT: <span class="text-primary"><%= sdt%></span></p>
                        <p class="text-secondary text-sm mt-1">Địa chỉ: <span class="text-primary"><%= diachi%></span></p>
                    </div>
                    <div>
                        <span class="order-status 
                              <%= "Chờ xử lý".equals(trangthai) ? "order-status-cho" : ""%>
                              <%= "Đang giao".equals(trangthai) ? "order-status-dang-giao" : ""%>
                              <%= "Đã giao".equals(trangthai) ? "order-status-da-giao" : ""%>
                              <%= "Đã hủy".equals(trangthai) ? "order-status-da-huy" : ""%>
                              "><%= trangthai%></span>
                    </div>
                </div>

                <!-- Danh sách sản phẩm -->
                <h2 class="font-playfair text-lg font-bold text-primary mb-4">Sản phẩm</h2>
                <div class="space-y-3">
                    <% for (Map<String, Object> item : details) {
                            String anh = (String) item.get("anh");
                            boolean isLink = (anh != null && (anh.startsWith("http://") || anh.startsWith("https://")));
                            String src = isLink ? anh : "img/" + anh;
                    %>
                    <div class="flex items-center gap-4 p-3 border-b border-outline-variant/20 last:border-0">
                        <div class="w-16 h-16 rounded-lg overflow-hidden bg-surface flex-shrink-0">
                            <img src="<%= src%>" class="w-full h-full object-cover" onerror="this.src='img/default.jpg'">
                        </div>
                        <div class="flex-1">
                            <p class="font-medium"><%= item.get("ten")%></p>
                            <p class="text-secondary text-sm">Số lượng: x<%= item.get("soluong")%></p>
                        </div>
                        <div class="text-right">
                            <p class="font-semibold text-primary"><%= formatter.format(item.get("gia"))%>đ</p>
                            <p class="text-secondary text-sm">Thành tiền: <%= formatter.format((int) item.get("soluong") * (int) item.get("gia"))%>đ</p>
                        </div>
                    </div>
                    <% }%>
                </div>

                <!-- Tổng tiền -->
                <div class="mt-6 pt-4 border-t border-outline-variant/30 flex justify-end">
                    <div class="text-right">
                        <p class="text-secondary text-sm">Tổng cộng</p>
                        <p class="font-playfair text-2xl font-bold text-primary"><%= formatter.format(tongtien)%>đ</p>
                    </div>
                </div>
                <div class="mt-6 flex gap-4">
                    <a href="thongtincanhan.jsp" class="inline-block px-6 py-2 border border-outline-variant text-secondary text-sm font-label-sm tracking-wider hover:border-primary hover:text-primary transition-colors rounded-lg">
                        ← Quay lại
                    </a>

                    <% if ("Chờ xử lý".equals(trangthai)) {%>
                    <button onclick="confirmCancel(<%= orderId%>)" 
                            class="px-6 py-2 bg-error text-black text-sm font-label-sm tracking-wider hover:bg-red-700 transition-colors rounded-lg">
                        Hủy đơn hàng
                    </button>
                    <% }%>
                </div>

                <script>
                    function confirmCancel(orderId) {
                        if (confirm('Bạn có chắc chắn muốn hủy đơn hàng #' + orderId + '?')) {
                            window.location.href = 'huy_donhang.jsp?id=' + orderId;
                        }
                    }
                </script>
                
            </div>
        </main>

        <jsp:include page="footer.jsp" />

    </body>
</html>