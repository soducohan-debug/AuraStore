/*
 * Click nbfs://nbhost/SystemFileSystem/Templates/Licenses/license-default.txt to change this license
 * Click nbfs://nbhost/SystemFileSystem/Templates/Classes/Class.java to edit this template
 */
package model;

public class giohang {
    private sanpham sp;
    private Size size;      // THÊM size
    private int soluong;
    
    // Constructor có size (dùng cho sản phẩm có size)
    public giohang(sanpham sp, Size size, int soluong) {
        this.sp = sp;
        this.size = size;
        this.soluong = soluong;
    }
    
    // Constructor không size (dùng cho sản phẩm không có size)
    public giohang(sanpham sp, int soluong) {
        this(sp, null, soluong);
    }
    
    // Getter/Setter
    public sanpham getSp() {
        return sp;
    }
    
    public void setSp(sanpham sp) {
        this.sp = sp;
    }
    
    public Size getSize() {
        return size;
    }
    
    public void setSize(Size size) {
        this.size = size;
    }
    
    public int getSoluong() {
        return soluong;
    }
    
    public void setSoluong(int soluong) {
        this.soluong = soluong;
    }
    
    // Tính tổng tiền cho item này
    public int getTongTien() {
        return sp.getGiaHienTai() * soluong;
    }
    
    // Lấy tên size để hiển thị (nếu có)
    public String getTenSize() {
        return size != null ? size.getTenSize() : "";
    }
    
    @Override
    public String toString() {
        return "giohang{" +
                "sp=" + (sp != null ? sp.getTen() : "null") +
                ", size=" + (size != null ? size.getTenSize() : "null") +
                ", soluong=" + soluong +
                '}';
    }
}