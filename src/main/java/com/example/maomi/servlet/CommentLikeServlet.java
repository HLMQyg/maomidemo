package com.example.maomi.servlet;

import com.example.maomi.dao.ForumDAO;
import com.example.maomi.model.User;
import javax.servlet.annotation.WebServlet;
import javax.servlet.http.*;
import java.io.IOException;

@WebServlet("/commentLike")
public class CommentLikeServlet extends HttpServlet {
    protected void doPost(HttpServletRequest request, HttpServletResponse response)
            throws IOException {
        HttpSession session = request.getSession(false);
        if (session == null || session.getAttribute("user") == null) {
            response.sendError(403);
            return;
        }
        User user = (User) session.getAttribute("user");
        int commentId = Integer.parseInt(request.getParameter("commentId"));
        ForumDAO dao = new ForumDAO();
        int count = dao.toggleCommentLike(commentId, user.getUsername());
        response.setContentType("application/json;charset=UTF-8");
        response.getWriter().write("{\"count\":" + count + "}");
    }
}