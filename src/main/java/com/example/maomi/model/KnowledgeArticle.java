package com.example.maomi.model;

import java.sql.Timestamp;

public class KnowledgeArticle {
    private int id;
    private String title;
    private String category;
    private String content;
    private String author;
    private int readCount;
    private int recommend;   // 0 或 1
    private Timestamp createdAt;

    public KnowledgeArticle() {}

    // Getter & Setter
    public int getId() { return id; }
    public void setId(int id) { this.id = id; }
    public String getTitle() { return title; }
    public void setTitle(String title) { this.title = title; }
    public String getCategory() { return category; }
    public void setCategory(String category) { this.category = category; }
    public String getContent() { return content; }
    public void setContent(String content) { this.content = content; }
    public String getAuthor() { return author; }
    public void setAuthor(String author) { this.author = author; }
    public int getReadCount() { return readCount; }
    public void setReadCount(int readCount) { this.readCount = readCount; }
    public int getRecommend() { return recommend; }
    public void setRecommend(int recommend) { this.recommend = recommend; }
    public Timestamp getCreatedAt() { return createdAt; }
    public void setCreatedAt(Timestamp createdAt) { this.createdAt = createdAt; }
}