/*
 * Click nbfs://nbhost/SystemFileSystem/Templates/Licenses/license-default.txt to change this license
 * Click nbfs://nbhost/SystemFileSystem/Templates/Classes/Class.java to edit this template
 */
package model;

import java.util.ArrayList;
import java.util.HashMap;
import java.util.List;
import java.util.Map;

public class sanpham {

    private int id;
    private String ten;
    private int gia;
    private Integer giaKm;
    private String anh;
    private List<String> anhGallery = new ArrayList<>();
    private String mota;
    private String chatlieu;
    private Double trongLuong;
    private Integer baoHanh;
    private int danhMucId;
    private String tenDanhMuc;
    private boolean isFeatured;
    private boolean isNew;
    private boolean isBestseller;
    private Map<Size, Integer> sizes;
    private int soluong;

    // Constructor đầy đủ
    public sanpham(int id, String ten, int gia, String anh, String mota, String tenDanhMuc) {
        this.id = id;
        this.ten = ten;
        this.gia = gia;
        this.anh = anh;
        this.mota = mota;
        this.tenDanhMuc = tenDanhMuc;
        this.sizes = new HashMap<>();
        this.anhGallery = new ArrayList<>();
    }

    // Constructor có thêm các trường
    public sanpham(int id, String ten, int gia, Integer giaKm, String anh, String mota,
            String chatlieu, Double trongLuong, Integer baoHanh, int danhMucId, String tenDanhMuc) {
        this(id, ten, gia, anh, mota, tenDanhMuc);
        this.giaKm = giaKm;
        this.chatlieu = chatlieu;
        this.trongLuong = trongLuong;
        this.baoHanh = baoHanh;
        this.danhMucId = danhMucId;
        this.anhGallery = new ArrayList<>();
    }

    // Constructor cũ
    public sanpham(int id, String ten, int gia, String anh, int soluong, String mota, String danhmuc) {
        this(id, ten, gia, anh, mota, danhmuc);
        if (soluong > 0) {
            Size defaultSize = new Size(0, "Default", "");
            this.sizes.put(defaultSize, soluong);
        }
        this.anhGallery = new ArrayList<>();
    }

    // ===== PHƯƠNG THỨC hasSize() - QUAN TRỌNG =====
    public boolean hasSize() {
        if (sizes == null || sizes.isEmpty()) {
            return false;
        }
        // Kiểm tra xem có size nào hợp lệ không (id > 0)
        for (Size size : sizes.keySet()) {
            if (size.getId() > 0) {
                return true;
            }
        }
        return false;
    }

    // ===== GETTER/SETTER =====
    public int getId() { return id; }
    public void setId(int id) { this.id = id; }

    public String getTen() { return ten; }
    public void setTen(String ten) { this.ten = ten; }
    public int getSoluong() {
    return soluong;
}
    public void setSoluong(int soluong) {
    this.soluong = soluong;
}
    public int getGia() { return gia; }
    public void setGia(int gia) { this.gia = gia; }

    public Integer getGiaKm() { return giaKm; }
    public void setGiaKm(Integer giaKm) { this.giaKm = giaKm; }

    public int getGiaHienTai() {
        return (giaKm != null && giaKm > 0 && giaKm < gia) ? giaKm : gia;
    }

    public String getAnh() { return anh; }
    public void setAnh(String anh) { this.anh = anh; }

    public String getMota() { return mota; }
    public void setMota(String mota) { this.mota = mota; }

    public String getChatlieu() { return chatlieu; }
    public void setChatlieu(String chatlieu) { this.chatlieu = chatlieu; }

    public Double getTrongLuong() { return trongLuong; }
    public void setTrongLuong(Double trongLuong) { this.trongLuong = trongLuong; }

    public Integer getBaoHanh() { return baoHanh; }
    public void setBaoHanh(Integer baoHanh) { this.baoHanh = baoHanh; }

    public int getDanhMucId() { return danhMucId; }
    public void setDanhMucId(int danhMucId) { this.danhMucId = danhMucId; }

    public String getTenDanhMuc() { return tenDanhMuc; }
    public void setTenDanhMuc(String tenDanhMuc) { this.tenDanhMuc = tenDanhMuc; }

    public boolean isFeatured() { return isFeatured; }
    public void setFeatured(boolean featured) { isFeatured = featured; }

    public boolean isNew() { return isNew; }
    public void setNew(boolean aNew) { isNew = aNew; }

    public boolean isBestseller() { return isBestseller; }
    public void setBestseller(boolean bestseller) { isBestseller = bestseller; }

    public Map<Size, Integer> getSizes() { return sizes; }
    public void setSizes(Map<Size, Integer> sizes) { this.sizes = sizes; }

    // ===== GALLERY =====
    public List<String> getAnhGallery() { return anhGallery; }
    public void setAnhGallery(List<String> anhGallery) { this.anhGallery = anhGallery; }
    public void addAnh(String anh) {
    if (this.anhGallery == null) {
        this.anhGallery = new ArrayList<>();
    }
    // Kiểm tra trùng lặp
    if (!this.anhGallery.contains(anh)) {
        this.anhGallery.add(anh);
    }
}

public String getAnhDaiDien() {
    if (anhGallery != null && !anhGallery.isEmpty()) {
        return anhGallery.get(0);
    }
    return anh != null ? anh : "default.jpg";
}
public boolean isImageLink() {
    return anh != null && (anh.startsWith("http://") || anh.startsWith("https://"));
}

public String getImageSrc() {
    if (anh == null || anh.isEmpty()) return "default.jpg";
    if (anh.startsWith("http://") || anh.startsWith("https://")) {
        return anh;
    }
    return "img/" + anh;
}
    // Lấy tổng số lượng
    public int getTotalSoluong() {
        int total = 0;
        if (sizes != null) {
            for (int sl : sizes.values()) {
                total += sl;
            }
        }
        return total;
    }

    @Override
    public String toString() {
        return "sanpham{id=" + id + ", ten='" + ten + "', gia=" + gia + "}";
    }
}