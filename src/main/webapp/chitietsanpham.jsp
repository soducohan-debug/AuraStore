<%-- 
    Document   : chitietsanpham
    Created on : Mar 17, 2026
    Author     : Ma
--%>
<%@ page contentType="text/html;charset=UTF-8" %>
<%@ page import="model.sanpham, model.Size, java.util.*, java.text.NumberFormat, java.util.Locale, java.sql.*, DAO.dbconnect" %>

<%
    NumberFormat formatter = NumberFormat.getNumberInstance(new Locale("vi", "VN"));
    sanpham sp = (sanpham) request.getAttribute("sp");

    // Lấy hướng dẫn size cho loại sản phẩm
    String loaiSanPham = "";
    if (sp != null) {
        String tenDanhMuc = sp.getTenDanhMuc();
        if (tenDanhMuc != null) {
            if (tenDanhMuc.contains("Nhẫn")) {
                loaiSanPham = "nhan";
            } else if (tenDanhMuc.contains("Vòng Tay")) {
                loaiSanPham = "vong-tay";
            } else if (tenDanhMuc.contains("Dây Chuyền")) {
                loaiSanPham = "day-chuyen";
            }
        }
    }

    // Lấy hướng dẫn từ database
    List<Map<String, String>> huongDanList = new ArrayList<>();
    if (!loaiSanPham.isEmpty()) {
        try {
            Connection conn = dbconnect.getConnection();
            String sql = "SELECT * FROM huong_dan_size WHERE loai_sanpham = ? ORDER BY thu_tu";
            PreparedStatement ps = conn.prepareStatement(sql);
            ps.setString(1, loaiSanPham);
            ResultSet rs = ps.executeQuery();
            while (rs.next()) {
                Map<String, String> item = new HashMap<>();
                item.put("tieu_de", rs.getString("tieu_de"));
                item.put("noi_dung", rs.getString("noi_dung"));
                item.put("hinh_anh", rs.getString("hinh_anh"));
                huongDanList.add(item);
            }
            rs.close();
            ps.close();
            conn.close();
        } catch (Exception e) {
            e.printStackTrace();
        }
    }

    // Lấy danh sách ảnh gallery
    List<String> allImages = new ArrayList<>();
    if (sp != null) {
        if (sp.getAnh() != null && !sp.getAnh().isEmpty()) {
            allImages.add(sp.getAnh());
        }
        List<String> galleryList = sp.getAnhGallery();
        if (galleryList != null && !galleryList.isEmpty()) {
            for (String img : galleryList) {
                if (img != null && !img.trim().isEmpty()) {
                    if (!allImages.contains(img.trim())) {
                        allImages.add(img.trim());
                    }
                }
            }
        }
        if (allImages.isEmpty()) {
            allImages.add("default.jpg");
        }
    }

    // Lấy sản phẩm liên quan
    List<sanpham> relatedProducts = new ArrayList<>();
    if (sp != null) {
        try {
            Connection conn = dbconnect.getConnection();
            String sql = "SELECT sp.*, dm.ten_danhmuc FROM sanpham sp "
                    + "JOIN danhmuc dm ON sp.danhmuc_id = dm.id "
                    + "WHERE sp.danhmuc_id = ? AND sp.id != ? "
                    + "ORDER BY RAND() LIMIT 4";
            PreparedStatement ps = conn.prepareStatement(sql);
            ps.setInt(1, sp.getDanhMucId());
            ps.setInt(2, sp.getId());
            ResultSet rs = ps.executeQuery();
            while (rs.next()) {
                sanpham spRelate = new sanpham(
                        rs.getInt("id"),
                        rs.getString("ten"),
                        rs.getInt("gia"),
                        rs.getString("anh") != null ? rs.getString("anh") : "default.jpg",
                        rs.getString("mota") != null ? rs.getString("mota") : "",
                        rs.getString("ten_danhmuc") != null ? rs.getString("ten_danhmuc") : "Chưa phân loại"
                );
                spRelate.setGiaKm(rs.getInt("gia_km") == 0 ? null : rs.getInt("gia_km"));
                spRelate.setChatlieu(rs.getString("chatlieu"));
                spRelate.setTrongLuong(rs.getDouble("trong_luong"));
                spRelate.setBaoHanh(rs.getInt("bao_hanh"));
                spRelate.setDanhMucId(rs.getInt("danhmuc_id"));
                spRelate.setFeatured(rs.getBoolean("is_featured"));
                spRelate.setNew(rs.getBoolean("is_new"));
                spRelate.setBestseller(rs.getBoolean("is_bestseller"));
                relatedProducts.add(spRelate);
            }
            rs.close();
            ps.close();
            conn.close();
        } catch (Exception e) {
            e.printStackTrace();
        }
    }
