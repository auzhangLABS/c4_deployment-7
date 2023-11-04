# Deployment 7 Documentation

## Purpose:
The primary goal of deployment 7 is to familiarize ourselves with the containerization of our banking applications with tools like Docker and Amazon Elastic Container (ECS). We will use AWS Fargate together with ECS, which allows us to get the benefits of container orchestration and container management from ECS. This banking application will also include a shared Relational Database Service (RDS), which ensures consistent data across the containers. We also implement an Application Load Blancher (ALB) that would distribute the traffic among the containers. This deployment allows us to mitigate configuration drift and optimize our resources.
