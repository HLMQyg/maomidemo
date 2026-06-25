package com.example.maomi.servlet;

import com.example.maomi.dao.AdminDAO;
import com.example.maomi.utils.JsonUtil;
import javax.servlet.ServletException;
import javax.servlet.annotation.MultipartConfig;
import javax.servlet.annotation.WebServlet;
import javax.servlet.http.*;
import java.io.File;
import java.io.IOException;
import java.util.List;
import java.util.Map;
import java.util.UUID;

@WebServlet("/adminFeeding")
@MultipartConfig(
        fileSizeThreshold = 1024 * 1024,
        maxFileSize = 1024 * 1024 * 5,
        maxRequestSize = 1024 * 1024 * 10
)
public class AdminFeedingServlet extends HttpServlet {
    protected void doGet(HttpServletRequest request, HttpServletResponse response) throws IOException {
        HttpSession session = request.getSession(false);
        if (session == null || !"admin".equals(session.getAttribute("role"))) {
            response.sendError(403);
            return;
        }
        AdminDAO dao = new AdminDAO();
        String action = request.getParameter("action");
        response.setContentType("application/json;charset=UTF-8");

        if ("list".equals(action)) {
            List<Map<String, Object>> feedingCats = dao.getFeedingCats();
            response.getWriter().write(JsonUtil.toJson(feedingCats));
        }
    }

    protected void doPost(HttpServletRequest request, HttpServletResponse response) throws ServletException, IOException {
        request.setCharacterEncoding("UTF-8");
        HttpSession session = request.getSession(false);
        if (session == null || !"admin".equals(session.getAttribute("role"))) {
            response.sendError(403);
            return;
        }
        AdminDAO dao = new AdminDAO();
        String action = request.getParameter("action");
        response.setContentType("text/plain;charset=UTF-8");

        if ("complete".equals(action)) {
            try {
                int catId = Integer.parseInt(request.getParameter("catId"));
                String feeder = request.getParameter("feeder");
                String message = request.getParameter("message");
                if (message == null) message = "";

                // 处理上传图片
                String imagePath = null;
                Part filePart = request.getPart("image");
                if (filePart != null && filePart.getSize() > 0) {
                    String fileName = extractFileName(filePart);
                    if (fileName != null && fileName.lastIndexOf(".") != -1) {
                        String ext = fileName.substring(fileName.lastIndexOf("."));
                        String newFileName = UUID.randomUUID().toString() + ext;
                        String uploadPath = request.getServletContext().getRealPath("/") + "uploads/feeding/";
                        File uploadDir = new File(uploadPath);
                        if (!uploadDir.exists()) uploadDir.mkdirs();
                        filePart.write(uploadPath + newFileName);
                        imagePath = "uploads/feeding/" + newFileName;
                    }
                }

                // 更新猫咪状态为“在校”
                boolean catUpdated = dao.completeFeeding(catId);
                // 插入回复消息
                boolean msgInserted = dao.insertFeedingMessage(catId, feeder, message, imagePath);

                response.getWriter().write(catUpdated && msgInserted ? "ok" : "操作失败");
            } catch (Exception e) {
                e.printStackTrace();
                response.getWriter().write("参数错误");
            }
        }
    }

    private String extractFileName(Part part) {
        String contentDisp = part.getHeader("content-disposition");
        if (contentDisp != null) {
            for (String token : contentDisp.split(";")) {
                if (token.trim().startsWith("filename")) {
                    return token.substring(token.indexOf("=") + 2, token.length() - 1);
                }
            }
        }
        return null;
    }
}