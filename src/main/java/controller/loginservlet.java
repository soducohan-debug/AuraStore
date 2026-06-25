/*
 * Click nbfs://nbhost/SystemFileSystem/Templates/Licenses/license-default.txt to change this license
 * Click nbfs://nbhost/SystemFileSystem/Templates/Classes/Class.java to edit this template
 */
package controller;

import DAO.dbconnect;
import jakarta.servlet.ServletException;
import jakarta.servlet.annotation.WebServlet;
import jakarta.servlet.http.HttpServlet;
import jakarta.servlet.http.HttpServletRequest;
import jakarta.servlet.http.HttpServletResponse;
import jakarta.servlet.http.HttpSession;
import java.io.IOException;
import java.sql.Connection;
import java.sql.PreparedStatement;
import java.sql.ResultSet;

@WebServlet("/login")
public class loginservlet extends HttpServlet {

    @Override
    protected void doPost(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {

        String user = request.getParameter("user");
        String pass = request.getParameter("pass");

        try (Connection conn = dbconnect.getConnection()) {
            String sql = "SELECT * FROM user WHERE username=? AND password=?";
            PreparedStatement ps = conn.prepareStatement(sql);
            ps.setString(1, user);
            ps.setString(2, pass);
            ResultSet rs = ps.executeQuery();

            if (rs.next()) {
                // Kiểm tra tài khoản có bị khóa không
                String status = rs.getString("status");
                if ("blocked".equals(status)) {
                    request.setAttribute("error", "Tài khoản đã bị khóa! Vui lòng liên hệ admin.");
                    request.getRequestDispatcher("login.jsp").forward(request, response);
                    return;
                }
                
                HttpSession session = request.getSession(true);
                session.setAttribute("user", user);
                session.setAttribute("role", rs.getString("role"));
                session.setAttribute("fullname", rs.getString("fullname"));
                
                // Kiểm tra redirect sau login (nếu có)
                String redirect = (String) session.getAttribute("redirectAfterLogin");
                if (redirect != null) {
                    session.removeAttribute("redirectAfterLogin");
                    response.sendRedirect(redirect);
                    return;
                }
                
                if ("admin".equals(rs.getString("role"))) {
                    response.sendRedirect("admin/admin_dashboard.jsp");
                } else {
                    response.sendRedirect("index.jsp");
                }
            } else {
                request.setAttribute("error", "Sai tài khoản hoặc mật khẩu!");
                request.getRequestDispatcher("login.jsp").forward(request, response);
            }
            
            rs.close();
            ps.close();
            
        } catch (Exception e) {
            e.printStackTrace();
            request.setAttribute("error", "Có lỗi xảy ra: " + e.getMessage());
            request.getRequestDispatcher("login.jsp").forward(request, response);
        }
    }
}