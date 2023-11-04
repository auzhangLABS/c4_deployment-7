# Deployment 7 Documentation

## Purpose:
The primary goal of deployment 7 is to familiarize ourselves with containerizing our banking applications with tools like Docker and Amazon Elastic Container (ECS). We will use AWS Fargate with ECS, which allows us to get the benefits of container orchestration and container management from ECS. This banking application will also include a shared Relational Database Service (RDS), which ensures consistent data across the containers. We also implemented an Application Load Blancher (ALB) that would distribute the traffic among the containers. This deployment allows us to mitigate configuration drift and optimize our resources.

## Steps:
I began this deployment by creating a new branch called `stage` in Git

#### Provisioning our First AWS Infrastructure with Terraform
I created a new AWS infrastructure using this [Terraform file](terraform file) that I created. This file is designed to create three distinct instances within my default VPC. Each instance has a specific configuration using different user data. Here is a detailed look: 
- Jenkins Instance: using [this user data]( Jenkins User data)
- Terraform Instance: using [this user data](Terraform User data)
- Docker Instance: using [this user data](Docker User data)

Here is what our first infrastructure looks like with Terraform:
![d7p1 drawio](https://github.com/auzhangLABS/c4_deployment-7/assets/138344000/78d0fc01-30f6-456d-8ca1-bb896e8c8586)

#### Ultizing Jenkins for specific stages in the deployment
We use the Jenkinsfile to leverage Jenkins agents on both the Terraform and Docker instances. To see how to install Jenkins agent, refer [here!](Jenkins agent) Here are the roles of the agents:
- Docker Agent: This agent will test the application, build the Docker image, authenticate Docker Hub, and push the image to Docker Hub. This process is crucial to ensuring that the application is tested and containerized.
- Terraform Agent: After the Docker agent is finished, this agent will handle the infrastructure. It will initialize the Terraform backend, plan the infrastructure, and apply a fresh infrastructure. <br>

To see the full JenkinsFile, click [here!](jenkins files).

The infrastructure that Terraform created includes:
- In VPC.tf:
   - 1 VPC
   - 2 Available Zones
   - 2 Public Subnets
   - 2 Private Subnets
   - 2 Security Groups:
     - One allowing inbound traffic on port 80.
     - Another allowing inbound traffic on port 8000.
   - 2 Route Table
   - 1 Elastic IP
   - 1 Internet Gateway
   - 1 NAT Gateway
- In ALB.tf:
   - Target Group: responsible for routing traffic to the receivers (IP).
   - Application Load Balancer: distributes incoming traffic to multiple targets.
   - ALB Listener: checks for requests from clients using port 80.
- In main.tf:
   - ECS Cluster: used to organize and run containerized applications.
   - CloudWatch Log Group: stored the logs from the ECS container.
   - ECS Task Definition: Blueprint for running containers may include the image, port, and resources (memory and CPU).
   - ECS Service: manage the deployment and scale the task definition.
