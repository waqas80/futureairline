locals {
  jenkins_master_url = "http://${aws_lb.falb.dns_name}:${var.jenkins_port}"
}

resource "aws_instance" "jenkins-slave" {
  ami = "ami-0b69ea66ff7391e80"
  instance_type = "t2.micro"
  availability_zone = "${var.aws_zone_two}"
  subnet_id = "${aws_subnet.fa_privatezone_1.id}"
  vpc_security_group_ids = ["${aws_security_group.sg_allow_ssh_jenkins.id}"]
  user_data = "${file("installjenkins.sh")}"
  key_name = "${var.ssh_key}"
  associate_public_ip_address = true
  tags = {
    Name = "Jenkins-Master"
  }
}

data "template_file" "bootstrap" {
  template = "${file("joincluster.tpl")}"

  vars = {
    jenkins_master_url = "${local.jenkins_master_url}"
  }

}