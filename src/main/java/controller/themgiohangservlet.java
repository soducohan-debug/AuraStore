package controller;

import DAO.dbconnect;
import jakarta.servlet.*;
import jakarta.servlet.http.*;
import jakarta.servlet.annotation.WebServlet;
import java.io.IOException;
import java.sql.*;
import java.util.*;
import model.giohang;
import model.sanpham;
import model.Size;

@WebServlet("/themgiohang")
public class themgiohangservlet extends HttpServlet {

    @Override
    protected void doGet(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {

        String idParam = request.getParameter("id");
        String sizeIdParam = request.getParameter("sizeId");
        String soLuongParam = request.getParameter("soluong");

        if (idParam == null || idParam.trim().isEmpty()) {
            response.sendRedirect("sanpham.jsp");
            return;
        }

        int id = Integer.parseInt(idParam);
        int soluong = 1;
        int sizeId = 0;

        if (soLuongParam != null && !soLuongParam.isEmpty()) {
            soluong = Integer.parseInt(soLuongParam);
        }
        if (sizeIdParam != null && !sizeIdParam.isEmpty()) {
            sizeId = Integer.parseInt(sizeIdParam);
        }

        HttpSession session = request.getSession();
        List<giohang> cart = (List<giohang>) session.getAttribute("cart");
        if (cart == null) {
            cart = new ArrayList<>();
        }

        try (Connection conn = dbconnect.getConnection()) {
            String sql = "SELECT * FROM sanpham WHERE id = ?";
            try (PreparedStatement ps = conn.prepareStatement(sql)) {
                ps.setInt(1, id);
                try (ResultSet rs = ps.executeQuery()) {
                    if (!rs.next()) {
                        response.sendRedirect("sanpham.jsp");
                        return;
                    }

                    sanpham sp = new sanpham(
                        rs.getInt("id"),
                        rs.getString("ten"),
                        rs.getInt("gia"),
                        rs.getString("anh"),
                        rs.getString("mota"),
                        ""
                    );
                    sp.setGiaKm(rs.getInt("gia_km") == 0 ? null : rs.getInt("gia_km"));

                    Size selectedSize = null;
                    int tonKho = 0;

                    if (sizeId > 0) {
                        // Lấy thông tin size
                        String sqlSize = "SELECT * FROM size WHERE id = ?";
                        try (PreparedStatement psSize = conn.prepareStatement(sqlSize)) {
                            psSize.setInt(1, sizeId);
                            try (ResultSet rsSize = psSize.executeQuery()) {
                                if (rsSize.next()) {
                                    selectedSize = new Size(
                                        rsSize.getInt("id"),
                                        rsSize.getString("ten_size"),
                                        rsSize.getString("mo_ta"),
                                        rsSize.getString("loai")
                                    );
                                }
                            }
                        }

                        // Lấy tồn kho theo size
                        String sqlKho = "SELECT soluong FROM sanpham_size WHERE sanpham_id = ? AND size_id = ?";
                        try (PreparedStatement psKho = conn.prepareStatement(sqlKho)) {
                            psKho.setInt(1, id);
                            psKho.setInt(2, sizeId);
                            try (ResultSet rsKho = psKho.executeQuery()) {
                                if (rsKho.next()) {
                                    tonKho = rsKho.getInt("soluong");
                                }
                            }
                        }
                    } else {
                        // Sản phẩm không có size - lấy tồn kho từ bảng sanpham
                        tonKho = rs.getInt("soluong");
                    }

                    // ===== KIỂM TRA TỒN KHO =====
                    if (tonKho == 0) {
                        session.setAttribute("error", " Sản phẩm đã hết hàng!");
                        response.sendRedirect("chitiet?id=" + id);
                        return;
                    }

                    // Kiểm tra số lượng trong giỏ
                    int currentQtyInCart = 0;
                    for (giohang item : cart) {
                        if (item.getSp().getId() == id) {
                            if ((selectedSize == null && item.getSize() == null) ||
                                (selectedSize != null && item.getSize() != null && 
                                 item.getSize().getId() == selectedSize.getId())) {
                                currentQtyInCart = item.getSoluong();
                                break;
                            }
                        }
                    }

                    // Kiểm tra tổng số lượng
                    int totalQty = currentQtyInCart + soluong;
                    if (totalQty > tonKho) {
                        session.setAttribute("error", " Số lượng vượt quá tồn kho! Còn " + tonKho + " sản phẩm.");
                        response.sendRedirect("chitiet?id=" + id);
                        return;
                    }

                    // Thêm hoặc cập nhật giỏ hàng
                    boolean found = false;
                    for (giohang item : cart) {
                        if (item.getSp().getId() == id) {
                            if ((selectedSize == null && item.getSize() == null) ||
                                (selectedSize != null && item.getSize() != null && 
                                 item.getSize().getId() == selectedSize.getId())) {
                                int newSoluong = item.getSoluong() + soluong;
                                item.setSoluong(newSoluong);
                                found = true;
                                break;
                            }
                        }
                    }

                    if (!found && soluong > 0) {
                        cart.add(new giohang(sp, selectedSize, soluong));
                    }
                    
                    session.setAttribute("success", "Đã thêm sản phẩm vào giỏ hàng!");
                }
            }

        } catch (Exception e) {
            e.printStackTrace();
            session.setAttribute("error", "Có lỗi xảy ra: " + e.getMessage());
        }

        session.setAttribute("cart", cart);
        response.sendRedirect("giohang.jsp");
    }
}