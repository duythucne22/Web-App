package com.example.productmanagement.service;

import com.example.productmanagement.entity.Product;
import org.springframework.data.domain.Page;
import org.springframework.data.domain.Pageable;
import org.springframework.data.domain.Sort;

import java.math.BigDecimal;
import java.util.List;
import java.util.Map;
import java.util.Optional;

public interface ProductService {
    
    List<Product> getAllProducts();
    
    List<Product> getAllProducts(Sort sort);
    
    Optional<Product> getProductById(Long id);
    
    Product saveProduct(Product product);
    
    void deleteProduct(Long id);
    
    List<Product> searchProducts(String keyword);
    
    Page<Product> searchProducts(String keyword, Pageable pageable);
    
    List<Product> getProductsByCategory(String category);
    
    List<Product> getProductsByCategory(String category, Sort sort);
    
    // Exercise 5.1: Multi-Criteria Search
    List<Product> advancedSearch(String name, String category, BigDecimal minPrice, BigDecimal maxPrice);
    
    // Exercise 5.2: Category Filter
    List<String> getAllCategories();
    
    // Exercise 8.1: Statistics Methods
    long countByCategory(String category);
    
    BigDecimal calculateTotalValue();
    
    BigDecimal calculateAveragePrice();
    
    List<Product> findLowStockProducts(int threshold);
    
    List<Product> getRecentProducts();
    
    Map<String, Object> getDashboardStatistics();
}

