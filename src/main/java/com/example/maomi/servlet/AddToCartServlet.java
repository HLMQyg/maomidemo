package com.example.maomi.servlet;

import com.example.maomi.dao.CartDAO;
import com.example.maomi.model.User;
import javax.servlet.annotation.WebServlet;
import javax.servlet.http.*;
import java.io.IOException;

@WebServlet("/addToCart")
public class AddToCartServlet extends HttpServlet {
    protected void doPost(HttpServletRequest request, HttpServletResponse response) throws IOException {
        request.setCharacterEncoding("UTF-8");
        HttpSession session = request.getSession();
        User user = (User) session.getAttribute("user");
        if (user == null) { response.getWriter().write("login"); return; }
        int itemId = Integer.parseInt(request.getParameter("itemId"));
        int quantity = Integer.parseInt(request.getParameter("quantity"));
        CartDAO cartDAO = new CartDAO();
        boolean ok = cartDAO.add(user.getUsername(), itemId, quantity);
        response.setContentType("text/plain;charset=UTF-8");
        response.getWriter().write(ok ? "ok" : "fail");
    }
}