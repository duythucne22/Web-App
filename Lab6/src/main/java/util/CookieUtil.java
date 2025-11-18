package util;

import jakarta.servlet.http.Cookie;
import jakarta.servlet.http.HttpServletRequest;
import jakarta.servlet.http.HttpServletResponse;

public class CookieUtil {
    
    /**
     * Create and add cookie to response
     */
    public static void createCookie(HttpServletResponse response, 
                                   String name, 
                                   String value, 
                                   int maxAge) {
        Cookie cookie = new Cookie(name, value);
        cookie.setMaxAge(maxAge);
        cookie.setPath("/");
        cookie.setHttpOnly(true);
        // cookie.setSecure(true); // Enable in production with HTTPS
        response.addCookie(cookie);
    }
    
    /**
     * Get cookie value by name
     */
    public static String getCookieValue(HttpServletRequest request, String name) {
        Cookie[] cookies = request.getCookies();
        if (cookies != null) {
            for (Cookie cookie : cookies) {
                if (cookie.getName().equals(name)) {
                    return cookie.getValue();
                }
            }
        }
        return null;
    }
    
    /**
     * Check if cookie exists
     */
    public static boolean hasCookie(HttpServletRequest request, String name) {
        return getCookieValue(request, name) != null;
    }
    
    /**
     * Delete cookie by setting max age to 0
     */
    public static void deleteCookie(HttpServletResponse response, String name) {
        Cookie cookie = new Cookie(name, "");
        cookie.setMaxAge(0);
        cookie.setPath("/");
        response.addCookie(cookie);
    }
    
    /**
     * Update cookie value
     */
    public static void updateCookie(HttpServletResponse response, 
                                   String name, 
                                   String newValue, 
                                   int maxAge) {
        createCookie(response, name, newValue, maxAge);
    }
}
