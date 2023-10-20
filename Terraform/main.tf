

#vpc with 65k ip addresses
resource "aws_vpc" "main" {
  cidr_block = "10.0.0.0/16"

  tags = {
    name = "main"
  }
}


#IG for internet access conencted to main vpc as default route in public subnets
resource "aws_internet_gateway" "igw" {
    vpc_id = aws_vpc.main.id

    tags = {
        name = "igw"
    }
}


# 4 subnets to meet eks requirements 2 public 2 private in diff az each one 8k ip add
resource "aws_subnet" "private-eu-west-1a" {
    vpc_id = aws_vpc.main.id
    cidr_block = "10.0.0.0/19"
    availability_zone = "eu-west-1a"

    tags = {
        "name" = "private-eu-west-1a"
        "kubernetes.io/role/internal-elb" = "1" //needed for k8s to discover subnets whre private lb will be created
        "kubernetes.io/cluster/dev" = "owend" //eks cluster name owned meaning used only for k8s
    }
}

# second one private subnet - last ip in the frist subnet is 10.0.31.255 hence starts wtih .32
resource "aws_subnet" "private-eu-west-1b" {
    vpc_id = aws_vpc.main.id
    cidr_block = "10.0.32.0/19"
    availability_zone = "eu-west-1b"

    tags = {
        "name" = "private-eu-west-1b"
        "kubernetes.io/role/internal-elb" = "1" //needed for k8s to discover subnets whre private lb will be created
        "kubernetes.io/cluster/dev" = "owend" //eks cluster name owned meaning used only for k8s
    }
}


# first public subnet 
resource "aws_subnet" "public-eu-west-1a" {
    vpc_id = aws_vpc.main.id
    cidr_block = "10.0.64.0/19"
    availability_zone = "eu-west-1a"
    map_public_ip_on_launch = true // needed if you want to create public k8s instace groups worker will get public ip

    tags = {
        "name" = "public-eu-west-1a"
        "kubernetes.io/role/internal-elb" = "1" //needed for k8s to discover subnets whre private lb will be created
        "kubernetes.io/cluster/dev" = "owend" //eks cluster name owned meaning used only for k8s
    }
}

# second public subnet 
resource "aws_subnet" "public-eu-west-1a" {
    vpc_id = aws_vpc.main.id
    cidr_block = "10.0.96.0/19"
    availability_zone = "eu-west-1b"
    map_public_ip_on_launch = true //most times use private subnets for instance groups & create public lb in public subnets

    tags = {
        "name" = "public-eu-west-1b"
        "kubernetes.io/role/internal-elb" = "1" 
        "kubernetes.io/cluster/dev" = "owend" 
    }
}

# nat gw for private subnets to have access to internet
resource "aws_eip" "nat" {
    vpc = true

    tags = {
        name = "nat"
    }
}

# first allocate a public ip for nat gw
resource "aws_nat_gateway" "nat" {
    allocation_id = aws_eip.nat.id 
    subnet_id = aws_subnet.public-eu-west-1a.id //place it inside the public subnet - ig as default route

    tags = {
        name = "nat"
    }

    depends_on = [aws_internet_gateway.igw]
}


# private routing table and associate subnets with them
resource "aws_route_table" "private" {
    vpc_id = aws_vpc.main.id

    route = [
        {
            cidr_block = "0.0.0.0/0" //default route to nat gw
            nat_gateway_id = aws_nat_gateway.nat.id
            carrier_gateway_id = ""
            destination_prefix_list_id = ""
            egress_only_gateway_id = ""
            gateway_id = ""
            instance_id = ""
            ipv6_cidr_block = ""
            local_gateway_id = ""
            network_interface_id = ""
            transit_gateway_id = ""
            vpc_endpoint_id = ""
            vpc_peering_connection_id = ""

        }
    ]

    tags = {
        name = "private"
    }
}

# public  rt with default route to igw
resource "aws_route_table" "public" {
    vpc_id = aws_vpc.main.id

    route = [
        {
            cidr_block = "0.0.0.0/0" //default route to nat gw
            nat_gateway_id = aws_internet_gateway.igw.id
            carrier_gateway_id = ""
            destination_prefix_list_id = ""
            egress_only_gateway_id = ""
            gateway_id = ""
            instance_id = ""
            ipv6_cidr_block = ""
            local_gateway_id = ""
            network_interface_id = ""
            transit_gateway_id = ""
            vpc_endpoint_id = ""
            vpc_peering_connection_id = ""
        }
    ]

    tags = {
        name = "public"
    }
}

# To associate all 4 subnets with route table
resource "aws_route_table_association" "private-eu-west-1a" {
    subnet_id = aws_subnet.private-eu-west-1a.id
    route_table_id = aws_route_table.private.id
}

