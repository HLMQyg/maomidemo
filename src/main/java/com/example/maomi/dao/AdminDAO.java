package com.example.maomi.dao;

import com.example.maomi.model.Adoption;
import com.example.maomi.model.FeedingMessage;
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
                "(SELECT COUNT(*) FROM forum_comment) AS totalComments";
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


    /** 获取所有论坛评论（关联帖子标题） */
    public List<Map<String, Object>> getForumCommentsForAdmin() {
        List<Map<String, Object>> list = new ArrayList<>();
        String sql = "SELECT fc.*, ft.title AS thread_title, ft.user_id AS thread_author " +
                     "FROM forum_comment fc JOIN forum_thread ft ON fc.thread_id = ft.id " +
                     "ORDER BY fc.created_at DESC";
        try (Connection conn = DBUtil.getConnection();
             PreparedStatement stmt = conn.prepareStatement(sql);
             ResultSet rs = stmt.executeQuery()) {
            while (rs.next()) {
                Map<String, Object> row = new HashMap<>();
                row.put("id", rs.getInt("id"));
                row.put("threadId", rs.getInt("thread_id"));
                row.put("threadTitle", rs.getString("thread_title"));
                row.put("threadAuthor", rs.getString("thread_author"));
                row.put("userId", rs.getString("user_id"));
                row.put("content", rs.getString("content"));
                row.put("createdAt", rs.getTimestamp("created_at"));
                list.add(row);
            }
        } catch (SQLException e) { e.printStackTrace(); }
        return list;
    }

    /** 删除论坛评论 */
    public boolean deleteForumComment(int id) {
        String sql = "DELETE FROM forum_comment WHERE id=?";
        try (Connection conn = DBUtil.getConnection();
             PreparedStatement stmt = conn.prepareStatement(sql)) {
            stmt.setInt(1, id);
            return stmt.executeUpdate() > 0;
        } catch (SQLException e) { e.printStackTrace(); }
        return false;
    }    private Adoption mapAdoption(ResultSet rs) throws SQLException {
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

    // 获取所有喂养中的猫咪（状态为“喂养中”）
    public List<Map<String, Object>> getFeedingCats() {
        List<Map<String, Object>> list = new ArrayList<>();
        String sql = "SELECT c.id, c.name, c.image_path, fr.username AS feeder, fr.feed_time " +
                "FROM cats c JOIN (SELECT cat_id, username, MAX(feed_time) AS feed_time FROM feeding_records GROUP BY cat_id, username) fr ON c.id = fr.cat_id " +
                "WHERE c.state = '喂养中' ORDER BY fr.feed_time DESC";
        try (Connection conn = DBUtil.getConnection();
             Statement stmt = conn.createStatement();
             ResultSet rs = stmt.executeQuery(sql)) {
            while (rs.next()) {
                Map<String, Object> row = new HashMap<>();
                row.put("catId", rs.getInt("id"));
                row.put("catName", rs.getString("name"));
                row.put("catImage", rs.getString("image_path"));
                row.put("feeder", rs.getString("feeder"));
                row.put("feedTime", rs.getTimestamp("feed_time"));
                list.add(row);
            }
        } catch (SQLException e) { e.printStackTrace(); }
        return list;
    }

    // 更新猫咪状态为“已喂养”
    public boolean completeFeeding(int catId) {
        String sql = "UPDATE cats SET state='在校' WHERE id=?";
        try (Connection conn = DBUtil.getConnection();
             PreparedStatement stmt = conn.prepareStatement(sql)) {
            stmt.setInt(1, catId);
            return stmt.executeUpdate() > 0;
        } catch (SQLException e) { e.printStackTrace(); }
        return false;
    }

    // 插入喂养回复消息
    public boolean insertFeedingMessage(int catId, String feederUsername, String message, String imagePath) {
        String sql = "INSERT INTO feeding_messages (cat_id, feeder_username, message, image_path) VALUES (?,?,?,?)";
        try (Connection conn = DBUtil.getConnection();
             PreparedStatement stmt = conn.prepareStatement(sql)) {
            stmt.setInt(1, catId);
            stmt.setString(2, feederUsername);
            stmt.setString(3, message);
            stmt.setString(4, imagePath);
            return stmt.executeUpdate() > 0;
        } catch (SQLException e) { e.printStackTrace(); }
        return false;
    }

    // 获取给某个用户的喂养回复消息
    public List<FeedingMessage> getFeedingMessagesForUser(String feederUsername) {
        List<FeedingMessage> list = new ArrayList<>();
        String sql = "SELECT fm.*, c.name AS cat_name FROM feeding_messages fm " +
                "JOIN cats c ON fm.cat_id = c.id WHERE fm.feeder_username=? ORDER BY fm.created_at DESC";
        try (Connection conn = DBUtil.getConnection();
             PreparedStatement stmt = conn.prepareStatement(sql)) {
            stmt.setString(1, feederUsername);
            ResultSet rs = stmt.executeQuery();
            while (rs.next()) {
                FeedingMessage msg = new FeedingMessage();
                msg.setId(rs.getInt("id"));
                msg.setCatId(rs.getInt("cat_id"));
                msg.setFeederUsername(rs.getString("feeder_username"));
                msg.setMessage(rs.getString("message"));
                msg.setImagePath(rs.getString("image_path"));   // 新增
                msg.setStatus(rs.getString("status"));
                msg.setCreatedAt(rs.getTimestamp("created_at"));
                msg.setCatName(rs.getString("cat_name"));       // 新增
                list.add(msg);
            }
        } catch (SQLException e) { e.printStackTrace(); }
        return list;
    }
    // 获取未读喂养消息数量
    public int getUnreadFeedingMessageCount(String feederUsername) {
        String sql = "SELECT COUNT(*) FROM feeding_messages WHERE feeder_username=? AND status='未读'";
        try (Connection conn = DBUtil.getConnection();
             PreparedStatement stmt = conn.prepareStatement(sql)) {
            stmt.setString(1, feederUsername);
            ResultSet rs = stmt.executeQuery();
            if (rs.next()) return rs.getInt(1);
        } catch (SQLException e) { e.printStackTrace(); }
        return 0;
    }

    // 将指定用户的所有喂养消息标记为已读
    public boolean markFeedingMessagesAsRead(String feederUsername) {
        String sql = "UPDATE feeding_messages SET status='已读' WHERE feeder_username=? AND status='未读'";
        try (Connection conn = DBUtil.getConnection();
             PreparedStatement stmt = conn.prepareStatement(sql)) {
            stmt.setString(1, feederUsername);
            stmt.executeUpdate();
            return true;
        } catch (SQLException e) { e.printStackTrace(); }
        return false;
    }
}
