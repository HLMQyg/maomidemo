package com.example.maomi.servlet;

import com.example.maomi.dao.CatDAO;
import com.example.maomi.utils.JsonUtil;
import com.example.maomi.model.Cat;

import javax.servlet.annotation.WebServlet;
import javax.servlet.http.HttpServlet;
import javax.servlet.http.HttpServletRequest;
import javax.servlet.http.HttpServletResponse;
import java.io.IOException;

@WebServlet("/getCatDetail")
public class CatDetailServlet extends HttpServlet {
    protected void doGet(HttpServletRequest request, HttpServletResponse response) throws IOException {
        int id = Integer.parseInt(request.getParameter("id"));
        CatDAO dao = new CatDAO();
        Cat cat = dao.getCatById(id);
        response.setContentType("application/json;charset=UTF-8");
        if (cat == null) {
            response.getWriter().write("{}");
            return;
        }
        // 手动JSON
// use JsonUtil
        response.getWriter().write(com.example.maomi.utils.JsonUtil.toJson(cat));
    }
    private String escape(String s) { return s == null ? "" : s.replace("\\","\\\\").replace("\"","\\\""); }
}
