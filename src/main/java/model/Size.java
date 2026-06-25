package model;

public class Size {

    private int id;
    private String tenSize;
    private String moTa;
    private String loai;

    // Constructor đầy đủ
    public Size(int id, String tenSize, String moTa, String loai) {
        this.id = id;
        this.tenSize = tenSize;
        this.moTa = moTa;
        this.loai = loai;
    }

    // Constructor rút gọn (dùng phổ biến)
    public Size(int id, String tenSize, String moTa) {
        this(id, tenSize, moTa, null);
    }

    // Constructor mặc định
    public Size() {
        this(0, "", "");
    }

    // Getter/Setter
    public int getId() {
        return id;
    }

    public void setId(int id) {
        this.id = id;
    }

    public String getTenSize() {
        return tenSize;
    }

    public void setTenSize(String tenSize) {
        this.tenSize = tenSize;
    }

    public String getMoTa() {
        return moTa;
    }

    public void setMoTa(String moTa) {
        this.moTa = moTa;
    }

    public String getLoai() {
        return loai;
    }

    public void setLoai(String loai) {
        this.loai = loai;
    }

    @Override
    public boolean equals(Object obj) {
        if (this == obj) {
            return true;
        }
        if (obj == null || getClass() != obj.getClass()) {
            return false;
        }
        Size size = (Size) obj;
        return id == size.id;
    }

    @Override
    public int hashCode() {
        return Integer.hashCode(id);
    }

    @Override
    public String toString() {
        return tenSize;
    }
}
