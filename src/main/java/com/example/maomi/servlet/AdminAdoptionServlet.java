package com.example.maomi.servlet;

import com.example.maomi.dao.AdminDAO;
import com.example.maomi.dao.AdoptionDAO;
import com.example.maomi.model.Adoption;
import com.example.maomi.model.Cat;
import com.example.maomi.utils.JsonUtil;

import javax.servlet.annotation.WebServlet;
import javax.servlet.http.*;
import java.io.IOException;
import java.util.List;

@WebServlet("/adminAdoption")
public class AdminAdoptionServlet extends HttpServlet {
    protected void doGet(HttpServletRequest request, HttpServletResponse response)
            throws IOException {
        HttpSession session = request.getSession(false);
        if (session == null || !"admin".equals(session.getAttribute("role"))) {
            response.sendError(403);
            return;
        }
        AdminDAO dao = new AdminDAO();
        List<Adoption> adoptions = dao.getAllAdoptions();
        response.setContentType("application/json;charset=UTF-8");
        response.getWriter().write(JsonUtil.toJson(adoptions));
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
        AdminDAO adminDAO = new AdminDAO();
        AdoptionDAO adoptionDAO = new AdoptionDAO();

        response.setContentType("text/plain;charset=UTF-8");

        if ("review".equals(action)) {
            int id = Integer.parseInt(request.getParameter("id"));
            String status = request.getParameter("status");
            String notes = request.getParameter("notes");
            if (notes == null) notes = "";
            boolean ok = adminDAO.updateAdoptionStatus(id, status, notes);
            if (ok && "已通过".equals(status)) {
                Adoption ad = adoptionDAO.getById(id);
                if (ad != null) {
                    com.example.maomi.dao.CatDAO catDAO = new com.example.maomi.dao.CatDAO();
                    com.example.maomi.model.Cat cat = catDAO.getCatByName(ad.getCatName());
                    if (cat != null) {
                        catDAO.updateCatState(cat.getId(), "已领养");
                    }
                }
            }
            response.getWriter().write(ok ? "ok" : "操作失败");
        }
    }
}