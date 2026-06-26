package com.example.maomi.servlet;

import com.example.maomi.dao.ForumDAO;
import com.example.maomi.model.ForumReport;
import com.example.maomi.model.ForumComment;
import com.example.maomi.model.ForumThread;
import com.example.maomi.utils.JsonUtil;
import javax.servlet.annotation.WebServlet;
import javax.servlet.http.*;
import java.io.IOException;
import java.util.List;

@WebServlet("/adminForum")
public class AdminForumServlet extends HttpServlet {
    protected void doGet(HttpServletRequest request, HttpServletResponse response)
            throws IOException {
        HttpSession session = request.getSession(false);
        if (session == null || !"admin".equals(session.getAttribute("role"))) {
            response.sendError(403);
            return;
        }
        String type = request.getParameter("type");
        ForumDAO dao = new ForumDAO();
        response.setContentType("application/json;charset=UTF-8");

        if ("reports".equals(type)) {
            List<ForumReport> reports = dao.getAllReports();
            response.getWriter().write(JsonUtil.toJson(reports));
        } else if ("detail".equals(type)) {
            int id = Integer.parseInt(request.getParameter("id"));
            ForumThread thread = dao.getThreadById(id);
            if (thread == null) { response.sendError(404); return; }
            List<ForumComment> comments = dao.getCommentsWithReplies(id, "latest");
            StringBuilder json = new StringBuilder("{");
            json.append("\"id\":").append(thread.getId()).append(",");
            json.append("\"title\":\"").append(escapeJson(thread.getTitle())).append("\",");
            json.append("\"content\":\"").append(escapeJson(thread.getContent())).append("\",");
            json.append("\"userId\":\"").append(escapeJson(thread.getUserId())).append("\",");
            json.append("\"category\":\"").append(escapeJson(thread.getCategory())).append("\",");
            json.append("\"imagePath\":\"").append(escapeJson(thread.getImagePath())).append("\",");
            json.append("\"likeCount\":").append(thread.getLikeCount()).append(",");
            json.append("\"commentCount\":").append(thread.getCommentCount()).append(",");
            json.append("\"viewCount\":").append(thread.getViewCount()).append(",");
            json.append("\"createdAt\":\"").append(thread.getCreatedAt() != null ? thread.getCreatedAt().toString() : "").append("\",");
            json.append("\"catName\":\"").append(escapeJson(thread.getCatName())).append("\",");
            json.append("\"comments\":[");
            appendCommentsJson(json, comments);
            json.append("]");
            json.append("}");
            response.getWriter().write(json.toString());
        } else {
            List<ForumThread> threads = dao.getAllThreadsForAdmin();
            response.getWriter().write(JsonUtil.toJson(threads));
        }
    }

    protected void doPost(HttpServletRequest request, HttpServletResponse response)
            throws IOException {
        request.setCharacterEncoding("UTF-8");
        HttpSession session = request.getSession(false);
        if (session == null || !"admin".equals(session.getAttribute("role"))) {
            response.sendError(403);
            return;
        }
        String action = request.getParameter("action");
        ForumDAO dao = new ForumDAO();
        response.setContentType("text/plain;charset=UTF-8");

        try {
            if ("pin".equals(action)) {
                int id = Integer.parseInt(request.getParameter("id"));
                int pinned = Integer.parseInt(request.getParameter("pinned"));
                dao.togglePin(id, pinned);
                response.getWriter().write("ok");
            } else if ("hide".equals(action)) {
                int id = Integer.parseInt(request.getParameter("id"));
                int hidden = Integer.parseInt(request.getParameter("hidden"));
                dao.toggleHide(id, hidden);
                response.getWriter().write("ok");
            } else if ("delete".equals(action)) {
                int id = Integer.parseInt(request.getParameter("id"));
                response.getWriter().write(dao.deleteThread(id) ? "ok" : "删除失败");
            } else if ("handleReport".equals(action)) {
                int id = Integer.parseInt(request.getParameter("id"));
                String status = request.getParameter("status");
                String notes = request.getParameter("notes");
                if (notes == null) notes = "";
                boolean ok = dao.handleReport(id, status, notes);
                // 如果举报通过，同时下架帖子
                if (ok && "已处理".equals(status)) {
                    int threadId = Integer.parseInt(request.getParameter("threadId"));
                    dao.toggleHide(threadId, 1);
                }
                response.getWriter().write(ok ? "ok" : "操作失败");
            } else if ("post".equals(action)) {
                String title = request.getParameter("title");
                String content = request.getParameter("content");
                String category = request.getParameter("category");
                String adminName = (String) session.getAttribute("adminName");
                ForumThread t = new ForumThread();
                t.setTitle(title);
                t.setContent(content);
                t.setUserId("管理员-" + adminName);
                t.setCategory(category != null ? category : "闲聊交流");
                int id = dao.createThread(t);
                response.getWriter().write(id > 0 ? "ok" : "发帖失败");
            }
        } catch (Exception e) {
            response.getWriter().write("参数错误");
        }
    }

    private String escapeJson(String s) {
        if (s == null) return "";
        return s.replace("\\", "\\\\").replace("\"", "\\\"").replace("\n", "\\n").replace("\r", "");
    }

    private void appendCommentsJson(StringBuilder sb, List<ForumComment> comments) {
        boolean first = true;
        for (ForumComment c : comments) {
            if (!first) sb.append(",");
            first = false;
            sb.append("{");
            sb.append("\"id\":").append(c.getId()).append(",");
            sb.append("\"userId\":\"").append(escapeJson(c.getUserId())).append("\",");
            sb.append("\"content\":\"").append(escapeJson(c.getContent())).append("\",");
            sb.append("\"createdAt\":\"").append(c.getCreatedAt() != null ? c.getCreatedAt().toString() : "").append("\",");
            sb.append("\"likeCount\":").append(c.getLikeCount()).append(",");
            sb.append("\"replies\":[");
            if (c.getReplies() != null && !c.getReplies().isEmpty()) {
                appendCommentsJson(sb, c.getReplies());
            }
            sb.append("]");
            sb.append("}");
        }
    }}