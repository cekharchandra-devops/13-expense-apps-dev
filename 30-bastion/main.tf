module "ec2_instance" {
  source  = "terraform-aws-modules/ec2-instance/aws"

  name = local.instance_name
  ami = data.aws_ami.ami_info.id  # if dont give this terraform chooses default ami and login gets failed
  instance_type          = "t3.micro"
  vpc_security_group_ids = [local.bastion_sg]
  subnet_id              = local.public_subnet_id

  tags = merge(
    var.common_tags,
    var.bastion_tags,
    {
        Name = "${local.instance_name}-bastion"
    }
  )
}