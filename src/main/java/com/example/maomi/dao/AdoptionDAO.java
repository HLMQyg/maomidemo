package com.example.maomi.dao;

import com.example.maomi.model.Adoption;
import com.example.maomi.model.AdoptionMessage;
import com.example.maomi.utils.DBUtil;
import java.sql.*;
import java.util.ArrayList;
import java.util.List;

public class AdoptionDAO {

    // 提交领养申请（原 insert 方法，现在使用 cat_name）
    public boolean insert(Adoption ad) {
        String sql = "INSERT INTO adoptions (username, cat_name, applicant_name, applicant_phone, applicant_address, reason, status) VALUES (?,?,?,?,?,?,?)";
        try (Connection conn = DBUtil.getConnection();
             PreparedStatement stmt = conn.prepareStatement(sql)) {
            stmt.setString(1, ad.getUsername());
            stmt.setString(2, ad.getCatName());          // cat_name
            stmt.setString(3, ad.getApplicantName());
            stmt.setString(4, ad.getApplicantPhone());
            stmt.setString(5, ad.getApplicantAddress());
            stmt.setString(6, ad.getReason());
            stmt.setString(7, "待审核");
            return stmt.executeUpdate() > 0;
        } catch (SQLException e) { e.printStackTrace(); }
        return false;
    }

    // 根据用户名获取所有申请
    public List<Adoption> getByUsername(String username) {
        List<Adoption> list = new ArrayList<>();
        String sql = "SELECT * FROM adoptions WHERE username=? ORDER BY apply_date DESC";
        try (Connection conn = DBUtil.getConnection();
             PreparedStatement stmt = conn.prepareStatement(sql)) {
            stmt.setString(1, username);
            ResultSet rs = stmt.executeQuery();
            while (rs.next()) {
                list.add(mapRow(rs));
            }
        } catch (SQLException e) { e.printStackTrace(); }
        return list;
    }

    // 根据ID获取单个申请
    public Adoption getById(int id) {
        String sql = "SELECT * FROM adoptions WHERE id=?";
        try (Connection conn = DBUtil.getConnection();
             PreparedStatement stmt = conn.prepareStatement(sql)) {
            stmt.setInt(1, id);
            ResultSet rs = stmt.executeQuery();
            if (rs.next()) return mapRow(rs);
        } catch (SQLException e) { e.printStackTrace(); }
        return null;
    }

    // 获取某申请的所有消息
    public List<AdoptionMessage> getMessages(int adoptionId) {
        List<AdoptionMessage> list = new ArrayList<>();
        String sql = "SELECT * FROM adoption_messages WHERE adoption_id=? ORDER BY send_time ASC";
        try (Connection conn = DBUtil.getConnection();
             PreparedStatement stmt = conn.prepareStatement(sql)) {
            stmt.setInt(1, adoptionId);
            ResultSet rs = stmt.executeQuery();
            while (rs.next()) {
                AdoptionMessage msg = new AdoptionMessage();
                msg.setId(rs.getInt("id"));
                msg.setAdoptionId(rs.getInt("adoption_id"));
                msg.setSender(rs.getString("sender"));
                msg.setMessage(rs.getString("message"));
                msg.setSendTime(rs.getTimestamp("send_time"));
                list.add(msg);
            }
        } catch (SQLException e) { e.printStackTrace(); }
        return list;
    }

    // 添加消息
    public boolean addMessage(AdoptionMessage msg) {
        String sql = "INSERT INTO adoption_messages (adoption_id, sender, message) VALUES (?,?,?)";
        try (Connection conn = DBUtil.getConnection();
             PreparedStatement stmt = conn.prepareStatement(sql)) {
            stmt.setInt(1, msg.getAdoptionId());
            stmt.setString(2, msg.getSender());
            stmt.setString(3, msg.getMessage());
            return stmt.executeUpdate() > 0;
        } catch (SQLException e) { e.printStackTrace(); }
        return false;
    }

    // 映射方法
    private Adoption mapRow(ResultSet rs) throws SQLException {
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

    // 取消领养申请（仅限待审核状态的申请）
    public boolean cancelAdoption(int id) {
        String sql = "UPDATE adoptions SET status='已取消', cancel_time=NOW() WHERE id=? AND status='待审核'";
        try (Connection conn = DBUtil.getConnection();
             PreparedStatement stmt = conn.prepareStatement(sql)) {
            stmt.setInt(1, id);
            return stmt.executeUpdate() > 0;
        } catch (SQLException e) { e.printStackTrace(); }
        return false;
    }
}