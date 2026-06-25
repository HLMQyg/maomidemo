package com.example.maomi.servlet;

import com.example.maomi.dao.CartDAO;
import com.example.maomi.model.User;
import javax.servlet.annotation.WebServlet;
import javax.servlet.http.*;
import java.io.IOException;

@WebServlet("/updateCartItem")
public class UpdateCartItemServlet extends HttpServlet {
    protected void doPost(HttpServletRequest request, HttpServletResponse response) throws IOException {
        request.setCharacterEncoding("UTF-8");
        HttpSession session = request.getSession();
        User user = (User) session.getAttribute("user");
        if (user == null) { response.getWriter().write("login"); return; }
        int cartId = Integer.parseInt(request.getParameter("cartId"));
        int quantity = Integer.parseInt(request.getParameter("quantity"));
        if (quantity < 1) quantity = 1;
        CartDAO cartDAO = new CartDAO();
        boolean ok = cartDAO.updateQuantity(cartId, quantity);
        response.setContentType("text/plain;charset=UTF-8");
        response.getWriter().write(ok ? "ok" : "fail");
    }
}