# 8-bit Street Hoops

This project is a tiny 8-bit style basketball game rendered on a canvas. Move your player with the arrow keys, shoot with `Space`, and dunk with `D` when close to the hoop. A simple CPU opponent will try to steal the ball.

## Running locally

```
npm install
npm start
```

Then open `http://localhost:8080` in your browser.

## Container

A `Dockerfile` is provided. Build and run it locally with:

```
docker build -t hoops .
docker run -p 8080:8080 hoops
```

The image can be pushed to a container registry and deployed to AWS ECS using Fargate.

## One-step deployment

Run the provided `run` script to build the image, push it to ECR and apply the
Terraform configuration:

```bash
chmod +x run
./run
```

`AWS_REGION`, `TAG` and `ECR_REPO` can be overridden as environment variables
before running the script.

## Deployment with Terraform

Terraform scripts in the `terraform` directory provision an ECR repository, ECS cluster, task definition and service using AWS Fargate. Set the `container_image` variable to the image URI you pushed to ECR, then run:

```bash
terraform init
terraform apply -auto-approve -var="container_image=<ECR image URI>"
```

The service will launch a public task running the container on port 8080.
