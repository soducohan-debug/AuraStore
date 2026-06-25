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
import java.util.LinkedHashMap;
import java.util.List;
import java.util.Map;
import model.sanpham;
import model.Size;

@WebServlet("/admin/sanpham")
public class adminsanphamservlet extends HttpServlet {

    protected void doGet(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {

        List<sanpham> list = new ArrayList<>();
        String keyword = request.getParameter("keyword");
        String danhmucFilter = request.getParameter("danhmuc");

        try (Connection conn = dbconnect.getConnection()) {
            String sql = "SELECT sp.*, dm.ten_danhmuc FROM sanpham sp " +
                         "LEFT JOIN danhmuc dm ON sp.danhmuc_id = dm.id WHERE 1=1";
            
            if (keyword != null && !keyword.trim().isEmpty()) {
                sql += " AND sp.ten LIKE ?";
            }
            if (danhmucFilter != null && !danhmucFilter.isEmpty()) {
                sql += " AND sp.danhmuc_id = ?";
            }
            
            sql += " ORDER BY sp.id DESC";
            
            try (PreparedStatement ps = conn.prepareStatement(sql)) {
                int index = 1;
                if (keyword != null && !keyword.trim().isEmpty()) {
                    ps.setString(index++, "%" + keyword.trim() + "%");
                }
                if (danhmucFilter != null && !danhmucFilter.isEmpty()) {
                    ps.setInt(index++, Integer.parseInt(danhmucFilter));
                }
                
                try (ResultSet rs = ps.executeQuery()) {
                    while (rs.next()) {
                        String tenDanhMuc = rs.getString("ten_danhmuc");
                        if (tenDanhMuc == null) tenDanhMuc = "Chưa phân loại";
                        
                        sanpham sp = new sanpham(
                            rs.getInt("id"),
                            rs.getString("ten"),
                            rs.getInt("gia"),
                            rs.getString("anh") != null ? rs.getString("anh") : "default.jpg",
                            rs.getString("mota") != null ? rs.getString("mota") : "",
                            tenDanhMuc
                        );
                        
                        sp.setGiaKm(rs.getInt("gia_km") == 0 ? null : rs.getInt("gia_km"));
                        sp.setChatlieu(rs.getString("chatlieu"));
                        sp.setTrongLuong(rs.getDouble("trong_luong"));
                        sp.setBaoHanh(rs.getInt("bao_hanh"));
                        sp.setDanhMucId(rs.getInt("danhmuc_id"));
                        sp.setFeatured(rs.getBoolean("is_featured"));
                        sp.setNew(rs.getBoolean("is_new"));
                        sp.setBestseller(rs.getBoolean("is_bestseller"));
                        sp.setSoluong(rs.getInt("soluong"));
                        
                        // ===== QUAN TRỌNG: LẤY SIZE CHO TỪNG SẢN PHẨM =====
                        Map<Size, Integer> sizes = new LinkedHashMap<>();
                        String sqlSize = "SELECT s.id, s.ten_size, ps.soluong " +
                                         "FROM sanpham_size ps " +
                                         "JOIN size s ON ps.size_id = s.id " +
                                         "WHERE ps.sanpham_id = ? AND ps.soluong > 0";
                        try (PreparedStatement psSize = conn.prepareStatement(sqlSize)) {
                            psSize.setInt(1, sp.getId());
                            try (ResultSet rsSize = psSize.executeQuery()) {
                                while (rsSize.next()) {
                                    Size size = new Size(
                                        rsSize.getInt("id"),
                                        rsSize.getString("ten_size"),
                                        ""
                                    );
                                    sizes.put(size, rsSize.getInt("soluong"));
                                }
                            }
                        }
                        sp.setSizes(sizes);
                        
                        list.add(sp);
                    }
                }
            }
        } catch (Exception e) {
            e.printStackTrace();
            request.setAttribute("error", "Lỗi tải dữ liệu: " + e.getMessage());
        }

        request.setAttribute("list", list);
        request.getRequestDispatcher("/admin/admin_sanpham.jsp").forward(request, response);
    }
}