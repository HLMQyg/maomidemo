package com.example.maomi.servlet;

import com.example.maomi.dao.KnowledgeArticleDAO;
import com.example.maomi.model.KnowledgeArticle;
import javax.servlet.ServletException;
import javax.servlet.annotation.WebServlet;
import javax.servlet.http.*;
import java.io.IOException;

@WebServlet("/knowledgeDetail")
public class KnowledgeDetailServlet extends HttpServlet {
    protected void doGet(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {
        int id = Integer.parseInt(request.getParameter("id"));
        KnowledgeArticleDAO dao = new KnowledgeArticleDAO();
        KnowledgeArticle article = dao.getById(id);
        if (article != null) {
            dao.increaseReadCount(id); // 阅读量+1
            request.setAttribute("article", article);
            request.getRequestDispatcher("/pages/knowledge_detail.jsp").forward(request, response);
        } else {
            response.sendRedirect(request.getContextPath() + "/pages/knowledge.jsp");
        }
    }
}