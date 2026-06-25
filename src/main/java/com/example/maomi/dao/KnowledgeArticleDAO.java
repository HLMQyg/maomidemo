package com.example.maomi.dao;

import com.example.maomi.model.KnowledgeArticle;
import com.example.maomi.utils.DBUtil;
import java.sql.*;
import java.util.ArrayList;
import java.util.List;

public class KnowledgeArticleDAO {

    // 获取所有文章（按时间倒序）
    public List<KnowledgeArticle> getAll() {
        List<KnowledgeArticle> list = new ArrayList<>();
        String sql = "SELECT * FROM knowledge_article ORDER BY created_at DESC";
        try (Connection conn = DBUtil.getConnection();
             PreparedStatement stmt = conn.prepareStatement(sql);
             ResultSet rs = stmt.executeQuery()) {
            while (rs.next()) {
                list.add(mapRow(rs));
            }
        } catch (SQLException e) { e.printStackTrace(); }
        return list;
    }

    // 根据分类获取文章
    public List<KnowledgeArticle> getByCategory(String category) {
        List<KnowledgeArticle> list = new ArrayList<>();
        String sql = "SELECT * FROM knowledge_article WHERE category=? ORDER BY created_at DESC";
        try (Connection conn = DBUtil.getConnection();
             PreparedStatement stmt = conn.prepareStatement(sql)) {
            stmt.setString(1, category);
            ResultSet rs = stmt.executeQuery();
            while (rs.next()) {
                list.add(mapRow(rs));
            }
        } catch (SQLException e) { e.printStackTrace(); }
        return list;
    }

    // 搜索文章（标题或内容模糊匹配）
    public List<KnowledgeArticle> search(String keyword) {
        List<KnowledgeArticle> list = new ArrayList<>();
        String sql = "SELECT * FROM knowledge_article WHERE title LIKE ? OR content LIKE ? ORDER BY created_at DESC";
        try (Connection conn = DBUtil.getConnection();
             PreparedStatement stmt = conn.prepareStatement(sql)) {
            String kw = "%" + keyword + "%";
            stmt.setString(1, kw);
            stmt.setString(2, kw);
            ResultSet rs = stmt.executeQuery();
            while (rs.next()) {
                list.add(mapRow(rs));
            }
        } catch (SQLException e) { e.printStackTrace(); }
        return list;
    }

    // 根据ID获取文章
    public KnowledgeArticle getById(int id) {
        String sql = "SELECT * FROM knowledge_article WHERE id=?";
        try (Connection conn = DBUtil.getConnection();
             PreparedStatement stmt = conn.prepareStatement(sql)) {
            stmt.setInt(1, id);
            ResultSet rs = stmt.executeQuery();
            if (rs.next()) {
                return mapRow(rs);
            }
        } catch (SQLException e) { e.printStackTrace(); }
        return null;
    }

    // 增加阅读量
    public void increaseReadCount(int id) {
        String sql = "UPDATE knowledge_article SET read_count = read_count + 1 WHERE id=?";
        try (Connection conn = DBUtil.getConnection();
             PreparedStatement stmt = conn.prepareStatement(sql)) {
            stmt.setInt(1, id);
            stmt.executeUpdate();
        } catch (SQLException e) { e.printStackTrace(); }
    }

    private KnowledgeArticle mapRow(ResultSet rs) throws SQLException {
        KnowledgeArticle article = new KnowledgeArticle();
        article.setId(rs.getInt("id"));
        article.setTitle(rs.getString("title"));
        article.setCategory(rs.getString("category"));
        article.setContent(rs.getString("content"));
        article.setAuthor(rs.getString("author"));
        article.setReadCount(rs.getInt("read_count"));
        article.setRecommend(rs.getInt("recommend"));
        article.setCreatedAt(rs.getTimestamp("created_at"));
        return article;
    }
}