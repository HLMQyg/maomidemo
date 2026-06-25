package com.example.maomi.dao;

import com.example.maomi.model.UserInventory;
import com.example.maomi.utils.DBUtil;
import java.sql.*;
import java.util.ArrayList;
import java.util.List;

public class InventoryDAO {

    // 获取用户库存（只返回数量 > 0 的物品）
    public List<UserInventory> getByUsername(String username) {
        List<UserInventory> list = new ArrayList<>();
        String sql = "SELECT ui.*, i.name as item_name, i.image_path as item_image " +
                "FROM user_inventory ui JOIN items i ON ui.item_id = i.id " +
                "WHERE ui.username=? AND ui.quantity > 0";
        try (Connection conn = DBUtil.getConnection();
             PreparedStatement stmt = conn.prepareStatement(sql)) {
            stmt.setString(1, username);
            ResultSet rs = stmt.executeQuery();
            while (rs.next()) {
                UserInventory inv = new UserInventory();
                inv.setId(rs.getInt("id"));
                inv.setUsername(rs.getString("username"));
                inv.setItemId(rs.getInt("item_id"));
                inv.setQuantity(rs.getInt("quantity"));
                inv.setItemName(rs.getString("item_name"));
                inv.setItemImage(rs.getString("item_image"));
                list.add(inv);
            }
        } catch (SQLException e) { e.printStackTrace(); }
        return list;
    }

    // 增加库存（购买后调用）
    public boolean addOrUpdate(String username, int itemId, int quantity) {
        String checkSql = "SELECT id, quantity FROM user_inventory WHERE username=? AND item_id=?";
        try (Connection conn = DBUtil.getConnection();
             PreparedStatement checkStmt = conn.prepareStatement(checkSql)) {
            checkStmt.setString(1, username);
            checkStmt.setInt(2, itemId);
            ResultSet rs = checkStmt.executeQuery();
            if (rs.next()) {
                int newQty = rs.getInt("quantity") + quantity;
                String updateSql = "UPDATE user_inventory SET quantity=? WHERE id=?";
                try (PreparedStatement updateStmt = conn.prepareStatement(updateSql)) {
                    updateStmt.setInt(1, newQty);
                    updateStmt.setInt(2, rs.getInt("id"));
                    return updateStmt.executeUpdate() > 0;
                }
            } else {
                String insertSql = "INSERT INTO user_inventory (username, item_id, quantity) VALUES (?,?,?)";
                try (PreparedStatement insertStmt = conn.prepareStatement(insertSql)) {
                    insertStmt.setString(1, username);
                    insertStmt.setInt(2, itemId);
                    insertStmt.setInt(3, quantity);
                    return insertStmt.executeUpdate() > 0;
                }
            }
        } catch (SQLException e) { e.printStackTrace(); }
        return false;
    }

    // 消耗库存（喂养时调用）
    public boolean consume(String username, int itemId, int quantity) {
        String sql = "UPDATE user_inventory SET quantity = quantity - ? WHERE username=? AND item_id=? AND quantity >= ?";
        try (Connection conn = DBUtil.getConnection();
             PreparedStatement stmt = conn.prepareStatement(sql)) {
            stmt.setInt(1, quantity);
            stmt.setString(2, username);
            stmt.setInt(3, itemId);
            stmt.setInt(4, quantity);
            return stmt.executeUpdate() > 0;
        } catch (SQLException e) { e.printStackTrace(); }
        return false;
    }
}