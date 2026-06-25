package com.example.maomi.servlet;

import com.example.maomi.dao.KnowledgeArticleDAO;
import com.example.maomi.model.KnowledgeArticle;
import javax.servlet.ServletException;
import javax.servlet.annotation.WebServlet;
import javax.servlet.http.*;
import java.io.IOException;
import java.util.List;

@WebServlet("/knowledgeList")
public class KnowledgeListServlet extends HttpServlet {
    protected void doGet(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {
        request.setCharacterEncoding("UTF-8");
        String category = request.getParameter("category");
        String keyword = request.getParameter("keyword");

        KnowledgeArticleDAO dao = new KnowledgeArticleDAO();
        List<KnowledgeArticle> articles;

        if (keyword != null && !keyword.trim().isEmpty()) {
            articles = dao.search(keyword.trim());
        } else if (category != null && !category.trim().isEmpty()) {
            articles = dao.getByCategory(category.trim());
        } else {
            articles = dao.getAll();
        }

        request.setAttribute("articles", articles);
        request.getRequestDispatcher("/pages/knowledge.jsp").forward(request, response);
    }
}