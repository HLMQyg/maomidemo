package com.example.maomi.servlet;

import com.example.maomi.dao.CartDAO;
import com.example.maomi.dao.InventoryDAO;
import com.example.maomi.model.CartItem;
import com.example.maomi.model.User;
import javax.servlet.annotation.WebServlet;
import javax.servlet.http.*;
import java.io.IOException;
import java.util.List;

@WebServlet("/checkout")
public class CheckoutServlet extends HttpServlet {
    protected void doPost(HttpServletRequest request, HttpServletResponse response) throws IOException {
        HttpSession session = request.getSession();
        User user = (User) session.getAttribute("user");
        if (user == null) { response.sendRedirect("index.jsp"); return; }

        CartDAO cartDAO = new CartDAO();
        InventoryDAO invDAO = new InventoryDAO();
        List<CartItem> cartItems = cartDAO.getByUsername(user.getUsername());

        for (CartItem cart : cartItems) {
            invDAO.addOrUpdate(user.getUsername(), cart.getItemId(), cart.getQuantity());
        }
        cartDAO.clear(user.getUsername());

        response.setContentType("text/plain;charset=UTF-8");
        response.getWriter().write("ok");
    }
}