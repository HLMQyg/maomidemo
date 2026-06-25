package com.example.maomi.dao;

import com.example.maomi.model.*;
import com.example.maomi.utils.DBUtil;

import java.sql.*;
import java.util.ArrayList;
import java.util.HashMap;
import java.util.List;
import java.util.Map;

public class ForumDAO {

    // ==================== 帖子 ====================

    public int createThread(ForumThread t) {
        String sql = "INSERT INTO forum_thread (title, content, user_id, cat_id, image_path, category) VALUES (?,?,?,?,?,?)";
        try (Connection conn = DBUtil.getConnection();
             PreparedStatement stmt = conn.prepareStatement(sql, Statement.RETURN_GENERATED_KEYS)) {
            stmt.setString(1, t.getTitle());
            stmt.setString(2, t.getContent());
            stmt.setString(3, t.getUserId());
            if (t.getCatId() != null) stmt.setInt(4, t.getCatId());
            else stmt.setNull(4, Types.INTEGER);
            stmt.setString(5, t.getImagePath());
            stmt.setString(6, t.getCategory());
            stmt.executeUpdate();
            ResultSet rs = stmt.getGeneratedKeys();
            if (rs.next()) return rs.getInt(1);
        } catch (SQLException e) { e.printStackTrace(); }
        return -1;
    }

    /** 帖子列表（支持分类/排序/用户/猫咪/关键词筛选） */
    public List<ForumThread> getThreads(String category, String sort, String userId,
                                         Integer catId, String keyword) {
        List<ForumThread> list = new ArrayList<>();
        StringBuilder sql = new StringBuilder(
            "SELECT t.*, c.name AS cat_name FROM forum_thread t " +
            "LEFT JOIN cats c ON t.cat_id = c.id WHERE t.is_hidden = 0 ");
        List<Object> params = new ArrayList<>();

        if (category != null && !category.isEmpty()) {
            sql.append("AND t.category = ? ");
            params.add(category);
        }
        if (userId != null && !userId.isEmpty()) {
            sql.append("AND t.user_id = ? ");
            params.add(userId);
        }
        if (catId != null) {
            sql.append("AND t.cat_id = ? ");
            params.add(catId);
        }
        if (keyword != null && !keyword.isEmpty()) {
            sql.append("AND (t.title LIKE ? OR t.content LIKE ?) ");
            String kw = "%" + keyword + "%";
            params.add(kw);
            params.add(kw);
        }
        if ("hot".equals(sort)) {
            sql.append("ORDER BY t.is_pinned DESC, t.like_count DESC, t.created_at DESC");
        } else {
            sql.append("ORDER BY t.is_pinned DESC, t.created_at DESC");
        }
        try (Connection conn = DBUtil.getConnection();
             PreparedStatement stmt = conn.prepareStatement(sql.toString())) {
            for (int i = 0; i < params.size(); i++) stmt.setObject(i + 1, params.get(i));
            ResultSet rs = stmt.executeQuery();
            while (rs.next()) list.add(mapThread(rs));
        } catch (SQLException e) { e.printStackTrace(); }
        return list;
    }

    /** 帖子详情 */
    public ForumThread getThreadById(int id) {
        String sql = "SELECT t.*, c.name AS cat_name FROM forum_thread t LEFT JOIN cats c ON t.cat_id = c.id WHERE t.id = ?";
        try (Connection conn = DBUtil.getConnection();
             PreparedStatement stmt = conn.prepareStatement(sql)) {
            stmt.setInt(1, id);
            ResultSet rs = stmt.executeQuery();
            if (rs.next()) return mapThread(rs);
        } catch (SQLException e) { e.printStackTrace(); }
        return null;
    }

    public void incrementViewCount(int id) {
        String sql = "UPDATE forum_thread SET view_count = view_count + 1 WHERE id = ?";
        try (Connection conn = DBUtil.getConnection();
             PreparedStatement stmt = conn.prepareStatement(sql)) {
            stmt.setInt(1, id);
            stmt.executeUpdate();
        } catch (SQLException e) { e.printStackTrace(); }
    }

    // ==================== 管理员 ====================

