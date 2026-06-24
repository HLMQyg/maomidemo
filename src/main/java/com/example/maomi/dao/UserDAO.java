package com.example.maomi.dao;


import com.example.maomi.model.User;
import com.example.maomi.utils.DBUtil;
import java.sql.*;

public class UserDAO {
    // 用户登录验证
    public User login(String username, String password) {
        String sql = "SELECT * FROM users WHERE username=? AND password=?";
        try (Connection conn = DBUtil.getConnection();
             PreparedStatement stmt = conn.prepareStatement(sql)) {
            stmt.setString(1, username);
            stmt.setString(2, password);
            ResultSet rs = stmt.executeQuery();
            if (rs.next()) {
                User user = new User();
                user.setUsername(rs.getString("username"));
                user.setPhone(rs.getString("phone"));
                user.setEmail(rs.getString("email"));
                user.setAddress(rs.getString("address"));
                user.setProfileImage(rs.getString("profile_image"));
                // 更新最后登录时间
                updateLastLogin(username);
                return user;
            }
        } catch (SQLException e) {
            e.printStackTrace();
        }
        return null;
    }

    // 更新最后登录时间
    private void updateLastLogin(String username) {
        String sql = "UPDATE users SET last_login=CURRENT_TIMESTAMP WHERE username=?";
        try (Connection conn = DBUtil.getConnection();
             PreparedStatement stmt = conn.prepareStatement(sql)) {
            stmt.setString(1, username);
            stmt.executeUpdate();
        } catch (SQLException e) {
            e.printStackTrace();
        }
    }

    // 注册新用户
    public boolean register(User user) {
        String sql = "INSERT INTO users (username, password, phone) VALUES (?,?,?)";
        try (Connection conn = DBUtil.getConnection();
             PreparedStatement stmt = conn.prepareStatement(sql)) {
            stmt.setString(1, user.getUsername());
            stmt.setString(2, user.getPassword());
            stmt.setString(3, user.getPhone());
            return stmt.executeUpdate() > 0;
        } catch (SQLException e) {
            e.printStackTrace();
        }
        return false;
    }

    // 检查用户名是否已存在
    public boolean isUsernameExist(String username) {
        String sql = "SELECT 1 FROM users WHERE username=?";
        try (Connection conn = DBUtil.getConnection();
             PreparedStatement stmt = conn.prepareStatement(sql)) {
            stmt.setString(1, username);
            ResultSet rs = stmt.executeQuery();
            return rs.next();
        } catch (SQLException e) {
            e.printStackTrace();
        }
        return false;
    }

    // 检查手机号是否已注册
    public boolean isPhoneExist(String phone) {
        String sql = "SELECT 1 FROM users WHERE phone=?";
        try (Connection conn = DBUtil.getConnection();
             PreparedStatement stmt = conn.prepareStatement(sql)) {
            stmt.setString(1, phone);
            ResultSet rs = stmt.executeQuery();
            return rs.next();
        } catch (SQLException e) {
            e.printStackTrace();
        }
        return false;
    }

    // 更新个人信息（邮箱、地址）
    public boolean updateProfile(String username, String email, String address, String phone) {
        String sql = "UPDATE users SET email=?, address=?, phone=? WHERE username=?";
        try (Connection conn = DBUtil.getConnection();
             PreparedStatement stmt = conn.prepareStatement(sql)) {
            stmt.setString(1, email);
            stmt.setString(2, address);
            stmt.setString(3, phone);
            stmt.setString(4, username);
            return stmt.executeUpdate() > 0;
        } catch (SQLException e) {
            e.printStackTrace();
        }
        return false;
    }

    // 修改密码（验证旧密码后更新）
    public boolean updatePassword(String username, String oldPassword, String newPassword) {
        // 先验证旧密码
        String checkSql = "SELECT 1 FROM users WHERE username=? AND password=?";
        try (Connection conn = DBUtil.getConnection();
             PreparedStatement stmt = conn.prepareStatement(checkSql)) {
            stmt.setString(1, username);
            stmt.setString(2, oldPassword);
            ResultSet rs = stmt.executeQuery();
            if (!rs.next()) {
                return false; // 旧密码错误
            }
        } catch (SQLException e) {
            e.printStackTrace();
            return false;
        }
        // 更新密码
        String updateSql = "UPDATE users SET password=? WHERE username=?";
        try (Connection conn = DBUtil.getConnection();
             PreparedStatement stmt = conn.prepareStatement(updateSql)) {
            stmt.setString(1, newPassword);
            stmt.setString(2, username);
            return stmt.executeUpdate() > 0;
        } catch (SQLException e) {
            e.printStackTrace();
        }
        return false;
    }

    // 更新头像路径
    public boolean updateAvatar(String username, String avatarPath) {
        String sql = "UPDATE users SET profile_image=? WHERE username=?";
        try (Connection conn = DBUtil.getConnection();
             PreparedStatement stmt = conn.prepareStatement(sql)) {
            stmt.setString(1, avatarPath);
            stmt.setString(2, username);
            return stmt.executeUpdate() > 0;
        } catch (SQLException e) { e.printStackTrace(); }
        return false;
    }
}
