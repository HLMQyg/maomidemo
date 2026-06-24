package com.example.maomi.utils;

import java.util.Random;

public class CodeUtil {
    public static String generateCode(int len) {
        Random random = new Random();
        StringBuilder sb = new StringBuilder();
        for (int i = 0; i < len; i++) {
            sb.append(random.nextInt(10));
        }
        return sb.toString();
    }
}
