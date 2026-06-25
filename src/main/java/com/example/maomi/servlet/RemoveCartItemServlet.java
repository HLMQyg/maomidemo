package com.example.maomi.servlet;

import com.example.maomi.dao.CartDAO;
import com.example.maomi.model.User;
import javax.servlet.annotation.WebServlet;
import javax.servlet.http.*;
import java.io.IOException;

@WebServlet("/removeCartItem")
public class RemoveCartItemServlet extends HttpServlet {
    protected void doPost(HttpServletRequest request, HttpServletResponse response) throws IOException {
        request.setCharacterEncoding("UTF-8");
        HttpSession session = request.getSession();
        User user = (User) session.getAttribute("user");
        if (user == null) { response.getWriter().write("login"); return; }
        int cartId = Integer.parseInt(request.getParameter("cartId"));
        CartDAO cartDAO = new CartDAO();
        boolean ok = cartDAO.remove(cartId);
        response.setContentType("text/plain;charset=UTF-8");
        response.getWriter().write(ok ? "ok" : "fail");
    }
}