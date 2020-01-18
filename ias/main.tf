provider "aws" {
	access_key = "${var.aws_access_key}"
	secret_key = "${var.aws_secret_key}"
	region = "${var.region}"
}

##### VPC ######
resource "aws_vpc" "favpc" {
    cidr_block = "10.0.0.0/16"
    instance_tenancy = "default"
    enable_dns_support = true
    enable_dns_hostnames = true
    tags = {
        Name = "futurevpc"
    }
}

######## Public SubNet  #############
resource "aws_subnet" "fa_public_subnets_1" {
    vpc_id = "${aws_vpc.favpc.id}"
    cidr_block = "10.0.1.0/24"
    availability_zone = "${var.aws_zone_one}"
    map_public_ip_on_launch = true
    tags = {
        Name = "fa-publicsubnet_1"
    }
}
resource "aws_subnet" "fa_public_subnets_2" {
    vpc_id = "${aws_vpc.favpc.id}"
    cidr_block = "10.0.2.0/24"
    availability_zone = "${var.aws_zone_two}"
    map_public_ip_on_launch = true
    tags = {
        Name = "fa-publicsubnet_2"
    }
}

######## Private SubNet  #############
resource "aws_subnet" "fa_privatezone_1" {
    vpc_id = "${aws_vpc.favpc.id}"
    cidr_block = "10.0.10.0/24"
    availability_zone = "${var.aws_zone_one}"
    map_public_ip_on_launch = false
    tags = {
        Name = "fa-privatesubnet_1"
    }
}

resource "aws_subnet" "fa_privatezone_2" {
    vpc_id = "${aws_vpc.favpc.id}"
    cidr_block = "10.0.11.0/24"
    availability_zone = "${var.aws_zone_two}"
    map_public_ip_on_launch = false
    tags = {
        Name = "fa-privatesubnet_2"
    }
}

##### Internet Gateway ######
resource "aws_internet_gateway" "igw" {
    vpc_id = "${aws_vpc.favpc.id}"
    
    tags = {
        Name = "fa-igw"
    }
}

############## Public Route Table ##############
resource "aws_route_table" "main-public-rt" {
    vpc_id = "${aws_vpc.favpc.id}"
    route{
        cidr_block="0.0.0.0/0"
        gateway_id="${aws_internet_gateway.igw.id}"
    }

    tags = {
        Name="fa-public-rt"
    }
}

############## Public Route Table Association ##############
resource "aws_route_table_association" "route-tbl-link1" {
  subnet_id = "${aws_subnet.fa_public_subnets_1.id}"
  route_table_id = "${aws_route_table.main-public-rt.id}"
}

resource "aws_route_table_association" "route-tbl-link2" {
  subnet_id = "${aws_subnet.fa_public_subnets_2.id}"
  route_table_id = "${aws_route_table.main-public-rt.id}"
}

######## ALB ############
resource "aws_lb" "falb" {
    name = "fa-lb"
    internal = false
    load_balancer_type = "application"
    security_groups = ["${aws_security_group.lb-sg.id}"]
    subnets = ["${aws_subnet.fa_public_subnets_1.id}","${aws_subnet.fa_public_subnets_2.id}"]
    
}

##### ALB Target Group
resource "aws_alb_target_group" "lb-tg" {
  name = "fa-alb-tg"
  port = 8080
  protocol = "HTTP"
  vpc_id = "${aws_vpc.favpc.id}"

}
###### LB Listner #####
resource "aws_alb_listener" "lb-listner" {
  load_balancer_arn = "${aws_lb.falb.arn}"
  port = "8080"
  protocol = "HTTP"
  default_action {
      target_group_arn = "${aws_alb_target_group.lb-tg.arn}"
      type = "forward"
  }
}

resource "aws_instance" "jenkins-master" {
  ami = "ami-0b69ea66ff7391e80"
  instance_type = "t2.micro"
  availability_zone = "${var.aws_zone_one}"
  subnet_id = "${aws_subnet.fa_public_subnets_1.id}"
  vpc_security_group_ids = ["${aws_security_group.sg_allow_ssh_jenkins.id}"]
  user_data = "${file("installjenkins.sh")}"
  key_name = "${var.ssh_key}"
  associate_public_ip_address = true
  tags = {
    Name = "Jenkins-Master"
  }
}


###### Target group attachment #####
resource "aws_alb_target_group_attachment" "alb_instance1" {
  target_group_arn = "${aws_alb_target_group.lb-tg.arn}"
  target_id = "${aws_instance.jenkins-master.id}"
  port = 8080
}
output "jenkins_ip_address" {
  value = "${aws_lb.falb.dns_name}"
}