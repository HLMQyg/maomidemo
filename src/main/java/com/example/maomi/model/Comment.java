package com.example.maomi.model;

import java.sql.Timestamp;

public class Comment {
    private int id;
    private int catId;
    private String username;
    private String comment;
    private Timestamp commentTime;

    public Comment() {}

    public int getId() { return id; }
    public void setId(int id) { this.id = id; }
    public int getCatId() { return catId; }
    public void setCatId(int catId) { this.catId = catId; }
    public String getUsername() { return username; }
    public void setUsername(String username) { this.username = username; }
    public String getComment() { return comment; }
    public void setComment(String comment) { this.comment = comment; }
    public Timestamp getCommentTime() { return commentTime; }
    public void setCommentTime(Timestamp commentTime) { this.commentTime = commentTime; }
}