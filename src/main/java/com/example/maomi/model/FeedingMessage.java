package com.example.maomi.model;

import java.sql.Timestamp;

public class FeedingMessage {
    private int id;
    private int catId;
    private String feederUsername;
    private String message;
    private String imagePath;    // 新增：管理员上传的图片路径
    private String status;
    private Timestamp createdAt;
    private String catName;      // 新增：猫咪名称（查询时填充）

    public FeedingMessage() {
    }

    // getters & setters 略，请补充
    public String getImagePath() { return imagePath; }
    public void setImagePath(String imagePath) { this.imagePath = imagePath; }
    public String getCatName() { return catName; }
    public void setCatName(String catName) { this.catName = catName; }

    public int getId() {
        return id;
    }

    public void setId(int id) {
        this.id = id;
    }

    public int getCatId() {
        return catId;
    }

    public void setCatId(int catId) {
        this.catId = catId;
    }

    public String getFeederUsername() {
        return feederUsername;
    }

    public void setFeederUsername(String feederUsername) {
        this.feederUsername = feederUsername;
    }

    public String getMessage() {
        return message;
    }

    public void setMessage(String message) {
        this.message = message;
    }

    public String getStatus() {
        return status;
    }

    public void setStatus(String status) {
        this.status = status;
    }

    public Timestamp getCreatedAt() {
        return createdAt;
    }

    public void setCreatedAt(Timestamp createdAt) {
        this.createdAt = createdAt;
    }
}