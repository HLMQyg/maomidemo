package com.example.maomi.servlet;

import com.example.maomi.model.User;
import com.example.maomi.service.UserService;
import javax.servlet.annotation.WebServlet;
import javax.servlet.http.*;
import java.io.IOException;

@WebServlet("/updateProfile")
public class UpdateProfileServlet extends HttpServlet {
    protected void doPost(HttpServletRequest request, HttpServletResponse response) throws IOException {
        request.setCharacterEncoding("UTF-8");
        HttpSession session = request.getSession();
        User user = (User) session.getAttribute("user");
        if (user == null) {
            response.sendRedirect(request.getContextPath() + "/index.jsp");
            return;
        }
        String email = request.getParameter("email");
        String address = request.getParameter("address");
        String phone = request.getParameter("phone");

        UserService userService = new UserService();
        boolean ok = userService.updateProfile(user.getUsername(), email, address, phone);
        if (ok) {
            user.setEmail(email);
            user.setAddress(address);
            user.setPhone(phone);
            session.setAttribute("user", user);
            response.sendRedirect("pages/user_center.jsp?msg=profile_ok");
        } else {
            response.sendRedirect("pages/user_center.jsp?msg=profile_fail");
        }
    }
}