package com.example.maomi.servlet;

import com.example.maomi.dao.BusinessTaskDAO;
import com.example.maomi.dao.CatDAO;
import com.example.maomi.dao.FeedingRecordDAO;
import com.example.maomi.dao.InventoryDAO;
import com.example.maomi.model.Cat;
import com.example.maomi.model.User;
import javax.servlet.annotation.WebServlet;
import javax.servlet.http.*;
import java.io.IOException;

@WebServlet("/feedCat")
public class FeedCatServlet extends HttpServlet {
    protected void doPost(HttpServletRequest request, HttpServletResponse response) throws IOException {
        request.setCharacterEncoding("UTF-8");
        HttpSession session = request.getSession();
        User user = (User) session.getAttribute("user");
        if (user == null) {
            response.getWriter().write("login");
            return;
        }
        int catId = Integer.parseInt(request.getParameter("catId"));
        int itemId = Integer.parseInt(request.getParameter("itemId"));
        int quantity = Integer.parseInt(request.getParameter("quantity"));

        // 检查猫咪状态，如果已经在喂养中，则不允许再次喂养
        CatDAO catDAO = new CatDAO();
        Cat cat = catDAO.getCatById(catId);
        if (cat == null) {
            response.getWriter().write("猫咪不存在");
            return;
        }
        if ("喂养中".equals(cat.getState())) {
            response.getWriter().write("猫咪已经在喂养啦～");
            return;
        }

        InventoryDAO invDAO = new InventoryDAO();
        if (!invDAO.consume(user.getUsername(), itemId, quantity)) {
            response.getWriter().write("库存不足");
            return;
        }

        // 更新猫咪状态为“喂养中”
        catDAO.updateCatState(catId, "喂养中");

        // 插入喂养记录
        FeedingRecordDAO frDAO = new FeedingRecordDAO();
        frDAO.insert(user.getUsername(), catId, itemId, quantity);

        // 生成业务任务通知管理员
        BusinessTaskDAO taskDAO = new BusinessTaskDAO();
        taskDAO.create(user.getUsername(), "FEEDING", catId, itemId, quantity);

        response.setContentType("text/plain;charset=UTF-8");
        response.getWriter().write("ok");
    }
}