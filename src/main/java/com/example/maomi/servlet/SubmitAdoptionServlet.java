package com.example.maomi.servlet;

import com.example.maomi.dao.AdoptionDAO;
import com.example.maomi.model.Adoption;
import com.example.maomi.model.User;
import javax.servlet.annotation.WebServlet;
import javax.servlet.http.*;
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
        String catName = request.getParameter("catName");   // 前端必须传入
        String applicantName = request.getParameter("applicantName");
        String applicantPhone = request.getParameter("applicantPhone");
        String applicantAddress = request.getParameter("applicantAddress");
        String reason = request.getParameter("reason");

        Adoption adoption = new Adoption();
        adoption.setUsername(user.getUsername());
        adoption.setCatName(catName);
        adoption.setApplicantName(applicantName);
        adoption.setApplicantPhone(applicantPhone);
        adoption.setApplicantAddress(applicantAddress);
        adoption.setReason(reason);
        adoption.setStatus("待审核");

        AdoptionDAO dao = new AdoptionDAO();
        boolean ok = dao.insert(adoption);
        response.setContentType("text/plain;charset=UTF-8");
        response.getWriter().write(ok ? "success" : "数据库插入失败");
    }
}