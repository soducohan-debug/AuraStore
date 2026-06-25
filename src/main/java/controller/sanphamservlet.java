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
import java.io.IOException;
import java.sql.Connection;
import java.sql.PreparedStatement;
import java.sql.ResultSet;
import java.util.ArrayList;
import java.util.List;
import model.sanpham;

@WebServlet(name = "SanPhamServlet", urlPatterns = {"/sanpham"})
public class sanphamservlet extends HttpServlet {

    protected void processRequest(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {
        response.setContentType("text/html;charset=UTF-8");
        request.setCharacterEncoding("UTF-8");

        String keyword = request.getParameter("keyword");
        String cat = request.getParameter("cat"); // slug của danh mục
        
        List<sanpham> list = new ArrayList<>();

        try (Connection conn = dbconnect.getConnection()) {
            String sql = "SELECT sp.*, dm.ten_danhmuc FROM sanpham sp " +
                         "JOIN danhmuc dm ON sp.danhmuc_id = dm.id WHERE 1=1";
            
            if (keyword != null && !keyword.trim().isEmpty()) {
                sql += " AND sp.ten LIKE ?";
            }
            if (cat != null && !cat.trim().isEmpty()) {
                sql += " AND dm.slug = ?";
            }
            
            sql += " ORDER BY sp.id DESC";
            
            PreparedStatement ps = conn.prepareStatement(sql);
            int index = 1;
            
            if (keyword != null && !keyword.trim().isEmpty()) {
                ps.setString(index++, "%" + keyword + "%");
            }
            if (cat != null && !cat.trim().isEmpty()) {
                ps.setString(index++, cat);
            }
            
            ResultSet rs = ps.executeQuery();
            
            while (rs.next()) {
                sanpham sp = new sanpham(
                    rs.getInt("id"),
                    rs.getString("ten"),
                    rs.getInt("gia"),
                    rs.getString("anh"),
                    rs.getString("mota"),
                    rs.getString("ten_danhmuc")
                );
                sp.setGiaKm(rs.getInt("gia_km") == 0 ? null : rs.getInt("gia_km"));
                sp.setChatlieu(rs.getString("chatlieu"));
                sp.setFeatured(rs.getBoolean("is_featured"));
                sp.setNew(rs.getBoolean("is_new"));
                sp.setBestseller(rs.getBoolean("is_bestseller"));
                list.add(sp);
            }
            
            rs.close();
            ps.close();
            
        } catch (Exception e) {
            e.printStackTrace();
        }

        request.setAttribute("listSP", list);
        request.getRequestDispatcher("sanpham.jsp").forward(request, response);
    }

    @Override
    protected void doGet(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {
        processRequest(request, response);  
    }

    @Override
    protected void doPost(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {
        processRequest(request, response); 
    }
}