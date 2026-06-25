package com.example.maomi.servlet;

import com.example.maomi.dao.AdminDAO;
import com.example.maomi.dao.AdoptionDAO;
import com.example.maomi.model.Adoption;
import com.example.maomi.model.AdoptionMessage;
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
                    for (com.example.maomi.model.Cat cat : catDAO.getAllCats()) {
                        if (cat.getName().equals(ad.getCatName())) {
                            catDAO.updateCatState(cat.getId(), "已领养");
                            break;
                        }
                    }
                }
            }
            response.getWriter().write(ok ? "ok" : "操作失败");
        } else if ("message".equals(action)) {
            int adoptionId = Integer.parseInt(request.getParameter("adoptionId"));
            String message = request.getParameter("message");
            String adminName = (String) session.getAttribute("adminName");
            AdoptionMessage msg = new AdoptionMessage();
            msg.setAdoptionId(adoptionId);
            msg.setSender("管理员-" + adminName);
            msg.setMessage(message);
            boolean ok = adoptionDAO.addMessage(msg);
            response.getWriter().write(ok ? "ok" : "发送失败");
        }
    }
}
