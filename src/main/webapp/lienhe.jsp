<%@ page contentType="text/html; charset=UTF-8" pageEncoding="UTF-8" %>
<!DOCTYPE html>
<html class="scroll-smooth" lang="vi">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>Liên hệ - AURA</title>
    <script src="https://cdn.tailwindcss.com?plugins=forms,container-queries"></script>
    <link href="https://fonts.googleapis.com/css2?family=Playfair+Display:wght@400;500;600;700&family=Montserrat:wght@300;400;500;600&display=swap" rel="stylesheet">
    <link href="https://fonts.googleapis.com/css2?family=Material+Symbols+Outlined:wght,FILL@100..700,0..1&display=swap" rel="stylesheet">
    <style>
        body {
            font-family: 'Montserrat', sans-serif;
            background: #f9f9f9;
            background-image: url('https://images.pexels.com/photos/11139368/pexels-photo-11139368.jpeg');
        background-size: cover;
        background-position: center;
        background-attachment: fixed;
        background-repeat: no-repeat;
        
        }
        .contact-card {
            background: #ffffff;
            border-radius: 12px;
            box-shadow: 0 20px 60px rgba(0,0,0,0.06);
            border: 0.5px solid rgba(207,196,197,0.3);
        }
    </style>
</head>
<body>

    <jsp:include page="header.jsp" />

    <main class="pt-28 pb-16 px-4 max-w-4xl mx-auto">
        <div class="text-center mb-12">
            <h1 class="font-playfair text-4xl font-bold text-primary">Liên hệ</h1>
            <p class="text-secondary text-sm mt-2">Chúng tôi luôn sẵn sàng hỗ trợ bạn</p>
        </div>

        <div class="contact-card p-8 md:p-10 space-y-6">
            <div class="flex items-start gap-4 p-4 rounded-lg bg-surface">
                <span class="material-symbols-outlined text-primary text-2xl">location_on</span>
                <div>
                    <h3 class="font-medium text-sm text-primary">Địa chỉ</h3>
                    <p class="text-secondary text-sm">68 Nguyễn Chí Thanh, Đống Đa, Hà Nội</p>
                </div>
            </div>

            <div class="flex items-start gap-4 p-4 rounded-lg bg-surface">
                <span class="material-symbols-outlined text-primary text-2xl">phone</span>
                <div>
                    <h3 class="font-medium text-sm text-primary">Hotline</h3>
                    <p class="text-secondary text-sm"><a href="tel:19001234" class="hover:text-primary transition-colors">1900 1234</a></p>
                </div>
            </div>

            <div class="flex items-start gap-4 p-4 rounded-lg bg-surface">
                <span class="material-symbols-outlined text-primary text-2xl">email</span>
                <div>
                    <h3 class="font-medium text-sm text-primary">Email</h3>
                    <p class="text-secondary text-sm"><a href="mailto:aurastore@gmail.com" class="hover:text-primary transition-colors">aurastore@gmail.com</a></p>
                </div>
            </div>

            <div class="flex items-start gap-4 p-4 rounded-lg bg-surface">
                <span class="material-symbols-outlined text-primary text-2xl">schedule</span>
                <div>
                    <h3 class="font-medium text-sm text-primary">Giờ làm việc</h3>
                    <p class="text-secondary text-sm">8:00 - 22:00 (Thứ 2 - CN)</p>
                </div>
            </div>
        </div>
    </main>

    <jsp:include page="footer.jsp" />

</body>
</html>