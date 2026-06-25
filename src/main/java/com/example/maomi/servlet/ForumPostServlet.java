package com.example.maomi.servlet;

import com.example.maomi.dao.ForumDAO;
import com.example.maomi.model.ForumThread;
import com.example.maomi.model.User;
import javax.servlet.ServletException;
import javax.servlet.annotation.MultipartConfig;
import javax.servlet.annotation.WebServlet;
import javax.servlet.http.*;
import java.io.File;
import java.io.IOException;
import java.util.UUID;

@WebServlet("/forumPost")
@MultipartConfig(fileSizeThreshold = 1024 * 1024, maxFileSize = 1024 * 1024 * 10, maxRequestSize = 1024 * 1024 * 15)
public class ForumPostServlet extends HttpServlet {
    protected void doPost(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {
        request.setCharacterEncoding("UTF-8");
        HttpSession session = request.getSession(false);
        if (session == null || session.getAttribute("user") == null) {
            response.sendRedirect(request.getContextPath() + "/index.jsp");
            return;
        }
        User user = (User) session.getAttribute("user");

        String title = request.getParameter("title");
        String content = request.getParameter("content");
        String category = request.getParameter("category");
        String catIdStr = request.getParameter("catId");

        // 处理图片上传
        String imagePath = null;
        Part filePart = request.getPart("image");
        if (filePart != null && filePart.getSize() > 0) {
            String fileName = UUID.randomUUID().toString() + "_" + filePart.getSubmittedFileName();
            String uploadDir = getServletContext().getRealPath("/uploads/forum");
            File dir = new File(uploadDir);
            if (!dir.exists()) dir.mkdirs();
            filePart.write(uploadDir + File.separator + fileName);
            imagePath = "uploads/forum/" + fileName;
        }

        ForumThread t = new ForumThread();
        t.setTitle(title);
        t.setContent(content);
        t.setUserId(user.getUsername());
        t.setCategory(category != null ? category : "闲聊交流");
        t.setImagePath(imagePath);
        if (catIdStr != null && !catIdStr.isEmpty()) {
            t.setCatId(Integer.parseInt(catIdStr));
        }

        ForumDAO dao = new ForumDAO();
        int id = dao.createThread(t);
        if (id > 0) {
            response.sendRedirect(request.getContextPath() + "/forumDetail?id=" + id);
        } else {
            request.setAttribute("msg", "发帖失败");
            request.getRequestDispatcher("/pages/forum_post.jsp").forward(request, response);
        }
    }

    protected void doGet(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {
        HttpSession session = request.getSession(false);
        if (session == null || session.getAttribute("user") == null) {
            response.sendRedirect(request.getContextPath() + "/index.jsp");
            return;
        }
        request.getRequestDispatcher("/pages/forum_post.jsp").forward(request, response);
    }
}