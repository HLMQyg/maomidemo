package com.example.maomi.servlet;

import com.example.maomi.dao.AdoptionDAO;
import com.example.maomi.model.User;
import javax.servlet.annotation.WebServlet;
import javax.servlet.http.*;
import java.io.IOException;

@WebServlet("/cancelAdoption")
public class CancelAdoptionServlet extends HttpServlet {
    protected void doPost(HttpServletRequest request, HttpServletResponse response) throws IOException {
        request.setCharacterEncoding("UTF-8");
        HttpSession session = request.getSession();
        User user = (User) session.getAttribute("user");
        if (user == null) {
            response.getWriter().write("请先登录");
            return;
        }

        int id = Integer.parseInt(request.getParameter("id"));
        AdoptionDAO dao = new AdoptionDAO();
        boolean ok = dao.cancelAdoption(id);
        response.setContentType("text/plain;charset=UTF-8");
        response.getWriter().write(ok ? "ok" : "取消失败");
    }
}