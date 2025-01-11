
# Backend Infrastructure Deployment with Terraform

This document provides a detailed explanation of the Terraform configuration used to deploy a scalable backend infrastructure. The resources created include EC2 instances, load balancers, auto-scaling groups, and more, with the rationale behind each resource's creation.

---

## **1. EC2 Instance Creation (Backend)**
### **Module: `backend`**

**Purpose**:
- To create a single backend EC2 instance for configuration and AMI creation.

**Key Details**:
- **AMI**: `ami` is the image ID used to launch the instance.
- **Instance Type**: `t3.micro` is chosen for its balance of cost and performance.
- **Security Group**: The security group is fetched dynamically and attached to the instance to control traffic.
- **Tags**: Metadata such as `Name` is assigned for easier identification.

**Reason**:
This instance serves as a template for backend servers. It is configured and customized before being turned into an AMI.

---

## **2. Null Resource for Configuration**
### **Resource: `null_resource.backend`**

**Purpose**:
- To configure the backend instance after its creation using a script.

**Key Details**:
- **Triggers**: Executes whenever the `instance_id` changes.
- **Connection**: Connects via SSH to the instance using predefined credentials.
- **Provisioners**:
  - `file`: Uploads a script (`backend.sh`) to the instance.
  - `remote-exec`: Runs commands to execute the script and configure the instance.

**Reason**:
Automates the setup of the backend environment, ensuring consistency and saving time.

---

## **3. Stop EC2 Instance**
### **Resource: `aws_ec2_instance_state.backend`**

**Purpose**:
- To stop the backend instance after configuration.

**Reason**:
Stopping the instance ensures it is in a stable state before creating an AMI, avoiding issues with inconsistent configurations.

---

## **4. Create AMI from Instance**
### **Resource: `aws_ami_from_instance.backend`**

**Purpose**:
- To create a custom AMI from the configured EC2 instance.

**Reason**:
The AMI is used to launch identical backend instances, ensuring consistency across all instances in the Auto Scaling Group.

---

## **5. Terminate EC2 Instance**
### **Resource: `null_resource.backend_delete`**

**Purpose**:
- To terminate the EC2 instance after the AMI is created.

**Reason**:
The original instance is no longer needed once the AMI is prepared, reducing unnecessary costs.

---

## **6. Load Balancer Target Group**
### **Resource: `aws_lb_target_group.backend`**

**Purpose**:
- To define a target group for load balancing backend instances.

**Key Details**:
- **Port**: Backend applications listen on port `8080`.
- **Health Check**: Configures health checks to ensure only healthy instances receive traffic.

**Reason**:
Ensures traffic is routed to healthy backend instances, improving reliability and availability.

---

## **7. Launch Template**
### **Resource: `aws_launch_template.backend`**

**Purpose**:
- To define a reusable template for launching backend instances.

**Key Details**:
- **AMI**: Uses the custom AMI created earlier.
- **Instance Type**: Matches the backend instance type (`t3.micro`).
- **Tags**: Includes organizational metadata.

**Reason**:
Standardizes instance configurations, making it easier to manage and replicate instances in the Auto Scaling Group.

---

## **8. Auto Scaling Group (ASG)**
### **Resource: `aws_autoscaling_group.backend`**

**Purpose**:
- To automatically scale backend instances based on traffic or resource usage.

**Key Details**:
- **Desired Capacity**: Starts with 2 instances.
- **Min/Max Size**: Ensures at least 2 and at most 10 instances.
- **Health Check**: Monitors instance health and replaces unhealthy instances.
- **Subnets**: Launches instances in private subnets for security.

**Reason**:
Provides high availability and handles traffic spikes dynamically, ensuring backend services remain responsive.

---

## **9. Auto Scaling Policy**
### **Resource: `aws_autoscaling_policy.example`**

**Purpose**:
- To define a scaling policy based on CPU utilization.

**Key Details**:
- **Metric**: Monitors average CPU utilization of the ASG.
- **Threshold**: Adds or removes instances to maintain CPU usage around 70%.

**Reason**:
Optimizes resource usage and ensures performance during varying traffic loads.

---

## **Summary**
This Terraform configuration creates and manages a backend infrastructure with the following features:
1. A single EC2 instance is configured and used to create a custom AMI.
2. A Target Group ensures load balancing and health checks for backend instances.
3. A Launch Template standardizes instance configurations.
4. An Auto Scaling Group ensures high availability and dynamic scaling.
5. An Auto Scaling Policy optimizes resource usage based on traffic.

This approach ensures consistency, scalability, and cost-effectiveness for backend services.
