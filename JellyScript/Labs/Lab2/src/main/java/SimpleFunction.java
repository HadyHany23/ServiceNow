package com.example;

public class SimpleFunction{


  
    public String hello(String name) {
        return "Hello, " + name + "!";
    }

    public String evenOdd(int num) {
        if (num % 2 == 0) {
            return "Even";
        } 
        else {
            return "Odd";
        }
    }   
  
}