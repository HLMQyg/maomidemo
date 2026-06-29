package com.example.maomi.servlet;

import javax.servlet.ServletException;
import javax.servlet.annotation.WebServlet;
import javax.servlet.http.*;
import java.io.*;

@WebServlet("/avatar")
public class AvatarServlet extends HttpServlet {
    // 外部头像存储目录（与 UploadAvatarServlet 保持一致）
        protected void doGet(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {
        String filename = request.getParameter("name");
        if (filename == null || filename.isEmpty()) {
            response.sendError(HttpServletResponse.SC_NOT_FOUND);
            return;
        }
        // 防止路径穿越攻击
        if (filename.contains("..") || filename.contains("/") || filename.contains("\\")) {
            response.sendError(HttpServletResponse.SC_FORBIDDEN);
            return;
        }
        String avatarDir = getServletContext().getRealPath("/uploads/avatars");
        File file = new File(avatarDir, filename);
        if (!file.exists() || file.isDirectory()) {
            // 如果文件不存在，可返回默认图片（同样放在外部目录）
            file = new File(avatarDir, "default.png");
            if (!file.exists()) {
                response.sendError(HttpServletResponse.SC_NOT_FOUND);
                return;
            }
        }
        String mime = getServletContext().getMimeType(file.getName());
        if (mime == null) mime = "application/octet-stream";
        response.setContentType(mime);
        response.setContentLengthLong(file.length());
        try (FileInputStream fis = new FileInputStream(file);
             OutputStream out = response.getOutputStream()) {
            byte[] buffer = new byte[4096];
            int bytesRead;
            while ((bytesRead = fis.read(buffer)) != -1) {
                out.write(buffer, 0, bytesRead);
            }
        }
    }
}