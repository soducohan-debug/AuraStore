package controller;

import DAO.dbconnect;
import jakarta.servlet.ServletException;
import jakarta.servlet.annotation.WebServlet;
import jakarta.servlet.http.HttpServlet;
import jakarta.servlet.http.HttpServletRequest;
import jakarta.servlet.http.HttpServletResponse;
import java.io.IOException;
import java.io.PrintWriter;
import java.sql.Connection;
import java.sql.PreparedStatement;
import java.sql.ResultSet;

@WebServlet("/admin/get_sizes")
public class GetSizesServlet extends HttpServlet {
    
    @Override
    protected void doGet(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {
        
        response.setContentType("application/json");
        response.setCharacterEncoding("UTF-8");
        
        String productId = request.getParameter("product_id");
        StringBuilder json = new StringBuilder();
        json.append("[");
        
        try (Connection conn = dbconnect.getConnection()) {
            String sql = "SELECT size_id, soluong FROM sanpham_size WHERE sanpham_id = ?";
            PreparedStatement ps = conn.prepareStatement(sql);
            ps.setInt(1, Integer.parseInt(productId));
            ResultSet rs = ps.executeQuery();
            
            boolean first = true;
            while (rs.next()) {
                if (!first) {
                    json.append(",");
                }
                json.append("{");
                json.append("\"size_id\":").append(rs.getInt("size_id")).append(",");
                json.append("\"soluong\":").append(rs.getInt("soluong"));
                json.append("}");
                first = false;
            }
            rs.close();
            ps.close();
            
        } catch (Exception e) {
            e.printStackTrace();
        }
        
        json.append("]");
        
        PrintWriter out = response.getWriter();
        out.print(json.toString());
        out.flush();
    }
}