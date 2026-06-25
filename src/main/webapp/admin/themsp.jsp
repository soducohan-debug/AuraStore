<%-- 
    Document   : themsp
    Created on : Mar 23, 2026
    Author     : Ma
--%>
<%@page import="java.sql.*, DAO.dbconnect, java.util.*"%>
<%@ page contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<%
    // Lấy danh sách danh mục để hiển thị
    List<Map<String, String>> danhMucList = new ArrayList<>();
    try {
        Connection conn = dbconnect.getConnection();
        Statement st = conn.createStatement();
        ResultSet rs = st.executeQuery("SELECT * FROM danhmuc ORDER BY thu_tu");
        while (rs.next()) {
            Map<String, String> item = new HashMap<>();
            item.put("id", String.valueOf(rs.getInt("id")));
            item.put("slug", rs.getString("slug"));
            item.put("ten", rs.getString("ten_danhmuc"));
            item.put("has_size", String.valueOf(rs.getBoolean("has_size")));
            danhMucList.add(item);
        }
        rs.close();
        st.close();
        conn.close();
    } catch (Exception e) {
        e.printStackTrace();
    }

    // Lấy danh sách size
    Map<Integer, String> sizeMap = new LinkedHashMap<>();
    try {
        Connection conn = dbconnect.getConnection();
        Statement st = conn.createStatement();
        ResultSet rs = st.executeQuery("SELECT * FROM size ORDER BY loai, id");
        while (rs.next()) {
            sizeMap.put(rs.getInt("id"), rs.getString("ten_size") + " - " + rs.getString("mo_ta"));
        }
        rs.close();
        st.close();
        conn.close();
    } catch (Exception e) {
        e.printStackTrace();
    }
