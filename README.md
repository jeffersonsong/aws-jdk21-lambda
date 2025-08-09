# Resources for article on AWS Lambda with Spring Boot

Original Post: 
[Deploy AWS Lambda with Spring Boot, OpenTofu and Java](https://codecraftsphere.substack.com/p/how-to-use-spring-boot-with-aws-lambda)
```
# ./gradlew clean assemble bootJar
# cd opentofu
# tofu init
# tofu plan -var-file=dev/vars.tfvars
# tofu apply -var-file=dev/vars.tfvars
# tofu destroy -var-file=dev/vars.tfvars
```