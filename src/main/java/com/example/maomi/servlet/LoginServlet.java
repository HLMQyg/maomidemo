package com.example.maomi.servlet;


import com.example.maomi.dao.AdminDAO;
import com.example.maomi.model.User;
import com.example.maomi.service.UserService;
import javax.servlet.ServletException;
import javax.servlet.annotation.WebServlet;
import javax.servlet.http.*;
import java.io.IOException;

@WebServlet("/login")
public class LoginServlet extends HttpServlet {
    protected void doPost(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {
        String username = request.getParameter("username");
        String password = request.getParameter("password");
        String role = request.getParameter("role"); // "user" 或 "admin"

        if ("user".equals(role)) {
            UserService userService = new UserService();
            User user = userService.login(username, password);
            if (user != null) {
                HttpSession session = request.getSession();
                session.setAttribute("user", user);
                session.setAttribute("role", "user");
                response.sendRedirect("pages/cat_list.jsp");
            } else {
                request.setAttribute("msg", "用户名或密码错误");
                request.getRequestDispatcher("index.jsp").forward(request, response);
            }
        } else if ("admin".equals(role)) {
            AdminDAO adminDAO = new AdminDAO();
            if (adminDAO.validate(username, password)) {
                HttpSession session = request.getSession();
                session.setAttribute("adminName", username);
                session.setAttribute("role", "admin");
                response.sendRedirect("admin/dashboard.jsp");
            } else {
                request.setAttribute("msg", "管理员账号或密码错误");
                request.getRequestDispatcher("index.jsp").forward(request, response);
            }
        }
    }
}
