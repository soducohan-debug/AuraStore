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
import java.util.*;
import model.giohang;

@WebServlet("/capnhatgiohang")
public class capnhatgiohangservlet extends HttpServlet {

    @Override
    protected void doPost(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {

        HttpSession session = request.getSession();
        List<giohang> cart = (List<giohang>) session.getAttribute("cart");

        if (cart != null && !cart.isEmpty()) {
            try (Connection conn = dbconnect.getConnection()) {
                for (giohang item : cart) {
                    // ===== TẠO KEY LẤY SỐ LƯỢNG =====
                    String paramName = "soluong_" + item.getSp().getId();
                    if (item.getSize() != null && item.getSize().getId() > 0) {
                        paramName += "_" + item.getSize().getId();
                    }
                    // Không thêm gì nếu không có size
                    
                    System.out.println("Param name: " + paramName); // Debug
                    
                    String param = request.getParameter(paramName);
                    System.out.println("Param value: " + param); // Debug
                    
                    if (param != null && !param.isEmpty()) {
                        try {
                            int newSoluong = Integer.parseInt(param);
                            
                            // ===== KIỂM TRA TỒN KHO =====
                            int tonKho = 0;
                            if (item.getSize() != null && item.getSize().getId() > 0) {
                                // Kiểm tra tồn kho theo size
                                String sqlKho = "SELECT soluong FROM sanpham_size WHERE sanpham_id = ? AND size_id = ?";
                                PreparedStatement psKho = conn.prepareStatement(sqlKho);
                                psKho.setInt(1, item.getSp().getId());
                                psKho.setInt(2, item.getSize().getId());
                                ResultSet rsKho = psKho.executeQuery();
                                if (rsKho.next()) {
                                    tonKho = rsKho.getInt("soluong");
                                }
                                rsKho.close();
                                psKho.close();
                            } else {
                                // Kiểm tra tồn kho từ cột soluong trong bảng sanpham
                                String sqlKho = "SELECT soluong FROM sanpham WHERE id = ?";
                                PreparedStatement psKho = conn.prepareStatement(sqlKho);
                                psKho.setInt(1, item.getSp().getId());
                                ResultSet rsKho = psKho.executeQuery();
                                if (rsKho.next()) {
                                    tonKho = rsKho.getInt("soluong");
                                }
                                rsKho.close();
                                psKho.close();
                            }
                            
                            System.out.println("Ton kho: " + tonKho); // Debug
                            
                            // ===== NẾU SỐ LƯỢNG > TỒN KHO =====
                            if (newSoluong > tonKho) {
                                newSoluong = tonKho;
                                session.setAttribute("error", "Số lượng vượt quá tồn kho! Còn " + tonKho + " sản phẩm.");
                            }
                            
                            if (newSoluong > 0) {
                                item.setSoluong(newSoluong);
                            } else {
                                // Nếu số lượng = 0, đánh dấu để xóa
                                item.setSoluong(0);
                            }
                        } catch (NumberFormatException e) {
                            // Bỏ qua nếu không phải số
                        }
                    }
                }
                
                // Xóa các sản phẩm có số lượng = 0
                cart.removeIf(item -> item.getSoluong() <= 0);
                
                session.setAttribute("cart", cart);
                
            } catch (Exception e) {
                e.printStackTrace();
                session.setAttribute("error", "Lỗi cập nhật giỏ hàng: " + e.getMessage());
            }
        }

        response.sendRedirect("giohang.jsp");
    }
}