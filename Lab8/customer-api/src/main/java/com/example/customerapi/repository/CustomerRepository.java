package com.example.customerapi.repository;

import com.example.customerapi.entity.Customer;
import com.example.customerapi.entity.CustomerStatus;
import org.springframework.data.jpa.repository.JpaRepository;
import java.util.List;
import java.util.Optional;

public interface CustomerRepository extends JpaRepository<Customer, Long> {
    Optional<Customer> findByCustomerCode(String code);
    Optional<Customer> findByEmail(String email);
    boolean existsByCustomerCode(String code);
    boolean existsByEmail(String email);
    List<Customer> findByStatus(CustomerStatus status);
}
