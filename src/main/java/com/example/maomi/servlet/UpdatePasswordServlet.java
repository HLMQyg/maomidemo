package com.example.maomi.servlet;

import com.example.maomi.model.User;
import com.example.maomi.service.UserService;
import javax.servlet.annotation.WebServlet;
import javax.servlet.http.*;
import java.io.IOException;
import java.net.URLEncoder;

@WebServlet("/updatePassword")
public class UpdatePasswordServlet extends HttpServlet {
    protected void doPost(HttpServletRequest request, HttpServletResponse response) throws IOException {
        request.setCharacterEncoding("UTF-8");
        HttpSession session = request.getSession();
        User user = (User) session.getAttribute("user");
        if (user == null) {
            response.sendRedirect(request.getContextPath() + "/index.jsp");
            return;
        }
        String oldPassword = request.getParameter("oldPassword");
        String newPassword = request.getParameter("newPassword");

        UserService userService = new UserService();
        String result = userService.updatePassword(user.getUsername(), oldPassword, newPassword);
        if ("success".equals(result)) {
            response.sendRedirect("pages/user_center.jsp?msg=pwd_ok");
        } else {
            response.sendRedirect("pages/user_center.jsp?msg=pwd_fail&error=" + URLEncoder.encode(result, "UTF-8"));
        }
    }
}