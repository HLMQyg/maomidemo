package com.example.maomi.servlet;

import com.example.maomi.dao.ForumDAO;
import com.example.maomi.model.ForumThread;
import javax.servlet.ServletException;
import javax.servlet.annotation.WebServlet;
import javax.servlet.http.*;
import java.io.IOException;
import java.util.List;

@WebServlet("/forumList")
public class ForumListServlet extends HttpServlet {
    protected void doGet(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {
        request.setCharacterEncoding("UTF-8");
        String category = request.getParameter("category");
        String sort = request.getParameter("sort");
        ForumDAO dao = new ForumDAO();
        List<ForumThread> threads = dao.getThreads(category, sort, null);
        request.setAttribute("threads", threads);
        request.setAttribute("currentCategory", category);
        request.setAttribute("currentSort", sort);
        request.getRequestDispatcher("/pages/forum.jsp").forward(request, response);
    }
}