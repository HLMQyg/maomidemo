package com.example.maomi.servlet;

import com.example.maomi.model.User;
import com.example.maomi.service.CommentService;
import javax.servlet.ServletException;
import javax.servlet.annotation.WebServlet;
import javax.servlet.http.*;
import java.io.IOException;

@WebServlet("/addComment")
public class AddCommentServlet extends HttpServlet {
    protected void doPost(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {
        HttpSession session = request.getSession();
        User user = (User) session.getAttribute("user");
        if (user == null) {
            response.getWriter().write("请先登录");
            return;
        }

        int catId = Integer.parseInt(request.getParameter("catId"));
        String comment = request.getParameter("comment");
        CommentService commentService = new CommentService();
        boolean success = commentService.addComment(catId, user.getUsername(), comment);

        response.setContentType("text/plain;charset=UTF-8");
        response.getWriter().write(success ? "ok" : "fail");
    }
}