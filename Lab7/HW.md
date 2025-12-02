# PART B: HOMEWORK EXERCISES (40 points)
**Deadline:** 1 week  
**Submission:** ZIP file with complete project + README

---

## EXERCISE 5: ADVANCED SEARCH (12 points)
Estimated Time: 45 minutes

### Task 5.1: Multi-Criteria Search (6 points)
Add search by multiple criteria:
- Name (contains)
- Category (exact match)
- Price range (min-max)

Add to `ProductRepository`:

```java
// repository query
@Query("SELECT p FROM Product p WHERE " +
       "(:name IS NULL OR p.name LIKE %:name%) AND " +
       "(:category IS NULL OR p.category = :category) AND " +
       "(:minPrice IS NULL OR p.price >= :minPrice) AND " +
       "(:maxPrice IS NULL OR p.price <= :maxPrice)")
List<Product> searchProducts(@Param("name") String name,
                            @Param("category") String category,
                            @Param("minPrice") BigDecimal minPrice,
                            @Param("maxPrice") BigDecimal maxPrice);
```

- Add service interface and implementation methods that forward these parameters to the repository.
- Controller endpoint example:

```java
@GetMapping("/advanced-search")
public String advancedSearch(
    @RequestParam(required = false) String name,
    @RequestParam(required = false) String category,
    @RequestParam(required = false) BigDecimal minPrice,
    @RequestParam(required = false) BigDecimal maxPrice,
    Model model) {
    // Implementation: call service.searchProducts(...), add results to model
}
```

- Add an advanced search form in `product-list.html`.

---

### Task 5.2: Category Filter (3 points)
Add category filter dropdown that shows all unique categories.

Repository:

```java
@Query("SELECT DISTINCT p.category FROM Product p ORDER BY p.category")
List<String> findAllCategories();
```

View snippet:

```html
<select name="category" onchange="this.form.submit()">
    <option value="">All Categories</option>
    <option th:each="cat : ${categories}" 
            th:value="${cat}" 
            th:text="${cat}"
            th:selected="${cat == selectedCategory}">
    </option>
</select>
```

---

### Task 5.3: Search with Pagination (3 points)
Implement pagination for search results.

Repository (use Pageable):

```java
Page<Product> findByNameContaining(String keyword, Pageable pageable);
```

Controller example:

```java
@GetMapping("/search")
public String searchProducts(
    @RequestParam("keyword") String keyword,
    @RequestParam(defaultValue = "0") int page,
    @RequestParam(defaultValue = "10") int size,
    Model model) {
    
    Pageable pageable = PageRequest.of(page, size);
    Page<Product> productPage = productService.searchProducts(keyword, pageable);
    
    model.addAttribute("products", productPage.getContent());
    model.addAttribute("currentPage", page);
    model.addAttribute("totalPages", productPage.getTotalPages());
    
    return "product-list";
}
```

---

## EXERCISE 6: VALIDATION (10 points)
Estimated Time: 40 minutes

### Task 6.1: Add Validation Annotations (5 points)
Add to `Product` entity:

```java
import jakarta.validation.constraints.*;

@Entity
public class Product {
    
    @NotBlank(message = "Product code is required")
    @Size(min = 3, max = 20, message = "Product code must be 3-20 characters")
    @Pattern(regexp = "^P\\d{3,}$", message = "Product code must start with P followed by numbers")
    private String productCode;
    
    @NotBlank(message = "Product name is required")
    @Size(min = 3, max = 100, message = "Name must be 3-100 characters")
    private String name;
    
    @NotNull(message = "Price is required")
    @DecimalMin(value = "0.01", message = "Price must be greater than 0")
    @DecimalMax(value = "999999.99", message = "Price is too high")
    private BigDecimal price;
    
    @NotNull(message = "Quantity is required")
    @Min(value = 0, message = "Quantity cannot be negative")
    private Integer quantity;
    
    @NotBlank(message = "Category is required")
    private String category;
}
```

### Task 6.2: Add Validation in Controller (3 points)

```java
import jakarta.validation.Valid;
import org.springframework.validation.BindingResult;

@PostMapping("/save")
public String saveProduct(
    @Valid @ModelAttribute("product") Product product,
    BindingResult result,
    Model model,
    RedirectAttributes redirectAttributes) {
    
    if (result.hasErrors()) {
        return "product-form";
    }
    
    try {
        productService.saveProduct(product);
        redirectAttributes.addFlashAttribute("message", "Product saved successfully!");
    } catch (Exception e) {
        redirectAttributes.addFlashAttribute("error", "Error: " + e.getMessage());
    }
    
    return "redirect:/products";
}
```

### Task 6.3: Display Validation Errors (2 points)
Update `product-form.html`:

