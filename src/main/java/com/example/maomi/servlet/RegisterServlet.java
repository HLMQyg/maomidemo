package com.example.maomi.servlet;


import com.example.maomi.service.UserService;
import javax.servlet.ServletException;
import javax.servlet.annotation.WebServlet;
import javax.servlet.http.*;
import java.io.IOException;

@WebServlet("/register")
public class RegisterServlet extends HttpServlet {
    protected void doPost(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {
        String username = request.getParameter("username");
        String password = request.getParameter("password");
        String phone = request.getParameter("phone");
        String inputCode = request.getParameter("code");

        HttpSession session = request.getSession();
        String sessionCode = (String) session.getAttribute("regCode");

        UserService userService = new UserService();
        String result = userService.register(username, password, phone, inputCode, sessionCode);

        if ("success".equals(result)) {
            session.removeAttribute("regCode"); // 注册成功移除验证码
            request.setAttribute("msg", "注册成功，请登录");
            request.getRequestDispatcher("index.jsp").forward(request, response);
        } else {
            request.setAttribute("msg", result);
            request.getRequestDispatcher("index.jsp").forward(request, response);
        }
    }
}
