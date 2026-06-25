package com.example.maomi.servlet;

import com.example.maomi.dao.AdminDAO;
import com.example.maomi.utils.JsonUtil;

import javax.servlet.annotation.WebServlet;
import javax.servlet.http.*;
import java.io.IOException;
import java.util.Map;

@WebServlet("/adminStats")
public class AdminStatsServlet extends HttpServlet {
    protected void doGet(HttpServletRequest request, HttpServletResponse response)
            throws IOException {
        HttpSession session = request.getSession(false);
        if (session == null || !"admin".equals(session.getAttribute("role"))) {
            response.sendError(403);
            return;
        }
        AdminDAO dao = new AdminDAO();
        Map<String, Integer> stats = dao.getStats();
        response.setContentType("application/json;charset=UTF-8");
        response.getWriter().write(JsonUtil.toJson(stats));
    }
}
