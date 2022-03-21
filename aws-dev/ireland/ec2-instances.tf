module "jenkins-dev-master" {
  source                      = "../../modules/ec2/"
  instance_hostname           = "jenkins-dev-master"
  instance_subnet_id          = module.eks-vpc.public_subnets[0]
  instance_security_group_ids = [aws_security_group.bloomreach-jenkins-dev-sg.id]
  instance_type               = "t3a.medium"
  iam_instance_profile        = aws_iam_instance_profile.cloudwatch-agent-instance-profile.name
  instance_ami                = "ami-0069d66985b09d219"
  record_zone_id              = aws_route53_zone.bloomreach.zone_id
  ssh_user                    = "jenkins"
  ssh_authorized_keys         = aws_key_pair.bloomreach-jenkins-dev.public_key
  tags                        = merge({ Name = "jenkins-dev-master" }, local.dev-tags)
}

resource "aws_eip" "jenkins-master-eip" {
  vpc      = true
  instance = module.jenkins-dev-master.servers[0].id
  tags     = merge({ Name = "jenkins-master-eip" }, local.dev-tags)
}