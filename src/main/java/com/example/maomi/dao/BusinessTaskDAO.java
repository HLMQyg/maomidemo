package com.example.maomi.dao;

import com.example.maomi.utils.DBUtil;
import java.sql.*;

public class BusinessTaskDAO {
    public boolean create(String username, String taskType, int catId, int itemId, int quantity) {
        String sql = "INSERT INTO business_tasks (username, task_type, cat_id, item_id, quantity, status) VALUES (?,?,?,?,?, '待处理')";
        try (Connection conn = DBUtil.getConnection();
             PreparedStatement stmt = conn.prepareStatement(sql)) {
            stmt.setString(1, username);
            stmt.setString(2, taskType);
            stmt.setInt(3, catId);
            stmt.setInt(4, itemId);
            stmt.setInt(5, quantity);
            return stmt.executeUpdate() > 0;
        } catch (SQLException e) { e.printStackTrace(); }
        return false;
    }
}