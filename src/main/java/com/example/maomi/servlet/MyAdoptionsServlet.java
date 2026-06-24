package com.example.maomi.servlet;

import com.example.maomi.dao.AdoptionDAO;
import com.example.maomi.model.Adoption;
import com.example.maomi.model.User;
import javax.servlet.ServletException;
import javax.servlet.annotation.WebServlet;
import javax.servlet.http.*;
import java.io.IOException;
import java.util.List;

@WebServlet("/myAdoptions")
public class MyAdoptionsServlet extends HttpServlet {
    protected void doGet(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {
        HttpSession session = request.getSession();
        User user = (User) session.getAttribute("user");
        if (user == null) {
            response.sendRedirect(request.getContextPath() + "/index.jsp");
            return;
        }
        AdoptionDAO dao = new AdoptionDAO();
        List<Adoption> adoptions = dao.getByUsername(user.getUsername());
        request.setAttribute("adoptions", adoptions);
        request.getRequestDispatcher("/pages/my_adoptions.jsp").forward(request, response);
    }
}