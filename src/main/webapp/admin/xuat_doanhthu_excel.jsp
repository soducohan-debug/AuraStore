<%-- 
    Document   : xuat_doanhthu_excel
    Created on : Jun 25, 2026
    Author     : Ma
    Description: Xuat thong ke doanh thu ra Excel
--%>
<%@ page contentType="application/vnd.openxmlformats-officedocument.spreadsheetml.sheet" %>
<%@ page import="java.sql.*, DAO.dbconnect, java.text.NumberFormat, java.util.Locale, java.util.*" %>
<%@ page import="org.apache.poi.xssf.usermodel.*" %>
<%@ page import="org.apache.poi.ss.usermodel.*" %>
<%@ page import="org.apache.poi.ss.util.CellRangeAddress" %>

<%
    // Kiem tra dang nhap admin
    String user = (String) session.getAttribute("user");
    String role = (String) session.getAttribute("role");

    if (user == null || !"admin".equals(role)) {
        response.sendRedirect("../login.jsp");
        return;
    }

    NumberFormat formatter = NumberFormat.getNumberInstance(new Locale("vi", "VN"));
    Connection conn = null;
    
    // Lay du lieu thong ke
    long doanhThuThangNay = 0;
    int soDonThangNay = 0;
    
    Map<String, Long> doanhThu6Thang = new LinkedHashMap<>();
    Map<String, Integer> soDon6Thang = new LinkedHashMap<>();
    
    List<Map<String, Object>> danhMucBanChay = new ArrayList<>();
    List<Map<String, Object>> sanPhamBanChay = new ArrayList<>();
    
    try {
        conn = dbconnect.getConnection();
        
        // 1. Doanh thu thang nay
        java.util.Calendar cal = java.util.Calendar.getInstance();
        int thangHienTai = cal.get(java.util.Calendar.MONTH) + 1;
        int namHienTai = cal.get(java.util.Calendar.YEAR);
        
        String sqlDTThang = "SELECT SUM(tongtien) as tong, COUNT(*) as so_luong FROM donhang "
                          + "WHERE trangthai='Da giao' AND MONTH(ngay)=? AND YEAR(ngay)=?";
        PreparedStatement psDTThang = conn.prepareStatement(sqlDTThang);
        psDTThang.setInt(1, thangHienTai);
        psDTThang.setInt(2, namHienTai);
        ResultSet rsDTThang = psDTThang.executeQuery();
        if (rsDTThang.next()) {
            doanhThuThangNay = rsDTThang.getLong("tong");
            soDonThangNay = rsDTThang.getInt("so_luong");
        }
        rsDTThang.close();
        psDTThang.close();
        
        // 2. Doanh thu 6 thang
        String[] thangNames = {"T1", "T2", "T3", "T4", "T5", "T6", "T7", "T8", "T9", "T10", "T11", "T12"};
        
        for (int i = 5; i >= 0; i--) {
            cal = java.util.Calendar.getInstance();
            cal.add(java.util.Calendar.MONTH, -i);
            int thang = cal.get(java.util.Calendar.MONTH) + 1;
            int nam = cal.get(java.util.Calendar.YEAR);
            
            String sqlDT = "SELECT SUM(tongtien) as tong, COUNT(*) as so_luong FROM donhang "
                          + "WHERE trangthai='Da giao' AND MONTH(ngay)=? AND YEAR(ngay)=?";
            PreparedStatement psDT = conn.prepareStatement(sqlDT);
            psDT.setInt(1, thang);
            psDT.setInt(2, nam);
            ResultSet rsDT = psDT.executeQuery();
            long dt = 0;
            int soDon = 0;
            if (rsDT.next()) {
                dt = rsDT.getLong("tong");
                soDon = rsDT.getInt("so_luong");
            }
            rsDT.close();
            psDT.close();
            
            String key = thangNames[thang - 1] + "/" + nam;
            doanhThu6Thang.put(key, dt);
            soDon6Thang.put(key, soDon);
        }
        
        // 3. Danh muc ban chay
        String sqlDanhMuc = "SELECT dm.ten_danhmuc, SUM(ct.soluong) as so_luong_ban, SUM(ct.soluong * ct.gia) as doanh_thu "
                          + "FROM chitietdonhang ct "
                          + "JOIN sanpham sp ON ct.sanpham_id = sp.id "
                          + "JOIN danhmuc dm ON sp.danhmuc_id = dm.id "
                          + "JOIN donhang dh ON ct.donhang_id = dh.id "
                          + "WHERE dh.trangthai='Da giao' "
                          + "GROUP BY dm.id, dm.ten_danhmuc "
                          + "ORDER BY so_luong_ban DESC LIMIT 5";
        Statement stDanhMuc = conn.createStatement();
        ResultSet rsDanhMuc = stDanhMuc.executeQuery(sqlDanhMuc);
        while (rsDanhMuc.next()) {
            Map<String, Object> item = new HashMap<>();
            item.put("ten", rsDanhMuc.getString("ten_danhmuc"));
            item.put("so_luong", rsDanhMuc.getInt("so_luong_ban"));
            item.put("doanh_thu", rsDanhMuc.getLong("doanh_thu"));
            danhMucBanChay.add(item);
        }
        rsDanhMuc.close();
        stDanhMuc.close();
        
        // 4. San pham ban chay nhat
        String sqlSP = "SELECT sp.id, sp.ten, SUM(ct.soluong) as so_luong_ban, SUM(ct.soluong * ct.gia) as doanh_thu "
                      + "FROM chitietdonhang ct "
                      + "JOIN sanpham sp ON ct.sanpham_id = sp.id "
                      + "JOIN donhang dh ON ct.donhang_id = dh.id "
                      + "WHERE dh.trangthai='Da giao' "
                      + "GROUP BY sp.id, sp.ten "
                      + "ORDER BY so_luong_ban DESC LIMIT 5";
        Statement stSP = conn.createStatement();
        ResultSet rsSP = stSP.executeQuery(sqlSP);
        while (rsSP.next()) {
            Map<String, Object> item = new HashMap<>();
            item.put("id", rsSP.getInt("id"));
            item.put("ten", rsSP.getString("ten"));
            item.put("so_luong", rsSP.getInt("so_luong_ban"));
            item.put("doanh_thu", rsSP.getLong("doanh_thu"));
            sanPhamBanChay.add(item);
        }
        rsSP.close();
        stSP.close();
        
    } catch (Exception e) {
        e.printStackTrace();
    } finally {
        if (conn != null) try { conn.close(); } catch(Exception e) {}
    }
    
    // Tao file Excel
    XSSFWorkbook workbook = new XSSFWorkbook();
    
    // Font
    XSSFFont fontBold = workbook.createFont();
    fontBold.setBold(true);
    fontBold.setFontHeightInPoints((short) 12);
    
    XSSFFont fontNormal = workbook.createFont();
    fontNormal.setFontHeightInPoints((short) 11);
    
    // Style header
    XSSFCellStyle headerStyle = workbook.createCellStyle();
    headerStyle.setFont(fontBold);
    headerStyle.setAlignment(HorizontalAlignment.CENTER);
    headerStyle.setFillForegroundColor(IndexedColors.GREY_25_PERCENT.getIndex());
    headerStyle.setFillPattern(FillPatternType.SOLID_FOREGROUND);
    headerStyle.setBorderTop(BorderStyle.THIN);
    headerStyle.setBorderBottom(BorderStyle.THIN);
    headerStyle.setBorderLeft(BorderStyle.THIN);
    headerStyle.setBorderRight(BorderStyle.THIN);
    
    // Style normal
    XSSFCellStyle normalStyle = workbook.createCellStyle();
    normalStyle.setFont(fontNormal);
    normalStyle.setBorderTop(BorderStyle.THIN);
    normalStyle.setBorderBottom(BorderStyle.THIN);
    normalStyle.setBorderLeft(BorderStyle.THIN);
    normalStyle.setBorderRight(BorderStyle.THIN);
    
    // Style tieu de
    XSSFCellStyle titleStyle = workbook.createCellStyle();
    titleStyle.setFont(fontBold);
    titleStyle.setAlignment(HorizontalAlignment.CENTER);
    
    // Sheet 1: Tong quan
    XSSFSheet sheet1 = workbook.createSheet("Tong quan");
    int rowNum = 0;
    
    // Tieu de
    XSSFRow titleRow = sheet1.createRow(rowNum++);
    XSSFCell titleCell = titleRow.createCell(0);
    titleCell.setCellValue("BAO CAO DOANH THU AURA");
    titleCell.setCellStyle(titleStyle);
    sheet1.addMergedRegion(new CellRangeAddress(0, 0, 0, 3));
    titleRow.setHeightInPoints(30);
    
    rowNum++;
    
    // Thong tin tong quan
    XSSFRow rowInfo1 = sheet1.createRow(rowNum++);
    rowInfo1.createCell(0).setCellValue("Doanh thu thang nay:");
    rowInfo1.createCell(1).setCellValue(doanhThuThangNay);
    rowInfo1.createCell(2).setCellValue("Don ban thang nay:");
    rowInfo1.createCell(3).setCellValue(soDonThangNay);
    
    XSSFRow rowInfo2 = sheet1.createRow(rowNum++);
    rowInfo2.createCell(0).setCellValue("Ngay xuat:");
    rowInfo2.createCell(1).setCellValue(new java.text.SimpleDateFormat("dd/MM/yyyy HH:mm").format(new java.util.Date()));
    
    rowNum++;
    
    // Bang doanh thu 6 thang
    XSSFRow headerRow = sheet1.createRow(rowNum++);
    String[] headers6 = {"Thang", "Doanh thu", "So don hang"};
    for (int i = 0; i < headers6.length; i++) {
        XSSFCell cell = headerRow.createCell(i);
        cell.setCellValue(headers6[i]);
        cell.setCellStyle(headerStyle);
    }
    
    for (Map.Entry<String, Long> entry : doanhThu6Thang.entrySet()) {
        XSSFRow dataRow = sheet1.createRow(rowNum++);
        dataRow.createCell(0).setCellValue(entry.getKey());
        dataRow.createCell(1).setCellValue(entry.getValue());
        dataRow.createCell(2).setCellValue(soDon6Thang.get(entry.getKey()));
    }
    
    // Sheet 2: Danh muc ban chay
    XSSFSheet sheet2 = workbook.createSheet("Danh muc ban chay");
    rowNum = 0;
    
    XSSFRow titleRow2 = sheet2.createRow(rowNum++);
    XSSFCell titleCell2 = titleRow2.createCell(0);
    titleCell2.setCellValue("DANH MUC BAN CHAY");
    titleCell2.setCellStyle(titleStyle);
    sheet2.addMergedRegion(new CellRangeAddress(0, 0, 0, 2));
    titleRow2.setHeightInPoints(30);
    rowNum++;
    
    String[] headersDM = {"STT", "Danh muc", "So luong ban", "Doanh thu"};
    XSSFRow headerRowDM = sheet2.createRow(rowNum++);
    for (int i = 0; i < headersDM.length; i++) {
        XSSFCell cell = headerRowDM.createCell(i);
        cell.setCellValue(headersDM[i]);
        cell.setCellStyle(headerStyle);
    }
    
    int sttDM = 0;
    for (Map<String, Object> item : danhMucBanChay) {
        sttDM++;
        XSSFRow dataRow = sheet2.createRow(rowNum++);
        dataRow.createCell(0).setCellValue(sttDM);
        dataRow.createCell(1).setCellValue((String) item.get("ten"));
        dataRow.createCell(2).setCellValue((int) item.get("so_luong"));
        dataRow.createCell(3).setCellValue((long) item.get("doanh_thu"));
    }
    
    // Sheet 3: San pham ban chay
    XSSFSheet sheet3 = workbook.createSheet("San pham ban chay");
    rowNum = 0;
    
    XSSFRow titleRow3 = sheet3.createRow(rowNum++);
    XSSFCell titleCell3 = titleRow3.createCell(0);
    titleCell3.setCellValue("SAN PHAM BAN CHAY");
    titleCell3.setCellStyle(titleStyle);
    sheet3.addMergedRegion(new CellRangeAddress(0, 0, 0, 3));
    titleRow3.setHeightInPoints(30);
    rowNum++;
    
    String[] headersSP = {"STT", "San pham", "So luong ban", "Doanh thu"};
    XSSFRow headerRowSP = sheet3.createRow(rowNum++);
    for (int i = 0; i < headersSP.length; i++) {
        XSSFCell cell = headerRowSP.createCell(i);
        cell.setCellValue(headersSP[i]);
        cell.setCellStyle(headerStyle);
    }
    
    int sttSP = 0;
    for (Map<String, Object> item : sanPhamBanChay) {
        sttSP++;
        XSSFRow dataRow = sheet3.createRow(rowNum++);
        dataRow.createCell(0).setCellValue(sttSP);
        dataRow.createCell(1).setCellValue((String) item.get("ten"));
        dataRow.createCell(2).setCellValue((int) item.get("so_luong"));
        dataRow.createCell(3).setCellValue((long) item.get("doanh_thu"));
    }
    
    // Auto size
    for (int i = 0; i < 4; i++) {
        sheet1.autoSizeColumn(i);
        sheet2.autoSizeColumn(i);
        sheet3.autoSizeColumn(i);
    }
    
    // Xuat file
    response.setHeader("Content-Disposition", "attachment; filename=\"Bao_cao_doanh_thu_AURA.xlsx\"");
    workbook.write(response.getOutputStream());
    workbook.close();
%>