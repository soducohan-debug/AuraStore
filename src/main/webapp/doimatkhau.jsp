<%-- 
    Document   : doimatkhau
    Created on : Jun 24, 2026
    Author     : Ma
--%>
<%@ page contentType="text/html;charset=UTF-8" %>
<%@ page import="java.sql.*, DAO.dbconnect" %>

<%
    String user = (String) session.getAttribute("user");
    if (user == null) {
        session.setAttribute("redirectAfterLogin", "doimatkhau.jsp");
        response.sendRedirect("login.jsp");
        return;
    }
    
    String msg = null;
    String error = null;
    
    if ("update".equals(request.getParameter("action"))) {
        String oldPass = request.getParameter("oldPass");
        String newPass = request.getParameter("newPass");
        String confirmPass = request.getParameter("confirmPass");
        
        if (newPass != null && newPass.equals(confirmPass)) {
            try {
                Connection conn = dbconnect.getConnection();
                // Kiểm tra mật khẩu cũ
                String checkSql = "SELECT password FROM user WHERE username = ?";
                PreparedStatement psCheck = conn.prepareStatement(checkSql);
                psCheck.setString(1, user);
                ResultSet rsCheck = psCheck.executeQuery();
                if (rsCheck.next()) {
                    String currentPass = rsCheck.getString("password");
                    if (currentPass.equals(oldPass)) {
                        // Cập nhật mật khẩu mới
                        String updateSql = "UPDATE user SET password = ? WHERE username = ?";
                        PreparedStatement psUpdate = conn.prepareStatement(updateSql);
                        psUpdate.setString(1, newPass);
                        psUpdate.setString(2, user);
                        int result = psUpdate.executeUpdate();
                        if (result > 0) {
                            msg = "Đổi mật khẩu thành công!";
                        } else {
                            error = "Không thể đổi mật khẩu!";
                        }
                        psUpdate.close();
                    } else {
                        error = "Mật khẩu cũ không đúng!";
                    }
                }
                rsCheck.close();
                psCheck.close();
                conn.close();
            } catch (Exception e) {
                e.printStackTrace();
                error = "Có lỗi xảy ra: " + e.getMessage();
            }
        } else {
            error = "Mật khẩu mới và xác nhận không khớp!";
        }
    }
%>

<!DOCTYPE html>
<html class="scroll-smooth" lang="vi">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>Đổi mật khẩu - AURA</title>
    <script src="https://cdn.tailwindcss.com?plugins=forms,container-queries"></script>
    <link href="https://fonts.googleapis.com/css2?family=Playfair+Display:wght@400;500;600;700&family=Montserrat:wght@300;400;500;600&display=swap" rel="stylesheet">
    <link href="https://fonts.googleapis.com/css2?family=Material+Symbols+Outlined:wght,FILL@100..700,0..1&display=swap" rel="stylesheet">
    <style>
        body { font-family: 'Montserrat', sans-serif; background: #f9f9f9; }
        .card {
            background: #ffffff;
            border-radius: 12px;
            border: 0.5px solid rgba(207,196,197,0.3);
            box-shadow: 0 20px 60px rgba(0,0,0,0.06);
        }
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
        .btn-cancel {
            background: transparent;
            color: #000000;
            padding: 12px 32px;
            border-radius: 8px;
            font-family: 'Montserrat', sans-serif;
            font-size: 12px;
            font-weight: 600;
            letter-spacing: 0.15em;
            text-transform: uppercase;
            border: 1px solid #000000;
            cursor: pointer;
            transition: all 0.3s ease;
            text-decoration: none;
            display: inline-block;
            text-align: center;
        }
        .btn-cancel:hover { background: #000000; color: #ffffff; }
        .alert-success {
            background: #d4edda; color: #155724;
            padding: 12px 16px; border-radius: 8px;
            border: 1px solid #c3e6cb; margin-bottom: 16px;
        }
        .alert-error {
            background: #f8d7da; color: #721c24;
            padding: 12px 16px; border-radius: 8px;
            border: 1px solid #f5c6cb; margin-bottom: 16px;
        }
    </style>
</head>
<body>

    <jsp:include page="header.jsp" />

    <main class="pt-28 pb-16 px-4 md:px-8 max-w-md mx-auto">
        <div class="card p-8">
            <h1 class="font-playfair text-2xl font-bold text-primary text-center mb-2">Đổi mật khẩu</h1>
            <p class="text-secondary text-sm text-center mb-6">Cập nhật mật khẩu để bảo mật tài khoản</p>

            <% if (msg != null) { %>
                <div class="alert-success"><%= msg %></div>
            <% } %>
            <% if (error != null) { %>
                <div class="alert-error"><%= error %></div>
            <% } %>

            <form action="doimatkhau.jsp?action=update" method="post" class="space-y-5">
                <div>
                    <label class="block text-xs font-medium text-secondary uppercase tracking-wider mb-2">Mật khẩu hiện tại</label>
                    <input type="password" name="oldPass" required
                           class="w-full px-4 py-3 bg-surface border-0 border-b border-outline-variant focus:border-primary focus:ring-0 outline-none transition-colors text-sm"
                           placeholder="Nhập mật khẩu hiện tại">
                </div>

                <div>
                    <label class="block text-xs font-medium text-secondary uppercase tracking-wider mb-2">Mật khẩu mới</label>
                    <input type="password" name="newPass" required
                           class="w-full px-4 py-3 bg-surface border-0 border-b border-outline-variant focus:border-primary focus:ring-0 outline-none transition-colors text-sm"
                           placeholder="Nhập mật khẩu mới">
                </div>

                <div>
                    <label class="block text-xs font-medium text-secondary uppercase tracking-wider mb-2">Xác nhận mật khẩu mới</label>
                    <input type="password" name="confirmPass" required
                           class="w-full px-4 py-3 bg-surface border-0 border-b border-outline-variant focus:border-primary focus:ring-0 outline-none transition-colors text-sm"
                           placeholder="Nhập lại mật khẩu mới">
                </div>

                <div class="flex gap-4 pt-2">
                    <button type="submit" class="btn-save flex-1">Đổi mật khẩu</button>
                    <a href="thongtincanhan.jsp" class="btn-cancel flex-1 text-center">Hủy</a>
                </div>
            </form>
        </div>
    </main>

    <jsp:include page="footer.jsp" />

</body>
</html>