package com.example.maomi.model;

import java.sql.Timestamp;

public class ForumReport {
    private int id;
    private int threadId;
    private String userId;
    private String reason;
    private String status;
    private String adminNotes;
    private Timestamp createdAt;
    // 列表展示用
    private String threadTitle;

    public ForumReport() {}

    public int getId() { return id; }
    public void setId(int id) { this.id = id; }
    public int getThreadId() { return threadId; }
    public void setThreadId(int threadId) { this.threadId = threadId; }
    public String getUserId() { return userId; }
    public void setUserId(String userId) { this.userId = userId; }
    public String getReason() { return reason; }
    public void setReason(String reason) { this.reason = reason; }
    public String getStatus() { return status; }
    public void setStatus(String status) { this.status = status; }
    public String getAdminNotes() { return adminNotes; }
    public void setAdminNotes(String adminNotes) { this.adminNotes = adminNotes; }
    public Timestamp getCreatedAt() { return createdAt; }
    public void setCreatedAt(Timestamp createdAt) { this.createdAt = createdAt; }
    public String getThreadTitle() { return threadTitle; }
    public void setThreadTitle(String threadTitle) { this.threadTitle = threadTitle; }
}