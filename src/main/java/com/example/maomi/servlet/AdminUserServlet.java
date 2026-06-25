package com.example.maomi.servlet;

import com.example.maomi.dao.AdminDAO;
import com.example.maomi.model.User;
import com.example.maomi.utils.JsonUtil;

import javax.servlet.annotation.WebServlet;
import javax.servlet.http.*;
import java.io.IOException;
import java.util.List;

@WebServlet("/adminUser")
public class AdminUserServlet extends HttpServlet {
    protected void doGet(HttpServletRequest request, HttpServletResponse response)
            throws IOException {
        HttpSession session = request.getSession(false);
        if (session == null || !"admin".equals(session.getAttribute("role"))) {
            response.sendError(403);
            return;
        }
        AdminDAO dao = new AdminDAO();
        List<User> users = dao.getAllUsers();
        response.setContentType("application/json;charset=UTF-8");
        response.getWriter().write(JsonUtil.toJson(users));
    }

    protected void doPost(HttpServletRequest request, HttpServletResponse response)
            throws IOException {
        request.setCharacterEncoding("UTF-8");
        HttpSession session = request.getSession(false);
        if (session == null || !"admin".equals(session.getAttribute("role"))) {
            response.sendError(403);
            return;
        }

        String action = request.getParameter("action");
        response.setContentType("text/plain;charset=UTF-8");

        if ("delete".equals(action)) {
            String username = request.getParameter("username");
            AdminDAO dao = new AdminDAO();
            boolean ok = dao.deleteUser(username);
            response.getWriter().write(ok ? "ok" : "删除失败");
        }
    }
}
