package com.example.maomi.model;

import java.sql.Timestamp;
import java.util.List;

public class ForumComment {
    private int id;
    private int threadId;
    private String userId;
    private String content;
    private Timestamp createdAt;
    private Integer parentId;
    private int likeCount;
    private List<ForumComment> replies;

    public ForumComment() {}

    public int getId() { return id; }
    public void setId(int id) { this.id = id; }
    public int getThreadId() { return threadId; }
    public void setThreadId(int threadId) { this.threadId = threadId; }
    public String getUserId() { return userId; }
    public void setUserId(String userId) { this.userId = userId; }
    public String getContent() { return content; }
    public void setContent(String content) { this.content = content; }
    public Timestamp getCreatedAt() { return createdAt; }
    public void setCreatedAt(Timestamp createdAt) { this.createdAt = createdAt; }
    public Integer getParentId() { return parentId; }
    public void setParentId(Integer parentId) { this.parentId = parentId; }
    public int getLikeCount() { return likeCount; }
    public void setLikeCount(int likeCount) { this.likeCount = likeCount; }
    public List<ForumComment> getReplies() { return replies; }
    public void setReplies(List<ForumComment> replies) { this.replies = replies; }
}