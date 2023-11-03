
# configure aws provider
provider "aws" {
  # for access/secret key please enter your own
  access_key = var.access_key
  secret_key = var.secret_key
  region = "us-east-1"
  #profile = "Admin"
}



# create instance
resource "aws_instance" "jenkins_man" {
  ami = var.ami
  instance_type = var.instance_type
  associate_public_ip_address = true
  #key_name = "ubuntuSandbox"
  vpc_security_group_ids = [var.defaultsg]
  key_name = "d6"

  user_data = "${file("deployjenkins.sh")}"

  tags = {
    "Name" : "d7_Jenkins_manager"
  }

}

# create instance
resource "aws_instance" "terraform" {
  ami = var.ami
  instance_type = var.instance_type
  associate_public_ip_address = true
  #key_name = "ubuntuSandbox"
  vpc_security_group_ids = [var.defaultsg]
  key_name = "d6"
  user_data = "${file("deployterraform.sh")}"

  tags = {
    "Name" : "d7_Terraform"
  }

}

# create instance
resource "aws_instance" "docker" {
  ami = var.ami
  instance_type = var.instance_type
  associate_public_ip_address = true
  #key_name = "ubuntuSandbox"
  vpc_security_group_ids = [var.defaultsg]
  key_name = "d6"
  user_data = "${file("deploydocker.sh")}"

  tags = {
    "Name" : "d7_Docker"
  }

}


output "instance_ip" {
  value = aws_instance.jenkins_man.public_ip

}

output "instance_ip2" {
  value = aws_instance.terraform.public_ip
}

output "instance_ip3" {
  value = aws_instance.docker.public_ip
}
