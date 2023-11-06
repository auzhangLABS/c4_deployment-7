# Deployment 7 Documentation

## Purpose:
The primary goal of deployment 7 is to familiarize ourselves with containerizing our banking applications with tools like Docker and Amazon Elastic Container (ECS). We will use AWS Fargate with ECS, which allows us to get the benefits of container orchestration and container management from ECS. This banking application will also include a shared Relational Database Service (RDS), which ensures consistent data across the containers. We also implemented an Application Load Blancher (ALB) that would distribute the traffic among the containers. This deployment allows us to mitigate configuration drift and optimize our resources.

## Steps:
I began this deployment by creating a new branch called `stage` in Git and creating a new RDS. To see how to create a new RDS, click [here!](https://github.com/auzhangLABS/c4_deployment-6-main)

#### Provisioning our First AWS Infrastructure with Terraform
I created a new AWS infrastructure using this [Terraform file](https://github.com/auzhangLABS/c4_deployment-7/blob/main/firstTerraform/main.tf) that I created. This file is designed to create three distinct instances within my default VPC. Each instance has a specific configuration using different user data. Here is a detailed look: 
- Jenkins Instance: using [this user data](https://github.com/auzhangLABS/c4_deployment-7/blob/main/firstTerraform/deployjenkins.sh).
- Terraform Instance: using [this user data](https://github.com/auzhangLABS/c4_deployment-7/blob/main/firstTerraform/deployterraform.sh).
- Docker Instance: using [this user data](https://github.com/auzhangLABS/c4_deployment-7/blob/main/firstTerraform/deploydocker.sh).

Here is what our first infrastructure looks like with Terraform:
![d7p1 drawio](https://github.com/auzhangLABS/c4_deployment-7/assets/138344000/78d0fc01-30f6-456d-8ca1-bb896e8c8586)

#### Ultizing Jenkins for specific stages in the deployment
We use the Jenkinsfile to leverage Jenkins agents on both the Terraform and Docker instances. To see how to install Jenkins agent, refer [here!](https://github.com/auzhangLABS/c4_deployment5.1#creating-a-jenkins-agent-on-instance). Here are the roles of the agents:
- Docker Agent: This agent will test the application, build the Docker image, authenticate Docker Hub, and push the image to Docker Hub. This process is crucial to ensuring that the application is tested and containerized.
- Terraform Agent: After the Docker agent is finished, this agent will handle the infrastructure. It will initialize the Terraform backend, plan the infrastructure, and apply a fresh infrastructure. <br>

To see the full JenkinsFile, click [here!](https://github.com/auzhangLABS/c4_deployment-7/blob/main/Jenkinsfiles).

The second AWS infrastructure that Terraform agent created includes:
- In [VPC.tf](https://github.com/auzhangLABS/c4_deployment-7/blob/main/intTerraform/vpc.tf) :
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
- In [ALB.tf](https://github.com/auzhangLABS/c4_deployment-7/blob/main/intTerraform/ALB.tf) :
   - Target Group: responsible for routing traffic to the receivers (IP). We set the target to be identified by IP address and enabled a health check. This allows the ALB to send requests to the path to ensure the targets are healthy and able to handle incoming requests.
   - Application Load Balancer: distributes incoming traffic to multiple targets.
   - ALB Listener: checks for requests from clients using port 80.
- In [main.tf](https://github.com/auzhangLABS/c4_deployment-7/blob/main/intTerraform/main.tf) :
   - ECS Cluster: used to organize and run containerized applications.
   - CloudWatch Log Group: stored the logs from the ECS service.
   - ECS Task Definition: The blueprint for running containers may include the image, port, and resources (memory and CPU). In this deployment, we expose port 8000 of the container and run it with Fargate (serverless infrastructure). We also set the memory and CPU requirements for this task
   - ECS Service: manage the deployment and scale the task definition. We configured this to use the Fargate launch type, which allows us to run the container without the use of instances. Additionally, we specified the desired count to two which would ensure that two tasks are running at any given time
 
Here is a visual look at the resources:
![d7 2 drawio](https://github.com/auzhangLABS/c4_deployment-7/assets/138344000/ecb5c7cb-1bcc-4d51-993c-aefbdeec4576)

#### Customizing the Jenkin Pipeline Configuration
1. Edit Jenkinsfile line 4 to integrate my Dockhub account:
   `DOCKERHUB_CREDENTIALS = credentials('your docker user name-dockerhub')`: this line tells Jenkins to use your Docker credentials stored on Jenkins to authenticate.
3. Modify Jenkinsfile lines 31 and 42 with my Docker image
   `sh 'docker build -t aubreyz/bank4 .` and `sh 'docker push aubreyz/bank4'`: ensuring Jenkins build and pushes using the correct image

#### Configuring Jenkins with Docker and other Credentials
First, I added my AWS access and secret key to Jenkins global credentials. To see how I added my credentials to Jenkins, click [here](https://github.com/auzhangLABS/c4_deployment-6-main#configuring-aws-credentials-in-jenkins) <br>
Then, I created my Docker token from Docker Hub, in which I entered my Docken token into the Jenkin global credentials section. Here is how I enter my Docker credentials: <br>
![image](https://github.com/auzhangLABS/c4_deployment-7/assets/138344000/671a29be-3667-4412-83b9-aad5d8a6f1eb)

#### Running the Jenkins Pipeline and verifying Application and Infrastructure
We ran a multibranch pipeline. Once this is finished, we check our infrastructure to make sure it is correct, as well as check the banking application to make sure it's running.
We ran a multibranch pipeline within Jenkins to deploy our banking application. Once this was successful, we performed a verification of the infrastructure to ensure all resources were created. Additionally, we check our banking application to ensure it works using the ALB DNS. <br>
![image](https://github.com/auzhangLABS/c4_deployment-7/assets/138344000/8c80a553-757b-4ad1-90bc-9597589f2cba)

Just so you know, the implementation was carried out on a new branch called Stage. After testing and ensuring that all files worked properly, I merged it back to the main from the Git repository.

## System Design Diagram:
![image](https://github.com/auzhangLABS/c4_deployment-7/assets/138344000/c5f53e96-627f-4389-9590-a2f14ec12a86)
<br>
To view the full system design diagram, click [here!](https://github.com/auzhangLABS/c4_deployment-7/blob/main/finaldiagram.png)

## Issues and Troubleshooting
I encountered an issue with the Jenkins pipeline where the Docker authentication was not accepting my credentials. I resolve this by appending `-dockerhub` to my username.

## Optimization
1. Implement an auto-scaling group: we currently have a static number of containers running. To accommodate traffic spikes, we can consider an ASG to dynamically adjust the number of active containers in response to demand.
2. Enhance Database Security: Currently, we have our RDS in the public subnet. Consider putting it on a private subnet and making the RDS inaccessible from the public internet.

### Commonly Asked Questions:
1. Is your infrastructure secure? If yes or no, why?
   - I believe the container infrastructure is secure. However, the database is not because it currently resides on the public subnet.
2. What happens when you terminate one instance? Is this infrastructure fault-tolerant?
   - This infrastructure is fault-tolerant because if one container is down or fails, it will automatically launch another replacement one.
3. Which subnet were the containers deployed?
   - Containers were deployed in the private subnet of us-east-1a and us-east-1b
