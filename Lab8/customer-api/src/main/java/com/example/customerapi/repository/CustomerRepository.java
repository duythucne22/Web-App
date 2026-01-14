package com.example.customerapi.repository;

import com.example.customerapi.entity.Customer;
import com.example.customerapi.entity.CustomerStatus;
import org.springframework.data.jpa.repository.JpaRepository;
import org.springframework.data.jpa.repository.Query;
import org.springframework.data.repository.query.Param;
import java.util.List;
import java.util.Optional;

public interface CustomerRepository extends JpaRepository<Customer, Long> {
    Optional<Customer> findByCustomerCode(String code);
    Optional<Customer> findByEmail(String email);
    boolean existsByCustomerCode(String code);
    boolean existsByEmail(String email);
    List<Customer> findByStatus(CustomerStatus status);

    @Query("SELECT c FROM Customer c WHERE " +
           "LOWER(c.fullName) LIKE LOWER(CONCAT('%', :keyword, '%')) OR " +
           "LOWER(c.email) LIKE LOWER(CONCAT('%', :keyword, '%')) OR " +
           "LOWER(c.customerCode) LIKE LOWER(CONCAT('%', :keyword, '%'))")
    List<Customer> searchCustomers(@Param("keyword") String keyword);

    @Query("SELECT c FROM Customer c WHERE " +
           "(:name IS NULL OR LOWER(c.fullName) LIKE LOWER(CONCAT('%', :name, '%'))) AND " +
           "(:email IS NULL OR LOWER(c.email) LIKE LOWER(CONCAT('%', :email, '%'))) AND " +
           "(:status IS NULL OR c.status = :status)")
    List<Customer> advancedSearch(@Param("name") String name, 
                                  @Param("email") String email, 
                                  @Param("status") CustomerStatus status);
}
