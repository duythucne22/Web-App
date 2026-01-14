package com.example.customerapi.dto;

import jakarta.validation.constraints.Email;
import jakarta.validation.constraints.Pattern;
import jakarta.validation.constraints.Size;

// Exercise 7: Partial Update with PATCH
public class CustomerUpdateDTO {
    
    @Size(min = 2, max = 100)
    private String fullName;

    @Email
    private String email;

    @Pattern(regexp = "^\\+?[0-9]{10,20}$")
    private String phone;

    @Size(max = 500)
    private String address;

    public CustomerUpdateDTO() {}

    public CustomerUpdateDTO(String fullName, String email, String phone, String address) {
        this.fullName = fullName;
        this.email = email;
        this.phone = phone;
        this.address = address;
    }

    public String getFullName() { return fullName; }
    public void setFullName(String fullName) { this.fullName = fullName; }

    public String getEmail() { return email; }
    public void setEmail(String email) { this.email = email; }

    public String getPhone() { return phone; }
    public void setPhone(String phone) { this.phone = phone; }

    public String getAddress() { return address; }
    public void setAddress(String address) { this.address = address; }
}
