package com.example.maomi.model;

import java.sql.Timestamp;

public class Adoption {
    private int id;
    private String username;
    private String catName;          // 改为 catName
    private String applicantName;
    private String applicantPhone;
    private String applicantAddress;
    private String reason;
    private String status;
    private String reviewNotes;
    private Timestamp applyDate;
    private Timestamp reviewDate;
    private Timestamp cancelTime;

    // Getter & Setter ...
    public int getId() { return id; }
    public void setId(int id) { this.id = id; }
    public String getUsername() { return username; }
    public void setUsername(String username) { this.username = username; }
    public String getCatName() { return catName; }
    public void setCatName(String catName) { this.catName = catName; }
    public String getApplicantName() { return applicantName; }
    public void setApplicantName(String applicantName) { this.applicantName = applicantName; }
    public String getApplicantPhone() { return applicantPhone; }
    public void setApplicantPhone(String applicantPhone) { this.applicantPhone = applicantPhone; }
    public String getApplicantAddress() { return applicantAddress; }
    public void setApplicantAddress(String applicantAddress) { this.applicantAddress = applicantAddress; }
    public String getReason() { return reason; }
    public void setReason(String reason) { this.reason = reason; }
    public String getStatus() { return status; }
    public void setStatus(String status) { this.status = status; }
    public String getReviewNotes() { return reviewNotes; }
    public void setReviewNotes(String reviewNotes) { this.reviewNotes = reviewNotes; }
    public Timestamp getApplyDate() { return applyDate; }
    public void setApplyDate(Timestamp applyDate) { this.applyDate = applyDate; }
    public Timestamp getReviewDate() { return reviewDate; }
    public void setReviewDate(Timestamp reviewDate) { this.reviewDate = reviewDate; }
    public Timestamp getCancelTime() { return cancelTime; }
    public void setCancelTime(Timestamp cancelTime) { this.cancelTime = cancelTime; }
}