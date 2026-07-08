cd ~/do cls## Incident Management Portal — AWS ECS Fargate Deployment

This project is a containerized full-stack Incident Management Portal deployed to AWS using Terraform, Docker, ECS Fargate, Application Load Balancer, RDS PostgreSQL, Route 53, ACM, Secrets Manager, ECR, CloudWatch, and GitHub Actions.

The goal of the project was to move a local Dockerized application into a production-style AWS environment with secure networking, HTTPS, database connectivity, API routing, and automated deployments.

### Live Architecture

The application uses the following AWS services:

* **Amazon ECS Fargate** to run frontend and backend containers
* **Amazon ECR** to store Docker images
* **Application Load Balancer** to route public traffic
* **HTTPS listener on port 443** using an ACM certificate
* **HTTP listener on port 80** redirecting traffic to HTTPS
* **Route 53** for custom domain DNS
* **Amazon RDS PostgreSQL** for persistent ticket data
* **AWS Secrets Manager** for secure database connection storage
* **CloudWatch Logs** for backend and frontend container logs
* **Terraform** for infrastructure provisioning
* **GitHub Actions** for CI/CD deployment

### Routing Design

The ALB routes traffic as follows:

```text
https://incident.starttechapp.uk        → Frontend ECS service
https://incident.starttechapp.uk/api/*  → Backend ECS service
http://incident.starttechapp.uk         → Redirects to HTTPS
```

### API Validation

The backend exposes health and ticket endpoints:

```bash
curl -i https://incident.starttechapp.uk/api/health
curl -i https://incident.starttechapp.uk/api/health/db
curl -i https://incident.starttechapp.uk/api/tickets
```

The database health endpoint confirms that the backend can connect successfully to PostgreSQL.

### CI/CD Pipeline

GitHub Actions is used to automate deployments. On push to the main branch, the pipeline:

1. Checks out the repository
2. Authenticates to AWS
3. Builds the backend Docker image
4. Pushes the backend image to ECR
5. Builds the frontend Docker image
6. Pushes the frontend image to ECR
7. Registers new ECS task definitions
8. Updates the ECS frontend and backend services
9. Validates the live HTTPS application endpoints

### Week 6: Terraform Modules and Team Workflow

For the Week 6 portfolio task, the infrastructure code was prepared for a more realistic team-based delivery workflow.

Key changes included:

* **Refactored ECS Terraform into reusable modules** so shared infrastructure components such as VPC, security groups, RDS, Secrets Manager, IAM, ALB, CloudWatch, ECS, ACM, and Route 53 are separated from the environment configuration.
* **Used ticket-based branch naming** with branches such as `project-101-*`, `project-103-*`, and `project-107-*` to keep infrastructure changes linked to clear units of work.
* **Created a PR-style workflow** where changes are developed on feature branches, pushed to GitHub, reviewed through pull requests, and merged only after checks pass.
* **Added validation steps** through GitHub Actions to run Terraform formatting, initialization, validation, and planning before infrastructure changes are merged.
* **Practiced Terraform plan review** by using `terraform plan` output to inspect what Terraform intends to create, update, or delete before applying changes.
* **Documented module usage** so the production environment mainly calls reusable modules instead of defining every AWS resource directly in one large file.
* **Prepared the project for team-based infrastructure delivery** by making the codebase easier to review, safer to change, and more consistent with collaborative DevOps practices.

### Key Problems Solved

During the deployment, I resolved several real-world infrastructure issues, including:

* Configuring ALB path-based routing for `/api/*`
* Setting up HTTPS with ACM and Route 53
* Redirecting HTTP traffic to HTTPS
* Injecting the database connection string securely into ECS tasks using Secrets Manager
* Fixing ECS backend database connectivity after rebuilding the environment
* Recovering from Terraform state issues after local files were accidentally removed
* Cleaning up AWS resources safely after state drift
* Rebuilding the environment successfully from Terraform after destroy

### Final Validation

The final deployment confirmed:

* Frontend loads over HTTPS
* Backend API is reachable through the ALB
* RDS PostgreSQL is available
* Backend connects successfully to the database
* Ticket creation and ticket retrieval work successfully
* GitHub Actions can deploy new container images to ECS

### Cleanup

To avoid ongoing AWS charges, the infrastructure can be destroyed with:

```bash
cd terraform/environments/ecs-prod
terraform destroy
```

Important: After destroy, verify that ECS, RDS, ALB, NAT Gateway, and Elastic IP resources have been removed...
