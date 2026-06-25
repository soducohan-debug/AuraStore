<%-- 
    Document   : xuat_hoadon
    Created on : Jun 25, 2026
    Author     : Ma
    Description: 
--%>
<%@ page contentType="text/html;charset=UTF-8" %>
<%@ page import="java.sql.*, DAO.dbconnect, java.text.NumberFormat, java.util.Locale" %>

<%
    NumberFormat formatter = NumberFormat.getNumberInstance(new Locale("vi", "VN"));
    String id = request.getParameter("id");
    if (id == null || !id.matches("\\d+")) {
        response.sendRedirect("admin_donhang.jsp");
        return;
    }
    
    Connection conn = null;
    try {
        conn = dbconnect.getConnection();
        
        String sql = "SELECT * FROM donhang WHERE id = ?";
        PreparedStatement ps = conn.prepareStatement(sql);
        ps.setInt(1, Integer.parseInt(id));
        ResultSet rs = ps.executeQuery();
        
        if (!rs.next()) {
            response.sendRedirect("admin_donhang.jsp");
            return;
        }
        
        String tenkhach = rs.getString("tenkhach");
        String sdt = rs.getString("sdt");
        String email = rs.getString("email");
        String diachi = rs.getString("diachi");
        int tongtien = rs.getInt("tongtien");
        String trangthai = rs.getString("trangthai");
        Timestamp ngay = rs.getTimestamp("ngay");
        
        String sqlDetail = "SELECT ct.*, sp.ten FROM chitietdonhang ct "
                         + "JOIN sanpham sp ON ct.sanpham_id = sp.id "
                         + "WHERE ct.donhang_id = ?";
        PreparedStatement psDetail = conn.prepareStatement(sqlDetail);
        psDetail.setInt(1, Integer.parseInt(id));
        ResultSet rsDetail = psDetail.executeQuery();
%>
<!DOCTYPE html>
<html>
<head>
    <meta charset="UTF-8">
    <title>Hóa đơn #<%= id %></title>
    <style>
        * { margin: 0; padding: 0; box-sizing: border-box; }
        body {
            font-family: Arial, sans-serif;
            background: #f5f5f5;
            padding: 20px;
        }
        .invoice-wrapper {
            max-width: 800px;
            margin: 0 auto;
            background: white;
            padding: 30px;
            border-radius: 8px;
            box-shadow: 0 2px 10px rgba(0,0,0,0.1);
        }
        .invoice-header {
            text-align: center;
            border-bottom: 3px solid #1a1917;
            padding-bottom: 20px;
            margin-bottom: 20px;
        }
        .invoice-header h1 {
            font-size: 28px;
            letter-spacing: 3px;
            color: #1a1917;
        }
        .invoice-header p {
            color: #888;
            font-size: 14px;
            margin-top: 4px;
        }
        .info-grid {
            display: grid;
            grid-template-columns: 1fr 1fr;
            gap: 20px;
            margin-bottom: 20px;
            padding: 15px;
            background: #f9f9f9;
            border-radius: 6px;
        }
        .info-grid .label { color: #888; font-size: 13px; }
        .info-grid .value { font-weight: 500; }
        table {
            width: 100%;
            border-collapse: collapse;
            margin: 20px 0;
        }
        th {
            background: #1a1917;
            color: white;
            padding: 10px;
            text-align: center;
            font-size: 13px;
            text-transform: uppercase;
        }
        td {
            padding: 8px 10px;
            border-bottom: 1px solid #eee;
            text-align: center;
        }
        td.left { text-align: left; }
        .total {
            text-align: right;
            font-size: 20px;
            font-weight: bold;
            padding-top: 15px;
            border-top: 2px solid #1a1917;
        }
        .invoice-footer {
            text-align: center;
            margin-top: 30px;
            padding-top: 20px;
            border-top: 1px solid #eee;
            color: #888;
            font-size: 13px;
        }
        .btn-group {
            display: flex;
            gap: 10px;
            justify-content: center;
            margin-bottom: 20px;
        }
        .btn {
            padding: 10px 30px;
            border: none;
            border-radius: 6px;
            font-size: 14px;
            cursor: pointer;
            font-weight: 500;
            text-decoration: none;
            display: inline-block;
        }
        .btn-print { background: #1a1917; color: white; }
        .btn-print:hover { background: #333; }
        .btn-back { background: #eee; color: #333; }
        .btn-back:hover { background: #ddd; }
        .status-badge {
            display: inline-block;
            padding: 3px 12px;
            border-radius: 4px;
            font-size: 12px;
            font-weight: 500;
        }
        .status-cho { background: #fff3cd; color: #856404; }
        .status-dang-giao { background: #cce5ff; color: #004085; }
        .status-da-giao { background: #d4edda; color: #155724; }
        .status-da-huy { background: #f8d7da; color: #721c24; }
        @media print {
            .btn-group { display: none; }
            .invoice-wrapper { box-shadow: none; padding: 10px; }
            body { background: white; padding: 0; }
        }
        @media (max-width: 600px) {
            .info-grid { grid-template-columns: 1fr; }
            .invoice-wrapper { padding: 15px; }
        }
    </style>
</head>
<body>
    <div class="invoice-wrapper">
        <!-- Nút chức năng -->
        <div class="btn-group">
            <button class="btn btn-print" onclick="window.print()">In / Lưu PDF</button>
            <a href="chitietdonhang.jsp?id=<%= id %>" class="btn btn-back">← Quay lại</a>
        </div>
        
        <!-- Header -->
        <div class="invoice-header">
            <h1>AURA</h1>
            <p>Trang sức cao cấp</p>
            <p style="font-size:12px;color:#aaa;margin-top:4px;">68 Nguyễn Chí Thanh, Đống Đa, Hà Nội</p>
        </div>
        
        <!-- Thông tin -->
        <div class="info-grid">
            <div>
                <div><span class="label">Hóa đơn số:</span> <span class="value">#<%= id %></span></div>
                <div><span class="label">Ngày lập:</span> <span class="value"><%= ngay != null ? ngay.toString() : "" %></span></div>
                <div><span class="label">Trạng thái:</span> 
                    <span class="status-badge <%= 
                        "Chờ xử lý".equals(trangthai) ? "status-cho" :
                        "Đang giao".equals(trangthai) ? "status-dang-giao" :
                        "Đã giao".equals(trangthai) ? "status-da-giao" :
                        "status-da-huy"
                    %>"><%= trangthai %></span>
                </div>
            </div>
            <div>
                <div><span class="label">Khách hàng:</span> <span class="value"><%= tenkhach %></span></div>
                <div><span class="label">Điện thoại:</span> <span class="value"><%= sdt %></span></div>
                <div><span class="label">Email:</span> <span class="value"><%= email != null && !email.isEmpty() ? email : "---" %></span></div>
                <div><span class="label">Địa chỉ:</span> <span class="value"><%= diachi %></span></div>
            </div>
        </div>
        
        <!-- Sản phẩm -->
        <table>
            <thead>
                <tr>
                    <th style="width:50px;">STT</th>
                    <th style="text-align:left;">Tên sản phẩm</th>
                    <th style="width:80px;">SL</th>
                    <th style="width:120px;">Đơn giá</th>
                    <th style="width:130px;">Thành tiền</th>
                </tr>
            </thead>
            <tbody>
                <% 
                    int stt = 0;
                    int tong = 0;
                    while (rsDetail.next()) {
                        stt++;
                        int gia = rsDetail.getInt("gia");
                        int soluong = rsDetail.getInt("soluong");
                        int thanhTien = gia * soluong;
                        tong += thanhTien;
                %>
                <tr>
                    <td><%= stt %></td>
                    <td class="left"><%= rsDetail.getString("ten") %></td>
                    <td><%= soluong %></td>
                    <td><%= formatter.format(gia) %>đ</td>
                    <td><%= formatter.format(thanhTien) %>đ</td>
                </tr>
                <% } %>
            </tbody>
        </table>
        
        <!-- Tổng cộng -->
        <div class="total">
            Tổng cộng: <%= formatter.format(tong) %>đ
        </div>
        
        <!-- Footer -->
        <div class="invoice-footer">
            <p>Cảm ơn quý khách đã tin tưởng và mua sắm tại AURA!</p>
            <p style="font-size:12px;margin-top:4px;">Hotline: 1900 1234 | Email: aurastore@gmail.com</p>
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