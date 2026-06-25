package com.example.maomi.dao;

import com.example.maomi.model.CartItem;
import com.example.maomi.utils.DBUtil;
import java.sql.*;
import java.util.ArrayList;
import java.util.List;

public class CartDAO {

    public List<CartItem> getByUsername(String username) {
        List<CartItem> list = new ArrayList<>();
        String sql = "SELECT ci.*, i.name, i.price, i.image_path FROM cart_items ci " +
                "JOIN items i ON ci.item_id = i.id WHERE ci.username=?";
        try (Connection conn = DBUtil.getConnection();
             PreparedStatement stmt = conn.prepareStatement(sql)) {
            stmt.setString(1, username);
            ResultSet rs = stmt.executeQuery();
            while (rs.next()) {
                CartItem cart = new CartItem();
                cart.setId(rs.getInt("id"));
                cart.setUsername(rs.getString("username"));
                cart.setItemId(rs.getInt("item_id"));
                cart.setQuantity(rs.getInt("quantity"));
                cart.setItemName(rs.getString("name"));
                cart.setItemPrice(rs.getDouble("price"));
                cart.setImagePath(rs.getString("image_path"));
                list.add(cart);
            }
        } catch (SQLException e) { e.printStackTrace(); }
        return list;
    }

    public boolean add(String username, int itemId, int quantity) {
        String checkSql = "SELECT id, quantity FROM cart_items WHERE username=? AND item_id=?";
        try (Connection conn = DBUtil.getConnection();
             PreparedStatement checkStmt = conn.prepareStatement(checkSql)) {
            checkStmt.setString(1, username);
            checkStmt.setInt(2, itemId);
            ResultSet rs = checkStmt.executeQuery();
            if (rs.next()) {
                int newQty = rs.getInt("quantity") + quantity;
                String updateSql = "UPDATE cart_items SET quantity=? WHERE id=?";
                try (PreparedStatement updateStmt = conn.prepareStatement(updateSql)) {
                    updateStmt.setInt(1, newQty);
                    updateStmt.setInt(2, rs.getInt("id"));
                    return updateStmt.executeUpdate() > 0;
                }
            } else {
                String insertSql = "INSERT INTO cart_items (username, item_id, quantity) VALUES (?,?,?)";
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

    public boolean updateQuantity(int cartId, int quantity) {
        String sql = "UPDATE cart_items SET quantity=? WHERE id=?";
        try (Connection conn = DBUtil.getConnection();
             PreparedStatement stmt = conn.prepareStatement(sql)) {
            stmt.setInt(1, quantity);
            stmt.setInt(2, cartId);
            return stmt.executeUpdate() > 0;
        } catch (SQLException e) { e.printStackTrace(); }
        return false;
    }

    public boolean remove(int cartId) {
        String sql = "DELETE FROM cart_items WHERE id=?";
        try (Connection conn = DBUtil.getConnection();
             PreparedStatement stmt = conn.prepareStatement(sql)) {
            stmt.setInt(1, cartId);
            return stmt.executeUpdate() > 0;
        } catch (SQLException e) { e.printStackTrace(); }
        return false;
    }

    public boolean clear(String username) {
        String sql = "DELETE FROM cart_items WHERE username=?";
        try (Connection conn = DBUtil.getConnection();
             PreparedStatement stmt = conn.prepareStatement(sql)) {
            stmt.setString(1, username);
            stmt.executeUpdate();
            return true;
        } catch (SQLException e) { e.printStackTrace(); }
        return false;
    }
}