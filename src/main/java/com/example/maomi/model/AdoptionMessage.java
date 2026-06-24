package com.example.maomi.model;

import java.sql.Timestamp;

public class AdoptionMessage {
    private int id;
    private int adoptionId;
    private String sender;       // 发送者（用户名或管理员账号）
    private String message;      // 消息内容
    private Timestamp sendTime;  // 发送时间

    // 无参构造
    public AdoptionMessage() {}

    // Getter 和 Setter
    public int getId() {
        return id;
    }
    public void setId(int id) {
        this.id = id;
    }
    public int getAdoptionId() {
        return adoptionId;
    }
    public void setAdoptionId(int adoptionId) {
        this.adoptionId = adoptionId;
    }
    public String getSender() {
        return sender;
    }
    public void setSender(String sender) {
        this.sender = sender;
    }
    public String getMessage() {
        return message;
    }
    public void setMessage(String message) {
        this.message = message;
    }
    public Timestamp getSendTime() {
        return sendTime;
    }
    public void setSendTime(Timestamp sendTime) {
        this.sendTime = sendTime;
    }
}