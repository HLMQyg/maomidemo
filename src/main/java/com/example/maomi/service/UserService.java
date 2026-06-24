package com.example.maomi.service;

import com.example.maomi.dao.UserDAO;
import com.example.maomi.model.User;

public class UserService {
    private UserDAO userDAO = new UserDAO();

    public User login(String username, String password) {
        return userDAO.login(username, password);
    }

    public String register(String username, String password, String phone, String inputCode, String sessionCode) {
        // 验证码校验
        if (sessionCode == null || !sessionCode.equals(inputCode)) {
            return "验证码错误";
        }
        // 检查用户名唯一性
        if (userDAO.isUsernameExist(username)) {
            return "用户名已存在";
        }
        // 检查手机号唯一性
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
}
