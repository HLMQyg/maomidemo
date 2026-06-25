package com.example.maomi.dao;

import com.example.maomi.model.FeedingRecord;
import com.example.maomi.utils.DBUtil;
import java.sql.*;

public class FeedingRecordDAO {

    // 插入喂养记录
    public boolean insert(String username, int catId, int itemId, int quantity) {
        String sql = "INSERT INTO feeding_records (username, cat_id, item_id, quantity) VALUES (?,?,?,?)";
        try (Connection conn = DBUtil.getConnection();
             PreparedStatement stmt = conn.prepareStatement(sql)) {
            stmt.setString(1, username);
            stmt.setInt(2, catId);
            stmt.setInt(3, itemId);
            stmt.setInt(4, quantity);
            return stmt.executeUpdate() > 0;
        } catch (SQLException e) { e.printStackTrace(); }
        return false;
    }

    // 获取某只猫咪最新的喂养用户（用于显示“喂养中”的用户）
    public String getLastFeedingUserByCatId(int catId) {
        String sql = "SELECT username FROM feeding_records WHERE cat_id=? ORDER BY feed_time DESC LIMIT 1";
        try (Connection conn = DBUtil.getConnection();
             PreparedStatement stmt = conn.prepareStatement(sql)) {
            stmt.setInt(1, catId);
            ResultSet rs = stmt.executeQuery();
            if (rs.next()) {
                return rs.getString("username");
            }
        } catch (SQLException e) { e.printStackTrace(); }
        return null;
    }
}