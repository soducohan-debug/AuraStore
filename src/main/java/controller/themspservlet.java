package controller;

import DAO.dbconnect;
import jakarta.servlet.ServletException;
import jakarta.servlet.annotation.MultipartConfig;
import jakarta.servlet.annotation.WebServlet;
import jakarta.servlet.http.HttpServlet;
import jakarta.servlet.http.HttpServletRequest;
import jakarta.servlet.http.HttpServletResponse;
import jakarta.servlet.http.Part;
import java.io.File;
import java.io.IOException;
import java.nio.file.Paths;
import java.sql.Connection;
import java.sql.PreparedStatement;
import java.sql.ResultSet;
import java.sql.Statement;
import java.util.ArrayList;
import java.util.Collection;
import java.util.List;

@WebServlet("/admin/themsp")
@MultipartConfig(maxFileSize = 1024 * 1024 * 5) 
public class themspservlet extends HttpServlet {

    @Override
    protected void doGet(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {
        request.getRequestDispatcher("/admin/themsp.jsp").forward(request, response);
    }

    @Override
    protected void doPost(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {

        try {
            request.setCharacterEncoding("UTF-8");

            // Lấy thông tin sản phẩm
            String ten = request.getParameter("ten");
            int gia = Integer.parseInt(request.getParameter("gia"));
            String giaKmParam = request.getParameter("gia_km");
            Integer giaKm = (giaKmParam != null && !giaKmParam.isEmpty()) ? Integer.parseInt(giaKmParam) : null;
            String mota = request.getParameter("mota");
            String danhmucSlug = request.getParameter("danhmuc");
            String chatlieu = request.getParameter("chatlieu");
            String trongLuongParam = request.getParameter("trong_luong");
            Double trongLuong = (trongLuongParam != null && !trongLuongParam.isEmpty()) ? Double.parseDouble(trongLuongParam) : null;
            String baoHanhParam = request.getParameter("bao_hanh");
            Integer baoHanh = (baoHanhParam != null && !baoHanhParam.isEmpty()) ? Integer.parseInt(baoHanhParam) : 12;
            boolean isFeatured = request.getParameter("is_featured") != null;
            boolean isNew = request.getParameter("is_new") != null;
            
            String soLuongParam = request.getParameter("soluong");
            int soLuong = (soLuongParam != null && !soLuongParam.isEmpty()) ? Integer.parseInt(soLuongParam) : 0;

            // ===== XỬ LÝ ẢNH =====
            String imageSource = request.getParameter("image_source");
            String finalImage = "default.jpg";
            List<String> uploadedImages = new ArrayList<>();
            
            String uploadPath = getServletContext().getRealPath("/img");
            File uploadDir = new File(uploadPath);
            if (!uploadDir.exists()) {
                uploadDir.mkdirs();
            }
            
            System.out.println("=== DEBUG THEMSP ===");
            System.out.println("image_source: " + imageSource);
            
            // Nếu chọn Upload ảnh
            if ("upload".equals(imageSource)) {
                Part filePart = request.getPart("anh");
                if (filePart != null && filePart.getSize() > 0) {
                    String originalFileName = Paths.get(filePart.getSubmittedFileName()).getFileName().toString();
                    finalImage = System.currentTimeMillis() + "_" + originalFileName;
                    filePart.write(uploadPath + File.separator + finalImage);
                    uploadedImages.add(finalImage);
                    System.out.println("Upload file: " + finalImage);
                }
            } 
            // Nếu chọn Link ảnh
            else if ("link".equals(imageSource)) {
                String imageUrl = request.getParameter("anh_url");
                System.out.println("imageUrl: " + imageUrl);
                if (imageUrl != null && !imageUrl.trim().isEmpty()) {
                    finalImage = imageUrl.trim();
                    uploadedImages.add(finalImage);
                    System.out.println("Save link: " + finalImage);
                }
            }
            
            // ===== XỬ LÝ GALLERY =====
            String gallerySource = request.getParameter("gallery_source");
            System.out.println("gallery_source: " + gallerySource);
            
            // Nếu chọn Upload gallery
            if ("upload".equals(gallerySource)) {
                Collection<Part> galleryParts = request.getParts();
                for (Part part : galleryParts) {
                    if (part.getName().equals("anh_gallery") && part.getSize() > 0) {
                        String galleryFileName = Paths.get(part.getSubmittedFileName()).getFileName().toString();
                        String galleryNewName = System.currentTimeMillis() + "_gallery_" + galleryFileName;
                        part.write(uploadPath + File.separator + galleryNewName);
                        uploadedImages.add(galleryNewName);
                        System.out.println("Upload gallery: " + galleryNewName);
                    }
                }
            } 
            // Nếu chọn Link gallery
            else if ("link".equals(gallerySource)) {
                String galleryUrls = request.getParameter("anh_gallery_url");
                System.out.println("galleryUrls: " + galleryUrls);
                if (galleryUrls != null && !galleryUrls.trim().isEmpty()) {
                    String[] urls = galleryUrls.split(",");
                    for (String url : urls) {
                        String trimmed = url.trim();
                        if (!trimmed.isEmpty()) {
                            uploadedImages.add(trimmed);
                            System.out.println("Save gallery link: " + trimmed);
                        }
                    }
                }
            }
            
            // Chuyển danh sách ảnh thành chuỗi phân cách bằng dấu phẩy
            String anhGallery = String.join(",", uploadedImages);
            System.out.println("finalImage: " + finalImage);
            System.out.println("anhGallery: " + anhGallery);
            
            try (Connection conn = dbconnect.getConnection()) {
                // Lấy danhmuc_id từ slug
                int danhmucId = 1;
                String sqlGetDanhMuc = "SELECT id FROM danhmuc WHERE slug = ?";
                try (PreparedStatement psGet = conn.prepareStatement(sqlGetDanhMuc)) {
                    psGet.setString(1, danhmucSlug);
                    try (ResultSet rs = psGet.executeQuery()) {
                        if (rs.next()) {
                            danhmucId = rs.getInt("id");
                        }
                    }
                }

                // Thêm sản phẩm
                String sql = "INSERT INTO sanpham(ten, gia, gia_km, anh, mota, danhmuc_id, chatlieu, trong_luong, bao_hanh, soluong, anh_gallery, is_featured, is_new) "
                        + "VALUES (?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?)";

                try (PreparedStatement ps = conn.prepareStatement(sql, PreparedStatement.RETURN_GENERATED_KEYS)) {
                    ps.setString(1, ten);
                    ps.setInt(2, gia);
                    if (giaKm != null) {
                        ps.setInt(3, giaKm);
                    } else {
                        ps.setNull(3, java.sql.Types.INTEGER);
                    }
                    ps.setString(4, finalImage);
                    ps.setString(5, mota != null ? mota : "");
                    ps.setInt(6, danhmucId);
                    ps.setString(7, chatlieu != null ? chatlieu : "Bạc 925");
                    if (trongLuong != null) {
                        ps.setDouble(8, trongLuong);
                    } else {
                        ps.setNull(8, java.sql.Types.DOUBLE);
                    }
                    ps.setInt(9, baoHanh);
                    ps.setInt(10, soLuong);
                    ps.setString(11, anhGallery);
                    ps.setBoolean(12, isFeatured);
                    ps.setBoolean(13, isNew);

                    ps.executeUpdate();

                    // Lấy id sản phẩm vừa thêm
                    try (ResultSet rsGen = ps.getGeneratedKeys()) {
                        int sanphamId = 0;
                        if (rsGen.next()) {
                            sanphamId = rsGen.getInt(1);
                        }

                        // Thêm size và số lượng
                        if (sanphamId > 0) {
                            String[] sizeIds = request.getParameterValues("size_id");
                            String[] soluongs = request.getParameterValues("soluong_size");

                            if (sizeIds != null && soluongs != null) {
                                String sqlSize = "INSERT INTO sanpham_size(sanpham_id, size_id, soluong) VALUES (?, ?, ?)";
                                try (PreparedStatement psSize = conn.prepareStatement(sqlSize)) {
                                    for (int i = 0; i < sizeIds.length; i++) {
                                        if (sizeIds[i] != null && !sizeIds[i].isEmpty()) {
                                            int sizeId = Integer.parseInt(sizeIds[i]);
                                            int sl = (i < soluongs.length && soluongs[i] != null && !soluongs[i].isEmpty()) 
                                                    ? Integer.parseInt(soluongs[i]) : 0;
                                            if (sl > 0) {
                                                psSize.setInt(1, sanphamId);
                                                psSize.setInt(2, sizeId);
                                                psSize.setInt(3, sl);
                                                psSize.addBatch();
                                            }
                                        }
                                    }
                                    psSize.executeBatch();
                                }
                            }
                        }
                    }
                }
            }

        } catch (Exception e) {
            e.printStackTrace();
            request.setAttribute("error", "Lỗi thêm sản phẩm: " + e.getMessage());
            request.getRequestDispatcher("/admin/themsp.jsp").forward(request, response);
            return;
        }

        response.sendRedirect(request.getContextPath() + "/admin/admin_sanpham.jsp?success=added");
    }
}