    public List<ForumThread> getAllThreadsForAdmin() {
        List<ForumThread> list = new ArrayList<>();
        String sql = "SELECT t.*, c.name AS cat_name FROM forum_thread t LEFT JOIN cats c ON t.cat_id = c.id ORDER BY t.is_pinned DESC, t.created_at DESC";
        try (Connection conn = DBUtil.getConnection();
             PreparedStatement stmt = conn.prepareStatement(sql);
             ResultSet rs = stmt.executeQuery()) {
            while (rs.next()) list.add(mapThread(rs));
        } catch (SQLException e) { e.printStackTrace(); }
        return list;
    }

    public void togglePin(int id, int pinned) {
        String sql = "UPDATE forum_thread SET is_pinned = ? WHERE id = ?";
        try (Connection conn = DBUtil.getConnection();
             PreparedStatement stmt = conn.prepareStatement(sql)) {
            stmt.setInt(1, pinned);
            stmt.setInt(2, id);
            stmt.executeUpdate();
        } catch (SQLException e) { e.printStackTrace(); }
    }

    public void toggleHide(int id, int hidden) {
        String sql = "UPDATE forum_thread SET is_hidden = ? WHERE id = ?";
        try (Connection conn = DBUtil.getConnection();
             PreparedStatement stmt = conn.prepareStatement(sql)) {
            stmt.setInt(1, hidden);
            stmt.setInt(2, id);
            stmt.executeUpdate();
        } catch (SQLException e) { e.printStackTrace(); }
    }

