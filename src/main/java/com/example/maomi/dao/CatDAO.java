package com.example.maomi.dao;

import com.example.maomi.model.Cat;
import com.example.maomi.utils.DBUtil;

import java.sql.*;
import java.util.ArrayList;
import java.util.List;
import java.util.Set;

public class CatDAO {

    /**
     * 获取所有猫咪（按创建时间倒序）
     */
    public List<Cat> getAllCats() {
        List<Cat> cats = new ArrayList<>();
        String sql = "SELECT * FROM cats ORDER BY created_at DESC";
        try (Connection conn = DBUtil.getConnection();
             PreparedStatement stmt = conn.prepareStatement(sql);
             ResultSet rs = stmt.executeQuery()) {
            while (rs.next()) {
                cats.add(mapRowToCat(rs));
            }
        } catch (SQLException e) {
            e.printStackTrace();
        }
        return cats;
    }

    /**
     * 按状态获取猫咪（如 "在校" 或 "已领养"）
     */
    public List<Cat> getCatsByState(String state) {
        List<Cat> cats = new ArrayList<>();
        String sql = "SELECT * FROM cats WHERE state=? ORDER BY created_at DESC";
        try (Connection conn = DBUtil.getConnection();
             PreparedStatement stmt = conn.prepareStatement(sql)) {
            stmt.setString(1, state);
            ResultSet rs = stmt.executeQuery();
            while (rs.next()) {
                cats.add(mapRowToCat(rs));
            }
        } catch (SQLException e) {
            e.printStackTrace();
        }
        return cats;
    }

    /**
     * 根据ID获取单只猫咪
     */
    public Cat getCatById(int id) {
        String sql = "SELECT * FROM cats WHERE id=?";
        try (Connection conn = DBUtil.getConnection();
             PreparedStatement stmt = conn.prepareStatement(sql)) {
            stmt.setInt(1, id);
            ResultSet rs = stmt.executeQuery();
            if (rs.next()) {
                return mapRowToCat(rs);
            }
        } catch (SQLException e) {
            e.printStackTrace();
        }
        return null;
    }
    /** 根据名称获取猫咪 */
    public Cat getCatByName(String name) {
        String sql = "SELECT * FROM cats WHERE name=?";
        try (Connection conn = DBUtil.getConnection();
             PreparedStatement stmt = conn.prepareStatement(sql)) {
            stmt.setString(1, name);
            ResultSet rs = stmt.executeQuery();
            if (rs.next()) {
                return mapRowToCat(rs);
            }
        } catch (SQLException e) {
            e.printStackTrace();
        }
        return null;
    }


    /**
     * 添加猫咪
     */
    public boolean addCat(Cat cat) {
        String sql = "INSERT INTO cats (name, color, age, gender, health_status, description, found_location, found_date, image_path, state) " +
                "VALUES (?,?,?,?,?,?,?,?,?,?)";
        try (Connection conn = DBUtil.getConnection();
             PreparedStatement stmt = conn.prepareStatement(sql)) {
            stmt.setString(1, cat.getName());
            stmt.setString(2, cat.getColor());
            stmt.setInt(3, cat.getAge());
            stmt.setString(4, cat.getGender());
            stmt.setString(5, cat.getHealthStatus());
            stmt.setString(6, cat.getDescription());
            stmt.setString(7, cat.getFoundLocation());
            stmt.setDate(8, cat.getFoundDate());
            stmt.setString(9, cat.getImagePath());
            stmt.setString(10, cat.getState());
            return stmt.executeUpdate() > 0;
        } catch (SQLException e) {
            e.printStackTrace();
        }
        return false;
    }

    /**
     * 更新猫咪状态（例如领养时改为 "已领养"）
     */
    public boolean updateCatState(int catId, String state) {
        String sql = "UPDATE cats SET state=? WHERE id=?";
        try (Connection conn = DBUtil.getConnection();
             PreparedStatement stmt = conn.prepareStatement(sql)) {
            stmt.setString(1, state);
            stmt.setInt(2, catId);
            return stmt.executeUpdate() > 0;
        } catch (SQLException e) {
            e.printStackTrace();
        }
        return false;
    }

    /**
     * 删除猫咪（可选）
     */
    public boolean deleteCat(int id) {
        String sql = "DELETE FROM cats WHERE id=?";
        try (Connection conn = DBUtil.getConnection();
             PreparedStatement stmt = conn.prepareStatement(sql)) {
            stmt.setInt(1, id);
            return stmt.executeUpdate() > 0;
        } catch (SQLException e) {
            e.printStackTrace();
        }
        return false;
    }

    /**
     * 根据ID集合批量获取猫咪（用于收藏列表等）
     */
    public List<Cat> getCatsByIds(Set<Integer> ids) {
        List<Cat> list = new ArrayList<>();
        if (ids == null || ids.isEmpty()) return list;
        StringBuilder sql = new StringBuilder("SELECT * FROM cats WHERE id IN (");
        for (int i = 0; i < ids.size(); i++) {
            sql.append("?,");
        }
        sql.deleteCharAt(sql.length() - 1);
        sql.append(")");
        try (Connection conn = DBUtil.getConnection();
             PreparedStatement stmt = conn.prepareStatement(sql.toString())) {
            int index = 1;
            for (Integer id : ids) {
                stmt.setInt(index++, id);
            }
            ResultSet rs = stmt.executeQuery();
            while (rs.next()) {
                list.add(mapRowToCat(rs));
            }
        } catch (SQLException e) {
            e.printStackTrace();
        }
        return list;
    }

    /**
     * 将 ResultSet 当前行映射为 Cat 对象
     */
    private Cat mapRowToCat(ResultSet rs) throws SQLException {
        Cat cat = new Cat();
        cat.setId(rs.getInt("id"));
        cat.setName(rs.getString("name"));
        cat.setColor(rs.getString("color"));
        cat.setAge(rs.getInt("age"));
        cat.setGender(rs.getString("gender"));
        cat.setHealthStatus(rs.getString("health_status"));
        cat.setDescription(rs.getString("description"));
        cat.setFoundLocation(rs.getString("found_location"));
        cat.setFoundDate(rs.getDate("found_date"));
        cat.setImagePath(rs.getString("image_path"));
        cat.setState(rs.getString("state"));
        cat.setCreatedAt(rs.getTimestamp("created_at"));
        return cat;
    }
}