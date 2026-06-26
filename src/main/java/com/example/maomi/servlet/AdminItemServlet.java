package com.example.maomi.servlet;

import com.example.maomi.dao.ItemDAO;
import com.example.maomi.model.Item;
import com.example.maomi.utils.JsonUtil;
import javax.servlet.annotation.WebServlet;
import javax.servlet.http.*;
import java.io.IOException;
import java.util.List;

@WebServlet("/adminItem")
public class AdminItemServlet extends HttpServlet {
    protected void doGet(HttpServletRequest request, HttpServletResponse response) throws IOException {
        HttpSession session = request.getSession(false);
        if (session == null || !"admin".equals(session.getAttribute("role"))) {
            response.sendError(403);
            return;
        }
        ItemDAO dao = new ItemDAO();
        List<Item> items = dao.getAllItemsAdmin();   // 管理员看到所有
        response.setContentType("application/json;charset=UTF-8");
        response.getWriter().write(JsonUtil.toJson(items));
    }
    protected void doPost(HttpServletRequest request, HttpServletResponse response) throws IOException {
        request.setCharacterEncoding("UTF-8");
        HttpSession session = request.getSession(false);
        if (session == null || !"admin".equals(session.getAttribute("role"))) {
            response.sendError(403);
            return;
        }

        String action = request.getParameter("action");
        ItemDAO dao = new ItemDAO();
        response.setContentType("text/plain;charset=UTF-8");

        try {
            // ===== 新增：处理添加商品 =====
            if ("add".equals(action)) {
                Item item = new Item();
                item.setName(request.getParameter("name"));
                item.setDescription(request.getParameter("description"));
                item.setPrice(Double.parseDouble(request.getParameter("price")));
                item.setImagePath(request.getParameter("imagePath"));
                item.setCategory(request.getParameter("category"));
                item.setStatus("上架");   // 默认上架
                boolean ok = dao.insertItem(item);
                response.getWriter().write(ok ? "ok" : "添加失败");
            }
            else if ("toggle".equals(action)) {
                int id = Integer.parseInt(request.getParameter("id"));
                String status = request.getParameter("status");
                boolean ok = dao.updateItemStatus(id, status);
                response.getWriter().write(ok ? "ok" : "操作失败");
            }
            else if ("update".equals(action)) {
                Item item = new Item();
                item.setId(Integer.parseInt(request.getParameter("id")));
                item.setName(request.getParameter("name"));
                item.setDescription(request.getParameter("description"));
                item.setPrice(Double.parseDouble(request.getParameter("price")));
                item.setImagePath(request.getParameter("imagePath"));
                item.setCategory(request.getParameter("category"));
                boolean ok = dao.updateItem(item);
                response.getWriter().write(ok ? "ok" : "更新失败");
            }
            else if ("delete".equals(action)) {
                int id = Integer.parseInt(request.getParameter("id"));
                boolean ok = dao.deleteItem(id);
                response.getWriter().write(ok ? "ok" : "删除失败");
            }
        } catch (Exception e) {
            response.getWriter().write("参数错误");
        }
    }


}