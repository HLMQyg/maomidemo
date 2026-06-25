package com.example.maomi.servlet;

import com.example.maomi.dao.ForumDAO;
import com.example.maomi.model.ForumComment;
import com.example.maomi.model.ForumThread;
import javax.servlet.ServletException;
import javax.servlet.annotation.WebServlet;
import javax.servlet.http.*;
import java.io.IOException;
import java.util.List;

@WebServlet("/forumDetail")
public class ForumDetailServlet extends HttpServlet {
    protected void doGet(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {
        int id = Integer.parseInt(request.getParameter("id"));
        ForumDAO dao = new ForumDAO();
        ForumThread thread = dao.getThreadById(id);
        if (thread == null || thread.getIsHidden() == 1) {
            response.sendRedirect(request.getContextPath() + "/forumList");
            return;
        }
        dao.incrementViewCount(id);
        List<ForumComment> comments = dao.getComments(id);
        HttpSession session = request.getSession(false);
        if (session != null && session.getAttribute("user") != null) {
            com.example.maomi.model.User user = (com.example.maomi.model.User) session.getAttribute("user");
            request.setAttribute("liked", dao.isLiked(id, user.getUsername()));
        }
        request.setAttribute("thread", thread);
        request.setAttribute("comments", comments);
        request.getRequestDispatcher("/pages/forum_detail.jsp").forward(request, response);
    }
}