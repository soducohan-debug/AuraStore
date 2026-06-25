<%@ page contentType="text/html" pageEncoding="UTF-8"%>
<!DOCTYPE html>
<html class="scroll-smooth" lang="vi">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>Đăng nhập - AURA</title>
    <script src="https://cdn.tailwindcss.com?plugins=forms,container-queries"></script>
    <link href="https://fonts.googleapis.com/css2?family=Playfair+Display:wght@400;500;600;700&family=Montserrat:wght@300;400;500;600&display=swap" rel="stylesheet">
    <link href="https://fonts.googleapis.com/css2?family=Material+Symbols+Outlined:wght,FILL@100..700,0..1&display=swap" rel="stylesheet">
    <style>
        body { font-family: 'Montserrat', sans-serif; 
        background-image: url('https://images.pexels.com/photos/31459472/pexels-photo-31459472.jpeg');
        background-size: cover;
        background-position: center;
        background-attachment: fixed;
        background-repeat: no-repeat;
        ; }
        .login-card {
            background: #ffffff;
            border-radius: 12px;
            box-shadow: 0 20px 60px rgba(0,0,0,0.06);
            border: 0.5px solid rgba(207,196,197,0.3);
        }
        .btn-login {
            background: #000000;
            color: #ffffff;
            padding: 14px;
            border-radius: 8px;
            font-family: 'Montserrat', sans-serif;
            font-size: 12px;
            font-weight: 600;
            letter-spacing: 0.15em;
            text-transform: uppercase;
            width: 100%;
            border: none;
            cursor: pointer;
            transition: background 0.3s ease;
        }
        .btn-login:hover {
            background: #333333;
        }
    </style>
</head>
<body>

    <jsp:include page="header.jsp" />

    <div class="min-h-screen flex items-center justify-center px-4 pt-20 pb-12">
        <div class="w-full max-w-md">
            <div class="login-card p-8 md:p-10">
                <div class="text-center mb-8">
                    <h1 class="font-playfair text-3xl font-bold text-primary">Đăng nhập</h1>
                    <p class="text-secondary text-sm mt-2">Chào mừng bạn trở lại</p>
                </div>

                <form action="login" method="post" class="space-y-5">
                    <div>
                        <label class="block text-xs font-medium text-secondary uppercase tracking-wider mb-2">Tên đăng nhập</label>
                        <input type="text" name="user" required
                               class="w-full px-4 py-3 bg-surface border-0 border-b border-outline-variant focus:border-primary focus:ring-0 outline-none transition-colors text-sm"
                               placeholder="Nhập username">
                    </div>

                    <div>
                        <label class="block text-xs font-medium text-secondary uppercase tracking-wider mb-2">Mật khẩu</label>
                        <input type="password" name="pass" required
                               class="w-full px-4 py-3 bg-surface border-0 border-b border-outline-variant focus:border-primary focus:ring-0 outline-none transition-colors text-sm"
                               placeholder="Nhập mật khẩu">
                    </div>

                    <% if (request.getAttribute("error") != null) { %>
                        <div class="bg-error/10 text-error text-sm p-3 rounded-lg border border-error/20">
                            <%= request.getAttribute("error") %>
                        </div>
                    <% } %>

                    <button type="submit" class="btn-login">
                        Đăng nhập
                    </button>
                </form>

                <div class="text-center mt-6">
                    <p class="text-sm text-secondary">
                        Chưa có tài khoản? 
                        <a href="dangky.jsp" class="text-primary font-medium hover:underline">Đăng ký ngay</a>
                    </p>
                </div>
            </div>
        </div>
    </div>

    <jsp:include page="footer.jsp" />

</body>
</html>