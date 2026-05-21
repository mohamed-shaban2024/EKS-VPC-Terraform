########################### الجزء بتاع ال vpc ######################
module "vpc" {
  source  = "terraform-aws-modules/vpc/aws"
  version = "5.8.1"

  name = "eks-vpc"
  cidr = "10.0.0.0/16"

  azs             = ["us-east-1a", "us-east-1b"]
  private_subnets = ["10.0.1.0/24", "10.0.2.0/24"]
  public_subnets  = ["10.0.101.0/24", "10.0.102.0/24"]

  enable_nat_gateway = true
  single_nat_gateway  = true

  tags = {
    "kubernetes.io/cluster/mo-eks" = "shared"
  }
}

########################### الجزء بتاع ال EKS ######################


module "eks" {
  source  = "terraform-aws-modules/eks/aws"
  version = "~> 19.21.0" # كنت عاوز اشوف ال موضوع ال versions دا 

  cluster_name    = "mo-eks"
  cluster_version = "1.29"

  vpc_id     = module.vpc.vpc_id
  subnet_ids  = module.vpc.private_subnets

  eks_managed_node_groups = {
    dev = {
      instance_types = ["t3.small"]

      min_size     = 1
      max_size     = 2
      desired_size = 1

      capacity_type = "ON_DEMAND"
      ami_type      = "AL2_x86_64"
    }
  }

  tags = {
    Environment = "mo"
    Terraform   = "true"
  }
}
