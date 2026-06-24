package com.example.maomi.dao;

import com.example.maomi.utils.DBUtil;
import java.sql.*;
import java.util.HashSet;
import java.util.Set;

public class FavoriteDAO {

    // 添加收藏
    public boolean addFavorite(String username, int catId) {
        String sql = "INSERT IGNORE INTO user_favorites (username, cat_id) VALUES (?, ?)";
        try (Connection conn = DBUtil.getConnection();
             PreparedStatement stmt = conn.prepareStatement(sql)) {
            stmt.setString(1, username);
            stmt.setInt(2, catId);
            return stmt.executeUpdate() > 0;
        } catch (SQLException e) {
            e.printStackTrace();
        }
        return false;
    }

    // 取消收藏
    public boolean removeFavorite(String username, int catId) {
        String sql = "DELETE FROM user_favorites WHERE username=? AND cat_id=?";
        try (Connection conn = DBUtil.getConnection();
             PreparedStatement stmt = conn.prepareStatement(sql)) {
            stmt.setString(1, username);
            stmt.setInt(2, catId);
            return stmt.executeUpdate() > 0;
        } catch (SQLException e) {
            e.printStackTrace();
        }
        return false;
    }

    // 检查是否已收藏
    public boolean isFavorited(String username, int catId) {
        String sql = "SELECT 1 FROM user_favorites WHERE username=? AND cat_id=?";
        try (Connection conn = DBUtil.getConnection();
             PreparedStatement stmt = conn.prepareStatement(sql)) {
            stmt.setString(1, username);
            stmt.setInt(2, catId);
            return stmt.executeQuery().next();
        } catch (SQLException e) {
            e.printStackTrace();
        }
        return false;
    }

    // 获取用户收藏的所有猫咪ID
    public Set<Integer> getFavoriteCatIds(String username) {
        Set<Integer> ids = new HashSet<>();
        String sql = "SELECT cat_id FROM user_favorites WHERE username=?";
        try (Connection conn = DBUtil.getConnection();
             PreparedStatement stmt = conn.prepareStatement(sql)) {
            stmt.setString(1, username);
            ResultSet rs = stmt.executeQuery();
            while (rs.next()) {
                ids.add(rs.getInt("cat_id"));
            }
        } catch (SQLException e) {
            e.printStackTrace();
        }
        return ids;
    }
}