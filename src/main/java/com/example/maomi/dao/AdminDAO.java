package com.example.maomi.dao;


import com.example.maomi.utils.DBUtil;
import java.sql.*;

public class AdminDAO {
    public boolean validate(String name, String password) {
        String sql = "SELECT 1 FROM admin WHERE name=? AND password=?";
        try (Connection conn = DBUtil.getConnection();
             PreparedStatement stmt = conn.prepareStatement(sql)) {
            stmt.setString(1, name);
            stmt.setString(2, password);
            ResultSet rs = stmt.executeQuery();
            return rs.next();
        } catch (SQLException e) {
            e.printStackTrace();
        }
        return false;
    }
}
