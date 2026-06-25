package controller;

import DAO.dbconnect;
import jakarta.servlet.ServletException;
import jakarta.servlet.annotation.WebServlet;
import jakarta.servlet.http.HttpServlet;
import jakarta.servlet.http.HttpServletRequest;
import jakarta.servlet.http.HttpServletResponse;
import java.io.IOException;
import java.net.URLEncoder;
import java.nio.charset.StandardCharsets;
import java.sql.Connection;
import java.sql.PreparedStatement;
import java.sql.ResultSet;

@WebServlet("/dangky")
public class dangkyservlet extends HttpServlet {

    @Override
    protected void doPost(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {

        request.setCharacterEncoding("UTF-8");
        
        String user = request.getParameter("user");
        String pass = request.getParameter("pass");
        String fullname = request.getParameter("fullname");
        String email = request.getParameter("email");
        String phone = request.getParameter("phone");

        // Kiểm tra dữ liệu đầu vào
        if (user == null || user.trim().isEmpty() || pass == null || pass.trim().isEmpty()) {
            request.setAttribute("error", "Vui lòng nhập tên đăng nhập và mật khẩu!");
            request.getRequestDispatcher("dangky.jsp").forward(request, response);
            return;
        }

        try {
            Connection conn = dbconnect.getConnection();
            
            // Kiểm tra username đã tồn tại chưa
            String checkSql = "SELECT * FROM user WHERE username=?";
            PreparedStatement psCheck = conn.prepareStatement(checkSql);
            psCheck.setString(1, user);
            ResultSet rsCheck = psCheck.executeQuery();

            if (rsCheck.next()) {
                rsCheck.close();
                psCheck.close();
                conn.close();
                request.setAttribute("error", "Tên đăng nhập đã tồn tại!");
                request.getRequestDispatcher("dangky.jsp").forward(request, response);
                return;
            }
            rsCheck.close();
            psCheck.close();

            // Thêm user mới
            String sql = "INSERT INTO user(username, password, fullname, email, phone, role, status) VALUES(?,?,?,?,?,?,?)";
            PreparedStatement ps = conn.prepareStatement(sql);
            ps.setString(1, user);
            ps.setString(2, pass);
            ps.setString(3, fullname != null ? fullname : "");
            ps.setString(4, email != null ? email : "");
            ps.setString(5, phone != null ? phone : "");
            ps.setString(6, "user");
            ps.setString(7, "active");
            
            int result = ps.executeUpdate();
            ps.close();
            conn.close();

            if (result > 0) {
                // ===== MÃ HÓA URL TRƯỚC KHI GỬI =====
                String msg = URLEncoder.encode("", StandardCharsets.UTF_8.toString());
                response.sendRedirect("login.jsp?msg=" + msg);
            } else {
                request.setAttribute("error", "Đăng ký thất bại, vui lòng thử lại!");
                request.getRequestDispatcher("dangky.jsp").forward(request, response);
            }

        } catch (Exception e) {
            e.printStackTrace();
            request.setAttribute("error", "Có lỗi xảy ra: " + e.getMessage());
            request.getRequestDispatcher("dangky.jsp").forward(request, response);
        }
    }
}