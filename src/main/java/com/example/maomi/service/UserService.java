package com.example.maomi.service;

import com.example.maomi.dao.UserDAO;
import com.example.maomi.model.User;

public class UserService {
    private UserDAO userDAO = new UserDAO();

    // ===== 原有方法 =====
    public User login(String username, String password) {
        return userDAO.login(username, password);
    }

    public String register(String username, String password, String phone, String inputCode, String sessionCode) {
        if (sessionCode == null || !sessionCode.equals(inputCode)) {
            return "验证码错误";
        }
        if (userDAO.isUsernameExist(username)) {
            return "用户名已存在";
        }
        if (userDAO.isPhoneExist(phone)) {
            return "手机号已被注册";
        }
        User user = new User();
        user.setUsername(username);
        user.setPassword(password);
        user.setPhone(phone);
        if (userDAO.register(user)) {
            return "success";
        } else {
            return "注册失败，请重试";
        }
    }

    // ===== 新增方法 =====
    public boolean updateProfile(String username, String email, String address, String phone) {
        return userDAO.updateProfile(username, email, address, phone);
    }

    public String updatePassword(String username, String oldPassword, String newPassword) {
        if (oldPassword.equals(newPassword)) {
            return "新密码不能与旧密码相同";
        }
        boolean success = userDAO.updatePassword(username, oldPassword, newPassword);
        return success ? "success" : "旧密码错误";
    }

    public boolean updateAvatar(String username, String avatarPath) {
        return userDAO.updateAvatar(username, avatarPath);
    }
}