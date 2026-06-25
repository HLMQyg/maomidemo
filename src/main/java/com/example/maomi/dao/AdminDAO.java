package com.example.maomi.dao;

import com.example.maomi.model.Adoption;
import com.example.maomi.model.Comment;
import com.example.maomi.model.User;
import com.example.maomi.utils.DBUtil;

import java.sql.*;
import java.util.ArrayList;
import java.util.HashMap;
import java.util.List;
import java.util.Map;

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

    /** 获取统计数据 */
    public Map<String, Integer> getStats() {
        Map<String, Integer> stats = new HashMap<>();
        String sql = "SELECT " +
                "(SELECT COUNT(*) FROM cats) AS totalCats, " +
                "(SELECT COUNT(*) FROM cats WHERE state='在校') AS schoolCats, " +
                "(SELECT COUNT(*) FROM cats WHERE state='已领养') AS adoptedCats, " +
                "(SELECT COUNT(*) FROM users) AS totalUsers, " +
                "(SELECT COUNT(*) FROM adoptions WHERE status='待审核') AS pendingAdoptions, " +
                "(SELECT COUNT(*) FROM adoptions WHERE status='已通过') AS approvedAdoptions, " +
                "(SELECT COUNT(*) FROM adoptions WHERE status='已拒绝') AS rejectedAdoptions, " +
                "(SELECT COUNT(*) FROM cat_comments) AS totalComments";
        try (Connection conn = DBUtil.getConnection();
             Statement stmt = conn.createStatement();
             ResultSet rs = stmt.executeQuery(sql)) {
            if (rs.next()) {
                stats.put("totalCats", rs.getInt("totalCats"));
                stats.put("schoolCats", rs.getInt("schoolCats"));
                stats.put("adoptedCats", rs.getInt("adoptedCats"));
                stats.put("totalUsers", rs.getInt("totalUsers"));
                stats.put("pendingAdoptions", rs.getInt("pendingAdoptions"));
                stats.put("approvedAdoptions", rs.getInt("approvedAdoptions"));
                stats.put("rejectedAdoptions", rs.getInt("rejectedAdoptions"));
                stats.put("totalComments", rs.getInt("totalComments"));
            }
        } catch (SQLException e) {
            e.printStackTrace();
        }
        return stats;
    }

    /** 获取所有领养申请 */
    public List<Adoption> getAllAdoptions() {
        List<Adoption> list = new ArrayList<>();
        String sql = "SELECT * FROM adoptions ORDER BY apply_date DESC";
        try (Connection conn = DBUtil.getConnection();
             PreparedStatement stmt = conn.prepareStatement(sql);
             ResultSet rs = stmt.executeQuery()) {
            while (rs.next()) {
                list.add(mapAdoption(rs));
            }
        } catch (SQLException e) {
            e.printStackTrace();
        }
        return list;
    }

    /** 更新领养状态 */
    public boolean updateAdoptionStatus(int id, String status, String notes) {
        String sql = "UPDATE adoptions SET status=?, review_notes=?, review_date=NOW() WHERE id=?";
        try (Connection conn = DBUtil.getConnection();
             PreparedStatement stmt = conn.prepareStatement(sql)) {
            stmt.setString(1, status);
            stmt.setString(2, notes);
            stmt.setInt(3, id);
            return stmt.executeUpdate() > 0;
        } catch (SQLException e) {
            e.printStackTrace();
        }
        return false;
    }

    /** 获取所有用户 */
    public List<User> getAllUsers() {
        List<User> list = new ArrayList<>();
        String sql = "SELECT username, phone, email, address, register_date, last_login, profile_image FROM users ORDER BY register_date DESC";
        try (Connection conn = DBUtil.getConnection();
             PreparedStatement stmt = conn.prepareStatement(sql);
             ResultSet rs = stmt.executeQuery()) {
            while (rs.next()) {
                User user = new User();
                user.setUsername(rs.getString("username"));
                user.setPhone(rs.getString("phone"));
                user.setEmail(rs.getString("email"));
                user.setAddress(rs.getString("address"));
                user.setRegisterDate(rs.getTimestamp("register_date"));
                user.setLastLogin(rs.getTimestamp("last_login"));
                user.setProfileImage(rs.getString("profile_image"));
                list.add(user);
            }
        } catch (SQLException e) {
            e.printStackTrace();
        }
        return list;
    }

    /** 删除用户 */
    public boolean deleteUser(String username) {
        try (Connection conn = DBUtil.getConnection()) {
            conn.setAutoCommit(false);
            try {
                // 删除用户相关的收藏、评论、领养消息、领养申请
                String[] sqls = {
                    "DELETE FROM user_favorites WHERE username=?",
                    "DELETE FROM cat_comments WHERE username=?",
                    "DELETE FROM adoption_messages WHERE sender=?",
                    "DELETE FROM adoption_messages WHERE adoption_id IN (SELECT id FROM adoptions WHERE username=?)",
                    "DELETE FROM adoptions WHERE username=?",
                    "DELETE FROM users WHERE username=?"
                };
                for (String sql : sqls) {
                    try (PreparedStatement stmt = conn.prepareStatement(sql)) {
                        stmt.setString(1, username);
                        stmt.executeUpdate();
                    }
                }
                conn.commit();
                return true;
            } catch (SQLException e) {
                conn.rollback();
                e.printStackTrace();
            } finally {
                conn.setAutoCommit(true);
            }
        } catch (SQLException e) {
            e.printStackTrace();
        }
        return false;
    }

    /** 获取所有评论 */
    public List<Comment> getAllComments() {
        List<Comment> list = new ArrayList<>();
        String sql = "SELECT id, cat_id, username, comment, comment_time FROM cat_comments ORDER BY comment_time DESC";
        try (Connection conn = DBUtil.getConnection();
             PreparedStatement stmt = conn.prepareStatement(sql);
             ResultSet rs = stmt.executeQuery()) {
            while (rs.next()) {
                Comment c = new Comment();
                c.setId(rs.getInt("id"));
                c.setCatId(rs.getInt("cat_id"));
                c.setUsername(rs.getString("username"));
                c.setComment(rs.getString("comment"));
                c.setCommentTime(rs.getTimestamp("comment_time"));
                list.add(c);
            }
        } catch (SQLException e) {
            e.printStackTrace();
        }
        return list;
    }

    /** 删除评论 */
    public boolean deleteComment(int id) {
        String sql = "DELETE FROM cat_comments WHERE id=?";
        try (Connection conn = DBUtil.getConnection();
             PreparedStatement stmt = conn.prepareStatement(sql)) {
            stmt.setInt(1, id);
            return stmt.executeUpdate() > 0;
        } catch (SQLException e) {
            e.printStackTrace();
        }
        return false;
    }

    /** 更新猫咪信息 */
    public boolean updateCat(int id, String name, String color, int age, String gender,
                             String healthStatus, String description, String foundLocation,
                             java.sql.Date foundDate, String imagePath) {
        String sql = "UPDATE cats SET name=?, color=?, age=?, gender=?, health_status=?, " +
                "description=?, found_location=?, found_date=?, image_path=? WHERE id=?";
        try (Connection conn = DBUtil.getConnection();
             PreparedStatement stmt = conn.prepareStatement(sql)) {
            stmt.setString(1, name);
            stmt.setString(2, color);
            stmt.setInt(3, age);
            stmt.setString(4, gender);
            stmt.setString(5, healthStatus);
            stmt.setString(6, description);
            stmt.setString(7, foundLocation);
            stmt.setDate(8, foundDate);
            stmt.setString(9, imagePath);
            stmt.setInt(10, id);
            return stmt.executeUpdate() > 0;
        } catch (SQLException e) {
            e.printStackTrace();
        }
        return false;
    }

    private Adoption mapAdoption(ResultSet rs) throws SQLException {
        Adoption ad = new Adoption();
        ad.setId(rs.getInt("id"));
        ad.setUsername(rs.getString("username"));
        ad.setCatName(rs.getString("cat_name"));
        ad.setApplicantName(rs.getString("applicant_name"));
        ad.setApplicantPhone(rs.getString("applicant_phone"));
        ad.setApplicantAddress(rs.getString("applicant_address"));
        ad.setReason(rs.getString("reason"));
        ad.setStatus(rs.getString("status"));
        ad.setReviewNotes(rs.getString("review_notes"));
        ad.setApplyDate(rs.getTimestamp("apply_date"));
        ad.setReviewDate(rs.getTimestamp("review_date"));
        ad.setCancelTime(rs.getTimestamp("cancel_time"));
        return ad;
    }
}
