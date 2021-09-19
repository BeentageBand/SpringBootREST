package com.example.demo;

import java.util.stream.*;
import java.util.Collection;
import org.springframework.web.bind.annotation.GetMapping;
import org.springframework.web.bind.annotation.RestController;

@RestController
class DemoController {

  @GetMapping("/demo")
  public Collection<String> demo() {
    return IntStream.range(0, 10)
      .mapToObj(i -> "Hello number" + i)
      .collect(Collectors.toList());
  }
}