```html
<div class="form-group">
    <label for="productCode">Product Code *</label>
    <input type="text" 
           id="productCode" 
           th:field="*{productCode}" 
           th:errorclass="error" />
    <span th:if="${#fields.hasErrors('productCode')}" 
          th:errors="*{productCode}" 
          class="error-message">Error</span>
</div>
```

CSS:

```css
.error { border-color: red; }
.error-message { color: red; font-size: 12px; }
```

---

## EXERCISE 7: SORTING & FILTERING (10 points)
Estimated Time: 40 minutes

### Task 7.1: Add Sorting (5 points)
Controller:

```java
@GetMapping
public String listProducts(
    @RequestParam(required = false) String sortBy,
    @RequestParam(defaultValue = "asc") String sortDir,
    Model model) {
    
    List<Product> products;
    
    if (sortBy != null) {
        Sort sort = sortDir.equals("asc") ? 
            Sort.by(sortBy).ascending() : 
            Sort.by(sortBy).descending();
        products = productService.getAllProducts(sort);
    } else {
        products = productService.getAllProducts();
    }
    
    model.addAttribute("products", products);
    model.addAttribute("sortBy", sortBy);
    model.addAttribute("sortDir", sortDir);
    
    return "product-list";
}
```

View sorting link example:

```html
<th>
    <a th:href="@{/products(sortBy='name',sortDir=${sortDir=='asc'?'desc':'asc'})}">
        Name
        <span th:if="${sortBy=='name'}" th:text="${sortDir=='asc'?'↑':'↓'}"></span>
    </a>
</th>
```

### Task 7.2 & 7.3: Filter by Category and Combine Sorting & Filtering
- Add category filter controls that preserve current sorting parameters when submitting.

---

## EXERCISE 8: STATISTICS DASHBOARD (8 points)
Estimated Time: 35 minutes

### Task 8.1: Add Statistics Methods (4 points)
Repository:

```java
@Query("SELECT COUNT(p) FROM Product p WHERE p.category = :category")
long countByCategory(@Param("category") String category);

@Query("SELECT SUM(p.price * p.quantity) FROM Product p")
BigDecimal calculateTotalValue();

@Query("SELECT AVG(p.price) FROM Product p")
BigDecimal calculateAveragePrice();

@Query("SELECT p FROM Product p WHERE p.quantity < :threshold")
List<Product> findLowStockProducts(@Param("threshold") int threshold);
```

### Task 8.2: Create Dashboard Controller (2 points)

```java
@Controller
@RequestMapping("/dashboard")
public class DashboardController {
    
    @Autowired
    private ProductService productService;
    
    @GetMapping
    public String showDashboard(Model model) {
        // Add statistics to model
        return "dashboard";
    }
}
```

### Task 8.3: Create Dashboard View (2 points)
Create `src/main/resources/templates/dashboard.html` and display:
- Total products count
- Products by category (pie chart or list)
- Total inventory value
- Average product price
- Low stock alerts (quantity < 10)
- Recent products (last 5 added)

---

## BONUS EXERCISES (Optional - Extra Credit)
Not required, earn up to 20 bonus points

### BONUS 1: REST API Endpoints (8 points)
Create RESTful API for products.

```java
@RestController
@RequestMapping("/api/products")
public class ProductRestController {
    
    @GetMapping
    public ResponseEntity<List<Product>> getAllProducts() {
        // Return JSON
    }
    
    @GetMapping("/{id}")
    public ResponseEntity<Product> getProduct(@PathVariable Long id) {
        // Return single product or 404
    }
    
    @PostMapping
    public ResponseEntity<Product> createProduct(@RequestBody Product product) {
        // Create and return 201
    }
    
    @PutMapping("/{id}")
    public ResponseEntity<Product> updateProduct(@PathVariable Long id, @RequestBody Product product) {
        // Update and return
    }
    
    @DeleteMapping("/{id}")
    public ResponseEntity<Void> deleteProduct(@PathVariable Long id) {
        // Delete and return 204
    }
}
```

Test with Thunder Client, Postman, or browser for GET requests.

### BONUS 2: Image Upload (6 points)
Add product image upload functionality.

- Add imagePath field to Product entity
- Handle file upload in controller using MultipartFile
- Store images in uploads/ directory
- Display images in product list and details

### BONUS 3: Export to Excel (6 points)
Add Excel export functionality.

Dependency:

```xml
<dependency>
    <groupId>org.apache.poi</groupId>
    <artifactId>poi-ooxml</artifactId>
    <version>5.2.3</version>
</dependency>
```

Controller stub:

```java
@Controller
@RequestMapping("/export")
public class ExportController {
    
    @GetMapping("/excel")
    public void exportToExcel(HttpServletResponse response) throws IOException {
        // Create Excel workbook
        // Write data
        // Send to browser
    }
}
```

