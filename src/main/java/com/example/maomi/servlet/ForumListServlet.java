package com.example.maomi.servlet;

import com.example.maomi.dao.ForumDAO;
import com.example.maomi.model.ForumThread;
import com.example.maomi.model.User;
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
        String keyword = request.getParameter("keyword");
        String catIdStr = request.getParameter("catId");
        String my = request.getParameter("my");  // my=1 查看我的帖子

        Integer catId = null;
        if (catIdStr != null && !catIdStr.isEmpty()) {
            try { catId = Integer.parseInt(catIdStr); } catch (NumberFormatException ignored) {}
        }

        String userId = null;
        if ("1".equals(my)) {
            HttpSession session = request.getSession(false);
            if (session != null && session.getAttribute("user") != null) {
                userId = ((User) session.getAttribute("user")).getUsername();
            }
        }

        ForumDAO dao = new ForumDAO();
        List<ForumThread> threads = dao.getThreads(category, sort, userId, catId, keyword);
        request.setAttribute("threads", threads);
        request.setAttribute("currentCategory", category != null ? category : "");
        request.setAttribute("currentSort", sort != null ? sort : "latest");
        request.setAttribute("currentKeyword", keyword);
        request.setAttribute("currentCatId", catIdStr);
        request.setAttribute("currentMy", my);
        request.getRequestDispatcher("/pages/forum.jsp").forward(request, response);
    }
}