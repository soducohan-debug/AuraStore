/*
 * Click nbfs://nbhost/SystemFileSystem/Templates/Licenses/license-default.txt to change this license
 * Click nbfs://nbhost/SystemFileSystem/Templates/Classes/Class.java to edit this template
 */
package DAO;

import java.sql.Connection;
import java.sql.DriverManager;
import java.sql.SQLException;

/**
 *
 * @author Ma
 */
public class dbconnect {

    private static final String URL =
            System.getenv().getOrDefault(
                    "DB_URL",
                    "jdbc:mysql://localhost:3306/aurastore");

    private static final String USER =
            System.getenv().getOrDefault(
                    "DB_USER",
                    "root");

    private static final String PASS =
            System.getenv().getOrDefault(
                    "DB_PASSWORD",
                    "");

    public static Connection getConnection() {
        Connection conn = null;
        try {
            Class.forName("com.mysql.cj.jdbc.Driver");
            conn = DriverManager.getConnection(URL, USER, PASS);
            System.out.println("Ket noi MySQL thanh cong!");
        } catch (ClassNotFoundException | SQLException e) {
            System.out.println("Loi ket noi: " + e.getMessage());
        }
        return conn;
    }
}