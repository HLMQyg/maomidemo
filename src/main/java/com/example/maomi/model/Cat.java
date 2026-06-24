package com.example.maomi.model;

import java.sql.Timestamp;

public class Cat {
    private int id;
    private String name;
    private String color;
    private int age;
    private String gender;          // 公/母
    private String healthStatus;
    private String description;
    private String foundLocation;
    private java.sql.Date foundDate; // 发现日期，或可用 String
    private String imagePath;
    private String state;           // 在校/已领养
    private Timestamp createdAt;

    // 无参构造
    public Cat() {}

    // 带参构造（常用字段）
    public Cat(String name, String color, int age, String gender,
               String healthStatus, String description, String foundLocation,
               java.sql.Date foundDate, String imagePath, String state) {
        this.name = name;
        this.color = color;
        this.age = age;
        this.gender = gender;
        this.healthStatus = healthStatus;
        this.description = description;
        this.foundLocation = foundLocation;
        this.foundDate = foundDate;
        this.imagePath = imagePath;
        this.state = state;
    }

    // Getter 和 Setter
    public int getId() { return id; }
    public void setId(int id) { this.id = id; }

    public String getName() { return name; }
    public void setName(String name) { this.name = name; }

    public String getColor() { return color; }
    public void setColor(String color) { this.color = color; }

    public int getAge() { return age; }
    public void setAge(int age) { this.age = age; }

    public String getGender() { return gender; }
    public void setGender(String gender) { this.gender = gender; }

    public String getHealthStatus() { return healthStatus; }
    public void setHealthStatus(String healthStatus) { this.healthStatus = healthStatus; }

    public String getDescription() { return description; }
    public void setDescription(String description) { this.description = description; }

    public String getFoundLocation() { return foundLocation; }
    public void setFoundLocation(String foundLocation) { this.foundLocation = foundLocation; }

    public java.sql.Date getFoundDate() { return foundDate; }
    public void setFoundDate(java.sql.Date foundDate) { this.foundDate = foundDate; }

    public String getImagePath() { return imagePath; }
    public void setImagePath(String imagePath) { this.imagePath = imagePath; }

    public String getState() { return state; }
    public void setState(String state) { this.state = state; }

    public Timestamp getCreatedAt() { return createdAt; }
    public void setCreatedAt(Timestamp createdAt) { this.createdAt = createdAt; }
}