    public boolean deleteThread(int id) {
        try (Connection conn = DBUtil.getConnection()) {
            conn.setAutoCommit(false);
            try {
                String[] sqls = {
                    "DELETE FROM forum_report WHERE thread_id = ?",
                    "DELETE FROM forum_comment_like WHERE comment_id IN (SELECT id FROM forum_comment WHERE thread_id = ?)",
                    "DELETE FROM forum_like WHERE thread_id = ?",
                    "DELETE FROM forum_comment WHERE thread_id = ?",
                    "DELETE FROM forum_thread WHERE id = ?"
                };
                for (String sql : sqls) {
                    try (PreparedStatement stmt = conn.prepareStatement(sql)) {
                        stmt.setInt(1, id);
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
        } catch (SQLException e) { e.printStackTrace(); }
        return false;
    }

    // ==================== 评论 ====================

    /** 添加评论（支持回复） */
    public boolean addComment(int threadId, String userId, String content, Integer parentId) {
        String sql = parentId != null
            ? "INSERT INTO forum_comment (thread_id, user_id, content, parent_id) VALUES (?,?,?,?)"
            : "INSERT INTO forum_comment (thread_id, user_id, content) VALUES (?,?,?)";
        try (Connection conn = DBUtil.getConnection();
             PreparedStatement stmt = conn.prepareStatement(sql)) {
            stmt.setInt(1, threadId);
            stmt.setString(2, userId);
            stmt.setString(3, content);
            if (parentId != null) stmt.setInt(4, parentId);
            boolean ok = stmt.executeUpdate() > 0;
            if (ok) updateCommentCount(threadId);
            return ok;
        } catch (SQLException e) { e.printStackTrace(); }
        return false;
    }

    /** 获取帖子评论（带嵌套回复和点赞数） */
    public List<ForumComment> getCommentsWithReplies(int threadId, String sort) {
        List<ForumComment> all = new ArrayList<>();
        String order = "hot".equals(sort) ? "like_count DESC, created_at ASC" : "created_at ASC";
        String sql = "SELECT c.*, COALESCE(l.like_cnt, 0) AS like_count " +
                     "FROM forum_comment c " +
                     "LEFT JOIN (SELECT comment_id, COUNT(*) AS like_cnt FROM forum_comment_like GROUP BY comment_id) l " +
                     "ON c.id = l.comment_id " +
                     "WHERE c.thread_id = ? " +
                     "ORDER BY c.parent_id IS NULL DESC, " + order;
        try (Connection conn = DBUtil.getConnection();
             PreparedStatement stmt = conn.prepareStatement(sql)) {
            stmt.setInt(1, threadId);
            ResultSet rs = stmt.executeQuery();
            while (rs.next()) {
                ForumComment c = new ForumComment();
                c.setId(rs.getInt("id"));
                c.setThreadId(rs.getInt("thread_id"));
                c.setUserId(rs.getString("user_id"));
                c.setContent(rs.getString("content"));
                c.setCreatedAt(rs.getTimestamp("created_at"));
                int pid = rs.getInt("parent_id");
                c.setParentId(rs.wasNull() ? null : pid);
                c.setLikeCount(rs.getInt("like_count"));
                all.add(c);
            }
        } catch (SQLException e) { e.printStackTrace(); }
        return buildCommentTree(all);
    }

    /** 获取帖子评论（兼容旧接口） */
    public List<ForumComment> getComments(int threadId) {
        return getCommentsWithReplies(threadId, "latest");
    }

    /** 将扁平评论列表构建为树形 */
    private List<ForumComment> buildCommentTree(List<ForumComment> all) {
        Map<Integer, ForumComment> map = new HashMap<>();
        List<ForumComment> roots = new ArrayList<>();
        for (ForumComment c : all) {
            map.put(c.getId(), c);
            c.setReplies(new ArrayList<>());
        }
        for (ForumComment c : all) {
            if (c.getParentId() != null && map.containsKey(c.getParentId())) {
                map.get(c.getParentId()).getReplies().add(c);
            } else {
                roots.add(c);
            }
        }
        return roots;
    }

    private void updateCommentCount(int threadId) {
        String sql = "UPDATE forum_thread SET comment_count = (SELECT COUNT(*) FROM forum_comment WHERE thread_id = ?) WHERE id = ?";
        try (Connection conn = DBUtil.getConnection();
             PreparedStatement stmt = conn.prepareStatement(sql)) {
            stmt.setInt(1, threadId);
            stmt.setInt(2, threadId);
            stmt.executeUpdate();
        } catch (SQLException e) { e.printStackTrace(); }
    }

    // ==================== 评论点赞 ====================

    public int toggleCommentLike(int commentId, String userId) {
        try (Connection conn = DBUtil.getConnection()) {
            String checkSql = "SELECT id FROM forum_comment_like WHERE comment_id = ? AND user_id = ?";
            try (PreparedStatement stmt = conn.prepareStatement(checkSql)) {
                stmt.setInt(1, commentId);
                stmt.setString(2, userId);
                ResultSet rs = stmt.executeQuery();
                if (rs.next()) {
                    try (PreparedStatement ds = conn.prepareStatement("DELETE FROM forum_comment_like WHERE id = ?")) {
                        ds.setInt(1, rs.getInt("id"));
                        ds.executeUpdate();
                    }
                } else {
                    try (PreparedStatement is = conn.prepareStatement("INSERT INTO forum_comment_like (comment_id, user_id) VALUES (?,?)")) {
                        is.setInt(1, commentId);
                        is.setString(2, userId);
                        is.executeUpdate();
                    }
                }
            }
            try (PreparedStatement stmt = conn.prepareStatement("SELECT COUNT(*) FROM forum_comment_like WHERE comment_id = ?")) {
                stmt.setInt(1, commentId);
                ResultSet rs = stmt.executeQuery();
                if (rs.next()) return rs.getInt(1);
            }
        } catch (SQLException e) { e.printStackTrace(); }
        return 0;
    }

    public boolean isCommentLiked(int commentId, String userId) {
        String sql = "SELECT 1 FROM forum_comment_like WHERE comment_id = ? AND user_id = ?";
        try (Connection conn = DBUtil.getConnection();
             PreparedStatement stmt = conn.prepareStatement(sql)) {
            stmt.setInt(1, commentId);
            stmt.setString(2, userId);
            return stmt.executeQuery().next();
        } catch (SQLException e) { e.printStackTrace(); }
        return false;
    }

    // ==================== 点赞（帖子） ====================

    public int toggleLike(int threadId, String userId) {
        try (Connection conn = DBUtil.getConnection()) {
            String checkSql = "SELECT id FROM forum_like WHERE thread_id = ? AND user_id = ?";
            try (PreparedStatement stmt = conn.prepareStatement(checkSql)) {
                stmt.setInt(1, threadId);
                stmt.setString(2, userId);
                ResultSet rs = stmt.executeQuery();
                if (rs.next()) {
                    try (PreparedStatement ds = conn.prepareStatement("DELETE FROM forum_like WHERE id = ?")) {
                        ds.setInt(1, rs.getInt("id"));
                        ds.executeUpdate();
                    }
                } else {
                    try (PreparedStatement is = conn.prepareStatement("INSERT INTO forum_like (thread_id, user_id) VALUES (?,?)")) {
                        is.setInt(1, threadId);
                        is.setString(2, userId);
                        is.executeUpdate();
                    }
                }
            }
            String updSql = "UPDATE forum_thread SET like_count = (SELECT COUNT(*) FROM forum_like WHERE thread_id = ?) WHERE id = ?";
            try (PreparedStatement stmt = conn.prepareStatement(updSql)) {
                stmt.setInt(1, threadId);
                stmt.setInt(2, threadId);
                stmt.executeUpdate();
            }
            String cntSql = "SELECT like_count FROM forum_thread WHERE id = ?";
            try (PreparedStatement stmt = conn.prepareStatement(cntSql)) {
                stmt.setInt(1, threadId);
                ResultSet rs = stmt.executeQuery();
                if (rs.next()) return rs.getInt("like_count");
            }
        } catch (SQLException e) { e.printStackTrace(); }
        return 0;
    }

    public boolean isLiked(int threadId, String userId) {
        String sql = "SELECT 1 FROM forum_like WHERE thread_id = ? AND user_id = ?";
        try (Connection conn = DBUtil.getConnection();
             PreparedStatement stmt = conn.prepareStatement(sql)) {
            stmt.setInt(1, threadId);
            stmt.setString(2, userId);
            return stmt.executeQuery().next();
        } catch (SQLException e) { e.printStackTrace(); }
        return false;
    }

    // ==================== 举报 ====================

    public boolean addReport(ForumReport r) {
        String sql = "INSERT INTO forum_report (thread_id, user_id, reason) VALUES (?,?,?)";
        try (Connection conn = DBUtil.getConnection();
             PreparedStatement stmt = conn.prepareStatement(sql)) {
            stmt.setInt(1, r.getThreadId());
            stmt.setString(2, r.getUserId());
            stmt.setString(3, r.getReason());
            return stmt.executeUpdate() > 0;
        } catch (SQLException e) { e.printStackTrace(); }
        return false;
    }

    public List<ForumReport> getAllReports() {
        List<ForumReport> list = new ArrayList<>();
        String sql = "SELECT r.*, t.title AS thread_title FROM forum_report r JOIN forum_thread t ON r.thread_id = t.id ORDER BY r.created_at DESC";
        try (Connection conn = DBUtil.getConnection();
             PreparedStatement stmt = conn.prepareStatement(sql);
             ResultSet rs = stmt.executeQuery()) {
            while (rs.next()) {
                ForumReport r = new ForumReport();
                r.setId(rs.getInt("id"));
                r.setThreadId(rs.getInt("thread_id"));
                r.setUserId(rs.getString("user_id"));
                r.setReason(rs.getString("reason"));
                r.setStatus(rs.getString("status"));
                r.setAdminNotes(rs.getString("admin_notes"));
                r.setCreatedAt(rs.getTimestamp("created_at"));
                r.setThreadTitle(rs.getString("thread_title"));
                list.add(r);
            }
        } catch (SQLException e) { e.printStackTrace(); }
        return list;
    }

    public boolean handleReport(int id, String status, String notes) {
        String sql = "UPDATE forum_report SET status = ?, admin_notes = ? WHERE id = ?";
        try (Connection conn = DBUtil.getConnection();
             PreparedStatement stmt = conn.prepareStatement(sql)) {
            stmt.setString(1, status);
            stmt.setString(2, notes);
            stmt.setInt(3, id);
            return stmt.executeUpdate() > 0;
        } catch (SQLException e) { e.printStackTrace(); }
        return false;
    }

    // ==================== 工具 ====================

    private ForumThread mapThread(ResultSet rs) throws SQLException {
        ForumThread t = new ForumThread();
        t.setId(rs.getInt("id"));
        t.setTitle(rs.getString("title"));
        t.setContent(rs.getString("content"));
        t.setUserId(rs.getString("user_id"));
        t.setCatId(rs.getObject("cat_id") != null ? rs.getInt("cat_id") : null);
        t.setImagePath(rs.getString("image_path"));
        t.setCategory(rs.getString("category"));
        t.setIsPinned(rs.getInt("is_pinned"));
        t.setIsHidden(rs.getInt("is_hidden"));
        t.setViewCount(rs.getInt("view_count"));
        t.setLikeCount(rs.getInt("like_count"));
        t.setCommentCount(rs.getInt("comment_count"));
        t.setCreatedAt(rs.getTimestamp("created_at"));
        try { t.setCatName(rs.getString("cat_name")); } catch (SQLException ignored) {}
        return t;
    }
}