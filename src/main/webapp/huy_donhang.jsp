<%-- 
    Document   : huy_donhang
    Created on : Jun 24, 2026
    Author     : Ma
    Description: Xử lý hủy đơn hàng của người dùng
--%>
<%@ page contentType="text/html;charset=UTF-8" %>
<%@ page import="java.sql.*, DAO.dbconnect" %>

<%
    // Kiểm tra đăng nhập
    String user = (String) session.getAttribute("user");
    if (user == null) {
        session.setAttribute("redirectAfterLogin", "thongtincanhan.jsp");
        response.sendRedirect("login.jsp");
        return;
    }
    
    String orderIdStr = request.getParameter("id");
    if (orderIdStr == null || !orderIdStr.matches("\\d+")) {
        response.sendRedirect("thongtincanhan.jsp?error=invalid_order");
        return;
    }
    
    int orderId = Integer.parseInt(orderIdStr);
    String msg = null;
    String error = null;
    
    Connection conn = null;
    PreparedStatement ps = null;
    ResultSet rs = null;
    
    try {
        conn = dbconnect.getConnection();
        conn.setAutoCommit(false);
        
        // 1. Kiểm tra đơn hàng có tồn tại và thuộc về user này không
        String checkSql = "SELECT trangthai FROM donhang WHERE id = ? AND username = ? FOR UPDATE";
        ps = conn.prepareStatement(checkSql);
        ps.setInt(1, orderId);
        ps.setString(2, user);
        rs = ps.executeQuery();
        
        if (!rs.next()) {
            conn.rollback();
            response.sendRedirect("thongtincanhan.jsp?error=not_found");
            return;
        }
        
        String trangThai = rs.getString("trangthai");
        rs.close();
        ps.close();
        
        // 2. Kiểm tra trạng thái có thể hủy không (chỉ hủy khi "Chờ xử lý")
        if (!"Chờ xử lý".equals(trangThai)) {
            conn.rollback();
            response.sendRedirect("thongtincanhan.jsp?error=cannot_cancel");
            return;
        }
        
        // 3. Lấy chi tiết đơn hàng để hoàn lại số lượng vào kho
        String detailSql = "SELECT sanpham_id, size_id, soluong FROM chitietdonhang WHERE donhang_id = ?";
        ps = conn.prepareStatement(detailSql);
        ps.setInt(1, orderId);
        rs = ps.executeQuery();
        
        // Cập nhật lại số lượng kho
        String updateStockSql = "";
        PreparedStatement psUpdate = null;
        
        while (rs.next()) {
            int sanphamId = rs.getInt("sanpham_id");
            int sizeId = rs.getInt("size_id");
            int soluong = rs.getInt("soluong");
            
            if (sizeId > 0) {
                // Sản phẩm có size
                updateStockSql = "UPDATE sanpham_size SET soluong = soluong + ? WHERE sanpham_id = ? AND size_id = ?";
                psUpdate = conn.prepareStatement(updateStockSql);
                psUpdate.setInt(1, soluong);
                psUpdate.setInt(2, sanphamId);
                psUpdate.setInt(3, sizeId);
                psUpdate.executeUpdate();
            } else {
                // Sản phẩm không có size
                updateStockSql = "UPDATE sanpham SET soluong = soluong + ? WHERE id = ?";
                psUpdate = conn.prepareStatement(updateStockSql);
                psUpdate.setInt(1, soluong);
                psUpdate.setInt(2, sanphamId);
                psUpdate.executeUpdate();
            }
            psUpdate.close();
        }
        rs.close();
        ps.close();
        
        // 4. Cập nhật trạng thái đơn hàng thành "Đã hủy"
        String updateSql = "UPDATE donhang SET trangthai = 'Đã hủy' WHERE id = ? AND username = ?";
        ps = conn.prepareStatement(updateSql);
        ps.setInt(1, orderId);
        ps.setString(2, user);
        int result = ps.executeUpdate();
        ps.close();
        
        if (result > 0) {
            conn.commit();
            msg = "Đơn hàng #" + orderId + " đã được hủy thành công!";
            session.setAttribute("success", msg);
        } else {
            conn.rollback();
            error = "Không thể hủy đơn hàng!";
        }
        
    } catch (Exception e) {
        try {
            if (conn != null) conn.rollback();
        } catch (Exception ex) {}
        e.printStackTrace();
        error = "Có lỗi xảy ra: " + e.getMessage();
    } finally {
        if (rs != null) try { rs.close(); } catch(Exception e) {}
        if (ps != null) try { ps.close(); } catch(Exception e) {}
        if (conn != null) try { conn.close(); } catch(Exception e) {}
    }
    
    // Chuyển hướng về trang thông tin cá nhân với thông báo
    if (msg != null) {
        response.sendRedirect("thongtincanhan.jsp?success=" + java.net.URLEncoder.encode(msg, "UTF-8"));
    } else {
        response.sendRedirect("thongtincanhan.jsp?error=" + (error != null ? java.net.URLEncoder.encode(error, "UTF-8") : "unknown_error"));
    }
%>