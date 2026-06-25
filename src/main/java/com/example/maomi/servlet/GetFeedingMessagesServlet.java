package com.example.maomi.servlet;

import com.example.maomi.dao.AdminDAO;
import com.example.maomi.model.FeedingMessage;
import com.example.maomi.model.User;
import com.example.maomi.utils.JsonUtil;
import javax.servlet.annotation.WebServlet;
import javax.servlet.http.*;
import java.io.IOException;
import java.util.List;

@WebServlet("/getFeedingMessages")
public class GetFeedingMessagesServlet extends HttpServlet {

    // 获取未读消息数 or 消息列表
    protected void doGet(HttpServletRequest request, HttpServletResponse response) throws IOException {
        HttpSession session = request.getSession(false);
        User user = (User) (session != null ? session.getAttribute("user") : null);
        if (user == null) { response.sendError(403); return; }

        String action = request.getParameter("action");
        AdminDAO dao = new AdminDAO();

        if ("unreadCount".equals(action)) {
            int count = dao.getUnreadFeedingMessageCount(user.getUsername());
            response.setContentType("application/json;charset=UTF-8");
            response.getWriter().write("{\"count\":" + count + "}");
            return;
        }

        // 默认：返回消息列表
        List<FeedingMessage> messages = dao.getFeedingMessagesForUser(user.getUsername());
        response.setContentType("application/json;charset=UTF-8");
        response.getWriter().write(JsonUtil.toJson(messages));
    }

    // 标记已读
    protected void doPost(HttpServletRequest request, HttpServletResponse response) throws IOException {
        HttpSession session = request.getSession(false);
        User user = (User) (session != null ? session.getAttribute("user") : null);
        if (user == null) { response.sendError(403); return; }

        String action = request.getParameter("action");
        if ("markRead".equals(action)) {
            AdminDAO dao = new AdminDAO();
            boolean ok = dao.markFeedingMessagesAsRead(user.getUsername());
            response.setContentType("text/plain;charset=UTF-8");
            response.getWriter().write(ok ? "ok" : "fail");
        }
    }
}