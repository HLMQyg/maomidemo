package com.example.maomi.servlet;

import com.example.maomi.dao.InventoryDAO;
import com.example.maomi.model.User;
import com.example.maomi.model.UserInventory;
import javax.servlet.annotation.WebServlet;
import javax.servlet.http.*;
import java.io.IOException;
import java.util.List;

@WebServlet("/getInventory")
public class GetInventoryServlet extends HttpServlet {
    protected void doGet(HttpServletRequest request, HttpServletResponse response) throws IOException {
        HttpSession session = request.getSession();
        User user = (User) session.getAttribute("user");
        if (user == null) { response.getWriter().write("[]"); return; }
        InventoryDAO dao = new InventoryDAO();
        List<UserInventory> list = dao.getByUsername(user.getUsername());

        StringBuilder json = new StringBuilder("[");
        for (int i = 0; i < list.size(); i++) {
            UserInventory inv = list.get(i);
            json.append("{");
            json.append("\"itemId\":").append(inv.getItemId()).append(",");
            json.append("\"name\":\"").append(escape(inv.getItemName())).append("\",");
            json.append("\"image\":\"").append(escape(inv.getItemImage())).append("\",");
            json.append("\"quantity\":").append(inv.getQuantity());
            json.append("}");
            if (i < list.size() - 1) json.append(",");
        }
        json.append("]");
        response.setContentType("application/json;charset=UTF-8");
        response.getWriter().write(json.toString());
    }
    private String escape(String s) { return s == null ? "" : s.replace("\\","\\\\").replace("\"","\\\""); }
}