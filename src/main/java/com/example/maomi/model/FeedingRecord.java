package com.example.maomi.model;

import java.sql.Timestamp;

public class FeedingRecord {
    private int id;
    private String username;
    private int catId;
    private int itemId;
    private int quantity;
    private Timestamp feedTime;

    // 构造、getter/setter 略，请自行补充


    public FeedingRecord() {
    }

    public String getUsername() { return username; }
    public void setUsername(String username) { this.username = username; }
    public int getCatId() { return catId; }
    public void setCatId(int catId) { this.catId = catId; }

    public int getId() {
        return id;
    }

    public void setId(int id) {
        this.id = id;
    }

    public int getItemId() {
        return itemId;
    }

    public void setItemId(int itemId) {
        this.itemId = itemId;
    }

    public int getQuantity() {
        return quantity;
    }

    public void setQuantity(int quantity) {
        this.quantity = quantity;
    }

    public Timestamp getFeedTime() {
        return feedTime;
    }

    public void setFeedTime(Timestamp feedTime) {
        this.feedTime = feedTime;
    }
}
