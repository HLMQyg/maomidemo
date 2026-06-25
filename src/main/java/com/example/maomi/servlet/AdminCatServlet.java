package com.example.maomi.servlet;

import com.example.maomi.dao.AdminDAO;
import com.example.maomi.dao.CatDAO;
import com.example.maomi.model.Cat;
import com.example.maomi.utils.JsonUtil;

import javax.servlet.annotation.WebServlet;
import javax.servlet.http.*;
import java.io.IOException;
import java.text.SimpleDateFormat;
import java.util.List;

@WebServlet("/adminCat")
public class AdminCatServlet extends HttpServlet {
    protected void doGet(HttpServletRequest request, HttpServletResponse response)
            throws IOException {
        HttpSession session = request.getSession(false);
        if (session == null || !"admin".equals(session.getAttribute("role"))) {
            response.sendError(403);
            return;
        }
        CatDAO dao = new CatDAO();
        List<Cat> cats = dao.getAllCats();
        response.setContentType("application/json;charset=UTF-8");
        response.getWriter().write(JsonUtil.toJson(cats));
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
        CatDAO catDAO = new CatDAO();
        AdminDAO adminDAO = new AdminDAO();

        response.setContentType("text/plain;charset=UTF-8");

        if ("delete".equals(action)) {
            int id = Integer.parseInt(request.getParameter("id"));
            boolean ok = catDAO.deleteCat(id);
            response.getWriter().write(ok ? "ok" : "删除失败");
        } else {
            String name = request.getParameter("name");
            String color = request.getParameter("color");
            int age = Integer.parseInt(request.getParameter("age"));
            String gender = request.getParameter("gender");
            String healthStatus = request.getParameter("healthStatus");
            String description = request.getParameter("description");
            String foundLocation = request.getParameter("foundLocation");
            String imagePath = request.getParameter("imagePath");
            if (imagePath == null || imagePath.isEmpty()) {
                imagePath = "images/cats/default.jpg";
            }

            try {
                SimpleDateFormat sdf = new SimpleDateFormat("yyyy-MM-dd");
                java.sql.Date foundDate = new java.sql.Date(sdf.parse(request.getParameter("foundDate")).getTime());

                if ("update".equals(action)) {
                    int id = Integer.parseInt(request.getParameter("id"));
                    boolean ok = adminDAO.updateCat(id, name, color, age, gender,
                            healthStatus, description, foundLocation, foundDate, imagePath);
                    response.getWriter().write(ok ? "ok" : "更新失败");
                } else {
                    Cat cat = new Cat(name, color, age, gender, healthStatus, description,
                            foundLocation, foundDate, imagePath, "在校");
                    boolean ok = catDAO.addCat(cat);
                    response.getWriter().write(ok ? "ok" : "添加失败");
                }
            } catch (Exception e) {
                response.getWriter().write("参数错误: " + e.getMessage());
            }
        }
    }
}