resource "aws_route_table_association" "private-eu-west-1b" {
    subnet_id = aws_subnet.private-eu-west-1a.id
    route_table_id = aws_route_table.private.id
}


resource "aws_route_table_association" "public-eu-west-1a" {
    subnet_id = aws_subnet.public-eu-west-1a.id
    route_table_id = aws_route_table.public.id
}


resource "aws_route_table_association" "public-eu-west-1b" {
    subnet_id = aws_subnet.public-eu-west-1b.id
    route_table_id = aws_route_table.public.id
}



##### eks cluster

# iam role to call for the eks cluster
resource "aws_iam_role" "dev" {
    name = "eks-cluster-dev"
    
    assume_role_policy = <<POLICY
}

    "Version": "2012-10-17",
    "Statement": [
        {
            "Effect": "Allow",
            "Principal": {
                "Service": "eks.amazonaws.com"
            },
            "Action": "sts:AssumeRole"
        }
    ]
}
POLICY
}

# attach iam policy to the required iam role above
resource "aws_iam_role_policy_attachment" "dev-AmazonEKSClusterPolicy" {
    policy_arn = "arn:aws:iam::aws:policy/AmazonEKSClusterPolicy"
    role = aws_iam_role.demo.name
}


# eks cluster config 
resource "aws_eks_cluster" "demo" {
    name = "dev"
    role_arn = aws_iam_role.dev.arn //role created for eks

    vpc_config {
        subnet_ids = [  //subnets for eks to create nodes & lb
            aws_subnet.aws_subnet.private-eu-west-1a.id,
            aws_subnet.aws_subnet.private-eu-west-1b.id,
            aws_subnet.aws_subnet.public-eu-west-1a.id,
            aws_subnet.aws_subnet.public-eu-west-1b.id,
        ]
    }

    depends_on = [aws_iam_role.policy_attachment.dev-AmazonEKSClusterPolicy] //until iam role ready eks cluster wont be created
}



## NODES

# instance group for k8s iam role needed
resource "aws_iam_role" "nodes" {
    name = "eks-node-group-nodes"

    assume_role_policy = jsonencode({  //using built in jsoncoder tf function to convert this obj to json
        Statement = [{
            Action = "sts:AssumeRole"
            Effect = "Allow"
            Principle = {
                Service = "ec2.amazonaws.com"
            }
        }]
        Version = "2012-10-17"
    })
}

# attach policies to the role above
//aws eks kubelet makes calls to aws apis on ur behalf
resource "aws_iam_role_policy_attachment" "nodes-AmazonEKSWorkerNodePolicy" {
    policy_arn = "arn:aws:iam::aws:policy/AmazonEKSWorkerNodePolicy" //grants access to eks and ec2
    role = aws_iam_role.nodes.name
}

resource "aws_iam_role_policy_attachment" "nodes-AmazonEKS_CNI_Policy" {
    policy_arn = "arn:aws:iam::aws:policy/AmazonEKS_CNI_Policy" //grants access to aws eks CNI policy
    role = aws_iam_role.nodes.name
}

resource "aws_iam_role_policy_attachment" "nodes-AmazonEC2ContainerRegistryReadOnly" {
    policy_arn = "arn:aws:iam::aws:policy/AmazonEC2ContainerRegistryReadOnly" //allows to download and run docker images from ecr reg
    role = aws_iam_role.nodes.name
}


# node group workers configs
resource "aws_eks_node_group" "private-nodes" {
    cluster_name = aws_eks_cluster.dev.name //assoicate instance group with eks cluster
    node_group_name = "private-nodes"
    node_role_arn = aws_iam_role.node.arn //attach iam role

    # define subnets where you want to run your nodes
    subnet_ids = [
        aws_subnet.private-eu-west-1a.id,
        aws_subnet.private-eu-west-1b.id
    ]

    capacity_type = "ON_DEMAND"  //or spot instance cheaper but can go offline
    instance_types = [t2.micro]

       // eks by itself wont scale ur nodes have to deploy cluster afterscalor and define min max, eks will use this setting to create aws afterscaling group on ur behalf
    scaling_config {  
        desired_size = 1
        max_size = 3
        min_size = 0
    }

    update_config {
        max_unavailable = 1 // this is the desired max num of unavail. worker nodes during node group updates
    }

    labels = {
        role = "general"
    }
    
    taint { // i.e node affinity to schedule on particular node group and repel pods
        key = "team"
        value = "devops"
        effect = "NO_SCHEDULE"
    }

    depends_on = [  //first create the roles to be created before this step
        aws_iam_role_policy_attachment.nodes-AmazonEKSWorkerNodePolicy,
        aws_iam_role_policy_attachment.nodes-AmazonEKS_CNI_Policy,
        aws_iam_role_policy_attachment.nodes-AmazonEC2ContainerRegistryReadOnly
    ]
}

