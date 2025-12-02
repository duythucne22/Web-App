package com.example.productmanagement.service;

import com.example.productmanagement.entity.Product;
import com.example.productmanagement.repository.ProductRepository;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.data.domain.Page;
import org.springframework.data.domain.Pageable;
import org.springframework.data.domain.Sort;
import org.springframework.stereotype.Service;
import org.springframework.transaction.annotation.Transactional;

import java.math.BigDecimal;
import java.util.HashMap;
import java.util.List;
import java.util.Map;
import java.util.Optional;

@Service
@Transactional
public class ProductServiceImpl implements ProductService {
    
    private final ProductRepository productRepository;
    
    @Autowired
    public ProductServiceImpl(ProductRepository productRepository) {
        this.productRepository = productRepository;
    }
    
    @Override
    public List<Product> getAllProducts() {
        return productRepository.findAll();
    }
    
    @Override
    public List<Product> getAllProducts(Sort sort) {
        return productRepository.findAll(sort);
    }
    
    @Override
    public Optional<Product> getProductById(Long id) {
        return productRepository.findById(id);
    }
    
    @Override
    public Product saveProduct(Product product) {
        return productRepository.save(product);
    }
    
    @Override
    public void deleteProduct(Long id) {
        productRepository.deleteById(id);
    }
    
    @Override
    public List<Product> searchProducts(String keyword) {
        return productRepository.findByNameContaining(keyword);
    }
    
    @Override
    public Page<Product> searchProducts(String keyword, Pageable pageable) {
        return productRepository.findByNameContaining(keyword, pageable);
    }
    
    @Override
    public List<Product> getProductsByCategory(String category) {
        return productRepository.findByCategory(category);
    }
    
    @Override
    public List<Product> getProductsByCategory(String category, Sort sort) {
        return productRepository.findByCategory(category, sort);
    }
    
    @Override
    public List<Product> advancedSearch(String name, String category, BigDecimal minPrice, BigDecimal maxPrice) {
        return productRepository.searchProducts(name, category, minPrice, maxPrice);
    }
    
    @Override
    public List<String> getAllCategories() {
        return productRepository.findAllCategories();
    }
    
    @Override
    public long countByCategory(String category) {
        return productRepository.countByCategory(category);
    }
    
    @Override
    public BigDecimal calculateTotalValue() {
        BigDecimal total = productRepository.calculateTotalValue();
        return total != null ? total : BigDecimal.ZERO;
    }
    
    @Override
    public BigDecimal calculateAveragePrice() {
        BigDecimal avg = productRepository.calculateAveragePrice();
        return avg != null ? avg : BigDecimal.ZERO;
    }
    
    @Override
    public List<Product> findLowStockProducts(int threshold) {
        return productRepository.findLowStockProducts(threshold);
    }
    
    @Override
    public List<Product> getRecentProducts() {
        return productRepository.findTop5ByOrderByCreatedAtDesc();
    }
    
    @Override
    public Map<String, Object> getDashboardStatistics() {
        Map<String, Object> stats = new HashMap<>();
        
        // Total products
        stats.put("totalProducts", productRepository.count());
        
        // Total inventory value
        stats.put("totalValue", calculateTotalValue());
        
        // Average price
        stats.put("averagePrice", calculateAveragePrice());
        
        // Low stock products
        stats.put("lowStockProducts", findLowStockProducts(10));
        
        // Recent products
        stats.put("recentProducts", getRecentProducts());
        
        // Categories with counts
        List<String> categories = getAllCategories();
        Map<String, Long> categoryCounts = new HashMap<>();
        for (String category : categories) {
            categoryCounts.put(category, countByCategory(category));
        }
        stats.put("categoryCounts", categoryCounts);
        
        return stats;
    }
}
