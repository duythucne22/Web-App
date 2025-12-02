package com.example.productmanagement.controller;

import com.example.productmanagement.service.ProductService;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.stereotype.Controller;
import org.springframework.ui.Model;
import org.springframework.web.bind.annotation.GetMapping;
import org.springframework.web.bind.annotation.RequestMapping;

import java.util.Map;

@Controller
@RequestMapping("/dashboard")
public class DashboardController {
    
    private final ProductService productService;
    
    @Autowired
    public DashboardController(ProductService productService) {
        this.productService = productService;
    }
    
    @GetMapping
    public String showDashboard(Model model) {
        Map<String, Object> statistics = productService.getDashboardStatistics();
        
        model.addAttribute("totalProducts", statistics.get("totalProducts"));
        model.addAttribute("totalValue", statistics.get("totalValue"));
        model.addAttribute("averagePrice", statistics.get("averagePrice"));
        model.addAttribute("lowStockProducts", statistics.get("lowStockProducts"));
        model.addAttribute("recentProducts", statistics.get("recentProducts"));
        model.addAttribute("categoryCounts", statistics.get("categoryCounts"));
        
        return "dashboard";
    }
}
