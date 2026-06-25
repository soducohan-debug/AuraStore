<%@ page contentType="text/html" pageEncoding="UTF-8"%>
<!DOCTYPE html>
<html class="scroll-smooth" lang="vi">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>Đăng ký - AURA</title>
    <script src="https://cdn.tailwindcss.com?plugins=forms,container-queries"></script>
    <link href="https://fonts.googleapis.com/css2?family=Playfair+Display:wght@400;500;600;700&family=Montserrat:wght@300;400;500;600&display=swap" rel="stylesheet">
    <link href="https://fonts.googleapis.com/css2?family=Material+Symbols+Outlined:wght,FILL@100..700,0..1&display=swap" rel="stylesheet">
    <style>
        body { 
            font-family: 'Montserrat', sans-serif; 
            background-image: url('https://images.pexels.com/photos/31459472/pexels-photo-31459472.jpeg');
            background-size: cover;
            background-position: center;
            background-attachment: fixed;
            background-repeat: no-repeat;
            min-height: 100vh;
        }
        .register-card {
            background: rgba(255, 255, 255, 0.92);
            backdrop-filter: blur(10px);
            border-radius: 16px;
            box-shadow: 0 20px 60px rgba(0,0,0,0.15);
            border: 1px solid rgba(255,255,255,0.2);
        }
        .btn-register {
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
            transition: all 0.3s ease;
        }
        .btn-register:hover {
            background: #333333;
            transform: translateY(-2px);
        }
        .btn-register:disabled {
            opacity: 0.6;
            cursor: not-allowed;
            transform: none;
        }
        .alert-success {
            background: #d4edda;
            color: #155724;
            padding: 12px 16px;
            border-radius: 8px;
            border: 1px solid #c3e6cb;
            margin-bottom: 16px;
        }
        .alert-error {
            background: #f8d7da;
            color: #721c24;
            padding: 12px 16px;
            border-radius: 8px;
            border: 1px solid #f5c6cb;
            margin-bottom: 16px;
        }
        .loading-spinner {
            display: inline-block;
            width: 16px;
            height: 16px;
            border: 2px solid rgba(255,255,255,0.3);
            border-radius: 50%;
            border-top-color: #ffffff;
            animation: spin 0.8s ease-in-out infinite;
            margin-right: 8px;
            vertical-align: middle;
        }
        @keyframes spin {
            to { transform: rotate(360deg); }
        }
        .input-field {
            width: 100%;
            padding: 12px 0;
            background: transparent;
            border: none;
            border-bottom: 1px solid rgba(0,0,0,0.15);
            outline: none;
            font-size: 14px;
            transition: border-color 0.3s ease;
            font-family: 'Montserrat', sans-serif;
        }
        .input-field:focus {
            border-bottom-color: #000000;
        }
        .input-field::placeholder {
            color: #aaa;
        }
    </style>
</head>
<body>

    <jsp:include page="header.jsp" />

    <div class="min-h-screen flex items-center justify-center px-4 pt-20 pb-12">
        <div class="w-full max-w-md">
            <div class="register-card p-8 md:p-10">
                <div class="text-center mb-8">
                    <h1 class="font-playfair text-3xl font-bold text-primary">Đăng ký</h1>
                    <p class="text-secondary text-sm mt-2">Tạo tài khoản mới</p>
                </div>

                <!-- Hiển thị thông báo từ URL (khi redirect từ servlet) -->
                <% 
                    String msg = request.getParameter("msg");
                    if (msg != null && !msg.isEmpty()) { 
                %>
                    <div class="alert-success">
                        ✅ <%= msg %>
                    </div>
                <% } %>

                <!-- Hiển thị lỗi từ request attribute -->
                <% if (request.getAttribute("error") != null) { %>
                    <div class="alert-error">
                        <%= request.getAttribute("error") %>
                    </div>
                <% } %>

                <form action="dangky" method="post" id="registerForm" class="space-y-4">
                    <div>
                        <label class="block text-xs font-medium text-secondary uppercase tracking-wider mb-2">Tên đăng nhập *</label>
                        <input type="text" name="user" required class="input-field" placeholder="Nhập username">
                    </div>

                    <div>
                        <label class="block text-xs font-medium text-secondary uppercase tracking-wider mb-2">Mật khẩu *</label>
                        <input type="password" name="pass" required class="input-field" placeholder="Nhập mật khẩu">
                    </div>

                    <div>
                        <label class="block text-xs font-medium text-secondary uppercase tracking-wider mb-2">Họ và tên</label>
                        <input type="text" name="fullname" class="input-field" placeholder="Nhập họ tên">
                    </div>

                    <div>
                        <label class="block text-xs font-medium text-secondary uppercase tracking-wider mb-2">Email</label>
                        <input type="email" name="email" class="input-field" placeholder="example@email.com">
                    </div>

                    <div>
                        <label class="block text-xs font-medium text-secondary uppercase tracking-wider mb-2">Số điện thoại</label>
                        <input type="tel" name="phone" class="input-field" placeholder="0912 345 678">
                    </div>

                    <button type="submit" class="btn-register" id="registerBtn">
                        Đăng ký
                    </button>
                </form>

                <div class="text-center mt-6">
                    <p class="text-sm text-secondary">
                        Đã có tài khoản? 
                        <a href="login.jsp" class="text-primary font-medium hover:underline">Đăng nhập</a>
                    </p>
                </div>
            </div>
        </div>
    </div>

    <jsp:include page="footer.jsp" />

    <script>
        // Xử lý submit form
        document.getElementById('registerForm').addEventListener('submit', function(e) {
            var btn = document.getElementById('registerBtn');
            var originalText = btn.innerHTML;
            
            // Disable nút và hiển thị loading
            btn.disabled = true;
            btn.innerHTML = '<span class="loading-spinner"></span> Đang xử lý...';
            
            // Sau 5 giây nếu không có response, reset nút (phòng trường hợp mất kết nối)
            setTimeout(function() {
                if (btn.disabled) {
                    btn.disabled = false;
                    btn.innerHTML = originalText;
                }
            }, 10000);
        });

        // Tự động ẩn thông báo sau 5 giây
        setTimeout(function() {
            var alerts = document.querySelectorAll('.alert-success, .alert-error');
            alerts.forEach(function(alert) {
                alert.style.transition = 'opacity 0.5s';
                alert.style.opacity = '0';
                setTimeout(function() {
                    alert.style.display = 'none';
                }, 500);
            });
        }, 5000);
    </script>

</body>
</html>