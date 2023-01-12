
# Resource-8: Create EC2 Instance
resource "aws_instance" "my-ec2-vm" {
  ami = "ami-0cca134ec43cf708f" # Amazon Linux
  instance_type = "t2.micro"
 # count = "${length(var.subnet_cidrs_private)}"
  subnet_id = aws_subnet.public[0].id
  key_name = "aws_key"
	#user_data = file("apache-install.sh")
  user_data = <<-EOF
    #!/bin/bash
    sudo yum update -y
    sudo yum install httpd -y
    sudo systemctl enable httpd
    sudo systemctl start httpd
    echo "<h1>Welcome to StackSimplify ! AWS Infra created using Terraform in $var.region Region</h1>" > /var/www/html/index.html
    EOF  
  vpc_security_group_ids = [ aws_security_group.dev-vpc-sg.id ]
  tags= {
    key = "Name"
    value = "Bastion-host"
  }

}

# Resource-9: Create Elastic IP
resource "aws_eip" "my-eip" {
#  count = "${length(var.subnet_cidrs_private)}"
# instance = aws_instance.my-ec2-vm[count.index].id
  instance = aws_instance.my-ec2-vm.id
  vpc = true
  depends_on = [ aws_internet_gateway.vpc-dev-igw ]
}

