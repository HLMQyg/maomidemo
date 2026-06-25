package com.example.maomi.model;

import java.sql.Timestamp;

public class ForumThread {
    private int id;
    private String title;
    private String content;
    private String userId;
    private Integer catId;
    private String imagePath;
    private String category;
    private int isPinned;
    private int isHidden;
    private int viewCount;
    private int likeCount;
    private int commentCount;
    private Timestamp createdAt;
    // 列表展示用
    private String catName;

    public ForumThread() {}

    public int getId() { return id; }
    public void setId(int id) { this.id = id; }
    public String getTitle() { return title; }
    public void setTitle(String title) { this.title = title; }
    public String getContent() { return content; }
    public void setContent(String content) { this.content = content; }
    public String getUserId() { return userId; }
    public void setUserId(String userId) { this.userId = userId; }
    public Integer getCatId() { return catId; }
    public void setCatId(Integer catId) { this.catId = catId; }
    public String getImagePath() { return imagePath; }
    public void setImagePath(String imagePath) { this.imagePath = imagePath; }
    public String getCategory() { return category; }
    public void setCategory(String category) { this.category = category; }
    public int getIsPinned() { return isPinned; }
    public void setIsPinned(int isPinned) { this.isPinned = isPinned; }
    public int getIsHidden() { return isHidden; }
    public void setIsHidden(int isHidden) { this.isHidden = isHidden; }
    public int getViewCount() { return viewCount; }
    public void setViewCount(int viewCount) { this.viewCount = viewCount; }
    public int getLikeCount() { return likeCount; }
    public void setLikeCount(int likeCount) { this.likeCount = likeCount; }
    public int getCommentCount() { return commentCount; }
    public void setCommentCount(int commentCount) { this.commentCount = commentCount; }
    public Timestamp getCreatedAt() { return createdAt; }
    public void setCreatedAt(Timestamp createdAt) { this.createdAt = createdAt; }
    public String getCatName() { return catName; }
    public void setCatName(String catName) { this.catName = catName; }
}