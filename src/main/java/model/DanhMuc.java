package model;

public class DanhMuc {

    private int id;
    private String tenDanhMuc;
    private String slug;
    private String icon;
    private boolean hasSize;
    private int thuTu;

    public DanhMuc() {
    }

    public DanhMuc(int id, String tenDanhMuc, String slug, String icon, boolean hasSize, int thuTu) {
        this.id = id;
        this.tenDanhMuc = tenDanhMuc;
        this.slug = slug;
        this.icon = icon;
        this.hasSize = hasSize;
        this.thuTu = thuTu;
    }

    
    public int getId() {
        return id;
    }

    public void setId(int id) {
        this.id = id;
    }

    public String getTenDanhMuc() {
        return tenDanhMuc;
    }

    public void setTenDanhMuc(String tenDanhMuc) {
        this.tenDanhMuc = tenDanhMuc;
    }

    public String getSlug() {
        return slug;
    }

    public void setSlug(String slug) {
        this.slug = slug;
    }

    public String getIcon() {
        return icon;
    }

    public void setIcon(String icon) {
        this.icon = icon;
    }

    public boolean isHasSize() {
        return hasSize;
    }

    public void setHasSize(boolean hasSize) {
        this.hasSize = hasSize;
    }

    public int getThuTu() {
        return thuTu;
    }

    public void setThuTu(int thuTu) {
        this.thuTu = thuTu;
    }
}
