package com.example.maomi.servlet;

import com.example.maomi.dao.ForumDAO;
import com.example.maomi.model.ForumComment;
import com.example.maomi.model.ForumThread;
import com.example.maomi.model.User;
import javax.servlet.ServletException;
import javax.servlet.annotation.WebServlet;
import javax.servlet.http.*;
import java.io.IOException;
import java.io.PrintWriter;
import java.util.List;

@WebServlet("/forumDetail")
public class ForumDetailServlet extends HttpServlet {
    protected void doGet(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {
        int id = Integer.parseInt(request.getParameter("id"));
        ForumDAO dao = new ForumDAO();
        ForumThread thread = dao.getThreadById(id);
        if (thread == null || thread.getIsHidden() == 1) {
            if ("1".equals(request.getParameter("ajax"))) {
                response.sendError(404);
            } else {
                response.sendRedirect(request.getContextPath() + "/forumList");
            }
            return;
        }
        dao.incrementViewCount(id);
        thread.setViewCount(thread.getViewCount() + 1);

        String sort = request.getParameter("commentSort");
        if (sort == null) sort = "latest";
        List<ForumComment> comments = dao.getCommentsWithReplies(id, sort);

        HttpSession session = request.getSession(false);
        String currentUser = null;
        boolean liked = false;
        if (session != null && session.getAttribute("user") != null) {
            User user = (User) session.getAttribute("user");
            currentUser = user.getUsername();
            liked = dao.isLiked(id, currentUser);
        }

        if ("1".equals(request.getParameter("ajax"))) {
            response.setContentType("text/html;charset=UTF-8");
            PrintWriter out = response.getWriter();
            String ctx = request.getContextPath();

            // Post detail HTML
            out.print("<div class=\"detail-card\">");
            out.print("<div class=\"detail-author\">");
            out.print("<div class=\"detail-avatar\">" + (thread.getUserId() != null && !thread.getUserId().isEmpty() ? thread.getUserId().substring(0,1) : "?") + "</div>");
            out.print("<div><div class=\"detail-author-name\">" + escape(thread.getUserId()) + "</div>");
            out.print("<div class=\"detail-author-time\">" + (thread.getCreatedAt() != null ? thread.getCreatedAt().toString().substring(0,16) : "") + "</div></div>");
            out.print("</div>");

            out.print("<div class=\"detail-title\">" + escape(thread.getTitle()) + "</div>");
            out.print("<div class=\"detail-content\">" + escapeHtml(thread.getContent()) + "</div>");

            if (thread.getImagePath() != null && !thread.getImagePath().isEmpty()) {
                out.print("<div class=\"detail-image\" onclick=\"openLightbox('" + ctx + "/" + thread.getImagePath() + "')\">");
                out.print("<img src=\"" + ctx + "/" + thread.getImagePath() + "\" alt=\"" + escape(thread.getTitle()) + "\" loading=\"lazy\" onerror=\"this.parentElement.style.display='none'\">");
                out.print("</div>");
            }

            out.print("<div class=\"detail-stats\">");
            if (currentUser != null) {
                out.print("<button class=\"post-action\" style=\"border:none;background:none;cursor:pointer;font-size:14px;color:#999;padding:4px 8px;display:flex;align-items:center;gap:5px;font-family:inherit;\" onclick=\"toggleDetailLike(" + id + ")\" id=\"detailLikeBtn\">");
                out.print("<svg viewBox=\"0 0 24 24\" fill=\"" + (liked ? "#e6a14c" : "none") + "\" stroke=\"currentColor\" stroke-width=\"2\" width=\"18\" height=\"18\"><path d=\"M20.84 4.61a5.5 5.5 0 0 0-7.78 0L12 5.67l-1.06-1.06a5.5 5.5 0 0 0-7.78 7.78l1.06 1.06L12 21.23l7.78-7.78 1.06-1.06a5.5 5.5 0 0 0 0-7.78z\"/></svg>");
                out.print("<span id=\"detailLikeCount\">" + thread.getLikeCount() + "</span>");
                out.print("</button>");
            } else {
                out.print("<span style=\"display:flex;align-items:center;gap:5px;font-size:14px;color:#999;\">&#x1f44d; <span id=\"detailLikeCount\">" + thread.getLikeCount() + "</span></span>");
            }
            out.print("<span>&#x1f4ac; " + thread.getCommentCount() + "</span>");
            out.print("<span>&#x1f441; " + thread.getViewCount() + "</span>");
            if (thread.getCategory() != null && !thread.getCategory().isEmpty()) {
                out.print("<span style=\"margin-left:auto;\">" + escape(thread.getCategory()) + "</span>");
            }
            out.print("</div>");
            out.print("</div>");

            // Comments section
            out.print("<div class=\"comment-section\">");
            out.print("<h3>评论 (" + thread.getCommentCount() + ")</h3>");
            if (currentUser != null) {
                out.print("<div class=\"comment-input-row\">");
                out.print("<textarea id=\"commentInput\" rows=\"2\" placeholder=\"写下你的评论...\"></textarea>");
                out.print("<button class=\"comment-send\" onclick=\"submitComment()\">发送</button>");
                out.print("</div>");
            }
            out.print("<div class=\"comment-sort\">");
            out.print("<button class=\"comment-sort-btn " + ("latest".equals(sort) ? "active" : "") + "\" onclick=\"loadDetail(" + id + ",'latest')\">最新</button>");
            out.print("<button class=\"comment-sort-btn " + ("hot".equals(sort) ? "active" : "") + "\" onclick=\"loadDetail(" + id + ",'hot')\">最热</button>");
            out.print("</div>");

            if (comments == null || comments.isEmpty()) {
                out.print("<div class=\"comment-empty\">暂无评论，来抢沙发吧</div>");
            } else {
                renderComments(out, comments, currentUser, ctx);
            }
            out.print("</div>");
        } else {
            request.setAttribute("thread", thread);
            request.setAttribute("comments", comments);
            request.setAttribute("liked", liked);
            request.getRequestDispatcher("/pages/forum_detail.jsp").forward(request, response);
        }
    }

    private void renderComments(PrintWriter out, List<ForumComment> comments, String currentUser, String ctx) {
        for (ForumComment c : comments) {
            out.print("<div class=\"comment-item\" data-comment-id=\"" + c.getId() + "\">");
            out.print("<div class=\"comment-top\">");
            out.print("<div class=\"comment-avatar\">" + (c.getUserId() != null && !c.getUserId().isEmpty() ? c.getUserId().substring(0,1) : "?") + "</div>");
            out.print("<span class=\"comment-user\">" + escape(c.getUserId()) + "</span>");
            out.print("<span class=\"comment-time\">" + (c.getCreatedAt() != null ? c.getCreatedAt().toString().substring(0,16) : "") + "</span>");
            out.print("</div>");
            out.print("<div class=\"comment-content\">" + escapeHtml(c.getContent()) + "</div>");
            out.print("<div class=\"comment-actions\">");
            out.print("<button class=\"comment-action\" onclick=\"toggleCommentLike(this," + c.getId() + ")\">&#x2764; <span>" + c.getLikeCount() + "</span></button>");
            if (currentUser != null) {
                out.print("<button class=\"comment-action\" onclick=\"replyTo(" + c.getId() + ",'" + escape(c.getUserId()) + "')\">&#x1f4ac; 回复</button>");
            }
            out.print("</div>");

            // Nested replies
            if (c.getReplies() != null && !c.getReplies().isEmpty()) {
                out.print("<button class=\"toggle-replies\" onclick=\"toggleReplies(this)\">展开 " + c.getReplies().size() + " 条回复</button>");
                out.print("<div class=\"comment-replies\">");
                renderComments(out, c.getReplies(), currentUser, ctx);
                out.print("</div>");
            }
            out.print("</div>");
        }
    }

    private String escape(String s) {
        if (s == null) return "";
        return s.replace("&", "&amp;").replace("<", "&lt;").replace(">", "&gt;").replace("\"", "&quot;").replace("'", "&#39;");
    }

    private String escapeHtml(String s) {
        if (s == null) return "";
        return s.replace("&", "&amp;").replace("<", "&lt;").replace(">", "&gt;").replace("\n", "<br>");
    }
}