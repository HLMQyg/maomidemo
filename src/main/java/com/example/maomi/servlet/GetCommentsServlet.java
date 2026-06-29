package com.example.maomi.servlet;

import com.example.maomi.model.Comment;
import com.example.maomi.utils.JsonUtil;
import com.example.maomi.service.CommentService;
import javax.servlet.ServletException;
import javax.servlet.annotation.WebServlet;
import javax.servlet.http.*;
import java.io.IOException;
import java.util.List;

@WebServlet("/getComments")
public class GetCommentsServlet extends HttpServlet {
    protected void doGet(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {
        int catId = Integer.parseInt(request.getParameter("catId"));
        CommentService commentService = new CommentService();
        List<Comment> comments = commentService.getCommentsByCatId(catId);

        // 手动拼 JSON 数组
        // use JsonUtil
        response.setContentType("application/json;charset=UTF-8");
        response.getWriter().write(com.example.maomi.utils.JsonUtil.toJson(comments));
    }
}