%>

<!DOCTYPE html>
<html class="scroll-smooth" lang="vi">
    <head>
        <meta charset="UTF-8">
        <meta name="viewport" content="width=device-width, initial-scale=1.0">
        <title><%= sp != null ? sp.getTen() : "Chi tiết sản phẩm"%> | AURA</title>
        <script src="https://cdn.tailwindcss.com?plugins=forms,container-queries"></script>
        <link href="https://fonts.googleapis.com/css2?family=Playfair+Display:wght@400;500;600;700&family=Montserrat:wght@300;400;500;600&display=swap" rel="stylesheet">
        <link href="https://fonts.googleapis.com/css2?family=Material+Symbols+Outlined:wght,FILL@100..700,0..1&display=swap" rel="stylesheet">
        <script>
            tailwind.config = {
                theme: {
                    extend: {
                        colors: {
                            "surface": "#f9f9f9",
                            "on-surface": "#1a1c1c",
                            "on-surface-variant": "#4c4546",
                            "primary": "#000000",
                            "secondary": "#5d5e5f",
                            "outline": "#7e7576",
                            "outline-variant": "#cfc4c5",
                            "surface-container": "#eeeeee",
                            "surface-container-low": "#f3f3f4",
                            "error": "#ba1a1a",
                            "background": "#f9f9f9",
                        },
                        fontFamily: {
                            "headline-display": ["Playfair Display", "serif"],
                            "headline-lg": ["Playfair Display", "serif"],
                            "headline-md": ["Playfair Display", "serif"],
                            "body-lg": ["Montserrat", "sans-serif"],
                            "body-md": ["Montserrat", "sans-serif"],
                            "label-sm": ["Montserrat", "sans-serif"],
                        }
                    }
                }
            }
        </script>
        <style>
            .material-symbols-outlined {
                font-variation-settings: 'FILL' 0, 'wght' 300, 'GRAD' 0, 'opsz' 24;
            }
            .size-btn {
                cursor: pointer;
                user-select: none;
                transition: all 0.3s ease;
                padding: 10px 20px;
                border: 1px solid #cfc4c5;
                border-radius: 8px;
                background: transparent;
                font-family: 'Montserrat', sans-serif;
                font-size: 14px;
                color: #5d5e5f;
            }
            .size-btn:hover {
                border-color: #000000;
                color: #000000;
            }
            .size-btn.selected {
                border-color: #000000;
                background: #000000;
                color: #ffffff;
            }
            .size-btn .stock-info {
                display: block;
                font-size: 10px;
                color: #999;
                margin-top: 2px;
            }
            .size-btn.selected .stock-info {
                color: rgba(255,255,255,0.7);
            }
            .gallery-thumb {
                cursor: pointer;
                transition: all 0.3s ease;
                border: 2px solid transparent;
                border-radius: 8px;
                overflow: hidden;
            }
            .gallery-thumb:hover {
                border-color: #000000;
            }
            .gallery-thumb.active {
                border-color: #000000;
            }
            .main-image-container {
                position: relative;
                overflow: hidden;
                border-radius: 12px;
                background: #f3f3f4;
            }
            .main-image-container img {
                transition: transform 0.5s ease;
                width: 100%;
                height: 100%;
                object-fit: cover;
            }
            .main-image-container:hover img {
                transform: scale(1.03);
            }
            .quantity-btn {
                width: 36px;
                height: 36px;
                display: flex;
                align-items: center;
                justify-content: center;
                border: none;
                background: transparent;
                cursor: pointer;
                transition: all 0.2s;
                border-radius: 50%;
                color: #5d5e5f;
                font-size: 18px;
            }
            .quantity-btn:hover {
                background: #eeeeee;
                color: #000000;
            }
            .quantity-input {
                width: 48px;
                text-align: center;
                border: none;
                outline: none;
                font-size: 16px;
                font-weight: 500;
                background: transparent;
                font-family: 'Montserrat', sans-serif;
            }
            .breadcrumb a {
                transition: color 0.3s ease;
            }
            .breadcrumb a:hover {
                color: #000000;
            }
            .size-guide-btn {
                font-size: 12px;
                color: #5d5e5f;
                cursor: pointer;
                transition: color 0.3s ease;
                background: none;
                border: none;
                font-family: 'Montserrat', sans-serif;
            }
            .size-guide-btn:hover {
                color: #000000;
            }
            /* Modal Size Guide */
            .size-guide-modal {
                display: none;
                position: fixed;
                top: 0;
                left: 0;
                width: 100%;
                height: 100%;
                background: rgba(0,0,0,0.5);
                z-index: 9999;
                justify-content: center;
                align-items: center;
                padding: 20px;
                backdrop-filter: blur(4px);
            }
            .size-guide-modal.active {
                display: flex;
            }
            .size-guide-modal .modal-content {
                background: #fff;
                border-radius: 12px;
                max-width: 700px;
                width: 100%;
                max-height: 90vh;
                overflow-y: auto;
                padding: 32px;
                position: relative;
                animation: slideUp 0.3s ease;
            }
            @keyframes slideUp {
                from {
                    opacity: 0;
                    transform: translateY(30px);
                }
                to {
                    opacity: 1;
                    transform: translateY(0);
                }
            }
            .size-guide-modal .modal-header {
                display: flex;
                justify-content: space-between;
                align-items: center;
                margin-bottom: 24px;
                padding-bottom: 16px;
                border-bottom: 1px solid #cfc4c5;
            }
            .size-guide-modal .modal-header h2 {
                font-family: 'Playfair Display', serif;
                font-size: 22px;
                font-weight: 700;
                color: #000000;
            }
            .size-guide-modal .modal-header .close-btn {
                font-size: 28px;
                cursor: pointer;
                color: #999;
                transition: all 0.3s;
                background: none;
                border: none;
                padding: 0 8px;
            }
            .size-guide-modal .modal-header .close-btn:hover {
                color: #000000;
                transform: rotate(90deg);
            }
            .size-guide-modal .content .step {
                margin-bottom: 16px;
                padding: 12px 16px;
                background: #f9f9f9;
                border-radius: 8px;
                border-left: 3px solid #000000;
            }
            .size-guide-modal .content .step h4 {
                font-weight: 600;
                color: #000000;
                margin-bottom: 4px;
                font-size: 14px;
            }
            .size-guide-modal .content .step p {
                color: #5d5e5f;
                line-height: 1.6;
                font-size: 13px;
            }
            .size-guide-modal .content .size-table {
                width: 100%;
                border-collapse: collapse;
                margin: 12px 0;
                font-size: 13px;
            }
            .size-guide-modal .content .size-table thead {
                background: #000000;
                color: #fff;
            }
            .size-guide-modal .content .size-table th,
            .size-guide-modal .content .size-table td {
                padding: 10px 12px;
                text-align: center;
                border: 1px solid #ddd;
            }
            .size-guide-modal .content .size-table tbody tr:nth-child(even) {
                background: #f9f9f9;
            }
            .size-guide-modal .content .note {
                margin-top: 12px;
                padding: 12px 16px;
                background: #fff3cd;
                border-radius: 8px;
                color: #856404;
                font-size: 13px;
                border: 1px solid #ffeaa7;
            }
            .size-guide-modal .content img {
                max-width: 100%;
                border-radius: 8px;
                margin: 12px 0;
            }
            /* Related Products */
            .related-item:hover .related-image {
                transform: scale(1.08);
            }
            .related-image {
                transition: transform 0.5s ease;
            }
        </style>
    </head>
    <body class="bg-surface text-on-surface font-body-md">

        <jsp:include page="header.jsp" />

        <main class="pt-28 pb-16 px-4 md:px-8 max-w-6xl mx-auto">
            <% if (sp != null) {%>
            <!-- Breadcrumb -->
            <div class="flex items-center gap-2 text-sm text-secondary mb-8 breadcrumb">
                <a href="index.jsp" class="hover:text-primary transition-colors">Trang chủ</a>
                <span class="material-symbols-outlined text-sm">chevron_right</span>
                <a href="sanpham.jsp" class="hover:text-primary transition-colors">Sản phẩm</a>
                <span class="material-symbols-outlined text-sm">chevron_right</span>
                <span class="text-primary font-medium"><%= sp.getTen()%></span>
            </div>

            <div class="grid grid-cols-1 lg:grid-cols-2 gap-12">
                <!-- ===== IMAGE GALLERY ===== -->
                <div>
                    <div class="main-image-container aspect-square">
                        <%
                            String firstImage = allImages.get(0);
                            boolean isLink = (firstImage != null && (firstImage.startsWith("http://") || firstImage.startsWith("https://")));
                            String mainSrc = isLink ? firstImage : "img/" + firstImage;
                        %>
                        <img id="mainImage" 
                             src="<%= mainSrc%>" 
                             alt="<%= sp.getTen()%>"
                             onerror="this.src='img/default.jpg'">
                    </div>

                    <!-- Thumbnails -->
                    <% if (allImages.size() > 1) { %>
                    <div class="grid grid-cols-5 gap-3 mt-4">
                        <% for (int i = 0; i < allImages.size(); i++) {
                                String img = allImages.get(i);
                                boolean isActive = (i == 0);
                                boolean isImgLink = (img != null && (img.startsWith("http://") || img.startsWith("https://")));
                                String thumbSrc = isImgLink ? img : "img/" + img;
                        %>
                        <div class="gallery-thumb <%= isActive ? "active" : ""%>"
                             onclick="changeImage(this, '<%= thumbSrc%>')">
                            <img src="<%= thumbSrc%>" 
                                 alt="<%= sp.getTen()%>"
                                 class="w-full h-full object-cover aspect-square"
                                 onerror="this.src='img/default.jpg'">
                        </div>
                        <% } %>
                    </div>
                    <% }%>
                </div>

                <!-- ===== PRODUCT INFO ===== -->
                <div>
                    <p class="font-label-sm text-[10px] tracking-widest text-outline uppercase mb-2">
                        <%= sp.getTenDanhMuc()%>
                    </p>
                    <h1 class="font-playfair text-3xl md:text-4xl font-bold text-primary mb-4">
                        <%= sp.getTen()%>
                    </h1>

                    <!-- Price -->
                    <div class="mb-6">
                        <% if (sp.getGiaKm() != null && sp.getGiaKm() > 0 && sp.getGiaKm() < sp.getGia()) {%>
                        <span class="text-2xl font-bold text-primary"><%= formatter.format(sp.getGiaKm())%>đ</span>
                        <span class="text-sm text-outline line-through ml-3"><%= formatter.format(sp.getGia())%>đ</span>
                        <span class="ml-3 bg-error text-white text-xs px-3 py-1 rounded-full font-label-sm tracking-wider">
                            -<%= Math.round((1 - (double) sp.getGiaKm() / sp.getGia()) * 100)%>%
                        </span>
                        <% } else {%>
                        <span class="text-2xl font-bold text-primary"><%= formatter.format(sp.getGia())%>đ</span>
                        <% } %>
                    </div>

                    <!-- Details -->
                    <div class="space-y-3 mb-8 text-sm">
                        <% if (sp.getChatlieu() != null && !sp.getChatlieu().isEmpty()) {%>
                        <div class="flex">
                            <span class="w-24 text-secondary">Chất liệu:</span>
                            <span class="font-medium"><%= sp.getChatlieu()%></span>
                        </div>
                        <% } %>
                        <% if (sp.getTrongLuong() != null && sp.getTrongLuong() > 0) {%>
                        <div class="flex">
                            <span class="w-24 text-secondary">Trọng lượng:</span>
                            <span class="font-medium"><%= String.format("%.1f", sp.getTrongLuong())%> gram</span>
                        </div>
                        <% } %>
                        <% if (sp.getBaoHanh() != null && sp.getBaoHanh() > 0) {%>
                        <div class="flex">
                            <span class="w-24 text-secondary">Bảo hành:</span>
                            <span class="font-medium"><%= sp.getBaoHanh()%> tháng</span>
                        </div>
                        <% }%>
                    </div>

                    <!-- Description -->
                    <div class="mb-8">
                        <h3 class="font-playfair font-bold text-lg text-primary mb-3">Mô tả</h3>
                        <p class="text-secondary text-sm leading-relaxed"><%= sp.getMota() != null ? sp.getMota() : "Chưa có mô tả chi tiết."%></p>
                    </div>

                    <!-- ===== ADD TO CART FORM ===== -->
                    <form action="themgiohang" method="get" class="space-y-6" id="addToCartForm">
                        <input type="hidden" name="id" value="<%= sp.getId()%>">

                        <!-- Size Selection -->
                        <%
                            boolean hasSize = false;
                            if (sp != null && sp.getSizes() != null && !sp.getSizes().isEmpty()) {
                                for (Size size : sp.getSizes().keySet()) {
                                    if (size.getId() > 0) {
                                        hasSize = true;
                                        break;
                                    }
                                }
                            }
                            if (hasSize) {
                        %>
                        <div>
                            <div class="flex items-center justify-between">
                                <label class="font-medium text-sm text-primary">Kích thước <span class="text-error">*</span></label>
                                <% if (!huongDanList.isEmpty()) { %>
                                <button type="button" class="size-guide-btn" onclick="openSizeGuide()">
                                    <span class="material-symbols-outlined text-sm">help</span>
                                    Hướng dẫn đo size
                                </button>
                                <% } %>
                            </div>
                            <div class="flex flex-wrap gap-3 mt-3" id="sizeContainer">
                                <% for (Map.Entry<Size, Integer> entry : sp.getSizes().entrySet()) {
                                        Size size = entry.getKey();
                                        int tonKho = entry.getValue();
                                        if (tonKho > 0 && size.getId() > 0) {
                                %>
                                <button type="button" 
                                        onclick="selectSize(<%= size.getId()%>, <%= tonKho%>, this)"
                                        class="size-btn"
                                        data-size-id="<%= size.getId()%>"
                                        data-ton-kho="<%= tonKho%>">
                                    <%= size.getTenSize()%>
                                    <span class="stock-info">Còn <%= tonKho%></span>
                                </button>
                                <% } %>
                                <% } %>
                            </div>
                            <input type="hidden" name="sizeId" id="selectedSizeId" value="">
                            <p class="text-xs text-secondary mt-2" id="sizeHint">Vui lòng chọn kích thước</p>
                        </div>
                        <% } else { %>
                        <input type="hidden" name="sizeId" value="0">
                        <% }%>


                        <!-- Số lượng -->
                        <div>
                            <label class="font-medium text-sm text-primary block mb-2">Số lượng</label>
                            <div class="flex items-center border border-outline-variant/50 rounded-full w-fit">
                                <button type="button" onclick="changeQuantity(-1)" class="quantity-btn">−</button>
                                <input type="number" name="soluong" id="quantity" value="1" min="1" 
                                       max="999" data-max-stock="<%= sp.getTotalSoluong() > 0 ? sp.getTotalSoluong() : sp.getSoluong()%>"
                                       class="quantity-input">
                                <button type="button" onclick="changeQuantity(1)" class="quantity-btn">+</button>
                            </div>
                            <p class="text-xs text-secondary mt-1">
                                Tồn kho: <strong id="stockDisplay">
                                    <%
                                        int stock = sp.getTotalSoluong() > 0 ? sp.getTotalSoluong() : sp.getSoluong();
                                        if (stock > 0) {
                                            out.print(stock);
                                        } else {
                                            out.print("Hết hàng");
                                        }
                                    %>
                                </strong>
                            </p>
                        </div>

                        <!-- Submit -->
                        <button type="submit" id="submitBtn"
                                class="w-full py-4 bg-primary text-white font-label-sm text-label-sm tracking-widest hover:bg-on-surface-variant transition-colors">
                            🛒 Thêm vào giỏ hàng
                        </button>
                    </form>
                </div>
            </div>

            <!-- ===== RELATED PRODUCTS ===== -->
            <% if (relatedProducts != null && !relatedProducts.isEmpty()) { %>
            <section class="mt-20 pt-12 border-t border-outline-variant/30">
                <h2 class="font-playfair text-2xl font-bold text-center text-primary mb-8">
                    ✨ Có thể bạn cũng thích
                </h2>
                <div class="grid grid-cols-2 md:grid-cols-4 gap-4">
                    <% for (sanpham relate : relatedProducts) {
                            int giaHienTai = relate.getGiaHienTai();
                            boolean hasDiscount = (relate.getGiaKm() != null && relate.getGiaKm() > 0 && relate.getGiaKm() < relate.getGia());
                            String relateAnh = relate.getAnh();
                            boolean isRelateLink = (relateAnh != null && (relateAnh.startsWith("http://") || relateAnh.startsWith("https://")));
                            String relateSrc = isRelateLink ? relateAnh : "img/" + relateAnh;
                    %>
                    <a href="chitiet?id=<%= relate.getId()%>" class="related-item group bg-white rounded-xl overflow-hidden border border-outline-variant/30 hover:shadow-lg transition-all">
                        <div class="aspect-square overflow-hidden bg-surface">
                            <img class="related-image w-full h-full object-cover" 
                                 src="<%= relateSrc%>" 
                                 alt="<%= relate.getTen()%>"
                                 onerror="this.src='img/default.jpg'">
                        </div>
                        <div class="p-3">
                            <p class="text-[10px] tracking-widest text-outline uppercase font-label-sm"><%= relate.getTenDanhMuc()%></p>
                            <h3 class="font-medium text-sm mt-1 group-hover:text-primary transition-colors"><%= relate.getTen()%></h3>
                            <p class="text-primary font-semibold text-sm mt-1">
                                <%= formatter.format(giaHienTai)%>đ
                                <% if (hasDiscount) {%>
                                <span class="text-outline line-through text-xs ml-1"><%= formatter.format(relate.getGia())%>đ</span>
                                <% } %>
                            </p>
                        </div>
                    </a>
                    <% } %>
                </div>
            </section>
            <% } %>

            <% } else { %>
            <div class="text-center py-20">
                <span class="material-symbols-outlined text-6xl text-outline mb-4">error</span>
                <h2 class="text-xl font-medium mb-2">Không tìm thấy sản phẩm!</h2>
                <a href="sanpham.jsp" class="inline-block mt-4 px-6 py-2 bg-primary text-white text-sm font-label-sm tracking-wider hover:bg-on-surface-variant transition-colors">
                    Quay lại
                </a>
            </div>
            <% } %>
        </main>

        <!-- ===== SIZE GUIDE MODAL ===== -->
        <div class="size-guide-modal" id="sizeGuideModal">
            <div class="modal-content">
                <div class="modal-header">
                    <h2>📏 Hướng dẫn đo size</h2>
                    <button class="close-btn" onclick="closeSizeGuide()">✕</button>
                </div>
                <div class="content">
                    <% if (!huongDanList.isEmpty()) {
                            for (Map<String, String> item : huongDanList) {
                    %>
                    <h3 style="font-size:18px;font-weight:600;margin-bottom:12px;color:#000;">
                        <%= item.get("tieu_de")%>
                    </h3>
                    <div>
                        <%= item.get("noi_dung")%>
                    </div>
                    <% if (item.get("hinh_anh") != null && !item.get("hinh_anh").isEmpty()) {%>
                    <img src="img/<%= item.get("hinh_anh")%>" 
                         alt="<%= item.get("tieu_de")%>"
                         onerror="this.style.display='none'">
                    <% } %>
                    <hr style="margin:20px 0;border-color:#cfc4c5;">
                    <% }
                    } else { %>
                    <p style="color:#999;text-align:center;padding:20px;">
                        Chưa có hướng dẫn cho sản phẩm này.
                    </p>
                    <% }%>
                </div>
            </div>
        </div>

        <jsp:include page="footer.jsp" />

        <script>
            var selectedSizeId = null;
            var selectedTonKho = 0;
            var hasSize = <%= (sp != null && sp.getSizes() != null && !sp.getSizes().isEmpty()) ? "true" : "false"%>;

            // ===== HÀM CHỌN SIZE =====
            function selectSize(sizeId, tonKho, button) {
                selectedSizeId = sizeId;
                selectedTonKho = tonKho;
                document.getElementById('selectedSizeId').value = sizeId;

                var qtyInput = document.getElementById('quantity');
                if (qtyInput) {
                    qtyInput.max = tonKho;
                    qtyInput.dataset.maxStock = tonKho;
                    if (parseInt(qtyInput.value) > tonKho) {
                        qtyInput.value = tonKho;
                    }
                    var stockDisplay = document.getElementById('stockDisplay');
                    if (stockDisplay) {
                        stockDisplay.textContent = tonKho;
                    }
                }

                var hint = document.getElementById('sizeHint');
                if (hint) {
                    var sizeName = button.textContent.trim().split('Còn')[0].trim();
                    hint.textContent = '✓ Đã chọn size ' + sizeName + ', còn lại ' + tonKho + ' sản phẩm';
                    hint.className = 'text-xs text-primary mt-2';
                }

                var allButtons = document.querySelectorAll('.size-btn');
                allButtons.forEach(function (btn) {
                    btn.className = 'size-btn';
                });
                button.className = 'size-btn selected';
            }

            // ===== HÀM THAY ĐỔI SỐ LƯỢNG =====
            function changeQuantity(delta) {
                var input = document.getElementById('quantity');
                var val = parseInt(input.value) + delta;
                var min = parseInt(input.min) || 1;
                var max = parseInt(input.max) || 999;

                // Lấy số lượng tồn kho từ data attribute
                var maxStock = parseInt(input.dataset.maxStock) || 999;

                // Nếu chưa chọn size nhưng sản phẩm có size, không cho tăng
                if (hasSize && !selectedSizeId && delta > 0) {
                    alert('Vui lòng chọn kích thước trước!');
                    return;
                }

                // Kiểm tra giới hạn
                if (val >= min && val <= max && val <= maxStock) {
                    input.value = val;
                } else if (val > maxStock && maxStock > 0 && maxStock < 999) {
                    alert('Số lượng không được vượt quá tồn kho (' + maxStock + ' sản phẩm)');
                    input.value = maxStock;
                } else if (val > max && max < 999) {
                    alert('Số lượng không được vượt quá ' + max);
                }
            }

            // ===== HÀM ĐỔI ẢNH =====
            function changeImage(element, imageUrl) {
                var mainImage = document.getElementById('mainImage');
                mainImage.style.opacity = '0';
                setTimeout(function () {
                    mainImage.src = imageUrl;
                    mainImage.style.opacity = '1';
                }, 200);

                var allThumbs = document.querySelectorAll('.gallery-thumb');
                allThumbs.forEach(function (item) {
                    item.classList.remove('active');
                });
                element.classList.add('active');
            }

            // ===== SIZE GUIDE =====
            function openSizeGuide() {
                document.getElementById('sizeGuideModal').classList.add('active');
                document.body.style.overflow = 'hidden';
            }

            function closeSizeGuide() {
                document.getElementById('sizeGuideModal').classList.remove('active');
                document.body.style.overflow = '';
            }

            document.getElementById('sizeGuideModal').addEventListener('click', function (e) {
                if (e.target === this) {
                    closeSizeGuide();
                }
            });

            document.addEventListener('keydown', function (e) {
                if (e.key === 'Escape') {
                    closeSizeGuide();
                }
            });

            // ===== SUBMIT VALIDATION =====
            document.addEventListener('DOMContentLoaded', function () {
                var form = document.getElementById('addToCartForm');
                if (form) {
                    form.addEventListener('submit', function (e) {
                        if (hasSize) {
                            if (!selectedSizeId) {
                                e.preventDefault();
                                alert('Vui lòng chọn kích thước sản phẩm!');
                                return false;
                            }
                        }
                        return true;
                    });
                }
            });
        </script>

    </body>
</html>