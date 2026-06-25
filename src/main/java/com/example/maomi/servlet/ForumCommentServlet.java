package com.example.maomi.servlet;

import com.example.maomi.dao.ForumDAO;
import com.example.maomi.model.ForumComment;
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
        if (content == null || content.trim().isEmpty()) {
            response.getWriter().write("内容不能为空");
            return;
        }
        ForumComment c = new ForumComment();
        c.setThreadId(threadId);
        c.setUserId(user.getUsername());
        c.setContent(content.trim());
        ForumDAO dao = new ForumDAO();
        response.getWriter().write(dao.addComment(c) ? "ok" : "评论失败");
    }
}