%>
<!DOCTYPE html>
<html>
    <head>
        <meta charset="UTF-8">
        <title>Thêm sản phẩm - Aurastore Admin</title>
        <script src="https://cdn.tailwindcss.com"></script>
        <link href="https://fonts.googleapis.com/css2?family=Plus+Jakarta+Sans:wght@400;500;600;700;800&display=swap" rel="stylesheet">
        <style>
            * {
                box-sizing: border-box;
                margin: 0;
                padding: 0;
            }
            body {
                font-family: 'Plus Jakarta Sans', sans-serif;
                background: #f5f4f0;
                padding-left: 240px;
            }
            .container {
                max-width: 800px;
                margin: 0 auto;
                padding: 40px 20px;
            }
            .card {
                background: #fff;
                border-radius: 16px;
                padding: 32px;
                box-shadow: 0 2px 12px rgba(0,0,0,0.08);
            }
            .card-title {
                font-size: 24px;
                font-weight: 700;
                color: #1a1917;
                margin-bottom: 8px;
            }
            .card-subtitle {
                font-size: 14px;
                color: #888;
                margin-bottom: 24px;
            }
            .form-group {
                margin-bottom: 16px;
            }
            .form-group label {
                display: block;
                font-size: 13px;
                font-weight: 600;
                color: #333;
                margin-bottom: 4px;
            }
            .form-group input, .form-group select, .form-group textarea {
                width: 100%;
                padding: 10px 14px;
                border: 0.5px solid #ddd;
                border-radius: 8px;
                font-size: 14px;
                font-family: inherit;
                background: #fafaf8;
                transition: all 0.2s;
            }
            .form-group input:focus, .form-group select:focus, .form-group textarea:focus {
                border-color: #00639c;
                outline: none;
                background: #fff;
                box-shadow: 0 0 0 3px rgba(0,99,156,0.1);
            }
            .form-group textarea {
                resize: vertical;
                min-height: 80px;
            }
            .form-row {
                display: grid;
                grid-template-columns: 1fr 1fr;
                gap: 16px;
            }
            .checkbox-group {
                display: flex;
                gap: 16px;
                flex-wrap: wrap;
                padding-top: 4px;
            }
            .checkbox-group label {
                font-weight: 400;
                font-size: 14px;
                display: flex;
                align-items: center;
                gap: 6px;
                cursor: pointer;
            }
            .checkbox-group input[type="checkbox"] {
                width: 18px;
                height: 18px;
                accent-color: #00639c;
                cursor: pointer;
            }
            .btn-submit {
                background: #00639c;
                color: #fff;
                border: none;
                padding: 12px 32px;
                border-radius: 8px;
                font-size: 16px;
                font-weight: 600;
                cursor: pointer;
                font-family: inherit;
                transition: all 0.2s;
                width: 100%;
            }
            .btn-submit:hover {
                background: #004d7a;
                transform: translateY(-1px);
            }
            .btn-cancel {
                background: #e8e6e0;
                color: #1a1917;
                border: none;
                padding: 12px 24px;
                border-radius: 8px;
                font-size: 14px;
                font-weight: 500;
                cursor: pointer;
                font-family: inherit;
                text-decoration: none;
                display: inline-block;
                text-align: center;
            }
            .btn-cancel:hover {
                background: #d5d3cc;
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
            .alert-error {
                background: #f8d7da;
                color: #721c24;
                padding: 12px 16px;
                border-radius: 8px;
                margin-bottom: 16px;
                border: 1px solid #f5c6cb;
            }
            .size-row {
                display: flex;
                gap: 10px;
                margin-bottom: 8px;
            }
            .size-row select {
                flex: 1;
            }
            .size-row input {
                width: 100px;
            }
            .size-row .remove-btn {
                background: #f8d7da;
                color: #c0392b;
                border: none;
                border-radius: 6px;
                padding: 0 12px;
                cursor: pointer;
                font-size: 18px;
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

            /* Phần size và số lượng */
            #sizeSection {
                display: none;
                border-top: 0.5px solid #e0ddd6;
                padding-top: 16px;
                margin-top: 16px;
            }
            #sizeSection.show {
                display: block;
            }

            /* Phần số lượng cho sản phẩm không có size */
            #soluongGroup {
                display: block;
                border-top: 0.5px solid #e0ddd6;
                padding-top: 16px;
                margin-top: 16px;
            }
            #soluongGroup.hidden {
                display: none;
            }

            .info-text {
                font-size: 11px;
                color: #999;
                margin-top: 4px;
            }
            @media (max-width: 768px) {
                body {
                    padding-left: 0;
                    padding-top: 60px;
                }
                .container {
                    padding: 16px;
                }
                .card {
                    padding: 20px;
                }
                .form-row {
                    grid-template-columns: 1fr;
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
        </style>
    </head>
    <body>
        <div class="container">
            <div class="card">
                <div class="card-title">➕ Thêm sản phẩm mới</div>
                <div class="card-subtitle">Nhập thông tin sản phẩm để thêm vào cửa hàng</div>

                <% if (request.getAttribute("error") != null) {%>
                <div class="alert-error">
                    ❌ <%= request.getAttribute("error")%>
                </div>
                <% }%>

                <form action="<%= request.getContextPath()%>/admin/themsp" 
                      method="post" enctype="multipart/form-data">

                    <div class="form-row">
                        <div class="form-group">
                            <label>Tên sản phẩm <span style="color:red;">*</span></label>
                            <input type="text" name="ten" required>
                        </div>
                        <div class="form-group">
                            <label>Danh mục <span style="color:red;">*</span></label>
                            <select name="danhmuc" id="danhmuc" required onchange="toggleFields()">
                                <%
                                    for (Map<String, String> item : danhMucList) {
                                %>
                                <option value="<%= item.get("slug")%>" 
                                        data-has-size="<%= item.get("has_size")%>">
                                    <%= item.get("ten")%>
                                </option>
                                <% } %>
                            </select>
                        </div>
                    </div>

                    <div class="form-row">
                        <div class="form-group">
                            <label>Giá (VNĐ) <span style="color:red;">*</span></label>
                            <input type="number" name="gia" required>
                        </div>
                        <div class="form-group">
                            <label>Giá khuyến mãi</label>
                            <input type="number" name="gia_km" placeholder="Để trống nếu không có">
                        </div>
                    </div>

                    <!-- ===== SỐ LƯỢNG CHO SẢN PHẨM KHÔNG CÓ SIZE ===== -->
                    <div id="soluongGroup">
                        <div class="form-group">
                            <label>Số lượng tổng <span style="color:red;">*</span></label>
                            <input type="number" name="soluong" value="0" min="0">
                            <div class="info-text">
                                📦 Nhập số lượng tổng cho sản phẩm (áp dụng cho sản phẩm không có size)
                            </div>
                        </div>
                    </div>

                    <!-- ===== SIZE VÀ SỐ LƯỢNG CHO SẢN PHẨM CÓ SIZE ===== -->
                    <div id="sizeSection">
                        <div class="form-group">
                            <label>Size và số lượng</label>
                            <div id="size-container">
                                <div class="size-row">
                                    <select name="size_id">
                                        <option value="">-- Chọn size --</option>
                                        <%
                                            for (Map.Entry<Integer, String> entry : sizeMap.entrySet()) {
                                        %>
                                        <option value="<%= entry.getKey()%>"><%= entry.getValue()%></option>
                                        <% }%>
                                    </select>
                                    <input type="number" name="soluong_size" placeholder="SL" min="0" value="0">
                                    <button type="button" class="remove-btn" onclick="removeSizeRow(this)">✕</button>
                                </div>
                            </div>
                            <button type="button" class="add-size-btn" onclick="addSizeRow()">
                                + Thêm size
                            </button>
                            <div class="info-text">
                                📦 Chọn size và nhập số lượng cho từng size
                            </div>
                        </div>
                    </div>

                    <div class="form-row">
                        <div class="form-group">
                            <label>Chất liệu</label>
                            <input type="text" name="chatlieu" value="Bạc 925">
                        </div>
                        <div class="form-group">
                            <label>Trọng lượng (gram)</label>
                            <input type="number" step="0.1" name="trong_luong" placeholder="VD: 3.5">
                        </div>
                    </div>

                    <div class="form-row">
                        <div class="form-group">
                            <label>Bảo hành (tháng)</label>
                            <input type="number" name="bao_hanh" value="12">
                        </div>
                    </div>

                    <div class="form-group">
                        <label>Mô tả</label>
                        <textarea name="mota" rows="3" placeholder="Nhập mô tả sản phẩm..."></textarea>
                    </div>

                    <!-- ===== UPLOAD ẢNH ===== -->
                    <!-- ===== UPLOAD ẢNH ===== -->
                    <div class="form-group">
                        <label>Ảnh đại diện <span style="color:red;">*</span></label>

                        <!-- Tab chọn cách thêm ảnh -->
                        <div style="display:flex;gap:8px;margin-bottom:12px;">
                            <button type="button" id="addTabUpload" class="tab-btn active" onclick="switchAddImageTab('upload')">
                                📤 Upload ảnh
                            </button>
                            <button type="button" id="addTabLink" class="tab-btn" onclick="switchAddImageTab('link')">
                                🔗 Dùng link ảnh
                            </button>
                        </div>

                        <!-- Phần Upload ảnh -->
                        <div id="addImageUploadTab">
                            <input type="file" name="anh" accept="image/*" id="addMainImage"
                                   class="w-full px-4 py-2 border rounded-lg focus:outline-none focus:border-blue-500">
                            <div style="font-size:11px;color:#999;margin-top:4px;">Chọn ảnh từ máy tính</div>
                        </div>

                        <!-- Phần Link ảnh -->
                        <div id="addImageLinkTab" style="display:none;">
                            <div style="display:flex;align-items:center;gap:16px;flex-wrap:wrap;">
                                <div>
                                    <img id="addImageLinkPreview" src="<%= request.getContextPath()%>/img/default.jpg" alt="Preview" 
                                         style="width:80px;height:80px;object-fit:cover;border-radius:8px;border:1px solid #ddd;">
                                    <div style="font-size:11px;color:#999;margin-top:4px;">Preview</div>
                                </div>
                                <div style="flex:1;min-width:200px;">
                                    <input type="url" name="anh_url" id="addImageUrl" 
                                           placeholder="Nhập link ảnh (VD: https://example.com/image.jpg)"
                                           class="w-full px-4 py-2 border rounded-lg focus:outline-none focus:border-blue-500">
                                    <div style="font-size:11px;color:#999;margin-top:4px;">
                                        📷 Nhập link ảnh từ internet (JPG, PNG, JPEG)
                                    </div>
                                </div>
                            </div>
                        </div>

                        <!-- Hidden field để biết đang dùng cách nào -->
                        <input type="hidden" name="image_source" id="addImageSource" value="upload">
                    </div>

                    <!-- ===== GALLERY ẢNH ===== -->
                    <div class="form-group">
                        <label>Gallery ảnh (chọn nhiều ảnh)</label>

                        <!-- Tab chọn cách thêm gallery -->
                        <div style="display:flex;gap:8px;margin-bottom:12px;">
                            <button type="button" id="addGalleryTabUpload" class="tab-btn active" onclick="switchAddGalleryTab('upload')">
                                📤 Upload nhiều ảnh
                            </button>
                            <button type="button" id="addGalleryTabLink" class="tab-btn" onclick="switchAddGalleryTab('link')">
                                🔗 Dùng link ảnh
                            </button>
                        </div>

                        <!-- Phần Upload gallery -->
                        <div id="addGalleryUploadTab">
                            <div class="image-upload-area" id="addGalleryDropArea">
                                <div class="icon">🖼️</div>
                                <p>Kéo thả ảnh vào đây hoặc click để chọn</p>
                                <input type="file" name="anh_gallery" accept="image/*" multiple 
                                       id="addGalleryInput" style="display:none;">
                            </div>
                            <div class="gallery-preview" id="addGalleryPreview"></div>
                            <div style="font-size:11px;color:#999;margin-top:8px;">
                                💡 Giữ Ctrl để chọn nhiều ảnh
                            </div>
                        </div>

                        <!-- Phần Link gallery -->
                        <div id="addGalleryLinkTab" style="display:none;">
                            <div style="display:flex;flex-direction:column;gap:8px;">
                                <textarea name="anh_gallery_url" id="addGalleryUrls" rows="3" 
                                          placeholder="Nhập link ảnh, cách nhau bằng dấu phẩy&#10;VD: https://example.com/1.jpg, https://example.com/2.jpg"
                                          class="w-full px-4 py-2 border rounded-lg focus:outline-none focus:border-blue-500"></textarea>
                                <div style="font-size:11px;color:#999;">
                                    💡 Nhập nhiều link ảnh, cách nhau bằng dấu phẩy (,)
                                </div>
                            </div>
                            <div class="gallery-preview" id="addGalleryPreviewUrls"></div>
                        </div>

                        <!-- Hidden field để biết đang dùng cách nào -->
                        <input type="hidden" name="gallery_source" id="addGallerySource" value="upload">
                    </div>

                    <div class="form-group">
                        <label>Đặc biệt</label>
                        <div class="checkbox-group">
                            <label><input type="checkbox" name="is_featured"> ⭐ Nổi bật</label>
                            <label><input type="checkbox" name="is_new"> 🆕 Sản phẩm mới</label>
                        </div>
                    </div>

                    <div style="display:flex;gap:12px;margin-top:8px;">
                        <button type="submit" class="btn-submit">💾 Thêm sản phẩm</button>
                        <a href="<%= request.getContextPath()%>/admin/admin_sanpham.jsp" class="btn-cancel" style="flex:0.3;">
                            Hủy
                        </a>
                    </div>
                </form>
            </div>
        </div>

        <script>
            // ===== Toggle hiển thị phần size và số lượng =====
            function toggleFields() {
                const select = document.getElementById('danhmuc');
                const selectedOption = select.options[select.selectedIndex];
                const hasSize = selectedOption.dataset.hasSize === 'true';

                const sizeSection = document.getElementById('sizeSection');
                const soluongGroup = document.getElementById('soluongGroup');

                if (hasSize) {
                    // Có size: hiển thị phần size, ẩn phần số lượng tổng
                    sizeSection.classList.add('show');
                    soluongGroup.classList.add('hidden');
                } else {
                    // Không có size: hiển thị phần số lượng tổng, ẩn phần size
                    sizeSection.classList.remove('show');
                    soluongGroup.classList.remove('hidden');
                }
            }

            // ===== Thêm dòng size =====
            function addSizeRow() {
                const container = document.getElementById('size-container');
                const firstRow = container.querySelector('.size-row');
                if (!firstRow)
                    return;

                const newRow = document.createElement('div');
                newRow.className = 'size-row';
                newRow.innerHTML = firstRow.innerHTML;

                // Reset giá trị
                const select = newRow.querySelector('select');
                if (select)
                    select.selectedIndex = 0;
                const input = newRow.querySelector('input[type="number"]');
                if (input)
                    input.value = '0';

                container.appendChild(newRow);
            }

            // ===== Xóa dòng size =====
            function removeSizeRow(btn) {
                const row = btn.parentElement;
                const container = document.getElementById('size-container');
                if (container.querySelectorAll('.size-row').length > 1) {
                    row.remove();
                } else {
                    alert('Phải có ít nhất 1 dòng size!');
                }
            }

            // ===== GALLERY UPLOAD =====
            // ===== SWITCH TAB ẢNH ĐẠI DIỆN (THÊM MỚI) =====
            function switchAddImageTab(tab) {
                var uploadTab = document.getElementById('addImageUploadTab');
                var linkTab = document.getElementById('addImageLinkTab');
                var tabUpload = document.getElementById('addTabUpload');
                var tabLink = document.getElementById('addTabLink');
                var source = document.getElementById('addImageSource');

                if (tab === 'upload') {
                    uploadTab.style.display = 'block';
                    linkTab.style.display = 'none';
                    tabUpload.className = 'tab-btn active';
                    tabLink.className = 'tab-btn';
                    source.value = 'upload';
                    document.getElementById('addMainImage').required = true;
                    document.getElementById('addImageUrl').required = false;
                } else {
                    uploadTab.style.display = 'none';
                    linkTab.style.display = 'block';
                    tabLink.className = 'tab-btn active';
                    tabUpload.className = 'tab-btn';
                    source.value = 'link';
                    document.getElementById('addMainImage').required = false;
                    document.getElementById('addImageUrl').required = true;
                }
            }

            // ===== SWITCH TAB GALLERY (THÊM MỚI) =====
            function switchAddGalleryTab(tab) {
                var uploadTab = document.getElementById('addGalleryUploadTab');
                var linkTab = document.getElementById('addGalleryLinkTab');
                var tabUpload = document.getElementById('addGalleryTabUpload');
                var tabLink = document.getElementById('addGalleryTabLink');
                var source = document.getElementById('addGallerySource');

                if (tab === 'upload') {
                    uploadTab.style.display = 'block';
                    linkTab.style.display = 'none';
                    tabUpload.className = 'tab-btn active';
                    tabLink.className = 'tab-btn';
                    source.value = 'upload';
                } else {
                    uploadTab.style.display = 'none';
                    linkTab.style.display = 'block';
                    tabLink.className = 'tab-btn active';
                    tabUpload.className = 'tab-btn';
                    source.value = 'link';
                }
            }

            // ===== PREVIEW LINK ẢNH ĐẠI DIỆN (THÊM MỚI) =====
            document.getElementById('addImageUrl').addEventListener('input', function (e) {
                var url = this.value.trim();
                var preview = document.getElementById('addImageLinkPreview');
                if (url !== '') {
                    preview.src = url;
                    preview.onerror = function () {
                        this.src = '<%= request.getContextPath()%>/img/default.jpg';
                    };
                } else {
                    preview.src = '<%= request.getContextPath()%>/img/default.jpg';
                }
            });

            // ===== PREVIEW LINK GALLERY (THÊM MỚI) =====
            document.getElementById('addGalleryUrls').addEventListener('input', function (e) {
                var container = document.getElementById('addGalleryPreviewUrls');
                container.innerHTML = '';
                var urls = this.value.split(',');
                for (var i = 0; i < urls.length; i++) {
                    var url = urls[i].trim();
                    if (url !== '') {
                        var div = document.createElement('div');
                        div.className = 'preview-item';
                        div.innerHTML = '<img src="' + url + '" onerror="this.src=\'<%= request.getContextPath()%>/img/default.jpg\'" style="object-fit:cover;width:100%;height:100%;">';
                        container.appendChild(div);
                    }
                }
            });

            // ===== UPLOAD GALLERY (THÊM MỚI) =====
            document.getElementById('addGalleryDropArea').addEventListener('click', function () {
                document.getElementById('addGalleryInput').click();
            });

            document.getElementById('addGalleryInput').addEventListener('change', function (e) {
                var files = this.files;
                var container = document.getElementById('addGalleryPreview');
                for (var i = 0; i < files.length; i++) {
                    var file = files[i];
                    var reader = new FileReader();
                    reader.onload = function (e) {
                        var div = document.createElement('div');
                        div.className = 'preview-item';
                        div.innerHTML = '<img src="' + e.target.result + '" style="object-fit:cover;width:100%;height:100%;">';
                        container.appendChild(div);
                    }
                    reader.readAsDataURL(file);
                }
                this.value = '';
            });

            // ===== KHỞI TẠO =====
            // Mặc định chọn tab Upload
            switchAddImageTab('upload');
            switchAddGalleryTab('upload');

            // ===== KHỞI TẠO =====
            // Gọi ngay khi trang load để set trạng thái ban đầu
            document.addEventListener('DOMContentLoaded', function () {
                toggleFields();
            });
        </script>
    </body>
</html>