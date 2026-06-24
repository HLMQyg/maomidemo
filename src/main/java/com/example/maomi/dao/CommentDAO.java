package com.example.maomi.dao;

import com.example.maomi.model.Comment;
import com.example.maomi.utils.DBUtil;
import java.sql.*;
import java.util.ArrayList;
import java.util.List;

public class CommentDAO {

    // 获取某只猫咪的所有留言（按时间正序）
    public List<Comment> getCommentsByCatId(int catId) {
        List<Comment> comments = new ArrayList<>();
        String sql = "SELECT id, cat_id, username, comment, comment_time FROM cat_comments WHERE cat_id=? ORDER BY comment_time ASC";
        try (Connection conn = DBUtil.getConnection();
             PreparedStatement stmt = conn.prepareStatement(sql)) {
            stmt.setInt(1, catId);
            ResultSet rs = stmt.executeQuery();
            while (rs.next()) {
                Comment c = new Comment();
                c.setId(rs.getInt("id"));
                c.setCatId(rs.getInt("cat_id"));
                c.setUsername(rs.getString("username"));
                c.setComment(rs.getString("comment"));
                c.setCommentTime(rs.getTimestamp("comment_time"));
                comments.add(c);
            }
        } catch (SQLException e) {
            e.printStackTrace();
        }
        return comments;
    }

    // 添加留言
    public boolean addComment(int catId, String username, String comment) {
        String sql = "INSERT INTO cat_comments (cat_id, username, comment) VALUES (?,?,?)";
        try (Connection conn = DBUtil.getConnection();
             PreparedStatement stmt = conn.prepareStatement(sql)) {
            stmt.setInt(1, catId);
            stmt.setString(2, username);
            stmt.setString(3, comment);
            return stmt.executeUpdate() > 0;
        } catch (SQLException e) {
            e.printStackTrace();
        }
        return false;
    }
}
