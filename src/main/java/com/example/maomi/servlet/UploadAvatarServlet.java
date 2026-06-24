package com.example.maomi.servlet;

import com.example.maomi.model.User;
import com.example.maomi.service.UserService;
import javax.servlet.ServletException;
import javax.servlet.annotation.MultipartConfig;
import javax.servlet.annotation.WebServlet;
import javax.servlet.http.*;
import java.io.File;
import java.io.IOException;
import java.util.UUID;

@WebServlet("/uploadAvatar")
@MultipartConfig(
        fileSizeThreshold = 1024 * 1024,     // 1MB
        maxFileSize = 1024 * 1024 * 5,       // 5MB
        maxRequestSize = 1024 * 1024 * 10    // 10MB
)
public class UploadAvatarServlet extends HttpServlet {
    protected void doPost(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {
        request.setCharacterEncoding("UTF-8");
        HttpSession session = request.getSession();
        User user = (User) session.getAttribute("user");
        if (user == null) {
            response.sendRedirect(request.getContextPath() + "/index.jsp");
            return;
        }

        Part filePart = request.getPart("avatar");
        String fileName = extractFileName(filePart);
        if (fileName == null || fileName.isEmpty()) {
            response.sendRedirect("pages/user_center.jsp?msg=avatar_fail");
            return;
        }

        // 生成唯一文件名
        String ext = fileName.substring(fileName.lastIndexOf("."));
        String newFileName = UUID.randomUUID().toString() + ext;

        // 外部目录（绝对路径）
        String uploadPath = "D:/Java Web程序设计课程设计/maomi/touxiang/";
        File uploadDir = new File(uploadPath);
        if (!uploadDir.exists()) uploadDir.mkdirs();
        filePart.write(uploadPath + newFileName);

// 数据库中只存文件名（不存路径）
        String avatarPath = newFileName;

        UserService userService = new UserService();
        boolean ok = userService.updateAvatar(user.getUsername(), avatarPath);
        if (ok) {
            user.setProfileImage(avatarPath);
            session.setAttribute("user", user);
            response.sendRedirect("pages/user_center.jsp?msg=avatar_ok");
        } else {
            response.sendRedirect("pages/user_center.jsp?msg=avatar_fail");
        }
    }

    private String extractFileName(Part part) {
        String contentDisp = part.getHeader("content-disposition");
        for (String token : contentDisp.split(";")) {
            if (token.trim().startsWith("filename")) {
                return token.substring(token.indexOf("=") + 2, token.length() - 1);
            }
        }
        return null;
    }
}