package com.example.maomi.dao;

import com.example.maomi.model.Adoption;
import com.example.maomi.utils.DBUtil;
import java.sql.*;

public class AdoptionDAO {
    public boolean insert(Adoption adoption) {
        String sql = "INSERT INTO adoptions (username, cat_id, applicant_name, applicant_phone, applicant_address, reason, status) VALUES (?,?,?,?,?,?,?)";
        try (Connection conn = DBUtil.getConnection();
             PreparedStatement stmt = conn.prepareStatement(sql)) {
            stmt.setString(1, adoption.getUsername());
            stmt.setInt(2, adoption.getCatId());
            stmt.setString(3, adoption.getApplicantName());
            stmt.setString(4, adoption.getApplicantPhone());
            stmt.setString(5, adoption.getApplicantAddress());
            stmt.setString(6, adoption.getReason());
            stmt.setString(7, adoption.getStatus());
            return stmt.executeUpdate() > 0;
        } catch (SQLException e) { e.printStackTrace(); }
        return false;
    }
}
