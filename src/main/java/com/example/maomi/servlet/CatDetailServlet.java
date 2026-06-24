package com.example.maomi.servlet;

import com.example.maomi.dao.CatDAO;
import com.example.maomi.model.Cat;

import javax.servlet.annotation.WebServlet;
import javax.servlet.http.HttpServlet;
import javax.servlet.http.HttpServletRequest;
import javax.servlet.http.HttpServletResponse;
import java.io.IOException;

@WebServlet("/getCatDetail")
public class CatDetailServlet extends HttpServlet {
    protected void doGet(HttpServletRequest request, HttpServletResponse response) throws IOException, IOException {
        int id = Integer.parseInt(request.getParameter("id"));
        CatDAO dao = new CatDAO();
        Cat cat = dao.getCatById(id);
        response.setContentType("application/json;charset=UTF-8");
        if (cat == null) {
            response.getWriter().write("{}");
            return;
        }
        // 手动JSON
        String json = String.format("{\"id\":%d,\"name\":\"%s\",\"color\":\"%s\",\"age\":%d,\"gender\":\"%s\",\"healthStatus\":\"%s\",\"description\":\"%s\",\"foundLocation\":\"%s\",\"foundDate\":\"%s\",\"imagePath\":\"%s\",\"state\":\"%s\"}",
                cat.getId(),
                escape(cat.getName()),
                escape(cat.getColor()),
                cat.getAge(),
                escape(cat.getGender()),
                escape(cat.getHealthStatus()),
                escape(cat.getDescription()),
                escape(cat.getFoundLocation()),
                cat.getFoundDate() != null ? cat.getFoundDate().toString() : "",
                escape(cat.getImagePath()),
                escape(cat.getState()));
        response.getWriter().write(json);
    }
    private String escape(String s) { return s == null ? "" : s.replace("\\","\\\\").replace("\"","\\\""); }
}
