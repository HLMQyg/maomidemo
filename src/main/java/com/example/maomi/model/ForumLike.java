package com.example.maomi.model;

public class ForumLike {
    private int id;
    private int threadId;
    private String userId;

    public ForumLike() {}

    public int getId() { return id; }
    public void setId(int id) { this.id = id; }
    public int getThreadId() { return threadId; }
    public void setThreadId(int threadId) { this.threadId = threadId; }
    public String getUserId() { return userId; }
    public void setUserId(String userId) { this.userId = userId; }
}