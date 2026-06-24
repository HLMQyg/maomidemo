package com.example.maomi.model;

import java.sql.Timestamp;

public class User {
    private String username;      // 用户名（主键）
    private String password;      // 密码
    private String phone;         // 手机号
    private String email;         // 邮箱
    private String address;       // 地址
    private Timestamp registerDate;  // 注册时间
    private Timestamp lastLogin;     // 最后登录时间
    private String profileImage;     // 头像路径
    private Timestamp createdAt;     // 创建时间

    // 无参构造
    public User() {}

    // 注册时常用的构造
    public User(String username, String password, String phone) {
        this.username = username;
        this.password = password;
        this.phone = phone;
    }

    // Getter 和 Setter 方法
    public String getUsername() { return username; }
    public void setUsername(String username) { this.username = username; }

    public String getPassword() { return password; }
    public void setPassword(String password) { this.password = password; }

    public String getPhone() { return phone; }
    public void setPhone(String phone) { this.phone = phone; }

    public String getEmail() { return email; }
    public void setEmail(String email) { this.email = email; }

    public String getAddress() { return address; }
    public void setAddress(String address) { this.address = address; }

    public Timestamp getRegisterDate() { return registerDate; }
    public void setRegisterDate(Timestamp registerDate) { this.registerDate = registerDate; }

    public Timestamp getLastLogin() { return lastLogin; }
    public void setLastLogin(Timestamp lastLogin) { this.lastLogin = lastLogin; }

    public String getProfileImage() { return profileImage; }
    public void setProfileImage(String profileImage) { this.profileImage = profileImage; }

    public Timestamp getCreatedAt() { return createdAt; }
    public void setCreatedAt(Timestamp createdAt) { this.createdAt = createdAt; }
}