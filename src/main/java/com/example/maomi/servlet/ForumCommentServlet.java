package com.example.maomi.servlet;

import com.example.maomi.dao.ForumDAO;
import com.example.maomi.model.User;
import javax.servlet.annotation.WebServlet;
import javax.servlet.http.*;
import java.io.IOException;

@WebServlet("/forumComment")
public class ForumCommentServlet extends HttpServlet {
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
        String content = request.getParameter("content");
        String parentIdStr = request.getParameter("parentId");
        Integer parentId = null;
        if (parentIdStr != null && !parentIdStr.isEmpty()) {
            try { parentId = Integer.parseInt(parentIdStr); } catch (NumberFormatException ignored) {}
        }

        if (content == null || content.trim().isEmpty()) {
            response.setContentType("text/plain;charset=UTF-8");
            response.getWriter().write("内容不能为空");
            return;
        }

        ForumDAO dao = new ForumDAO();
        boolean ok = dao.addComment(threadId, user.getUsername(), content.trim(), parentId);
        response.setContentType("text/plain;charset=UTF-8");
        response.getWriter().write(ok ? "ok" : "评论失败");
    }
}