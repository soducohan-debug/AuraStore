<%-- 
    Document   : admin_sanpham
    Created on : Mar 26, 2026
    Author     : Ma
    Description: Quản lý sản phẩm - Aurastore Admin
--%>

<%@page import="java.sql.*, DAO.dbconnect, java.util.*, model.sanpham"%>
<%@ page contentType="text/html;charset=UTF-8" %>
<jsp:include page="sidebar.jsp" />

<%
    // Kiểm tra đăng nhập admin
    String user = (String) session.getAttribute("user");
    String role = (String) session.getAttribute("role");

    if (user == null || !"admin".equals(role)) {
        response.sendRedirect("../login.jsp");
        return;
    }

    String path = request.getContextPath();

    // ===== XỬ LÝ XÓA SẢN PHẨM =====
    String xoaId = request.getParameter("xoa");
    if (xoaId != null && xoaId.matches("\\d+")) {
        try {
            Connection conn = dbconnect.getConnection();
            PreparedStatement psCheck = conn.prepareStatement(
                    "SELECT COUNT(*) FROM chitietdonhang WHERE sanpham_id=?");
            psCheck.setInt(1, Integer.parseInt(xoaId));
            ResultSet rsCheck = psCheck.executeQuery();
            rsCheck.next();
            int count = rsCheck.getInt(1);
            rsCheck.close();
            psCheck.close();

            if (count > 0) {
                response.sendRedirect(path + "/admin/admin_sanpham.jsp?error=in_use");
                conn.close();
                return;
            }

            PreparedStatement ps = conn.prepareStatement("DELETE FROM sanpham WHERE id=?");
            ps.setInt(1, Integer.parseInt(xoaId));
            ps.executeUpdate();
            ps.close();
            conn.close();

            response.sendRedirect(path + "/admin/admin_sanpham.jsp?success=deleted");
            return;
        } catch (Exception e) {
            e.printStackTrace();
            response.sendRedirect(path + "/admin/admin_sanpham.jsp?error=delete_failed");
            return;
        }
    }

    // ===== LẤY DANH SÁCH DANH MỤC =====
    Map<Integer, String> danhMucMap = new LinkedHashMap<>();
    try {
        Connection conn = dbconnect.getConnection();
        Statement st = conn.createStatement();
        ResultSet rs = st.executeQuery("SELECT * FROM danhmuc ORDER BY thu_tu");
        while (rs.next()) {
            danhMucMap.put(rs.getInt("id"), rs.getString("ten_danhmuc"));
        }
        rs.close();
        st.close();
        conn.close();
    } catch (Exception e) {
        e.printStackTrace();
    }

    // ===== LẤY DANH SÁCH SIZE =====
    Map<Integer, String> sizeMap = new LinkedHashMap<>();
    try {
        Connection conn = dbconnect.getConnection();
        Statement st = conn.createStatement();
        ResultSet rs = st.executeQuery("SELECT * FROM size ORDER BY loai, id");
        while (rs.next()) {
            sizeMap.put(rs.getInt("id"), rs.getString("ten_size"));
        }
        rs.close();
        st.close();
        conn.close();
    } catch (Exception e) {
        e.printStackTrace();
    }

    // ===== LẤY DANH SÁCH SẢN PHẨM =====
    List<sanpham> listSP = new ArrayList<>();
    String keyword = request.getParameter("keyword");
    String danhmucFilter = request.getParameter("danhmuc_filter");
    String stockFilter = request.getParameter("stock_filter");
    String sortBy = request.getParameter("sort_by");

    // ===== PHÂN TRANG =====
    int currentPage = 1;
    String pageStr = request.getParameter("page");
    if (pageStr != null && !pageStr.isEmpty()) {
        currentPage = Integer.parseInt(pageStr);
    }
    int recordsPerPage = 10;
    int offset = (currentPage - 1) * recordsPerPage;
    int totalRecords = 0;

    try {
        Connection conn = dbconnect.getConnection();

        // ===== ĐẾM TỔNG SỐ BẢN GHI =====
        String countSql = "SELECT COUNT(*) FROM sanpham sp LEFT JOIN danhmuc dm ON sp.danhmuc_id = dm.id WHERE 1=1";
        if (keyword != null && !keyword.trim().isEmpty()) {
            countSql += " AND sp.ten LIKE ?";
        }
        if (danhmucFilter != null && !danhmucFilter.isEmpty()) {
            countSql += " AND sp.danhmuc_id = ?";
        }

        PreparedStatement psCount = conn.prepareStatement(countSql);
        int idxCount = 1;
        if (keyword != null && !keyword.trim().isEmpty()) {
            psCount.setString(idxCount++, "%" + keyword.trim() + "%");
        }
        if (danhmucFilter != null && !danhmucFilter.isEmpty()) {
            psCount.setInt(idxCount++, Integer.parseInt(danhmucFilter));
        }
        ResultSet rsCount = psCount.executeQuery();
        if (rsCount.next()) {
            totalRecords = rsCount.getInt(1);
        }
        rsCount.close();
        psCount.close();

        // ===== LẤY DANH SÁCH SẢN PHẨM CÓ PHÂN TRANG =====
        String sql = "SELECT sp.*, dm.ten_danhmuc FROM sanpham sp "
                + "LEFT JOIN danhmuc dm ON sp.danhmuc_id = dm.id WHERE 1=1";

        if (keyword != null && !keyword.trim().isEmpty()) {
            sql += " AND sp.ten LIKE ?";
        }
        if (danhmucFilter != null && !danhmucFilter.isEmpty()) {
            sql += " AND sp.danhmuc_id = ?";
        }

        // Sắp xếp
        if (sortBy != null && !sortBy.isEmpty()) {
            if ("price_asc".equals(sortBy)) {
                sql += " ORDER BY sp.gia ASC";
            } else if ("price_desc".equals(sortBy)) {
                sql += " ORDER BY sp.gia DESC";
            } else if ("name_asc".equals(sortBy)) {
                sql += " ORDER BY sp.ten ASC";
            } else {
                sql += " ORDER BY sp.id DESC";
            }
        } else {
            sql += " ORDER BY sp.id DESC";
        }

        sql += " LIMIT ? OFFSET ?";

        PreparedStatement ps = conn.prepareStatement(sql);
        int idx = 1;
        if (keyword != null && !keyword.trim().isEmpty()) {
            ps.setString(idx++, "%" + keyword.trim() + "%");
        }
        if (danhmucFilter != null && !danhmucFilter.isEmpty()) {
            ps.setInt(idx++, Integer.parseInt(danhmucFilter));
        }
        ps.setInt(idx++, recordsPerPage);
        ps.setInt(idx++, offset);

        ResultSet rs = ps.executeQuery();

        while (rs.next()) {
            sanpham sp = new sanpham(
                    rs.getInt("id"),
                    rs.getString("ten"),
                    rs.getInt("gia"),
                    rs.getString("anh") != null ? rs.getString("anh") : "default.jpg",
                    rs.getString("mota") != null ? rs.getString("mota") : "",
                    rs.getString("ten_danhmuc") != null ? rs.getString("ten_danhmuc") : "Chưa phân loại"
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

            // Lấy danh sách ảnh gallery
            String anhGallery = rs.getString("anh_gallery");
            if (anhGallery != null && !anhGallery.isEmpty()) {
                String[] images = anhGallery.split(",");
                for (String img : images) {
                    if (img != null && !img.trim().isEmpty()) {
                        sp.addAnh(img.trim());
                    }
                }
            }

            // Lấy danh sách size và số lượng
            String sqlSize = "SELECT s.id, s.ten_size, ps.soluong FROM sanpham_size ps "
                    + "JOIN size s ON ps.size_id = s.id "
                    + "WHERE ps.sanpham_id = ? AND ps.soluong > 0";
            PreparedStatement psSize = conn.prepareStatement(sqlSize);
            psSize.setInt(1, sp.getId());
            ResultSet rsSize = psSize.executeQuery();
            while (rsSize.next()) {
                sp.getSizes().put(
                        new model.Size(rsSize.getInt("id"), rsSize.getString("ten_size"), ""),
                        rsSize.getInt("soluong")
                );
            }
            rsSize.close();
            psSize.close();

            listSP.add(sp);
        }
        rs.close();
        ps.close();
        conn.close();
    } catch (Exception e) {
        e.printStackTrace();
    }

    // ===== LỌC SẢN PHẨM THEO TRẠNG THÁI KHO =====
    List<sanpham> filteredList = new ArrayList<>();
    if (stockFilter != null && "low".equals(stockFilter)) {
        for (sanpham sp : listSP) {
            int totalQty = sp.getTotalSoluong();
            int qty = sp.getSoluong();
            int stock = (sp.getSizes() != null && !sp.getSizes().isEmpty()) ? totalQty : qty;
            if (stock <= 5 && stock > 0) {
                filteredList.add(sp);
            }
        }
    } else if (stockFilter != null && "empty".equals(stockFilter)) {
        for (sanpham sp : listSP) {
            int totalQty = sp.getTotalSoluong();
            int qty = sp.getSoluong();
            int stock = (sp.getSizes() != null && !sp.getSizes().isEmpty()) ? totalQty : qty;
            if (stock == 0) {
                filteredList.add(sp);
            }
        }
    } else {
        filteredList = listSP;
    }

    // ===== LẤY THÔNG BÁO =====
    String successMsg = request.getParameter("success");
    String errorMsg = request.getParameter("error");

    int totalPages = (int) Math.ceil((double) totalRecords / recordsPerPage);
%>

<!DOCTYPE html>
<html>
    <head>
        <title>Quản lý sản phẩm - Aurastore Admin</title>
        <link href="https://fonts.googleapis.com/css2?family=Be+Vietnam+Pro:wght@400;500;600&display=swap" rel="stylesheet">
        <link href="https://fonts.googleapis.com/css2?family=Material+Symbols+Outlined:wght,FILL@100..700,0..1&display=swap" rel="stylesheet">
        <style>
            * {
                box-sizing: border-box;
                margin: 0;
                padding: 0;
            }
            body {
                font-family: 'Be Vietnam Pro', sans-serif;
                background: #f5f4f0;
                min-height: 100vh;
                padding-left: 240px;
            }
            .container {
                max-width: 1400px;
                margin: 0 auto;
                padding: 20px;
            }
            .page-header {
                display: flex;
                align-items: center;
                justify-content: space-between;
                margin-bottom: 28px;
                flex-wrap: wrap;
                gap: 15px;
            }
            .page-title {
                font-size: 24px;
                font-weight: 700;
                color: #1a1917;
            }
            .page-title span {
                color: #00639c;
            }
            .page-subtitle {
                font-size: 13px;
                color: #888;
                margin-top: 4px;
            }

            .alert-success {
                background: #d4edda;
                color: #155724;
                padding: 12px 20px;
                border-radius: 8px;
                margin-bottom: 20px;
                border: 1px solid #c3e6cb;
                display: flex;
                justify-content: space-between;
                align-items: center;
            }
            .alert-error {
                background: #f8d7da;
                color: #721c24;
                padding: 12px 20px;
                border-radius: 8px;
                margin-bottom: 20px;
                border: 1px solid #f5c6cb;
                display: flex;
                justify-content: space-between;
                align-items: center;
            }
            .close-btn {
                background: none;
                border: none;
                font-size: 20px;
                cursor: pointer;
                opacity: 0.6;
            }
            .close-btn:hover {
                opacity: 1;
            }

            .filter-bar {
                background: #fff;
                border-radius: 14px;
                padding: 16px 20px;
                margin-bottom: 20px;
                display: flex;
                gap: 15px;
                flex-wrap: wrap;
                align-items: flex-end;
                border: 0.5px solid #e0ddd6;
            }
            .filter-group {
                display: flex;
                flex-direction: column;
                gap: 5px;
            }
            .filter-group label {
                font-size: 11px;
                font-weight: 600;
                color: #666;
                text-transform: uppercase;
                letter-spacing: 0.5px;
            }
            .filter-group input, .filter-group select {
                padding: 8px 12px;
                border-radius: 8px;
                border: 1px solid #ddd;
                font-size: 13px;
                font-family: inherit;
                background: #fafaf8;
                min-width: 160px;
            }
            .filter-group input:focus, .filter-group select:focus {
                border-color: #00639c;
                outline: none;
                box-shadow: 0 0 0 3px rgba(0,99,156,0.1);
            }
            .btn-filter {
                background: linear-gradient(135deg, #1a1a2e 0%, #16213e 50%, #0f3460 100%);
                color: white;
                border: none;
                padding: 8px 20px;
                border-radius: 8px;
                cursor: pointer;
                font-size: 13px;
                font-family: inherit;
                display: flex;
                align-items: center;
                gap: 6px;
                transition: all 0.2s;
            }
            .btn-filter:hover {
                background: #333;
                transform: translateY(-1px);
            }
            .btn-filter.reset {
                background: #666;
            }
            .btn-filter.reset:hover {
                background: #888;
            }
            .btn-add {
                background: linear-gradient(135deg, #1a1a2e 0%, #16213e 50%, #0f3460 100%);
                color: #fff;
                border: none;
                padding: 10px 24px;
                border-radius: 8px;
                font-size: 14px;
                font-weight: 600;
                cursor: pointer;
                font-family: inherit;
                text-decoration: none;
                display: inline-flex;
                align-items: center;
                gap: 8px;
                transition: all 0.2s;
            }
            .btn-add:hover {
                background: #004d7a;
                transform: translateY(-1px);
                box-shadow: 0 4px 12px rgba(0,99,156,0.3);
            }

            .table-card {
                background: #fff;
                border: 0.5px solid #e0ddd6;
                border-radius: 14px;
                overflow: hidden;
                overflow-x: auto;
            }
            table {
                width: 100%;
                border-collapse: collapse;
                min-width: 1000px;
            }
            thead tr {
                border-bottom: 0.5px solid #e8e6e0;
                background: #faf9f7;
            }
            thead th {
                font-size: 11px;
                font-weight: 600;
                color: #999;
                text-transform: uppercase;
                padding: 12px 14px;
                text-align: left;
                letter-spacing: 0.5px;
            }
            tbody tr {
                border-bottom: 0.5px solid #f0ede8;
                transition: background 0.15s;
            }
            tbody tr:hover {
                background: #faf9f7;
            }
            td {
                padding: 10px 14px;
                font-size: 13px;
                vertical-align: middle;
            }

            .id-badge {
                background: #f0ede8;
                color: #888;
                font-size: 11px;
                font-weight: 500;
                padding: 3px 8px;
                border-radius: 6px;
            }
            .img-thumb {
                width: 50px;
                height: 50px;
                border-radius: 8px;
                object-fit: cover;
                border: 0.5px solid #e0ddd6;
            }

            .stock-low {
                color: #e67e22;
                font-weight: 600;
            }
            .stock-empty {
                color: #e74c3c;
                font-weight: 600;
            }
            .stock-ok {
                color: #27ae60;
            }

            .size-stock {
                display: flex;
                flex-wrap: wrap;
                gap: 4px;
            }
            .size-stock .size-item {
                background: #f0ede8;
                padding: 2px 8px;
                border-radius: 4px;
                font-size: 11px;
                display: inline-flex;
                align-items: center;
                gap: 4px;
            }
            .size-stock .size-item .qty {
                font-weight: 600;
                color: #00639c;
            }
            .size-stock .size-item.low {
                background: #fdebd0;
            }
            .size-stock .size-item.empty {
                background: #fadbd8;
            }

            .gallery-thumbs {
                display: flex;
                gap: 4px;
                flex-wrap: wrap;
                align-items: center;
            }
            .gallery-thumbs img {
                width: 30px;
                height: 30px;
                border-radius: 4px;
                object-fit: cover;
                border: 0.5px solid #e0ddd6;
            }
            .gallery-thumbs .more-badge {
                background: #f0ede8;
                padding: 2px 6px;
                border-radius: 4px;
                font-size: 10px;
                display: flex;
                align-items: center;
            }

            .status-badge {
                display: inline-block;
                padding: 3px 10px;
                border-radius: 12px;
                font-size: 11px;
                font-weight: 500;
            }
            .status-featured {
                background: #cee5ff;
                color: #00639c;
            }
            .status-new {
                background: #d4edda;
                color: #155724;
            }
            .status-bestseller {
                background: #fff3cd;
                color: #856404;
            }

            .action-wrap {
                display: flex;
                align-items: center;
                gap: 4px;
                flex-wrap: nowrap;
                justify-content: center;
            }
            .btn-edit, .btn-del, .btn-view {
                padding: 6px 12px;
                border-radius: 6px;
                font-size: 12px;
                font-weight: 500;
                cursor: pointer;
                font-family: 'Quicksand', sans-serif;
                text-decoration: none;
                display: inline-flex;
                align-items: center;
                justify-content: center;
                min-width: 60px;
                height: 32px;
                white-space: nowrap;
                transition: all 0.2s;
                border: none;
            }
            .btn-edit {
                background: linear-gradient(135deg, #1a1a2e 0%, #16213e 50%, #0f3460 100%);
                color: #ffffff;
            }
            .btn-edit:hover {
                box-shadow: 0 4px 12px rgba(15, 52, 96, 0.2);
            }
            .btn-del {
                background: #dc3545;
                color: #ffffff;
            }
            .btn-del:hover {
                background: #c0392b;
            }
            .btn-view {
                background: #e8e5e0;
                color: #2d2d2d;
            }
            .btn-view:hover {
                background: #d4d4d4;
            }
            .badge-inuse {
                background: #f8d7da;
                color: #721c24;
                padding: 2px 8px;
                border-radius: 4px;
                font-size: 10px;
                margin-left: 4px;
                display: inline-block;
            }

            .pagination {
                display: flex;
                justify-content: center;
                gap: 6px;
                padding: 16px 0;
                flex-wrap: wrap;
            }
            .pagination a {
                padding: 6px 14px;
                border: 0.5px solid #ddd;
                border-radius: 6px;
                text-decoration: none;
                color: #1a1917;
                font-size: 13px;
                transition: all 0.2s;
            }
            .pagination a:hover {
                background: #f0ede8;
                border-color: #00639c;
            }
            .pagination a.active {
                background: #00639c;
                color: #fff;
                border-color: #00639c;
            }
            .pagination a.disabled {
                color: #ccc;
                cursor: not-allowed;
                pointer-events: none;
            }

            .empty-state {
                text-align: center;
                padding: 60px 20px;
                color: #999;
            }
            .empty-state .icon {
                font-size: 56px;
                margin-bottom: 16px;
            }
            .empty-state h3 {
                font-size: 20px;
                color: #666;
                margin-bottom: 8px;
            }
            .empty-state p {
                color: #aaa;
                font-size: 14px;
            }

            /* Modal */
            .modal-overlay {
                display: none;
                position: fixed;
                top: 0;
                left: 0;
                right: 0;
                bottom: 0;
                background: rgba(0,0,0,0.5);
                z-index: 1000;
                justify-content: center;
                align-items: center;
                padding: 20px;
                backdrop-filter: blur(4px);
            }
            .modal-overlay.active {
                display: flex;
            }
            .modal {
                background: #fff;
                border-radius: 16px;
                max-width: 800px;
                width: 100%;
                max-height: 90vh;
                overflow-y: auto;
                padding: 32px;
                animation: modalIn 0.3s ease;
                box-shadow: 0 20px 60px rgba(0,0,0,0.3);
            }
            @keyframes modalIn {
                from {
                    opacity: 0;
                    transform: scale(0.95) translateY(20px);
                }
                to {
                    opacity: 1;
                    transform: scale(1) translateY(0);
                }
            }
            .modal-header {
                display: flex;
                justify-content: space-between;
                align-items: center;
                margin-bottom: 24px;
                padding-bottom: 16px;
                border-bottom: 0.5px solid #e0ddd6;
            }
            .modal-header h2 {
                font-size: 20px;
                font-weight: 700;
                color: #1a1917;
            }
            .modal-close {
                background: none;
                border: none;
                font-size: 28px;
                cursor: pointer;
                color: #999;
                padding: 0 8px;
                line-height: 1;
                transition: all 0.3s;
            }
            .modal-close:hover {
                color: #1a1917;
                transform: rotate(90deg);
            }

            .modal .form-group {
                margin-bottom: 16px;
            }
            .modal label {
                display: block;
                font-size: 13px;
                font-weight: 600;
                color: #333;
                margin-bottom: 4px;
            }
            .modal input, .modal select, .modal textarea {
                width: 100%;
                padding: 10px 14px;
                border: 0.5px solid #ddd;
                border-radius: 8px;
                font-size: 14px;
                font-family: inherit;
                background: #fafaf8;
                transition: all 0.2s;
            }
            .modal input:focus, .modal select:focus, .modal textarea:focus {
                border-color: #00639c;
                outline: none;
                background: #fff;
                box-shadow: 0 0 0 3px rgba(0,99,156,0.1);
            }
            .modal textarea {
                resize: vertical;
                min-height: 80px;
            }
            .modal .form-row {
                display: grid;
                grid-template-columns: 1fr 1fr;
                gap: 16px;
            }
            .modal .checkbox-group {
                display: flex;
                gap: 16px;
                flex-wrap: wrap;
                padding-top: 8px;
            }
            .modal .checkbox-group label {
                font-weight: 400;
                font-size: 14px;
                display: flex;
                align-items: center;
                gap: 6px;
                cursor: pointer;
            }
            .modal .checkbox-group input[type="checkbox"] {
                width: 18px;
                height: 18px;
                accent-color: #00639c;
                cursor: pointer;
            }
            .modal-footer {
                display: flex;
                gap: 12px;
                justify-content: flex-end;
                padding-top: 20px;
                border-top: 0.5px solid #e0ddd6;
                margin-top: 8px;
            }
            .btn-submit {
                background: #00639c;
                color: #fff;
                border: none;
                padding: 10px 32px;
                border-radius: 8px;
                font-size: 14px;
                font-weight: 600;
                cursor: pointer;
                font-family: inherit;
                transition: all 0.2s;
            }
            .btn-submit:hover {
                background: #004d7a;
            }
            .btn-cancel {
                background: #e8e6e0;
                color: #1a1917;
                border: none;
                padding: 10px 24px;
                border-radius: 8px;
                font-size: 14px;
                font-weight: 500;
                cursor: pointer;
                font-family: inherit;
                transition: all 0.2s;
            }
            .btn-cancel:hover {
                background: #d5d3cc;
            }

            .size-row {
                display: flex;
                gap: 10px;
                margin-bottom: 8px;
                align-items: center;
            }
            .size-row select {
                flex: 1;
                padding: 8px 12px;
                border: 0.5px solid #ddd;
                border-radius: 6px;
                font-size: 14px;
                background: #fafaf8;
            }
            .size-row input {
                width: 100px;
                padding: 8px 12px;
                border: 0.5px solid #ddd;
                border-radius: 6px;
                font-size: 14px;
            }
            .size-row .remove-btn {
                background: #f8d7da;
                color: #c0392b;
                border: none;
                border-radius: 6px;
                padding: 0 12px;
                cursor: pointer;
                font-size: 18px;
                height: 40px;
            }
            .size-row .remove-btn:hover {
                background: #f5c6cb;
            }
            .add-size-btn {
                color: #00639c;
                background: none;
                border: none;
                cursor: pointer;
                font-size: 14px;
                font-weight: 500;
                padding: 4px 0;
            }
            .add-size-btn:hover {
                color: #004d7a;
            }

            @media (max-width: 768px) {
                body {
                    padding-left: 0;
                    padding-top: 60px;
                }
                .filter-bar {
                    flex-direction: column;
                }
                .filter-group {
                    width: 100%;
                }
                .filter-group input, .filter-group select {
                    min-width: 100%;
                }
                .page-header {
                    flex-direction: column;
                    align-items: flex-start;
                }
                .modal {
                    padding: 20px;
                    margin: 10px;
                }
                .modal .form-row {
                    grid-template-columns: 1fr;
                }
                .action-wrap {
                    flex-direction: column;
                    gap: 4px;
                }
                .btn-edit, .btn-del, .btn-view {
                    width: 100%;
                    justify-content: center;
                }
            }
            /* Tab buttons */
            .tab-btn {
                padding: 6px 16px;
                border: 0.5px solid #ddd;
                border-radius: 6px;
                background: #fafaf8;
                cursor: pointer;
                font-size: 13px;
                font-family: inherit;
                transition: all 0.2s;
            }
            .tab-btn:hover {
                background: #f0ede8;
            }
            .tab-btn.active {
                background: #00639c;
                color: #fff;
                border-color: #00639c;
            }
            .image-upload-area {
                border: 2px dashed #ddd;
                border-radius: 8px;
                padding: 20px;
                text-align: center;
                cursor: pointer;
                transition: all 0.3s;
                background: #fafaf8;
            }
            .image-upload-area:hover {
                border-color: #00639c;
                background: #f0f7ff;
            }
            .image-upload-area .icon {
                font-size: 40px;
                color: #999;
            }
            .image-upload-area p {
                color: #666;
                font-size: 13px;
                margin-top: 8px;
            }

            .gallery-preview {
                display: flex;
                gap: 10px;
                flex-wrap: wrap;
                margin-top: 12px;
            }
            .gallery-preview .preview-item {
                position: relative;
                width: 80px;
                height: 80px;
                border-radius: 8px;
                overflow: hidden;
                border: 1px solid #ddd;
            }
            .gallery-preview .preview-item img {
                width: 100%;
                height: 100%;
                object-fit: cover;
            }
            .gallery-preview .preview-item .remove-btn {
                position: absolute;
                top: -6px;
                right: -6px;
                width: 20px;
                height: 20px;
                border-radius: 50%;
                background: red;
                color: white;
                border: none;
                cursor: pointer;
                font-size: 12px;
                display: flex;
                align-items: center;
                justify-content: center;
            }
            .gallery-preview .preview-item .remove-btn:hover {
                background: darkred;
            }
        </style>
    </head>
    <body>
        <div class="container">
            <!-- Header -->
            <div class="page-header">
                <div>
                    <div class="page-title">Quản lý <span>sản phẩm</span></div>
                    <div class="page-subtitle">
                        Tổng số: <strong><%= totalRecords%></strong> sản phẩm 
                        <% if (stockFilter != null) { %>
                        | Đang lọc: <strong>
                            <% if ("low".equals(stockFilter)) { %>
                            ⚠️ Sắp hết hàng
                            <% } else if ("empty".equals(stockFilter)) { %>
                            🚫 Hết hàng
                            <% }%>
                        </strong> (còn <strong><%= filteredList.size()%></strong> sản phẩm)
                        <% }%>
                    </div>
                </div>
                <a href="<%= path%>/admin/themsp.jsp" class="btn-add">
                    <span style="font-size:20px;line-height:1;">+</span> Thêm sản phẩm
                </a>
            </div>

            <!-- Thông báo -->
            <% if (successMsg != null) { %>
            <div class="alert-success" id="alertMessage">
                <span>
                    <% if ("deleted".equals(successMsg)) { %>
                    Đã xóa sản phẩm thành công!
                    <% } else if ("updated".equals(successMsg)) { %>
                    Đã cập nhật sản phẩm thành công!
                    <% } %>
                </span>
                <button class="close-btn" onclick="closeAlert()">✕</button>
            </div>
            <% } %>

            <% if (errorMsg != null) { %>
            <div class="alert-error" id="alertMessage">
                <span>
                    <% if ("delete_failed".equals(errorMsg)) { %>
                    ❌ Không thể xóa sản phẩm. Vui lòng thử lại!
                    <% } else if ("in_use".equals(errorMsg)) { %>
                    ❌ Không thể xóa sản phẩm này vì đã có trong đơn hàng!
                    <% } else if ("update_failed".equals(errorMsg)) { %>
                    ❌ Không thể cập nhật sản phẩm. Vui lòng thử lại!
                    <% } else {%>
                    ❌ Có lỗi xảy ra: <%= errorMsg%>
                    <% } %>
                </span>
                <button class="close-btn" onclick="closeAlert()">✕</button>
            </div>
            <% }%>

            <!-- Filter -->
            <div class="filter-bar">
                <form method="get" style="display: flex; gap: 15px; flex-wrap: wrap; align-items: flex-end; width: 100%;">
                    <div class="filter-group">
                        <label>🔍 Tìm kiếm</label>
                        <input type="text" name="keyword" placeholder="Nhập tên sản phẩm..." 
                               value="<%= keyword != null ? keyword : ""%>">
                    </div>
                    <div class="filter-group">
                        <label>Danh mục</label>
                        <select name="danhmuc_filter">
                            <option value="">Tất cả danh mục</option>
                            <%
                                for (Map.Entry<Integer, String> entry : danhMucMap.entrySet()) {
                                    int catId = entry.getKey();
                                    String catName = entry.getValue();
                                    boolean selected = (danhmucFilter != null && String.valueOf(catId).equals(danhmucFilter));
                            %>
                            <option value="<%= catId%>" <%= selected ? "selected" : ""%>><%= catName%></option>
                            <% }%>
                        </select>
                    </div>
                    <div class="filter-group">
                        <label>Sắp xếp</label>
                        <select name="sort_by">
                            <option value="">Mới nhất</option>
                            <option value="price_asc" <%= "price_asc".equals(sortBy) ? "selected" : ""%>>Giá tăng dần</option>
                            <option value="price_desc" <%= "price_desc".equals(sortBy) ? "selected" : ""%>>Giá giảm dần</option>
                            <option value="name_asc" <%= "name_asc".equals(sortBy) ? "selected" : ""%>>Tên A-Z</option>
                        </select>
                    </div>
                    <div class="filter-group">
                        <label> Trạng thái kho</label>
                        <select name="stock_filter">
                            <option value="">Tất cả</option>
                            <option value="low" <%= "low".equals(stockFilter) ? "selected" : ""%>> Sắp hết (≤5)</option>
                            <option value="empty" <%= "empty".equals(stockFilter) ? "selected" : ""%>>Hết hàng (0)</option>
                        </select>
                    </div>
                    <button type="submit" class="btn-filter">Lọc</button>
                    <a href="admin_sanpham.jsp" class="btn-filter reset">Xóa lọc</a>
                </form>
            </div>

            <!-- Danh sách sản phẩm -->
            <div class="table-card">
                <table>
                    <thead>
                        <tr>
                            <th style="width:50px">ID</th>
                            <th style="min-width:150px">Tên sản phẩm</th>
                            <th style="width:100px">Giá</th>
                            <th style="width:100px">Giá KM</th>
                            <th style="width:80px">Ảnh</th>
                            <th style="width:180px">Số lượng</th>
                            <th style="width:140px">Danh mục</th>
                            <th style="width:120px">Đặc biệt</th>
                            <th style="width:200px;text-align:center">Hành động</th>
                        </tr>
                    </thead>
                    <tbody>
                        <% if (filteredList.isEmpty()) { %>
                        <tr>
                            <td colspan="9">
                                <div class="empty-state">
                                    <div class="icon">📭</div>
                                    <h3>Không tìm thấy sản phẩm</h3>
                                    <p>Hãy thay đổi bộ lọc hoặc thêm sản phẩm mới</p>
                                </div>
                            </td>
                        </tr>
                        <% } else {
                            for (sanpham sp : filteredList) {
                                int id = sp.getId();
                                String ten = sp.getTen() != null ? sp.getTen().replace("\"", "&quot;").replace("<", "&lt;") : "";
                                int gia = sp.getGia();
                                Integer giaKm = sp.getGiaKm();
                                String anh = sp.getAnh() != null ? sp.getAnh() : "default.jpg";
                                String tenDanhMuc = sp.getTenDanhMuc() != null ? sp.getTenDanhMuc() : "Chưa phân loại";
                                boolean isFeatured = sp.isFeatured();
                                boolean isNew = sp.isNew();
                                boolean isBestseller = sp.isBestseller();
                                List<String> gallery = sp.getAnhGallery();

                                boolean hasSize = (sp.getSizes() != null && !sp.getSizes().isEmpty());
                                int totalQty = sp.getTotalSoluong();
                                int qty = sp.getSoluong();
                                int stock = hasSize ? totalQty : qty;

                                String stockClass = "";
                                String stockLabel = "";
                                if (stock == 0) {
                                    stockClass = "stock-empty";
                                    stockLabel = "🚫 Hết hàng";
                                } else if (stock <= 5) {
                                    stockClass = "stock-low";
                                    stockLabel = "⚠️ Còn " + stock;
                                } else {
                                    stockClass = "stock-ok";
                                    stockLabel = " " + stock;
                                }

                                boolean inUse = false;
                                try {
                                    Connection connCheck = dbconnect.getConnection();
                                    PreparedStatement psCheck = connCheck.prepareStatement(
                                            "SELECT COUNT(*) FROM chitietdonhang WHERE sanpham_id=?");
                                    psCheck.setInt(1, id);
                                    ResultSet rsCheck = psCheck.executeQuery();
                                    if (rsCheck.next() && rsCheck.getInt(1) > 0) {
                                        inUse = true;
                                    }
                                    rsCheck.close();
                                    psCheck.close();
                                    connCheck.close();
                                } catch (Exception e) {
                                    e.printStackTrace();
                                }

                                // Tạo sizeData an toàn
                                String sizeData = "[]";
                                if (sp.getSizes() != null && !sp.getSizes().isEmpty()) {
                                    StringBuilder sb = new StringBuilder();
                                    sb.append("[");
                                    boolean firstSize = true;
                                    for (Map.Entry<model.Size, Integer> entry : sp.getSizes().entrySet()) {
                                        if (!firstSize) {
                                            sb.append(",");
                                        }
                                        sb.append("{");
                                        sb.append("\"size_id\":").append(entry.getKey().getId()).append(",");
                                        sb.append("\"soluong\":").append(entry.getValue());
                                        sb.append("}");
                                        firstSize = false;
                                    }
                                    sb.append("]");
                                    sizeData = sb.toString();
                                }

                                // Escape dữ liệu
                                String tenEscaped = ten.replace("'", "\\'");
                                String motaEscaped = "";
                                if (sp.getMota() != null) {
                                    motaEscaped = sp.getMota().replace("'", "\\'").replace("\n", "\\n");
                                }
                                String chatlieuEscaped = "";
                                if (sp.getChatlieu() != null) {
                                    chatlieuEscaped = sp.getChatlieu().replace("'", "\\'");
                                }
                                String galleryEscaped = "";
                                if (gallery != null) {
                                    galleryEscaped = String.join(",", gallery).replace("'", "\\'");
                                }
                        %>
                        <tr>
                            <td><span class="id-badge">#<%= String.format("%03d", id)%></span></td>
                            <td>
                                <strong><%= ten%></strong>
                                <% if (inUse) { %>

                                <% }%>
                            </td>
                            <td><%= String.format("%,d", gia)%>đ</td>
                            <td>
                                <% if (giaKm != null && giaKm > 0 && giaKm < gia) {%>
                                <span style="color:#00639c;font-weight:600;"><%= String.format("%,d", giaKm)%>đ</span>
                                <span style="color:#999;font-size:11px;display:block;text-decoration:line-through;"><%= String.format("%,d", gia)%>đ</span>
                                <% } else { %>
                                <span style="color:#999;">-</span>
                                <% }%>
                            </td>
                            <td>
                                <div class="gallery-thumbs">
                                    <%
                                        boolean isLink = (anh != null && (anh.startsWith("http://") || anh.startsWith("https://")));
                                        String src = isLink ? anh : path + "/img/" + anh;
                                    %>
                                    <img class="img-thumb" src="<%= src%>" 
                                         onerror="this.src='<%= path%>/img/default.jpg'"
                                         alt="<%= ten%>">
                                    <% if (gallery != null && gallery.size() > 1) {%>
                                    <span class="more-badge">+<%= gallery.size() - 1%></span>
                                    <% } %>
                                </div>
                            </td>
                            <td>
                                <div class="size-stock">
                                    <% if (hasSize) {
                                            for (Map.Entry<model.Size, Integer> entry : sp.getSizes().entrySet()) {
                                                String sizeName = entry.getKey().getTenSize();
                                                int qtySize = entry.getValue();
                                                String sizeClass = "";
                                                if (qtySize == 0)
                                                    sizeClass = "empty";
                                                else if (qtySize <= 5)
                                                    sizeClass = "low";
                                    %>
                                    <span class="size-item <%= sizeClass%>">
                                        <%= sizeName%>: <span class="qty"><%= qtySize%></span>
                                    </span>
                                    <%      }
                                    } else {
                                    %>
                                    <span class="<%= stockClass%>" style="font-weight:600;">
                                        <%= stockLabel%>
                                    </span>
                                    <% }%>
                                </div>
                            </td>
                            <td><%= tenDanhMuc%></td>
                            <td>
                                <div style="display:flex;flex-direction:column;gap:3px;">
                                    <% if (isFeatured) { %>
                                    <span class="status-badge status-featured">⭐ Nổi bật</span>
                                    <% } %>
                                    <% if (isNew) { %>
                                    <span class="status-badge status-new">🆕 Mới</span>
                                    <% } %>
                                    <% if (isBestseller) { %>
                                    <span class="status-badge status-bestseller">🔥 Bán chạy</span>
                                    <% } %>
                                    <% if (!isFeatured && !isNew && !isBestseller) { %>
                                    <span style="color:#999;font-size:11px;">-</span>
                                    <% }%>
                                </div>
                            </td>
                            <td>
                                <div class="action-wrap">
                                    <button class="btn-edit" 
                                            data-id="<%= id%>"
                                            data-ten="<%= tenEscaped%>"
                                            data-gia="<%= gia%>"
                                            data-gia-km="<%= giaKm != null ? giaKm : ""%>"
                                            data-danhmuc="<%= sp.getDanhMucId()%>"
                                            data-mota="<%= motaEscaped%>"
                                            data-chatlieu="<%= chatlieuEscaped%>"
                                            data-trong-luong="<%= sp.getTrongLuong() != null ? sp.getTrongLuong() : ""%>"
                                            data-bao-hanh="<%= sp.getBaoHanh() != null ? sp.getBaoHanh() : 12%>"
                                            data-featured="<%= isFeatured%>"
                                            data-new="<%= isNew%>"
                                            data-bestseller="<%= isBestseller%>"
                                            data-image="<%= anh%>"
                                            data-gallery="<%= galleryEscaped%>"
                                            data-stock="<%= stock%>"
                                            data-has-size="<%= hasSize%>"
                                            data-size-data='<%= sizeData%>'
                                            onclick="openEditModalFromData(this)">
                                        Sửa
                                    </button>
                                    <a class="btn-del" href="?xoa=<%= id%>"
                                       onclick="return confirm('Bạn có chắc muốn xóa sản phẩm \n\n<%= ten%>\n\n? Hành động này không thể hoàn tác!')">
                                        Xóa
                                    </a>
                                    <a class="btn-view" href="<%= path%>/chitiet?id=<%= id%>" target="_blank">
                                        👁 Xem
                                    </a>
                                </div>
                            </td>
                        </tr>
                        <% }
                            } %>
                    </tbody>
                </table>
            </div>

            <!-- Phân trang -->
            <% if (totalPages > 1) {%>
            <div class="pagination">
                <a href="?page=1<%= keyword != null ? "&keyword=" + keyword : ""%><%= danhmucFilter != null ? "&danhmuc_filter=" + danhmucFilter : ""%><%= stockFilter != null ? "&stock_filter=" + stockFilter : ""%><%= sortBy != null ? "&sort_by=" + sortBy : ""%>"
                   class="<%= currentPage == 1 ? "disabled" : ""%>">« Đầu</a>

                <a href="?page=<%= currentPage - 1%><%= keyword != null ? "&keyword=" + keyword : ""%><%= danhmucFilter != null ? "&danhmuc_filter=" + danhmucFilter : ""%><%= stockFilter != null ? "&stock_filter=" + stockFilter : ""%><%= sortBy != null ? "&sort_by=" + sortBy : ""%>"
                   class="<%= currentPage == 1 ? "disabled" : ""%>">‹</a>

                <%
                    int startPage = Math.max(1, currentPage - 2);
                    int endPage = Math.min(totalPages, currentPage + 2);
                    for (int i = startPage; i <= endPage; i++) {
                %>
                <a href="?page=<%= i%><%= keyword != null ? "&keyword=" + keyword : ""%><%= danhmucFilter != null ? "&danhmuc_filter=" + danhmucFilter : ""%><%= stockFilter != null ? "&stock_filter=" + stockFilter : ""%><%= sortBy != null ? "&sort_by=" + sortBy : ""%>"
                   class="<%= currentPage == i ? "active" : ""%>"><%= i%></a>
                <% }%>

                <a href="?page=<%= currentPage + 1%><%= keyword != null ? "&keyword=" + keyword : ""%><%= danhmucFilter != null ? "&danhmuc_filter=" + danhmucFilter : ""%><%= stockFilter != null ? "&stock_filter=" + stockFilter : ""%><%= sortBy != null ? "&sort_by=" + sortBy : ""%>"
                   class="<%= currentPage == totalPages ? "disabled" : ""%>">›</a>

                <a href="?page=<%= totalPages%><%= keyword != null ? "&keyword=" + keyword : ""%><%= danhmucFilter != null ? "&danhmuc_filter=" + danhmucFilter : ""%><%= stockFilter != null ? "&stock_filter=" + stockFilter : ""%><%= sortBy != null ? "&sort_by=" + sortBy : ""%>"
                   class="<%= currentPage == totalPages ? "disabled" : ""%>">Cuối »</a>
            </div>
            <% }%>

            <div style="margin-top: 20px; text-align: center; font-size: 12px; color: #999;">
                <p>Aurastore Admin Panel &copy; 2026 | Trang <%= currentPage%> / <%= totalPages%> | Tổng số <%= totalRecords%> sản phẩm</p>
            </div>
        </div>

        <!-- ===== MODAL SỬA SẢN PHẨM ===== -->
        <div class="modal-overlay" id="editModal">
            <div class="modal">
                <div class="modal-header">
                    <h2> Sửa sản phẩm</h2>
                    <button class="modal-close" onclick="closeEditModal()">✕</button>
                </div>
                <form class="modal-form" action="<%= path%>/admin/sua_sanpham" method="post" enctype="multipart/form-data">
                    <!-- Hidden fields -->
                    <input type="hidden" name="id" id="edit_id">
                    <input type="hidden" name="has_size" id="edit_has_size" value="false">
                    <input type="hidden" name="old_image" id="edit_old_image" value="">
                    <input type="hidden" name="image_source" id="editImageSource" value="upload">
                    <input type="hidden" name="gallery_source" id="editGallerySource" value="upload">
                    <input type="hidden" name="delete_images" id="edit_delete_images" value="">

                    <div class="form-group">
                        <label>Tên sản phẩm <span style="color:red;">*</span></label>
                        <input type="text" name="ten" id="edit_ten" required>
                    </div>

                    <div class="form-row">
                        <div class="form-group">
                            <label>Giá (VNĐ) <span style="color:red;">*</span></label>
                            <input type="number" name="gia" id="edit_gia" required>
                        </div>
                        <div class="form-group">
                            <label>Giá khuyến mãi</label>
                            <input type="number" name="gia_km" id="edit_gia_km" placeholder="Để trống nếu không có">
                        </div>
                    </div>

                    <div class="form-row">
                        <div class="form-group">
                            <label>Danh mục <span style="color:red;">*</span></label>
                            <select name="danhmuc_id" id="edit_danhmuc_id" required>
                                <% for (Map.Entry<Integer, String> entry : danhMucMap.entrySet()) {%>
                                <option value="<%= entry.getKey()%>"><%= entry.getValue()%></option>
                                <% }%>
                            </select>
                        </div>
                        <div class="form-group">
                            <label>Chất liệu</label>
                            <input type="text" name="chatlieu" id="edit_chatlieu" placeholder="VD: Bạc 925">
                        </div>
                    </div>

                    <div class="form-row">
                        <div class="form-group">
                            <label>Trọng lượng (gram)</label>
                            <input type="number" step="0.1" name="trong_luong" id="edit_trong_luong" placeholder="VD: 3.5">
                        </div>
                        <div class="form-group">
                            <label>Bảo hành (tháng)</label>
                            <input type="number" name="bao_hanh" id="edit_bao_hanh" placeholder="12">
                        </div>
                    </div>

                    <!-- Số lượng cho sản phẩm không có size -->
                    <div class="form-group" id="soluongGroup">
                        <label>Số lượng <span style="color:red;">*</span></label>
                        <input type="number" name="soluong" id="edit_soluong" min="0" value="0">
                        <div style="font-size:11px;color:#999;margin-top:4px;">
                            Nhập số lượng tổng cho sản phẩm
                        </div>
                    </div>

                    <!-- Size cho sản phẩm có size -->
                    <div class="form-group" id="sizeGroup">
                        <label>Size và số lượng</label>
                        <div id="editSizeContainer"></div>
                        <button type="button" class="add-size-btn" onclick="addEditSizeRow()">
                            + Thêm size
                        </button>
                        <div style="font-size:11px;color:#999;margin-top:8px;">
                            Chọn size và nhập số lượng cho từng size
                        </div>
                    </div>

                    <div class="form-group">
                        <label>Mô tả</label>
                        <textarea name="mota" id="edit_mota" rows="3" placeholder="Nhập mô tả sản phẩm..."></textarea>
                    </div>

                    <!-- ===== ẢNH ĐẠI DIỆN ===== -->
                    <div class="form-group">
                        <label>Ảnh đại diện</label>
                        <div style="display:flex;gap:8px;margin-bottom:12px;">
                            <button type="button" id="editTabUpload" class="tab-btn active" onclick="switchEditImageTab('upload')">
                                📤 Upload ảnh
                            </button>
                            <button type="button" id="editTabLink" class="tab-btn" onclick="switchEditImageTab('link')">
                                🔗 Dùng link ảnh
                            </button>
                        </div>

                        <div id="editImageUploadTab">
                            <div style="display:flex;align-items:center;gap:16px;flex-wrap:wrap;">
                                <div>
                                    <img id="currentImageDisplay" src="" alt="Ảnh hiện tại" 
                                         style="width:80px;height:80px;object-fit:cover;border-radius:8px;border:1px solid #ddd;">
                                    <div style="font-size:11px;color:#999;margin-top:4px;">Ảnh hiện tại</div>
                                </div>
                                <div style="flex:1;min-width:200px;">
                                    <input type="file" name="anh" accept="image/*" id="editMainImage"
                                           class="w-full px-4 py-2 border rounded-lg focus:outline-none focus:border-blue-500">
                                    <div style="font-size:11px;color:#999;margin-top:4px;">Chọn ảnh từ máy tính</div>
                                </div>
                            </div>
                        </div>

                        <div id="editImageLinkTab" style="display:none;">
                            <div style="display:flex;align-items:center;gap:16px;flex-wrap:wrap;">
                                <div>
                                    <img id="editImageLinkPreview" src="" alt="Preview link" 
                                         style="width:80px;height:80px;object-fit:cover;border-radius:8px;border:1px solid #ddd;">
                                    <div style="font-size:11px;color:#999;margin-top:4px;">Preview</div>
                                </div>
                                <div style="flex:1;min-width:200px;">
                                    <input type="url" name="anh_url" id="editImageUrl" 
                                           placeholder="Nhập link ảnh (VD: https://example.com/image.jpg)"
                                           class="w-full px-4 py-2 border rounded-lg focus:outline-none focus:border-blue-500">
                                    <div style="font-size:11px;color:#999;margin-top:4px;">
                                        Nhập link ảnh từ internet (JPG, PNG, JPEG)
                                    </div>
                                </div>
                            </div>
                        </div>
                    </div>

                    <!-- ===== GALLERY ẢNH ===== -->
                    <div class="form-group">
                        <label>Gallery ảnh</label>
                        <div style="display:flex;gap:8px;margin-bottom:12px;">
                            <button type="button" id="editGalleryTabUpload" class="tab-btn active" onclick="switchEditGalleryTab('upload')">
                                📤 Upload nhiều ảnh
                            </button>
                            <button type="button" id="editGalleryTabLink" class="tab-btn" onclick="switchEditGalleryTab('link')">
                                🔗 Dùng link ảnh
                            </button>
                        </div>

                        <div id="editGalleryUploadTab">
                            <div class="image-upload-area" id="editGalleryDropArea">
                                <div class="icon">️</div>
                                <p>Kéo thả ảnh vào đây hoặc click để chọn</p>
                                <input type="file" name="anh_gallery" accept="image/*" multiple 
                                       id="editGalleryInput" style="display:none;">
                            </div>
                            <div class="gallery-preview" id="editGalleryPreview"></div>
                            <div style="font-size:11px;color:#999;margin-top:8px;">
                                Giữ Ctrl để chọn nhiều ảnh
                            </div>
                        </div>

                        <div id="editGalleryLinkTab" style="display:none;">
                            <div style="display:flex;flex-direction:column;gap:8px;">
                                <textarea name="anh_gallery_url" id="editGalleryUrls" rows="3" 
                                          placeholder="Nhập link ảnh, cách nhau bằng dấu phẩy&#10;VD: https://example.com/1.jpg, https://example.com/2.jpg"
                                          class="w-full px-4 py-2 border rounded-lg focus:outline-none focus:border-blue-500"></textarea>
                                <div style="font-size:11px;color:#999;">
                                    Nhập nhiều link ảnh, cách nhau bằng dấu phẩy (,)
                                </div>
                            </div>
                            <div class="gallery-preview" id="editGalleryPreviewUrls"></div>
                        </div>
                    </div>

                    <!-- Đặc biệt -->
                    <div class="form-group">
                        <label>Đặc biệt</label>
                        <div class="checkbox-group">
                            <label><input type="checkbox" name="is_featured" id="edit_is_featured"> ⭐ Nổi bật</label>
                            <label><input type="checkbox" name="is_new" id="edit_is_new"> 🆕 Sản phẩm mới</label>
                            <label><input type="checkbox" name="is_bestseller" id="edit_is_bestseller"> 🔥 Bán chạy</label>
                        </div>
                    </div>

                    <div class="modal-footer">
                        <button type="button" class="btn-cancel" onclick="closeEditModal()">Hủy</button>
                        <button type="submit" class="btn-submit">Lưu thay đổi</button>
                    </div>
                </form>
            </div>
        </div>

        <script>
            var sizeMap = {};
            <%
                for (Map.Entry<Integer, String> entry : sizeMap.entrySet()) {
            %>
            sizeMap[<%= entry.getKey()%>] = '<%= entry.getValue()%>';
            <%
                }
            %>

            // ===== MỞ MODAL TỪ DATA ATTRIBUTE =====
            function openEditModalFromData(btn) {
                var id = btn.dataset.id;
                var ten = btn.dataset.ten;
                var gia = btn.dataset.gia;
                var giaKm = btn.dataset.giaKm;
                var danhmucId = btn.dataset.danhmuc;
                var mota = btn.dataset.mota;
                var chatlieu = btn.dataset.chatlieu;
                var trongLuong = btn.dataset.trongLuong;
                var baoHanh = btn.dataset.baoHanh;
                var isFeatured = btn.dataset.featured === 'true';
                var isNew = btn.dataset.new === 'true';
                var isBestseller = btn.dataset.bestseller === 'true';
                var currentImage = btn.dataset.image;
                var galleryStr = btn.dataset.gallery;
                var stock = parseInt(btn.dataset.stock) || 0;
                var hasSize = btn.dataset.hasSize === 'true';
                var sizeData = btn.dataset.sizeData;

                console.log("=== OPEN EDIT FROM DATA ===");
                console.log("ID:", id);
                console.log("Has Size:", hasSize);
                console.log("Size Data:", sizeData);

                openEditModal(id, ten, gia, giaKm, danhmucId, mota, chatlieu, trongLuong, baoHanh,
                        isFeatured, isNew, isBestseller, currentImage, galleryStr, stock, hasSize, sizeData);
            }


            // ===== MỞ MODAL SỬA =====
            function openEditModal(id, ten, gia, giaKm, danhmucId, mota, chatlieu, trongLuong, baoHanh, isFeatured, isNew, isBestseller, currentImage, galleryStr, stock, hasSize, sizeData) {
                try {
                    console.log("=== OPEN EDIT MODAL ===");
                    console.log("ID:", id);
                    console.log("Has Size:", hasSize);

                    // Kiểm tra và gán giá trị cho từng field
                    var editId = document.getElementById('edit_id');
                    var editTen = document.getElementById('edit_ten');
                    var editGia = document.getElementById('edit_gia');
                    var editGiaKm = document.getElementById('edit_gia_km');
                    var editDanhmucId = document.getElementById('edit_danhmuc_id');
                    var editMota = document.getElementById('edit_mota');
                    var editChatlieu = document.getElementById('edit_chatlieu');
                    var editTrongLuong = document.getElementById('edit_trong_luong');
                    var editBaoHanh = document.getElementById('edit_bao_hanh');
                    var editIsFeatured = document.getElementById('edit_is_featured');
                    var editIsNew = document.getElementById('edit_is_new');
                    var editIsBestseller = document.getElementById('edit_is_bestseller');
                    var editHasSize = document.getElementById('edit_has_size');
                    var editOldImage = document.getElementById('edit_old_image');
                    var currentImageDisplay = document.getElementById('currentImageDisplay');
                    var editImageLinkPreview = document.getElementById('editImageLinkPreview');
                    var editGalleryUrls = document.getElementById('editGalleryUrls');
                    var editSoluong = document.getElementById('edit_soluong');
                    var soluongGroup = document.getElementById('soluongGroup');
                    var sizeGroup = document.getElementById('sizeGroup');

                    // Gán giá trị (kiểm tra tồn tại)
                    if (editId)
                        editId.value = id || '';
                    if (editTen)
                        editTen.value = ten || '';
                    if (editGia)
                        editGia.value = gia || 0;
                    if (editGiaKm)
                        editGiaKm.value = giaKm || '';
                    if (editDanhmucId)
                        editDanhmucId.value = danhmucId || 1;
                    if (editMota)
                        editMota.value = mota || '';
                    if (editChatlieu)
                        editChatlieu.value = chatlieu || '';
                    if (editTrongLuong)
                        editTrongLuong.value = trongLuong || '';
                    if (editBaoHanh)
                        editBaoHanh.value = baoHanh || 12;
                    if (editIsFeatured)
                        editIsFeatured.checked = isFeatured || false;
                    if (editIsNew)
                        editIsNew.checked = isNew || false;
                    if (editIsBestseller)
                        editIsBestseller.checked = isBestseller || false;
                    if (editHasSize)
                        editHasSize.value = hasSize ? 'true' : 'false';
                    if (editOldImage)
                        editOldImage.value = currentImage || '';

                    // Xử lý ảnh
                    var contextPath = '<%= request.getContextPath()%>';
                    var isLink = (currentImage && (currentImage.startsWith('http://') || currentImage.startsWith('https://')));
                    var imagePath = (currentImage && currentImage !== '')
                            ? (isLink ? currentImage : contextPath + '/img/' + currentImage)
                            : contextPath + '/img/default.jpg';

                    if (currentImageDisplay)
                        currentImageDisplay.src = imagePath;
                    if (editImageLinkPreview)
                        editImageLinkPreview.src = imagePath;
                    // ===== XỬ LÝ GALLERY =====
                    editGalleryImages = [];
                    editDeletedImages = [];
                    document.getElementById('edit_delete_images').value = '';

                    var urlList = [];
                    var fileList = [];

                    if (galleryStr && galleryStr !== '') {
                        var images = galleryStr.split(',');
                        for (var i = 0; i < images.length; i++) {
                            var img = images[i].trim();
                            if (img !== '') {
                                if (img.startsWith('http://') || img.startsWith('https://')) {
                                    urlList.push(img);
                                } else {
                                    fileList.push(img);
                                    editGalleryImages.push(img);
                                }
                            }
                        }
                    }

                    // Nếu có link gallery, hiển thị ở tab Link
                    if (urlList.length > 0) {
                        document.getElementById('editGalleryUrls').value = urlList.join(', ');
                        previewEditGalleryUrls(urlList.join(', '));
                        switchEditGalleryTab('link');
                    } else {
                        document.getElementById('editGalleryUrls').value = '';
                        switchEditGalleryTab('upload');
                    }

                    // Hiển thị ảnh gallery cũ (dạng file) trong preview upload
                    renderEditGallery();

                    // Reset input gallery
                    document.getElementById('editGalleryInput').value = '';
                    // Reset input
                    var editMainImage = document.getElementById('editMainImage');
                    var editImageUrl = document.getElementById('editImageUrl');
                    if (editMainImage)
                        editMainImage.value = '';
                    if (editImageUrl)
                        editImageUrl.value = '';

                    // Chọn tab phù hợp
                    if (isLink) {
                        switchEditImageTab('link');
                        if (editImageUrl)
                            editImageUrl.value = currentImage;
                    } else {
                        switchEditImageTab('upload');
                    }

                    // Xử lý gallery
                    if (editGalleryUrls) {
                        if (galleryStr && galleryStr !== '') {
                            editGalleryUrls.value = galleryStr;
                        } else {
                            editGalleryUrls.value = '';
                        }
                    }

                    // Hiển thị đúng form theo loại sản phẩm
                    if (soluongGroup && sizeGroup) {
                        if (hasSize) {
                            soluongGroup.style.display = 'none';
                            sizeGroup.style.display = 'block';
                            loadEditSizesFromData(sizeData);
                        } else {
                            soluongGroup.style.display = 'block';
                            sizeGroup.style.display = 'none';
                            if (editSoluong)
                                editSoluong.value = stock || 0;
                        }
                    }

                    var modal = document.getElementById('editModal');
                    if (modal) {
                        modal.classList.add('active');
                        document.body.style.overflow = 'hidden';
                    }

                } catch (e) {
                    console.error("Error in openEditModal:", e);
                    alert("Có lỗi xảy ra khi mở modal: " + e.message);
                }
            }

            // ===== LOAD SIZE TỪ DỮ LIỆU =====
            function loadEditSizesFromData(sizeData) {
                var container = document.getElementById('editSizeContainer');
                container.innerHTML = '';

                if (!sizeData || sizeData === '[]' || sizeData === '') {
                    addEditSizeRow();
                    return;
                }

                try {
                    var sizes = JSON.parse(sizeData);
                    if (sizes.length === 0) {
                        addEditSizeRow();
                    } else {
                        for (var i = 0; i < sizes.length; i++) {
                            addEditSizeRow(sizes[i].size_id, sizes[i].soluong);
                        }
                    }
                } catch (e) {
                    console.log('Parse error:', e);
                    addEditSizeRow();
                }
            }
// ===== SWITCH TAB ẢNH TRONG MODAL SỬA =====
            function switchEditImageTab(tab) {
                var uploadTab = document.getElementById('editImageUploadTab');
                var linkTab = document.getElementById('editImageLinkTab');
                var tabUpload = document.getElementById('editTabUpload');
                var tabLink = document.getElementById('editTabLink');
                var source = document.getElementById('editImageSource');

                if (tab === 'upload') {
                    uploadTab.style.display = 'block';
                    linkTab.style.display = 'none';
                    tabUpload.className = 'tab-btn active';
                    tabLink.className = 'tab-btn';
                    source.value = 'upload';
                    document.getElementById('editMainImage').required = false;
                } else {
                    uploadTab.style.display = 'none';
                    linkTab.style.display = 'block';
                    tabLink.className = 'tab-btn active';
                    tabUpload.className = 'tab-btn';
                    source.value = 'link';
                    document.getElementById('editImageUrl').required = true;
                }
            }

            // ===== PREVIEW LINK ẢNH =====
            document.getElementById('editImageUrl').addEventListener('input', function (e) {
                var url = this.value.trim();
                var preview = document.getElementById('editImageLinkPreview');
                if (url !== '') {
                    preview.src = url;
                    preview.onerror = function () {
                        this.src = '<%= request.getContextPath()%>/img/default.jpg';
                    };
                } else {
                    // Nếu không có link, hiển thị ảnh hiện tại
                    var currentImage = document.getElementById('edit_old_image').value;
                    var contextPath = '<%= request.getContextPath()%>';
                    if (currentImage && currentImage.startsWith('http')) {
                        preview.src = currentImage;
                    } else {
                        preview.src = contextPath + '/img/' + (currentImage || 'default.jpg');
                    }
                }
            });
            // ===== BIẾN GALLERY =====
            var editGalleryImages = [];
            var editDeletedImages = [];

// ===== SWITCH TAB GALLERY TRONG MODAL SỬA =====
            function switchEditGalleryTab(tab) {
                var uploadTab = document.getElementById('editGalleryUploadTab');
                var linkTab = document.getElementById('editGalleryLinkTab');
                var tabUpload = document.getElementById('editGalleryTabUpload');
                var tabLink = document.getElementById('editGalleryTabLink');
                var source = document.getElementById('editGallerySource');

                if (tab === 'upload') {
                    if (uploadTab)
                        uploadTab.style.display = 'block';
                    if (linkTab)
                        linkTab.style.display = 'none';
                    if (tabUpload)
                        tabUpload.className = 'tab-btn active';
                    if (tabLink)
                        tabLink.className = 'tab-btn';
                    if (source)
                        source.value = 'upload';
                } else {
                    if (uploadTab)
                        uploadTab.style.display = 'none';
                    if (linkTab)
                        linkTab.style.display = 'block';
                    if (tabLink)
                        tabLink.className = 'tab-btn active';
                    if (tabUpload)
                        tabUpload.className = 'tab-btn';
                    if (source)
                        source.value = 'link';
                }
            }

// ===== RENDER GALLERY UPLOAD =====
            function renderEditGallery() {
                var container = document.getElementById('editGalleryPreview');
                if (!container)
                    return;
                container.innerHTML = '';

                var contextPath = '<%= request.getContextPath()%>';
                for (var i = 0; i < editGalleryImages.length; i++) {
                    var img = editGalleryImages[i];
                    var div = document.createElement('div');
                    div.className = 'preview-item';
                    var imgSrc = (img.startsWith('http') ? img : contextPath + '/img/' + img);
                    div.innerHTML = `
            <img src="` + imgSrc + `" 
                 onerror="this.src='` + contextPath + `/img/default.jpg'"
                 style="object-fit:cover;width:100%;height:100%;">
            <button class="remove-btn" onclick="removeEditGalleryImage('` + img + `')">✕</button>
        `;
                    container.appendChild(div);
                }
            }

// ===== XÓA ẢNH GALLERY =====
            function removeEditGalleryImage(imageName) {
                var index = editGalleryImages.indexOf(imageName);
                if (index > -1) {
                    editGalleryImages.splice(index, 1);
                    editDeletedImages.push(imageName);
                    document.getElementById('edit_delete_images').value = editDeletedImages.join(',');
                    renderEditGallery();
                }
            }

// ===== PREVIEW LINK GALLERY =====
            function previewEditGalleryUrls(urls) {
                var container = document.getElementById('editGalleryPreviewUrls');
                if (!container)
                    return;
                container.innerHTML = '';
                if (!urls || urls.trim() === '')
                    return;

                var urlArray = urls.split(',');
                for (var i = 0; i < urlArray.length; i++) {
                    var url = urlArray[i].trim();
                    if (url !== '') {
                        var div = document.createElement('div');
                        div.className = 'preview-item';
                        div.innerHTML = `<img src="${url}" onerror="this.src='<%= request.getContextPath()%>/img/default.jpg'" style="object-fit:cover;width:100%;height:100%;">`;
                        container.appendChild(div);
                    }
                }
            }

// ===== SỰ KIỆN UPLOAD GALLERY =====
            document.addEventListener('DOMContentLoaded', function () {
                // Upload gallery
                var galleryDropArea = document.getElementById('editGalleryDropArea');
                var galleryInput = document.getElementById('editGalleryInput');

                if (galleryDropArea) {
                    galleryDropArea.addEventListener('click', function () {
                        if (galleryInput)
                            galleryInput.click();
                    });
                }

                if (galleryInput) {
                    galleryInput.addEventListener('change', function (e) {
                        var files = this.files;
                        var container = document.getElementById('editGalleryPreview');
                        if (!container)
                            return;

                        for (var i = 0; i < files.length; i++) {
                            var file = files[i];
                            var reader = new FileReader();
                            reader.onload = function (e) {
                                var div = document.createElement('div');
                                div.className = 'preview-item';
                                div.innerHTML = `
                        <img src="` + e.target.result + `" style="object-fit:cover;width:100%;height:100%;">
                        <span style="position:absolute;bottom:2px;right:4px;font-size:10px;color:#00639c;background:rgba(255,255,255,0.8);padding:0 4px;border-radius:2px;">📷</span>
                    `;
                                container.appendChild(div);
                            }
                            reader.readAsDataURL(file);
                        }
                        this.value = '';
                    });
                }

                // Preview link gallery
                var galleryUrls = document.getElementById('editGalleryUrls');
                if (galleryUrls) {
                    galleryUrls.addEventListener('input', function (e) {
                        previewEditGalleryUrls(this.value);
                    });
                }
            });
            // ===== THÊM DÒNG SIZE =====
            function addEditSizeRow(selectedSizeId, quantity) {
                var container = document.getElementById('editSizeContainer');
                var row = document.createElement('div');
                row.className = 'size-row';

                var select = document.createElement('select');
                select.name = 'size_id';
                select.className = 'size-select';
                select.style.cssText = 'flex:1; padding:8px 12px; border:0.5px solid #ddd; border-radius:6px; font-size:14px; background:#fafaf8;';

                var defaultOption = document.createElement('option');
                defaultOption.value = '';
                defaultOption.textContent = '-- Chọn size --';
                select.appendChild(defaultOption);

                for (var id in sizeMap) {
                    var option = document.createElement('option');
                    option.value = id;
                    option.textContent = sizeMap[id];
                    if (selectedSizeId && parseInt(id) === parseInt(selectedSizeId)) {
                        option.selected = true;
                    }
                    select.appendChild(option);
                }

                var input = document.createElement('input');
                input.type = 'number';
                input.name = 'soluong_size';
                input.placeholder = 'SL';
                input.min = '0';
                input.value = quantity || '0';
                input.style.cssText = 'width:100px; padding:8px 12px; border:0.5px solid #ddd; border-radius:6px; font-size:14px;';

                var removeBtn = document.createElement('button');
                removeBtn.type = 'button';
                removeBtn.className = 'remove-btn';
                removeBtn.textContent = '✕';
                removeBtn.style.cssText = 'background:#f8d7da; color:#c0392b; border:none; border-radius:6px; padding:0 12px; cursor:pointer; font-size:18px; height:40px;';
                removeBtn.onclick = function () {
                    if (container.querySelectorAll('.size-row').length > 1) {
                        row.remove();
                    } else {
                        alert('Phải có ít nhất 1 dòng size!');
                    }
                };

                row.appendChild(select);
                row.appendChild(input);
                row.appendChild(removeBtn);
                container.appendChild(row);
            }

            // ===== ĐÓNG MODAL =====
            function closeEditModal() {
                document.getElementById('editModal').classList.remove('active');
                document.body.style.overflow = '';
            }

            document.getElementById('editModal').addEventListener('click', function (e) {
                if (e.target === this) {
                    closeEditModal();
                }
            });

            document.addEventListener('keydown', function (e) {
                if (e.key === 'Escape') {
                    closeEditModal();
                }
            });

            // ===== ĐÓNG THÔNG BÁO =====
            function closeAlert() {
                var alert = document.getElementById('alertMessage');
                if (alert) {
                    alert.style.transition = 'opacity 0.3s';
                    alert.style.opacity = '0';
                    setTimeout(function () {
                        alert.style.display = 'none';
                    }, 300);
                }
            }

            setTimeout(function () {
                var alert = document.getElementById('alertMessage');
                if (alert) {
                    alert.style.transition = 'opacity 0.5s';
                    alert.style.opacity = '0';
                    setTimeout(function () {
                        alert.style.display = 'none';
                    }, 500);
                }
            }, 5000);
        </script>
    </body>
</html>