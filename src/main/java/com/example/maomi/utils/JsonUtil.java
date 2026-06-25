package com.example.maomi.utils;

import java.lang.reflect.Method;
import java.sql.Timestamp;
import java.text.SimpleDateFormat;
import java.util.*;

/** 轻量 JSON 序列化工具，不依赖第三方库 */
public class JsonUtil {

    private static final SimpleDateFormat DATE_FMT = new SimpleDateFormat("yyyy-MM-dd HH:mm:ss");

    public static String toJson(Object obj) {
        if (obj == null) return "null";
        if (obj instanceof String) return "\"" + escape((String) obj) + "\"";
        if (obj instanceof Number || obj instanceof Boolean) return obj.toString();
        if (obj instanceof java.util.Date) return "\"" + DATE_FMT.format((java.util.Date) obj) + "\"";
        if (obj instanceof Map) return mapToJson((Map<?, ?>) obj);
        if (obj instanceof Collection) return collectionToJson((Collection<?>) obj);
        if (obj.getClass().isArray()) return arrayToJson((Object[]) obj);
        return beanToJson(obj);
    }

    private static String mapToJson(Map<?, ?> map) {
        StringBuilder sb = new StringBuilder("{");
        boolean first = true;
        for (Map.Entry<?, ?> e : map.entrySet()) {
            if (!first) sb.append(",");
            sb.append("\"").append(e.getKey()).append("\":").append(toJson(e.getValue()));
            first = false;
        }
        sb.append("}");
        return sb.toString();
    }

    private static String collectionToJson(Collection<?> col) {
        StringBuilder sb = new StringBuilder("[");
        boolean first = true;
        for (Object item : col) {
            if (!first) sb.append(",");
            sb.append(toJson(item));
            first = false;
        }
        sb.append("]");
        return sb.toString();
    }

    private static String arrayToJson(Object[] arr) {
        StringBuilder sb = new StringBuilder("[");
        for (int i = 0; i < arr.length; i++) {
            if (i > 0) sb.append(",");
            sb.append(toJson(arr[i]));
        }
        sb.append("]");
        return sb.toString();
    }

    private static String beanToJson(Object bean) {
        StringBuilder sb = new StringBuilder("{");
        Method[] methods = bean.getClass().getMethods();
        boolean first = true;
        for (Method m : methods) {
            String name = m.getName();
            // 只处理 getter（getXxx / isXxx），排除 getClass
            if (m.getParameterCount() != 0) continue;
            String key;
            if (name.startsWith("get") && name.length() > 3 && !name.equals("getClass")) {
                key = Character.toLowerCase(name.charAt(3)) + name.substring(4);
            } else if (name.startsWith("is") && name.length() > 2) {
                key = Character.toLowerCase(name.charAt(2)) + name.substring(3);
            } else {
                continue;
            }
            try {
                Object value = m.invoke(bean);
                // 跳过 null 值，让 JSON 更简洁
                if (value == null) continue;
                if (!first) sb.append(",");
                // 将 Java 属性名中的驼峰转为下划线风格（与现有JSON风格保持一致：imagePath → imagePath）
                sb.append("\"").append(key).append("\":").append(toJson(value));
                first = false;
            } catch (Exception ignored) {}
        }
        sb.append("}");
        return sb.toString();
    }

    private static String escape(String s) {
        return s.replace("\\", "\\\\")
                .replace("\"", "\\\"")
                .replace("\n", "\\n")
                .replace("\r", "\\r")
                .replace("\t", "\\t");
    }
}
