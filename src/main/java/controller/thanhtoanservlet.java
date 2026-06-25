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
import java.sql.Statement;
import java.util.List;
import model.giohang;

@WebServlet("/thanhtoan")
public class thanhtoanservlet extends HttpServlet {

    @Override
    protected void doPost(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {

        request.setCharacterEncoding("UTF-8");
        
        HttpSession session = request.getSession();
        String user = (String) session.getAttribute("user");

        // Kiểm tra đăng nhập
        if (user == null) {
            session.setAttribute("redirectAfterLogin", "thongtin.jsp");
            response.sendRedirect("login.jsp");
            return;
        }

        // Lấy thông tin từ form
        String tenkhach = request.getParameter("tenkhach");
        String sdt = request.getParameter("sdt");
        String email = request.getParameter("email");
        String diachi = request.getParameter("diachi");
        String ghichu = request.getParameter("ghichu");
        
        // ===== LẤY PHƯƠNG THỨC THANH TOÁN =====
        String paymentMethod = request.getParameter("payment");
        if (paymentMethod == null || paymentMethod.isEmpty()) {
            paymentMethod = "cod";
        }

        System.out.println("=== THANHTOAN DEBUG ===");
        System.out.println("paymentMethod: " + paymentMethod);

        List<giohang> cart = (List<giohang>) session.getAttribute("cart");

        if (cart == null || cart.isEmpty()) {
            response.sendRedirect("giohang.jsp");
            return;
        }

        Connection conn = null;
        try {
            conn = dbconnect.getConnection();
            conn.setAutoCommit(false);

            // Tính tổng tiền
            int tong = 0;
            for (giohang item : cart) {
                tong += item.getTongTien();
            }

            // Kiểm tra tồn kho lần cuối
            String checkSql = "SELECT soluong FROM sanpham_size WHERE sanpham_id = ? AND size_id = ?";
            PreparedStatement psCheck = conn.prepareStatement(checkSql);

            for (giohang item : cart) {
                int sizeId = (item.getSize() != null) ? item.getSize().getId() : 0;
                
                if (sizeId > 0) {
                    psCheck.setInt(1, item.getSp().getId());
                    psCheck.setInt(2, sizeId);
                    ResultSet rsCheck = psCheck.executeQuery();

                    if (rsCheck.next()) {
                        int tonKho = rsCheck.getInt("soluong");
                        if (tonKho < item.getSoluong()) {
                            conn.rollback();
                            session.setAttribute("error", "Sản phẩm \"" + item.getSp().getTen() + "\" không đủ số lượng! Còn " + tonKho + " sản phẩm.");
                            response.sendRedirect("giohang.jsp");
                            return;
                        }
                    }
                    rsCheck.close();
                } else {
                    String sqlCheckSP = "SELECT soluong FROM sanpham WHERE id = ?";
                    PreparedStatement psCheckSP = conn.prepareStatement(sqlCheckSP);
                    psCheckSP.setInt(1, item.getSp().getId());
                    ResultSet rsCheckSP = psCheckSP.executeQuery();
                    if (rsCheckSP.next()) {
                        int tonKho = rsCheckSP.getInt("soluong");
                        if (tonKho < item.getSoluong()) {
                            conn.rollback();
                            session.setAttribute("error", "Sản phẩm \"" + item.getSp().getTen() + "\" không đủ số lượng! Còn " + tonKho + " sản phẩm.");
                            response.sendRedirect("giohang.jsp");
                            return;
                        }
                    }
                    rsCheckSP.close();
                    psCheckSP.close();
                }
            }
            psCheck.close();

            // ===== LƯU ĐƠN HÀNG VỚI CỘT thanh_toan =====
            String sqlDonHang = "INSERT INTO donhang(username, tenkhach, sdt, email, diachi, ghichu, tongtien, trangthai, thanh_toan) "
                              + "VALUES (?, ?, ?, ?, ?, ?, ?, ?, ?)";
            PreparedStatement psOrder = conn.prepareStatement(sqlDonHang, Statement.RETURN_GENERATED_KEYS);
            psOrder.setString(1, user);
            psOrder.setString(2, tenkhach);
            psOrder.setString(3, sdt);
            psOrder.setString(4, email);
            psOrder.setString(5, diachi);
            psOrder.setString(6, ghichu);
            psOrder.setInt(7, tong);
            psOrder.setString(8, "Chờ xử lý");
            psOrder.setString(9, paymentMethod); // Lưu phương thức thanh toán
            psOrder.executeUpdate();

            ResultSet rs = psOrder.getGeneratedKeys();
            int orderId = 0;
            if (rs.next()) {
                orderId = rs.getInt(1);
            }
            rs.close();
            psOrder.close();

            if (orderId == 0) {
                throw new Exception("Không thể tạo đơn hàng");
            }

            // Lưu chi tiết đơn hàng và cập nhật kho
            String sqlChiTiet = "INSERT INTO chitietdonhang(donhang_id, sanpham_id, size_id, soluong, gia) VALUES (?, ?, ?, ?, ?)";
            PreparedStatement psDetail = conn.prepareStatement(sqlChiTiet);

            String sqlUpdateKho = "UPDATE sanpham_size SET soluong = soluong - ? WHERE sanpham_id = ? AND size_id = ?";
            PreparedStatement psUpdate = conn.prepareStatement(sqlUpdateKho);
            
            String sqlUpdateKhoSP = "UPDATE sanpham SET soluong = soluong - ? WHERE id = ?";
            PreparedStatement psUpdateSP = conn.prepareStatement(sqlUpdateKhoSP);

            for (giohang item : cart) {
                int sizeId = (item.getSize() != null) ? item.getSize().getId() : 0;
                
                psDetail.setInt(1, orderId);
                psDetail.setInt(2, item.getSp().getId());
                if (sizeId > 0) {
                    psDetail.setInt(3, sizeId);
                } else {
                    psDetail.setNull(3, java.sql.Types.INTEGER);
                }
                psDetail.setInt(4, item.getSoluong());
                psDetail.setInt(5, item.getSp().getGiaHienTai());
                psDetail.addBatch();

                if (sizeId > 0) {
                    psUpdate.setInt(1, item.getSoluong());
                    psUpdate.setInt(2, item.getSp().getId());
                    psUpdate.setInt(3, sizeId);
                    psUpdate.addBatch();
                } else {
                    psUpdateSP.setInt(1, item.getSoluong());
                    psUpdateSP.setInt(2, item.getSp().getId());
                    psUpdateSP.addBatch();
                }
            }

            psDetail.executeBatch();
            psUpdate.executeBatch();
            psUpdateSP.executeBatch();
            
            psDetail.close();
            psUpdate.close();
            psUpdateSP.close();

            conn.commit();

            // ===== LƯU THÔNG TIN VÀO SESSION =====
            session.setAttribute("orderId", orderId);
            session.setAttribute("orderTotal", tong);
            session.setAttribute("paymentMethod", paymentMethod);
            session.setAttribute("success", "Đặt hàng thành công! Cảm ơn bạn đã mua sắm tại AURA.");

            // Xóa giỏ hàng
            session.removeAttribute("cart");

            response.sendRedirect("thanhcong.jsp");

        } catch (Exception e) {
            try {
                if (conn != null) {
                    conn.rollback();
                }
            } catch (Exception ex) {
                ex.printStackTrace();
            }
            e.printStackTrace();
            session.setAttribute("error", "Có lỗi xảy ra: " + e.getMessage());
            response.sendRedirect("giohang.jsp");

        } finally {
            try {
                if (conn != null) {
                    conn.setAutoCommit(true);
                    conn.close();
                }
            } catch (Exception e) {
                e.printStackTrace();
            }
        }
    }
}