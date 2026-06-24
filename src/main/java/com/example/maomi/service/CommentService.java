package com.example.maomi.service;

import com.example.maomi.dao.CommentDAO;
import com.example.maomi.model.Comment;
import java.util.List;

public class CommentService {
    private CommentDAO commentDAO = new CommentDAO();

    public List<Comment> getCommentsByCatId(int catId) {
        return commentDAO.getCommentsByCatId(catId);
    }

    public boolean addComment(int catId, String username, String comment) {
        if (comment == null || comment.trim().isEmpty()) return false;
        return commentDAO.addComment(catId, username, comment.trim());
    }
}