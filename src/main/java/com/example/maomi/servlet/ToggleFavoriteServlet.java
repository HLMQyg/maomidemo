package com.example.maomi.servlet;

import com.example.maomi.dao.FavoriteDAO;
import com.example.maomi.model.User;
import javax.servlet.annotation.WebServlet;
import javax.servlet.http.*;
import java.io.IOException;

@WebServlet("/toggleFavorite")
public class ToggleFavoriteServlet extends HttpServlet {
    protected void doPost(HttpServletRequest request, HttpServletResponse response) throws IOException {
        request.setCharacterEncoding("UTF-8");
        HttpSession session = request.getSession();
        User user = (User) session.getAttribute("user");
        if (user == null) {
            response.getWriter().write("login");
            return;
        }

        int catId = Integer.parseInt(request.getParameter("catId"));
        FavoriteDAO dao = new FavoriteDAO();
        String username = user.getUsername();

        if (dao.isFavorited(username, catId)) {
            dao.removeFavorite(username, catId);
            response.getWriter().write("removed");
        } else {
            dao.addFavorite(username, catId);
            response.getWriter().write("added");
        }
    }
}