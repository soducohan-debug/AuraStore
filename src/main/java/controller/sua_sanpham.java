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

@WebServlet("/admin/sua_sanpham")
@MultipartConfig(
        maxFileSize = 1024 * 1024 * 10,
        maxRequestSize = 1024 * 1024 * 50
)
public class sua_sanpham extends HttpServlet {

    @Override
    protected void doPost(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {

        request.setCharacterEncoding("UTF-8");

        try {
            // ===== LẤY DỮ LIỆU TỪ FORM =====
            int id = Integer.parseInt(request.getParameter("id"));
            String ten = request.getParameter("ten");
            int gia = Integer.parseInt(request.getParameter("gia"));

            String giaKmStr = request.getParameter("gia_km");
            Integer giaKm = (giaKmStr != null && !giaKmStr.trim().isEmpty())
                    ? Integer.parseInt(giaKmStr) : null;

            int danhmucId = Integer.parseInt(request.getParameter("danhmuc_id"));
            String chatlieu = request.getParameter("chatlieu");

            String trongLuongStr = request.getParameter("trong_luong");
            Double trongLuong = (trongLuongStr != null && !trongLuongStr.trim().isEmpty())
                    ? Double.parseDouble(trongLuongStr) : null;

            String baoHanhStr = request.getParameter("bao_hanh");
            Integer baoHanh = (baoHanhStr != null && !baoHanhStr.trim().isEmpty())
                    ? Integer.parseInt(baoHanhStr) : 12;

            String mota = request.getParameter("mota");
            boolean isFeatured = request.getParameter("is_featured") != null;
            boolean isNew = request.getParameter("is_new") != null;
            boolean isBestseller = request.getParameter("is_bestseller") != null;

            // Kiểm tra sản phẩm có size hay không
            String hasSizeStr = request.getParameter("has_size");
            boolean hasSize = "true".equals(hasSizeStr);

            System.out.println("=== SUA SANPHAM ===");
            System.out.println("ID: " + id);
            System.out.println("Has Size: " + hasSize);

            // ===== XỬ LÝ ẢNH =====
            // ===== XỬ LÝ ẢNH =====
            String oldImage = request.getParameter("old_image");
            String imageSource = request.getParameter("image_source");
            String finalImage = oldImage;

            String uploadPath = getServletContext().getRealPath("/img");
            File uploadDir = new File(uploadPath);
            if (!uploadDir.exists()) {
                uploadDir.mkdirs();
            }

// Nếu chọn Upload ảnh
            if ("upload".equals(imageSource)) {
                Part filePart = request.getPart("anh");
                if (filePart != null && filePart.getSize() > 0) {
                    String originalFileName = Paths.get(filePart.getSubmittedFileName()).getFileName().toString();
                    String extension = "";
                    int dotIndex = originalFileName.lastIndexOf(".");
                    if (dotIndex > 0) {
                        extension = originalFileName.substring(dotIndex);
                    }
                    String fileName = System.currentTimeMillis() + "_" + System.nanoTime() + extension;
                    filePart.write(uploadPath + File.separator + fileName);
                    finalImage = fileName;
                    System.out.println("Upload new image: " + fileName);

                    // Xóa ảnh cũ
                    if (oldImage != null && !oldImage.equals("default.jpg") && !oldImage.isEmpty()) {
                        File oldFile = new File(uploadPath + File.separator + oldImage);
                        if (oldFile.exists()) {
                            oldFile.delete();
                            System.out.println("Deleted old image: " + oldImage);
                        }
                    }
                }
            } // Nếu chọn Link ảnh
            else if ("link".equals(imageSource)) {
                String imageUrl = request.getParameter("anh_url");
                System.out.println("Image URL: " + imageUrl);
                if (imageUrl != null && !imageUrl.trim().isEmpty()) {
                    finalImage = imageUrl.trim();
                    System.out.println("Save link: " + finalImage);
                }
            }
            // ===== XỬ LÝ GALLERY =====
            String gallerySource = request.getParameter("gallery_source");
            String oldGallery = request.getParameter("old_gallery");
            String finalGallery = oldGallery;

// Nếu chọn Upload gallery
            if ("upload".equals(gallerySource)) {
                StringBuilder galleryBuilder = new StringBuilder();
                boolean first = true;

                for (Part part : request.getParts()) {
                    if (part.getName().equals("anh_gallery") && part.getSize() > 0) {
                        String originalFileName = Paths.get(part.getSubmittedFileName()).getFileName().toString();
                        String extension = "";
                        int dotIndex = originalFileName.lastIndexOf(".");
                        if (dotIndex > 0) {
                            extension = originalFileName.substring(dotIndex);
                        }
                        String fileName = System.currentTimeMillis() + "_gallery_" + System.nanoTime() + extension;
                        part.write(uploadPath + File.separator + fileName);

                        if (!first) {
                            galleryBuilder.append(",");
                        }
                        galleryBuilder.append(fileName);
                        first = false;
                        System.out.println("Upload gallery: " + fileName);
                    }
                }

                if (galleryBuilder.length() > 0) {
                    finalGallery = galleryBuilder.toString();
                }
            } // Nếu chọn Link gallery
            else if ("link".equals(gallerySource)) {
                String galleryUrls = request.getParameter("anh_gallery_url");
                System.out.println("Gallery URLs: " + galleryUrls);
                if (galleryUrls != null && !galleryUrls.trim().isEmpty()) {
                    String[] urls = galleryUrls.split(",");
                    StringBuilder validUrls = new StringBuilder();
                    boolean first = true;
                    for (String url : urls) {
                        String trimmed = url.trim();
                        if (!trimmed.isEmpty()) {
                            if (!first) {
                                validUrls.append(",");
                            }
                            validUrls.append(trimmed);
                            first = false;
                        }
                    }
                    finalGallery = validUrls.toString();
                    System.out.println("Save gallery links: " + finalGallery);
                }
            }

            // ===== CẬP NHẬT DATABASE =====
            try (Connection conn = dbconnect.getConnection()) {
                conn.setAutoCommit(false);

                // 1. Cập nhật thông tin sản phẩm
                String sql = "UPDATE sanpham SET "
                        + "ten = ?, "
                        + "gia = ?, "
                        + "gia_km = ?, "
                        + "danhmuc_id = ?, "
                        + "chatlieu = ?, "
                        + "trong_luong = ?, "
                        + "bao_hanh = ?, "
                        + "mota = ?, "
                        + "anh = ?, "
                        + "anh_gallery = ?, "
                        + "is_featured = ?, "
                        + "is_new = ?, "
                        + "is_bestseller = ? "
                        + "WHERE id = ?";

                PreparedStatement ps = conn.prepareStatement(sql);
                ps.setString(1, ten);
                ps.setInt(2, gia);
                if (giaKm != null) {
                    ps.setInt(3, giaKm);
                } else {
                    ps.setNull(3, java.sql.Types.INTEGER);
                }
                ps.setInt(4, danhmucId);
                ps.setString(5, chatlieu != null ? chatlieu : "Bạc 925");
                if (trongLuong != null) {
                    ps.setDouble(6, trongLuong);
                } else {
                    ps.setNull(6, java.sql.Types.DOUBLE);
                }
                ps.setInt(7, baoHanh);
                ps.setString(8, mota != null ? mota : "");
                ps.setString(9, finalImage);
                ps.setString(10, finalGallery);
                ps.setBoolean(11, isFeatured);
                ps.setBoolean(12, isNew);
                ps.setBoolean(13, isBestseller);
                ps.setInt(14, id);

                int result = ps.executeUpdate();
                System.out.println("Update product result: " + result);
                ps.close();

                // 2. Xử lý size
                if (hasSize) {
                    // Lấy danh sách size từ form
                    String[] sizeIds = request.getParameterValues("size_id");
                    String[] soluongs = request.getParameterValues("soluong_size");

                    System.out.println("Size IDs: " + (sizeIds != null ? String.join(",", sizeIds) : "null"));
                    System.out.println("Soluongs: " + (soluongs != null ? String.join(",", soluongs) : "null"));

                    // Xóa tất cả size cũ
                    String sqlDelete = "DELETE FROM sanpham_size WHERE sanpham_id = ?";
                    PreparedStatement psDelete = conn.prepareStatement(sqlDelete);
                    psDelete.setInt(1, id);
                    int deleted = psDelete.executeUpdate();
                    System.out.println("Deleted old sizes: " + deleted);
                    psDelete.close();

                    // Thêm size mới
                    if (sizeIds != null && sizeIds.length > 0) {
                        String sqlInsert = "INSERT INTO sanpham_size(sanpham_id, size_id, soluong) VALUES (?, ?, ?)";
                        PreparedStatement psInsert = conn.prepareStatement(sqlInsert);
                        int count = 0;

                        for (int i = 0; i < sizeIds.length; i++) {
                            if (sizeIds[i] != null && !sizeIds[i].trim().isEmpty()) {
                                int sizeId = Integer.parseInt(sizeIds[i].trim());
                                int sl = 0;
                                if (i < soluongs.length && soluongs[i] != null && !soluongs[i].trim().isEmpty()) {
                                    sl = Integer.parseInt(soluongs[i].trim());
                                }
                                // Chỉ thêm nếu số lượng > 0
                                if (sl > 0) {
                                    psInsert.setInt(1, id);
                                    psInsert.setInt(2, sizeId);
                                    psInsert.setInt(3, sl);
                                    psInsert.addBatch();
                                    count++;
                                    System.out.println("Add size: " + sizeId + " - " + sl);
                                }
                            }
                        }
                        if (count > 0) {
                            psInsert.executeBatch();
                            System.out.println("Inserted " + count + " sizes");
                        }
                        psInsert.close();
                    }
                } else {
                    // Sản phẩm không có size - cập nhật số lượng vào bảng sanpham
                    String soLuongStr = request.getParameter("soluong");
                    int soLuong = (soLuongStr != null && !soLuongStr.trim().isEmpty())
                            ? Integer.parseInt(soLuongStr) : 0;

                    String sqlUpdateQty = "UPDATE sanpham SET soluong = ? WHERE id = ?";
                    PreparedStatement psQty = conn.prepareStatement(sqlUpdateQty);
                    psQty.setInt(1, soLuong);
                    psQty.setInt(2, id);
                    psQty.executeUpdate();
                    System.out.println("Update quantity: " + soLuong);
                    psQty.close();
                }

                conn.commit();
                System.out.println("=== UPDATE SUCCESS ===");
                response.sendRedirect(request.getContextPath() + "/admin/admin_sanpham.jsp?success=updated");

            } catch (Exception e) {
                e.printStackTrace();
                response.sendRedirect(request.getContextPath() + "/admin/admin_sanpham.jsp?error=" + e.getMessage());
            }

        } catch (Exception e) {
            e.printStackTrace();
            response.sendRedirect(request.getContextPath() + "/admin/admin_sanpham.jsp?error=" + e.getMessage());
        }
    }
}
