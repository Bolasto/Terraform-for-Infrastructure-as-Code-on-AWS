# Terraform-for-Infrastructure-as-Code-on-AWS
For the second semester project at Altschool, our task involved utilizing Terraform scripts to configure an infrastructure on AWS. The project aimed to set up two EC2 instances on AWS, establish a Nginx web server on these instances using Ansible, and implement an Application Load Balancer (ALB) to efficiently route requests to the EC2 instances.

To enhance scalability and load distribution, we ensured that all web traffic accessed the web servers exclusively through the ALB. By implementing the ALB, we achieved greater reliability and optimized performance for our application.

In terms of network configuration, we defined a logical network within the cloud environment for the servers. The EC2 instances were launched within a private network, ensuring that they were not assigned public IP addresses. This approach enhanced security and limited direct access to the instances, with all incoming traffic being properly routed through the ALB.

As part of the project requirements, the web servers were programmed to display their own Hostname or IP address. To access the web servers, we utilized the IP addresses associated with the instances, but only through the load balancer. This ensured that all requests were properly balanced and directed to the available instances.

By implementing this Terraform and Ansible-based solution on AWS, we achieved a robust and scalable infrastructure setup with proper load balancing and secure network configuration.
