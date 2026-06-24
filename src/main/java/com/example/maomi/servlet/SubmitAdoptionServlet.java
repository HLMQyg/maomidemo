package com.example.maomi.servlet;

import com.example.maomi.dao.AdoptionDAO;
import com.example.maomi.model.Adoption;
import com.example.maomi.model.User;

import javax.servlet.annotation.WebServlet;
import javax.servlet.http.HttpServlet;
import javax.servlet.http.HttpServletRequest;
import javax.servlet.http.HttpServletResponse;
import javax.servlet.http.HttpSession;
import java.io.IOException;

@WebServlet("/submitAdoption")
public class SubmitAdoptionServlet extends HttpServlet {
    protected void doPost(HttpServletRequest request, HttpServletResponse response) throws IOException {
        request.setCharacterEncoding("UTF-8");
        HttpSession session = request.getSession();
        User user = (User) session.getAttribute("user");
        if (user == null) {
            response.getWriter().write("请先登录");
            return;
        }
        int catId = Integer.parseInt(request.getParameter("catId"));
        Adoption adoption = new Adoption();
        adoption.setUsername(user.getUsername());
        adoption.setCatId(catId);
        adoption.setApplicantName(request.getParameter("applicantName"));
        adoption.setApplicantPhone(request.getParameter("applicantPhone"));
        adoption.setApplicantAddress(request.getParameter("applicantAddress"));
        adoption.setReason(request.getParameter("reason"));
        adoption.setStatus("待审核");

        AdoptionDAO dao = new AdoptionDAO();
        boolean ok = dao.insert(adoption);
        response.setContentType("text/plain;charset=UTF-8");
        response.getWriter().write(ok ? "success" : "插入失败");
    }
}