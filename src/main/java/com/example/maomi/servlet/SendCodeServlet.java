package com.example.maomi.servlet;

import com.example.maomi.utils.CodeUtil;
import javax.servlet.ServletException;
import javax.servlet.annotation.WebServlet;
import javax.servlet.http.*;
import java.io.IOException;

@WebServlet("/sendCode")
public class SendCodeServlet extends HttpServlet {
    protected void doPost(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {
        String phone = request.getParameter("phone");
        // 生成6位验证码
        String code = CodeUtil.generateCode(6);
        // 存入session
        request.getSession().setAttribute("regCode", code);
        // 返回给前端页面显示（模拟短信发送）
        response.setContentType("text/plain;charset=UTF-8");
        response.getWriter().write(code);
    }
}
