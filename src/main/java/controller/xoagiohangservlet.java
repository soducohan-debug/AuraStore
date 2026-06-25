package controller;

import jakarta.servlet.*;
import jakarta.servlet.http.*;
import jakarta.servlet.annotation.WebServlet;
import java.io.IOException;
import java.util.*;
import model.Size;
import model.giohang;

@WebServlet("/xoagiohang")
public class xoagiohangservlet extends HttpServlet {

    @Override
    protected void doGet(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {

        String idParam = request.getParameter("id");
        String sizeIdParam = request.getParameter("sizeId");
        
        if (idParam == null || idParam.trim().isEmpty()) {
            response.sendRedirect("giohang.jsp");
            return;
        }
        
        int id = Integer.parseInt(idParam);
        int sizeId = 0;
        
        if (sizeIdParam != null && !sizeIdParam.trim().isEmpty()) {
            try {
                sizeId = Integer.parseInt(sizeIdParam);
            } catch (NumberFormatException e) {
                // Bỏ qua
            }
        }

        HttpSession session = request.getSession();
        List<giohang> cart = (List<giohang>) session.getAttribute("cart");

        if (cart != null && !cart.isEmpty()) {
            Iterator<giohang> iterator = cart.iterator();
            while (iterator.hasNext()) {
                giohang item = iterator.next();
                
                if (item.getSp().getId() != id) {
                    continue;
                }
                
                // Nếu sizeId = 0 (xóa tất cả sản phẩm cùng id)
                if (sizeId == 0) {
                    iterator.remove();
                } 
                // Nếu có sizeId cụ thể
                else {
                    Size itemSize = item.getSize();
                    if (itemSize != null && itemSize.getId() == sizeId) {
                        iterator.remove();
                    }
                }
            }
        }

        session.setAttribute("cart", cart);
        response.sendRedirect("giohang.jsp");
    }
}