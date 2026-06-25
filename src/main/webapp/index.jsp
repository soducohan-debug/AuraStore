<%-- 
    Document   : index
    Created on : Mar 16, 2026
    Author     : Ma
--%>
<%@page import="DAO.dbconnect"%>
<%@ page contentType="text/html;charset=UTF-8" %>
<%@ page import="java.sql.*" %>
<%@ page import="java.text.NumberFormat" %>
<%@ page import="java.util.Locale" %>

<%
    NumberFormat formatter = NumberFormat.getNumberInstance(new Locale("vi", "VN"));
%>

<!DOCTYPE html>
<html class="scroll-smooth" lang="vi">
    <head>
        <meta charset="UTF-8">
        <meta name="viewport" content="width=device-width, initial-scale=1.0">
        <title>AURA | Trang Sức Cao Cấp</title>
        <script src="https://cdn.tailwindcss.com?plugins=forms,container-queries"></script>
        <link href="https://fonts.googleapis.com/css2?family=Playfair+Display:wght@400;500;600;700&family=Montserrat:wght@300;400;500;600&display=swap" rel="stylesheet">
        <link href="https://fonts.googleapis.com/css2?family=Material+Symbols+Outlined:wght,FILL@100..700,0..1&display=swap" rel="stylesheet">
        <script>
            tailwind.config = {
                darkMode: "class",
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
                            "on-secondary": "#ffffff",
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
                            "headline-display": ["64px", {lineHeight: "1.1", letterSpacing: "-0.02em", fontWeight: "400"}],
                            "headline-lg": ["40px", {lineHeight: "1.2", fontWeight: "400"}],
                            "headline-lg-mobile": ["32px", {lineHeight: "1.2", fontWeight: "400"}],
                            "headline-md": ["24px", {lineHeight: "1.3", fontWeight: "400"}],
                            "body-lg": ["18px", {lineHeight: "1.6", letterSpacing: "0.01em", fontWeight: "300"}],
                            "body-md": ["16px", {lineHeight: "1.5", fontWeight: "400"}],
                            "label-sm": ["12px", {lineHeight: "1", letterSpacing: "0.1em", fontWeight: "600"}],
                        },
                        spacing: {
                            "margin-desktop": "80px",
                            "margin-mobile": "20px",
                            "gutter": "24px",
                            "container-max": "1440px",
                            "section-gap": "120px",
                        }
                    }
                }
            }
        </script>
        <style>
            .material-symbols-outlined {
                font-variation-settings: 'FILL' 0, 'wght' 300, 'GRAD' 0, 'opsz' 24;
            }
            .silver-gradient {
                background: linear-gradient(135deg, #f3f3f4 0%, #e2e2e2 50%, #dadada 100%);
            }
            .hairline-border { border-width: 0.5px; }
            .scale-98:active { transform: scale(0.98); }
            @keyframes fadeInUp {
                from { opacity: 0; transform: translateY(30px); }
                to { opacity: 1; transform: translateY(0); }
            }
            .animate-fadeInUp {
                animation: fadeInUp 1s ease-out forwards;
            }
            .delay-100 { animation-delay: 0.1s; }
            .delay-200 { animation-delay: 0.2s; }
            .delay-300 { animation-delay: 0.3s; }
        </style>
    </head>
    <body class="bg-surface text-on-surface selection:bg-primary-fixed selection:text-primary">

        <!-- Header -->
        <jsp:include page="header.jsp" />

        <main>
            <!-- Hero Section -->
            <section class="relative h-screen w-full overflow-hidden">
                <div class="absolute inset-0 z-0">
                    <div class="w-full h-full bg-cover bg-center" 
                         style="background-image: url('https://images.pexels.com/photos/34372575/pexels-photo-34372575.jpeg'); background-position: 75% center;">
                    </div>
                    <div class="absolute inset-0 bg-black/5"></div>
                </div>
                <div class="relative z-10 h-full flex flex-col justify-center px-margin-mobile md:items-start md:text-left px-margin-desktop">
                    <h1 class="font-headline-display text-headline-display mb-8 text-primary max-w-4xl">Vẻ Đẹp Vượt Thời Gian</h1>
                    <p class="font-body-lg text-body-lg text-secondary mb-12 tracking-wide uppercase">Bộ Sưu Tập Trang Sức Cao Cấp 2026</p>
                    <a href="sanpham.jsp" class="bg-primary text-on-primary px-10 py-4 font-label-sm text-label-sm tracking-[0.2em] transition-all hover:bg-on-surface-variant active:scale-95 inline-block">
                        KHÁM PHÁ BỘ SƯU TẬP
                    </a>
                </div>
                <!-- Scroll Indicator -->
                <div class="absolute bottom-10 left-1/2 -translate-x-1/2 flex flex-col items-center gap-4 opacity-50">
                    <span class="font-label-sm text-[10px] tracking-widest uppercase text-primary">Cuộn xuống</span>
                    <div class="w-[1px] h-12 bg-primary animate-pulse"></div>
                </div>
            </section>

            <!-- Brand Story Section -->
            <section class="py-section-gap px-margin-desktop max-w-container-max mx-auto text-center">
                <div class="max-w-3xl mx-auto space-y-8">
                    
                    <h2 class="font-headline-lg text-headline-lg">Di Sản Của Sự Sang Trọng</h2>
                    <p class="font-body-lg text-body-lg text-on-surface-variant leading-relaxed">
                        AURA được thành lập trên nguyên tắc rằng sự sang trọng đích thực không cần phải ồn ào. 
                        Nó thì thầm qua độ chính xác của một đường cắt, trọng lượng của bạc nguyên chất, 
                        và độ tinh khiết của kim cương. Chúng tôi tạo ra những tác phẩm không chỉ để đeo, 
                        mà còn để lưu truyền — những bảo vật của vẻ đẹp dành cho người phụ nữ hiện đại, 
                        người trân trọng nghệ thuật của sự tinh tế.
                    </p>
                    <div class="pt-6">
                        <a href="lienhe.jsp" class="font-label-sm text-label-sm border-b border-primary pb-1 hover:text-outline transition-colors">
                            TÌM HIỂU THÊM
                        </a>
                    </div>
                </div>
            </section>

            <!-- Curated Favorites Section -->
            <section class="pb-section-gap px-margin-desktop max-w-container-max mx-auto" id="collections">
                <div class="flex justify-between items-end mb-16">
                    <h3 class="font-headline-md text-headline-md">Sản Phẩm Nổi Bật</h3>
                    <a href="sanpham.jsp" class="font-label-sm text-label-sm text-secondary hover:text-primary transition-colors">
                        XEM TẤT CẢ
                    </a>
                </div>
                <div class="grid grid-cols-1 md:grid-cols-2 lg:grid-cols-4 gap-gutter">
                    <%
                        Connection conn = null;
                        Statement st = null;
                        ResultSet rs = null;
                        try {
                            conn = dbconnect.getConnection();
                            String sql = "SELECT sp.*, dm.ten_danhmuc FROM sanpham sp "
                                    + "JOIN danhmuc dm ON sp.danhmuc_id = dm.id "
                                    + "WHERE sp.is_featured = TRUE ORDER BY sp.id DESC LIMIT 4";
                            st = conn.createStatement();
                            rs = st.executeQuery(sql);
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
                    <div class="group cursor-pointer">
                        <a href="chitiet?id=<%= id %>">
                            <div class="aspect-[3/4] mb-6 overflow-hidden bg-surface-container-low relative">
                                <img class="w-full h-full object-cover transition-transform duration-700 group-hover:scale-105" 
                                     src="<%= src %>" 
                                     alt="<%= ten %>"
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
                        <div class="text-center space-y-1">
                            <p class="font-label-sm text-label-sm text-outline uppercase tracking-wider"><%= danhmuc %></p>
                            <a href="chitiet?id=<%= id %>">
                                <h4 class="font-body-md text-body-md font-medium hover:text-primary transition-colors"><%= ten %></h4>
                            </a>
                            <p class="font-body-md text-body-md text-secondary">
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
                            if (st != null) try { st.close(); } catch (Exception e) {}
                            if (conn != null) try { conn.close(); } catch (Exception e) {}
                        }
                    %>
                </div>
            </section>

            <!-- Special Offers Section (Silver Metallic) -->
            <section class="py-section-gap silver-gradient">
                <div class="px-margin-desktop max-w-container-max mx-auto flex flex-col md:flex-row items-center gap-16">
                    <div class="flex-1 space-y-8">
                        <span class="font-label-sm text-label-sm text-primary tracking-[0.3em] uppercase">Phát Hành Giới Hạn</span>
                        <h2 class="font-headline-lg text-headline-lg text-primary">Bộ Sưu Tập Kỷ Niệm Bạc</h2>
                        <p class="font-body-lg text-body-lg text-on-surface-variant">
                            Kỷ niệm một thế kỷ thủ công với Bộ Sưu Tập Kỷ Niệm Bạc độc quyền của chúng tôi. 
                            Nhận hộp đựng trang sức bằng da cao cấp cho mọi đơn hàng trên 5.000.000đ.
                        </p>
                        <a href="sanpham.jsp" class="bg-primary text-on-primary px-10 py-4 font-label-sm text-label-sm tracking-widest transition-all hover:bg-on-surface-variant active:scale-95 inline-block">
                            KHÁM PHÁ BỘ SƯU TẬP
                        </a>
                    </div>
                    <div class="flex-1 w-full aspect-square md:aspect-[4/5] bg-surface relative overflow-hidden hairline-border border-outline-variant">
                        <img class="w-full h-full object-cover" 
                             src="https://lh3.googleusercontent.com/aida-public/AB6AXuBHbK8oFGLO02aWlnSjh44ZTABbseRSLicR0axlIje0mJSb-rSsNHNxqn031QjctAXz8bmYIgVZbOuYaXuhGA7Pmryi_1KbVggatKeYmgM48mmxUvYrH6W2RgTsy5DLCQcWR6BEXX9gUrW-_HK3wU1DjQ5eZZNn4V7PAaNcSHkvLCriQuQ6JOfsZMYG4vw_6-QmhU9snFUzgJynMFtwBaZlDqk6mVFNc1c52yBwILtIIbqCTVOMCEhtIJTbZuy2oFL4DYMvoCLkJ-4" 
                             alt="Bộ sưu tập bạc"
                             onerror="this.src='img/default.jpg'">
                    </div>
                </div>
            </section>

            <!-- Explore Categories Section -->
            <section class="py-section-gap px-margin-desktop max-w-container-max mx-auto">
                <h3 class="font-headline-md text-headline-md text-center mb-16">Khám Phá Danh Mục</h3>
                <div class="grid grid-cols-2 lg:grid-cols-4 gap-gutter">
                    <%
                        try {
                            Connection connCat = dbconnect.getConnection();
                            String sqlCat = "SELECT * FROM danhmuc ORDER BY thu_tu LIMIT 4";
                            Statement stCat = connCat.createStatement();
                            ResultSet rsCat = stCat.executeQuery(sqlCat);
                            while (rsCat.next()) {
                                String slug = rsCat.getString("slug");
                                String ten = rsCat.getString("ten_danhmuc");
                                String icon = rsCat.getString("icon");
                    %>
                    <a href="sanpham.jsp?cat=<%= slug %>" class="group block relative overflow-hidden aspect-[4/5] bg-surface-container">
                        <div class="w-full h-full flex flex-col items-center justify-center bg-surface-container-low transition-all duration-700 group-hover:scale-105">
                            <span class="material-symbols-outlined text-7xl text-primary/60 group-hover:text-primary transition-colors mb-4">
                                <%= icon != null ? icon : "redeem" %>
                            </span>
                            <span class="font-label-sm text-label-sm text-primary tracking-widest uppercase"><%= ten %></span>
                        </div>
                        <div class="absolute inset-0 bg-black/0 group-hover:bg-black/5 transition-colors"></div>
                    </a>
                    <%
                            }
                            rsCat.close();
                            stCat.close();
                            connCat.close();
                        } catch (Exception e) {
                            e.printStackTrace();
                        }
                    %>
                </div>
            </section>

            <!-- Newsletter Section -->
            <section class="py-section-gap bg-surface-container-lowest border-t border-outline-variant/30 text-center">
                <div class="max-w-2xl mx-auto px-margin-mobile space-y-8">
                    <h2 class="font-headline-md text-headline-md">Đăng ký ngay nhận nhiều ưu đãi</h2>
                    <p class="font-body-md text-body-md text-secondary">
                        Nhận quyền truy cập sớm độc quyền vào các bộ sưu tập theo mùa và lời mời tham dự các sự kiện xem riêng tư.
                    </p>
                    <form class="flex flex-col md:flex-row gap-4 mt-8" action="dangky.jsp" method="get">
                        <input class="flex-grow bg-transparent border-b border-outline-variant focus:border-primary border-t-0 border-x-0 py-3 font-label-sm text-label-sm outline-none transition-all placeholder:text-outline-variant" 
                               placeholder="NHẬP EMAIL CỦA BẠN" type="email" name="email">
                        <button class="bg-primary text-on-primary px-8 py-3 font-label-sm text-label-sm tracking-widest hover:bg-on-surface-variant transition-colors" type="submit">
                            ĐĂNG KÝ
                        </button>
                    </form>
                </div>
            </section>
        </main>

        <!-- Footer -->
        <jsp:include page="footer.jsp" />

        <script>
            // Simple intersection observer for scroll animations
            const observerOptions = {
                threshold: 0.1
            };

            const observer = new IntersectionObserver((entries) => {
                entries.forEach(entry => {
                    if (entry.isIntersecting) {
                        entry.target.classList.add('opacity-100');
                        entry.target.classList.remove('opacity-0', 'translate-y-10');
                    }
                });
            }, observerOptions);

            document.querySelectorAll('section').forEach(section => {
                section.classList.add('transition-all', 'duration-1000', 'opacity-0', 'translate-y-10');
                observer.observe(section);
            });

            // Sticky header background shift on scroll
            window.addEventListener('scroll', () => {
                const nav = document.querySelector('nav');
                if (nav) {
                    if (window.scrollY > 50) {
                        nav.classList.add('shadow-sm');
                    } else {
                        nav.classList.remove('shadow-sm');
                    }
                }
            });
        </script>
    </body>
</html>