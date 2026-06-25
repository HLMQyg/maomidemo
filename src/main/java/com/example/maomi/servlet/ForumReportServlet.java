package com.example.maomi.servlet;

import com.example.maomi.dao.ForumDAO;
import com.example.maomi.model.ForumReport;
import com.example.maomi.model.User;
import javax.servlet.annotation.WebServlet;
import javax.servlet.http.*;
import java.io.IOException;

@WebServlet("/forumReport")
public class ForumReportServlet extends HttpServlet {
    protected void doPost(HttpServletRequest request, HttpServletResponse response)
            throws IOException {
        request.setCharacterEncoding("UTF-8");
        HttpSession session = request.getSession(false);
        if (session == null || session.getAttribute("user") == null) {
            response.sendError(403);
            return;
        }
        User user = (User) session.getAttribute("user");
        int threadId = Integer.parseInt(request.getParameter("threadId"));
        String reason = request.getParameter("reason");
        if (reason == null || reason.trim().isEmpty()) {
            response.getWriter().write("请填写举报理由");
            return;
        }
        ForumReport r = new ForumReport();
        r.setThreadId(threadId);
        r.setUserId(user.getUsername());
        r.setReason(reason.trim());
        ForumDAO dao = new ForumDAO();
        response.setContentType("text/plain;charset=UTF-8");
        response.getWriter().write(dao.addReport(r) ? "ok" : "举报失败");
    }
}