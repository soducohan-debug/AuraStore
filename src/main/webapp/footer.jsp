<%-- 
    Document   : footer
    Created on : Mar 18, 2026
    Author     : Ma
--%>
<%@page contentType="text/html" pageEncoding="UTF-8"%>

<link href="https://fonts.googleapis.com/css2?family=Playfair+Display:wght@400;500;600;700&family=Montserrat:wght@300;400;500;600&display=swap" rel="stylesheet">
<link href="https://fonts.googleapis.com/css2?family=Material+Symbols+Outlined:wght,FILL@100..700,0..1&display=swap" rel="stylesheet">

<style>
    .aura-footer {
        background: #111111; /* Đổi sang màu đen huyền bí / tối giản */
        border-top: 0.5px solid rgba(255, 255, 255, 0.1); /* Đường kẻ mờ màu trắng */
        padding: 60px 40px 30px;
        font-family: 'Montserrat', sans-serif;
        margin-top: 60px;
    }
    .aura-footer .container {
        max-width: 1440px;
        margin: 0 auto;
        display: grid;
        grid-template-columns: 1.5fr 1fr 1fr 1fr;
        gap: 40px;
    }
    .aura-footer .brand h3 {
        font-family: 'Playfair Display', serif;
        font-size: 24px;
        font-weight: 700;
        letter-spacing: 0.15em;
        color: #ffffff; /* Chữ tiêu đề màu trắng */
        margin-bottom: 12px;
    }
    .aura-footer .brand .sub {
        font-size: 10px;
        font-weight: 300;
        letter-spacing: 0.15em;
        color: #a3a3a3; /* Chữ phụ màu xám bạc nhẹ */
        text-transform: uppercase;
    }
    .aura-footer .brand p {
        color: #b5b5b5; /* Đoạn văn màu xám sáng để dễ đọc */
        font-size: 14px;
        font-weight: 300;
        line-height: 1.8;
        margin-top: 16px;
        max-width: 320px;
    }
    .aura-footer h4 {
        font-size: 11px;
        font-weight: 600;
        letter-spacing: 0.15em;
        text-transform: uppercase;
        color: #ffffff; /* Tiêu đề các mục màu trắng */
        margin-bottom: 16px;
    }
    .aura-footer ul {
        list-style: none;
        padding: 0;
        margin: 0;
    }
    .aura-footer ul li {
        margin-bottom: 10px;
        color: #b5b5b5; /* Màu cho text không phải link (như địa chỉ) */
        font-size: 13px;
        font-weight: 300;
    }
    .aura-footer ul a {
        color: #b5b5b5; /* Màu link mặc định (xám sáng) */
        text-decoration: none;
        font-size: 13px;
        font-weight: 300;
        transition: color 0.3s ease;
    }
    .aura-footer ul a:hover {
        color: #ffffff; /* Khi hover sẽ sáng rực lên màu trắng */
    }
    .aura-footer .social {
        display: flex;
        gap: 16px;
        margin-top: 12px;
    }
    .aura-footer .social a {
        color: #b5b5b5;
        text-decoration: none;
        transition: color 0.3s ease;
    }
    .aura-footer .social a:hover {
        color: #ffffff;
    }
    .aura-footer .social .material-symbols-outlined {
        font-size: 24px;
    }
    .aura-footer .bottom {
        max-width: 1440px;
        margin: 40px auto 0;
        padding-top: 20px;
        border-top: 0.5px solid rgba(255, 255, 255, 0.1);
        display: flex;
        justify-content: space-between;
        align-items: center;
        flex-wrap: wrap;
        gap: 12px;
    }
    .aura-footer .bottom p {
        font-size: 11px;
        font-weight: 300;
        color: #888888; /* Bản quyền màu xám trầm hơn */
        letter-spacing: 0.05em;
    }
    .aura-footer .bottom .links {
        display: flex;
        gap: 24px;
    }
    .aura-footer .bottom .links a {
        font-size: 11px;
        font-weight: 300;
        color: #888888;
        text-decoration: none;
        letter-spacing: 0.05em;
        transition: color 0.3s ease;
    }
    .aura-footer .bottom .links a:hover {
        color: #ffffff;
    }
    @media (max-width: 992px) {
        .aura-footer .container {
            grid-template-columns: 1fr 1fr;
            gap: 30px;
        }
        .aura-footer {
            padding: 40px 20px 20px;
        }
    }
    @media (max-width: 576px) {
        .aura-footer .container {
            grid-template-columns: 1fr;
            gap: 24px;
        }
        .aura-footer .bottom {
            flex-direction: column;
            text-align: center;
        }
        .aura-footer .bottom .links {
            justify-content: center;
        }
    }
</style>

<footer class="aura-footer">
    <div class="container">
        <!-- Brand -->
        <div class="brand">
            <h3>AURA</h3>
            <div class="sub">SILVER EDITION</div>
            <p>
                Trang sức cao cấp. Mỗi tác phẩm là một minh chứng cho sự tinh tế 
                và đẳng cấp vượt thời gian.
            </p>
        </div>

        <!-- Collections -->
        <div>
            <h4>Bộ Sưu Tập</h4>
            <ul>
                <li><a href="sanpham.jsp">Trang sức cao cấp</a></li>
                <li><a href="sanpham.jsp">Nhẫn cưới</a></li>
                <li><a href="sanpham.jsp">Bộ sưu tập Icon</a></li>
                <li><a href="sanpham.jsp">Quà tặng</a></li>
            </ul>
        </div>

        <!-- Support -->
        <div>
            <h4>Hỗ Trợ</h4>
            <ul>
                <li><a href="lienhe.jsp">Liên hệ</a></li>
                <li><a href="#">Vận chuyển &amp; Đổi trả</a></li>
                <li><a href="#">Hướng dẫn bảo quản</a></li>
                <li><a href="#">Câu hỏi thường gặp</a></li>
            </ul>
        </div>

        <!-- Contact & Social -->
        <div>
            <h4>Kết Nối</h4>
            <ul>
                <li><a href="mailto:aurastore@gmail.com">aurastore@gmail.com</a></li>
                <li><a href="tel:19001234">1900 1234</a></li>
                <li>68 Nguyễn Chí Thanh, Hà Nội</li>
            </ul>
            <div class="social">
                <a href="#" aria-label="Instagram">
                    <span class="material-symbols-outlined">photo_camera</span>
                </a>
                <a href="#" aria-label="Facebook">
                    <span class="material-symbols-outlined">share</span>
                </a>
                <a href="#" aria-label="YouTube">
                    <span class="material-symbols-outlined">videocam</span>
                </a>
            </div>
        </div>
    </div>

    <div class="bottom">
        <p>© 2026 AuraStore. Tất cả các quyền được bảo vệ.</p>
        <div class="links">
            <a href="#">Chính sách bảo mật</a>
            <a href="#">Điều khoản dịch vụ</a>
        </div>
    </div>
</footer>