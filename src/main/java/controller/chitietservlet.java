package controller;

import DAO.dbconnect;
import jakarta.servlet.*;
import jakarta.servlet.http.*;
import jakarta.servlet.annotation.WebServlet;
import java.io.IOException;
import java.sql.*;
import java.util.*;
import model.sanpham;
import model.Size;

@WebServlet("/chitiet")
public class chitietservlet extends HttpServlet {

    @Override
    protected void doGet(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {

        String idParam = request.getParameter("id");
        if (idParam == null || idParam.trim().isEmpty()) {
            response.sendRedirect("sanpham.jsp");
            return;
        }

        int id = Integer.parseInt(idParam);
        sanpham sp = null;

        try (Connection conn = dbconnect.getConnection()) {
            // 1. Lấy thông tin sản phẩm
            String sql = "SELECT sp.*, dm.ten_danhmuc FROM sanpham sp " +
                         "JOIN danhmuc dm ON sp.danhmuc_id = dm.id " +
                         "WHERE sp.id = ?";
            try (PreparedStatement ps = conn.prepareStatement(sql)) {
                ps.setInt(1, id);
                try (ResultSet rs = ps.executeQuery()) {
                    if (rs.next()) {
                        sp = new sanpham(
                            rs.getInt("id"),
                            rs.getString("ten"),
                            rs.getInt("gia"),
                            rs.getString("anh"),
                            rs.getString("mota"),
                            rs.getString("ten_danhmuc")
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
                        
                        // ===== LẤY GALLERY ẢNH TỪ CỘT anh_gallery =====
                        String anhGallery = rs.getString("anh_gallery");
                        System.out.println("Gallery string: " + anhGallery); // Debug
                        
                        if (anhGallery != null && !anhGallery.isEmpty()) {
                            String[] images = anhGallery.split(",");
                            for (String img : images) {
                                if (img != null && !img.trim().isEmpty()) {
                                    sp.addAnh(img.trim());
                                    System.out.println("Added gallery image: " + img.trim()); // Debug
                                }
                            }
                        }
                        
                        // Nếu không có gallery, thêm ảnh chính vào gallery
                        if (sp.getAnhGallery().isEmpty() && sp.getAnh() != null && !sp.getAnh().isEmpty()) {
                            sp.addAnh(sp.getAnh());
                        }
                    }
                }
            }

            // 2. Lấy danh sách size và số lượng tồn kho
            if (sp != null) {
                Map<Size, Integer> sizes = new LinkedHashMap<>();
                String sqlSize = "SELECT s.id, s.ten_size, s.mo_ta, s.loai, ps.soluong " +
                                 "FROM sanpham_size ps " +
                                 "JOIN size s ON ps.size_id = s.id " +
                                 "WHERE ps.sanpham_id = ? AND ps.soluong > 0 " +
                                 "ORDER BY s.id ASC";
                try (PreparedStatement psSize = conn.prepareStatement(sqlSize)) {
                    psSize.setInt(1, sp.getId());
                    try (ResultSet rsSize = psSize.executeQuery()) {
                        while (rsSize.next()) {
                            Size size = new Size(
                                rsSize.getInt("id"),
                                rsSize.getString("ten_size"),
                                rsSize.getString("mo_ta"),
                                rsSize.getString("loai")
                            );
                            sizes.put(size, rsSize.getInt("soluong"));
                        }
                    }
                }
                sp.setSizes(sizes);
            }

        } catch (Exception e) {
            e.printStackTrace();
            request.setAttribute("error", "Có lỗi xảy ra: " + e.getMessage());
        }

        request.setAttribute("sp", sp);
        request.getRequestDispatcher("chitietsanpham.jsp").forward(request, response);
    }
}