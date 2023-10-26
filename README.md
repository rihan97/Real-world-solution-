# Real-world-solution-using-DevOps-core-technolgies

## Building and Deploying a Python Application with Docker, Infrastructure as Code, and Kubernetes


### Objective:
In this tech challenge, your objective is to showcase your ability to design, develop, and
deploy a reliable Python application using Docker, Infrastructure as Code (IaC), and
Kubernetes with a strong emphasis on ensuring system reliability and robustness. You will be
assessed on your proficiency in various aspects of infrastructure management, including
containerisation, IaC implementation, and Kubernetes orchestration. This challenge aims to
evaluate your problem-solving skills, attention to reliability, and understanding of
contemporary DevOps practices.


#### Task 1: Develop the Python API Server
Begin by developing a API Server using Python as the chosen programming language, with
two essential endpoints:
- GET /users: Retrieve a list of all users.
- POST /user: Enable the creation of a new user.
To enhance the reliability and maintainability of your application, please adhere to the
following guidelines:
- Structure your application code in a well-organised manner, following coding standards
and separation of concerns.
- Implement data persistence mechanisms to securely store user information. This will
not only extend the functionality of your application but will also provide an
opportunity to demonstrate your commitment to reliability.
- Apply basic error handling techniques to handle common scenarios, such as invalid
requests or database errors.


#### Task 2: Dockerise Your Application
Next, containerise your Python API server using Docker, ensuring that it can be seamlessly
deployed in containerised environments.


#### Task 3: Infrastructure as Code (IaC)
In this step, employ IaC principles and tools like Terraform or Pulumi to orchestrate the
creation of the EKS cluster. Provision all the essential resources, including roles and policies,
required for the EKS cluster’s operation.


#### Task 4: Kubernetes Deployment with Helm
Now, create a custom Helm Chart that includes templates for deploying your Python API
server within the Kubernetes cluster. Define Helm Chart templates to encapsulate
deployment, configuration, and scaling aspects of your application within the Kubernetes
cluster.