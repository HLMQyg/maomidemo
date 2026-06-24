package com.example.maomi.servlet;

import com.example.maomi.dao.AdoptionDAO;
import com.example.maomi.model.AdoptionMessage;
import javax.servlet.ServletException;
import javax.servlet.annotation.WebServlet;
import javax.servlet.http.*;
import java.io.IOException;
import java.util.List;

@WebServlet("/getAdoptionMessages")
public class GetAdoptionMessagesServlet extends HttpServlet {
    protected void doGet(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {
        int adoptionId = Integer.parseInt(request.getParameter("adoptionId"));
        AdoptionDAO dao = new AdoptionDAO();
        List<AdoptionMessage> messages = dao.getMessages(adoptionId);

        // 手动拼接 JSON 数组
        StringBuilder json = new StringBuilder("[");
        for (int i = 0; i < messages.size(); i++) {
            AdoptionMessage m = messages.get(i);
            json.append("{");
            json.append("\"sender\":\"").append(escape(m.getSender())).append("\",");
            json.append("\"message\":\"").append(escape(m.getMessage())).append("\",");
            json.append("\"time\":\"").append(m.getSendTime().toString().substring(0, 19)).append("\"");
            json.append("}");
            if (i < messages.size() - 1) json.append(",");
        }
        json.append("]");

        response.setContentType("application/json;charset=UTF-8");
        response.getWriter().write(json.toString());
    }

    private String escape(String s) {
        if (s == null) return "";
        return s.replace("\\", "\\\\").replace("\"", "\\\"");
    }
}