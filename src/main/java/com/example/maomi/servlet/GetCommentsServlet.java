package com.example.maomi.servlet;

import com.example.maomi.model.Comment;
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
        StringBuilder json = new StringBuilder("[");
        for (int i = 0; i < comments.size(); i++) {
            Comment c = comments.get(i);
            json.append("{");
            json.append("\"username\":\"").append(escapeJson(c.getUsername())).append("\",");
            json.append("\"comment\":\"").append(escapeJson(c.getComment())).append("\"");
            json.append("}");
            if (i < comments.size() - 1) {
                json.append(",");
            }
        }
        json.append("]");

        response.setContentType("application/json;charset=UTF-8");
        response.getWriter().write(json.toString());
    }

    // 简单转义双引号和反斜杠，防止 JSON 格式错误
    private String escapeJson(String s) {
        if (s == null) return "";
        return s.replace("\\", "\\\\").replace("\"", "\\\"");
    }
}
