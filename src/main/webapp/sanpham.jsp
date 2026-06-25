<%-- 
    Document   : sanpham
    Created on : Mar 17, 2026
    Author     : Ma
--%>
<%@page import="DAO.dbconnect"%>
<%@ page contentType="text/html; charset=UTF-8" %>
<%@ page import="java.sql.*, java.util.*, model.sanpham, java.text.NumberFormat, java.util.Locale" %>

<%
    NumberFormat formatter = NumberFormat.getNumberInstance(new Locale("vi", "VN"));
    String keyword = request.getParameter("keyword");
    String cat = request.getParameter("cat");

    int pageSize = 9;
    int currentPage = 1;
    String pageParam = request.getParameter("page");
    if (pageParam != null && !pageParam.isEmpty()) {
        currentPage = Integer.parseInt(pageParam);
    }
    int offset = (currentPage - 1) * pageSize;
%>

<!DOCTYPE html>
<html class="scroll-smooth" lang="vi">
    <head>
        <meta charset="UTF-8">
        <meta name="viewport" content="width=device-width, initial-scale=1.0">
        <title>Sản phẩm - AURA</title>
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
                            "surface-container-low": "#f3f3f4",
                            "surface-container-lowest": "#ffffff",
                            "surface-container": "#eeeeee",
                            "on-primary": "#ffffff",
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
                        },
                        fontSize: {
                            "headline-lg": ["40px", {lineHeight: "1.2", fontWeight: "400"}],
                            "headline-md": ["24px", {lineHeight: "1.3", fontWeight: "400"}],
                            "body-md": ["16px", {lineHeight: "1.5", fontWeight: "400"}],
                            "label-sm": ["12px", {lineHeight: "1", letterSpacing: "0.1em", fontWeight: "600"}],
                        }
                    }
                }
            }
        </script>
        <style>
            .material-symbols-outlined {
                font-variation-settings: 'FILL' 0, 'wght' 300, 'GRAD' 0, 'opsz' 24;
            }
            .product-card:hover .product-image {
                transform: scale(1.05);
            }
            .product-image {
                transition: transform 0.7s ease;
            }
            .filter-active {
                background: #000000;
                color: #ffffff;
            }
        </style>
    </head>
    <body class="bg-surface text-on-surface font-body-md">

        <jsp:include page="header.jsp" />

        <main class="pt-24 pb-16 px-4 md:px-8 max-w-7xl mx-auto">
            <!-- Page Header -->
            <header class="mb-12 text-center">
                <h1 class="font-headline-lg text-headline-lg text-primary">
                    <% if (keyword != null && !keyword.trim().isEmpty()) { %>
                    Kết quả tìm kiếm: "<%= keyword %>"
                    <% } else if (cat != null && !cat.trim().isEmpty()) {
                        String tenDanhMuc = cat;
                        try (Connection conn = dbconnect.getConnection()) {
                            String sql = "SELECT ten_danhmuc FROM danhmuc WHERE slug=?";
                            PreparedStatement ps = conn.prepareStatement(sql);
                            ps.setString(1, cat);
                            ResultSet rs = ps.executeQuery();
                            if (rs.next()) {
                                tenDanhMuc = rs.getString("ten_danhmuc");
                            }
                            rs.close();
                            ps.close();
                        } catch (Exception e) {}
                    %>
                    <%= tenDanhMuc %>
                    <% } else { %>
                    Bộ Sưu Tập
                    <% } %>
                </h1>
                <p class="text-secondary font-body-md mt-2">Khám phá những tác phẩm trang sức tinh tế</p>
            </header>

            <div class="flex flex-col md:flex-row gap-12">
                <!-- Sidebar -->
                <aside class="w-full md:w-64 flex-shrink-0">
                    <div class="sticky top-24 space-y-8">
                        <!-- Search -->
                        <form method="get" action="sanpham.jsp">
                            <div class="border-b border-outline-variant pb-2 flex items-center">
                                <input type="text" name="keyword" value="<%= keyword != null ? keyword : "" %>"
                                       placeholder="Tìm kiếm..." 
                                       class="w-full bg-transparent border-0 focus:ring-0 outline-none font-body-md text-sm text-on-surface placeholder:text-outline">
                                <button type="submit" class="text-secondary hover:text-primary transition-colors">
                                    <span class="material-symbols-outlined">search</span>
                                </button>
                            </div>
                        </form>

                        <!-- Categories -->
                        <div>
                            <h3 class="font-label-sm text-label-sm text-primary mb-4">Danh Mục</h3>
                            <div class="space-y-2">
                                <a href="sanpham.jsp" class="block font-body-md text-sm <%= (cat == null) ? "text-primary font-medium" : "text-secondary hover:text-primary" %> transition-colors">
                                    Tất cả
                                </a>
                                <%
                                    try (Connection conn = dbconnect.getConnection()) {
                                        String sql = "SELECT * FROM danhmuc ORDER BY thu_tu";
                                        PreparedStatement ps = conn.prepareStatement(sql);
                                        ResultSet rs = ps.executeQuery();
                                        while (rs.next()) {
                                            String slug = rs.getString("slug");
                                            String ten = rs.getString("ten_danhmuc");
                                %>
                                <a href="sanpham.jsp?cat=<%= slug %>" 
                                   class="block font-body-md text-sm <%= slug.equals(cat) ? "text-primary font-medium" : "text-secondary hover:text-primary" %> transition-colors">
                                    <%= ten %>
                                </a>
                                <%
                                        }
                                    } catch (Exception e) {}
                                %>
                            </div>
                        </div>
                    </div>
                </aside>

                <!-- Product Grid -->
                <div class="flex-1">
                    <div class="grid grid-cols-1 sm:grid-cols-2 lg:grid-cols-3 gap-8">
                        <%
                            Connection conn = null;
                            PreparedStatement ps = null;
                            ResultSet rs = null;
                            int totalProducts = 0;

                            try {
                                conn = dbconnect.getConnection();

                                // Count total
                                String countSql = "SELECT COUNT(*) FROM sanpham sp JOIN danhmuc dm ON sp.danhmuc_id = dm.id WHERE 1=1";
                                if (keyword != null && !keyword.trim().isEmpty()) {
                                    countSql += " AND sp.ten LIKE ?";
                                }
                                if (cat != null && !cat.trim().isEmpty()) {
                                    countSql += " AND dm.slug = ?";
                                }

                                PreparedStatement psCount = conn.prepareStatement(countSql);
                                int idx = 1;
                                if (keyword != null && !keyword.trim().isEmpty()) {
                                    psCount.setString(idx++, "%" + keyword + "%");
                                }
                                if (cat != null && !cat.trim().isEmpty()) {
                                    psCount.setString(idx++, cat);
                                }
                                ResultSet rsCount = psCount.executeQuery();
                                if (rsCount.next()) {
                                    totalProducts = rsCount.getInt(1);
                                }
                                rsCount.close();
                                psCount.close();

                                // Get products
                                String sql = "SELECT sp.*, dm.ten_danhmuc FROM sanpham sp "
                                        + "JOIN danhmuc dm ON sp.danhmuc_id = dm.id WHERE 1=1";
                                if (keyword != null && !keyword.trim().isEmpty()) {
                                    sql += " AND sp.ten LIKE ?";
                                }
                                if (cat != null && !cat.trim().isEmpty()) {
                                    sql += " AND dm.slug = ?";
                                }
                                sql += " ORDER BY sp.id DESC LIMIT ? OFFSET ?";

                                ps = conn.prepareStatement(sql);
                                idx = 1;
                                if (keyword != null && !keyword.trim().isEmpty()) {
                                    ps.setString(idx++, "%" + keyword + "%");
                                }
                                if (cat != null && !cat.trim().isEmpty()) {
                                    ps.setString(idx++, cat);
                                }
                                ps.setInt(idx++, pageSize);
                                ps.setInt(idx++, offset);

                                rs = ps.executeQuery();

                                if (!rs.isBeforeFirst()) {
                        %>
                        <div class="col-span-full text-center py-20">
                            <span class="material-symbols-outlined text-6xl text-outline mb-4">inbox</span>
                            <h3 class="text-xl font-medium mb-2">Không tìm thấy sản phẩm</h3>
                            <p class="text-secondary">Hãy thử tìm kiếm với từ khóa khác!</p>
                        </div>
                        <%
                            }

                            while (rs.next()) {
                                int id = rs.getInt("id");
                                String ten = rs.getString("ten");
                                int gia = rs.getInt("gia");
                                int giaKm = rs.getInt("gia_km");
                                String anh = rs.getString("anh");
                                String danhmuc = rs.getString("ten_danhmuc");
                                int giaHienTai = (giaKm > 0 && giaKm < gia) ? giaKm : gia;
                                boolean isLink = (anh != null && (anh.startsWith("http://") || anh.startsWith("https://")));
                                String src = isLink ? anh : "img/" + anh;
                        %>
                        <div class="group product-card">
                            <a href="chitiet?id=<%= id %>">
                                <div class="aspect-[3/4] overflow-hidden bg-surface-container-low relative mb-4">
                                    <img src="<%= src %>" 
                                         alt="<%= ten %>" 
                                         class="product-image w-full h-full object-cover"
                                         onerror="this.src='img/default.jpg'">
                                    <% if (giaKm > 0 && giaKm < gia) { %>
                                    <div class="absolute top-4 left-4 bg-error text-white text-xs px-3 py-1 rounded-full font-label-sm tracking-wider">
                                        -<%= Math.round((1 - (double) giaKm / gia) * 100)%>% 
                                    </div>
                                    <% } %>
                                    <a href="themgiohang?id=<%= id %>&soluong=1" 
                                       class="absolute bottom-4 right-4 bg-primary/80 backdrop-blur-md p-3 rounded-full opacity-0 translate-y-2 group-hover:opacity-100 group-hover:translate-y-0 transition-all duration-300">
                                        <span class="material-symbols-outlined text-white text-sm">add_shopping_cart</span>
                                    </a>
                                </div>
                            </a>
                            <div class="text-center">
                                <p class="font-label-sm text-[10px] tracking-widest text-outline uppercase mb-1"><%= danhmuc %></p>
                                <a href="chitiet?id=<%= id %>">
                                    <h3 class="font-body-md font-medium hover:text-primary transition-colors"><%= ten %></h3>
                                </a>
                                <p class="font-body-md text-secondary mt-1">
                                    <% if (giaKm > 0 && giaKm < gia) { %>
                                    <span class="text-primary font-semibold"><%= formatter.format(giaHienTai) %>đ</span>
                                    <span class="text-outline line-through ml-2"><%= formatter.format(gia) %>đ</span>
                                    <% } else { %>
                                    <span class="text-primary font-semibold"><%= formatter.format(gia) %>đ</span>
                                    <% } %>
                                </p>
                            </div>
                        </div>
                        <%
                                }
                            } catch (Exception e) {
                                e.printStackTrace();
                            } finally {
                                if (rs != null) try { rs.close(); } catch (Exception e) {}
                                if (ps != null) try { ps.close(); } catch (Exception e) {}
                                if (conn != null) try { conn.close(); } catch (Exception e) {}
                            }
                        %>
                    </div>

                    <!-- Pagination -->
                    <% if (totalProducts > pageSize) {
                            int totalPages = (int) Math.ceil((double) totalProducts / pageSize);
                    %>
                    <div class="mt-16 flex justify-center">
                        <div class="flex gap-2 flex-wrap">
                            <% if (currentPage > 1) { %>
                            <a href="?page=<%= currentPage - 1 %><%= keyword != null ? "&keyword=" + keyword : "" %><%= cat != null ? "&cat=" + cat : "" %>"
                               class="w-10 h-10 rounded-full border border-outline-variant flex items-center justify-center hover:border-primary hover:text-primary transition-colors">
                                <span class="material-symbols-outlined text-sm">chevron_left</span>
                            </a>
                            <% } %>
                            <% for (int i = Math.max(1, currentPage - 2); i <= Math.min(totalPages, currentPage + 2); i++) { %>
                            <a href="?page=<%= i %><%= keyword != null ? "&keyword=" + keyword : "" %><%= cat != null ? "&cat=" + cat : "" %>"
                               class="w-10 h-10 rounded-full flex items-center justify-center transition-colors <%= currentPage == i ? "bg-primary text-white" : "border border-outline-variant hover:border-primary hover:text-primary" %>">
                                <%= i %>
                            </a>
                            <% } %>
                            <% if (currentPage < totalPages) { %>
                            <a href="?page=<%= currentPage + 1 %><%= keyword != null ? "&keyword=" + keyword : "" %><%= cat != null ? "&cat=" + cat : "" %>"
                               class="w-10 h-10 rounded-full border border-outline-variant flex items-center justify-center hover:border-primary hover:text-primary transition-colors">
                                <span class="material-symbols-outlined text-sm">chevron_right</span>
                            </a>
                            <% } %>
                        </div>
                    </div>
                    <% } %>
                </div>
            </div>
        </main>

        <jsp:include page="footer.jsp" />

    </body>
</html>