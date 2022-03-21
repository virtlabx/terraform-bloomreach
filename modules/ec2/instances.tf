resource "aws_instance" "server" {
  count                       = var.instance_count
  vpc_security_group_ids      = var.instance_security_group_ids
  subnet_id                   = var.instance_subnet_id
  ami                         = var.instance_ami
  instance_type               = var.instance_type
  iam_instance_profile        = var.iam_instance_profile == "" ? null : var.iam_instance_profile
  ebs_optimized               = true
  associate_public_ip_address = var.public_ip
  key_name                    = "bloomreach-jenkins-dev"
  user_data                   = templatefile("${path.module}/cloud-init-generic.config.tpl", {
    hostname            = var.instance_hostname == "" ? format(var.instance_name_format, count.index + 1) : var.instance_hostname,
    jenkins_install     = var.jenkins_install,
    docker_install      = var.docker_install,
    cloudwatch_install  = var.cloudwatch_install,
    ssh_user            = var.ssh_user,
    ssh_authorized_keys = var.ssh_authorized_keys})
  root_block_device {
    volume_size = var.instance_volume_size
    volume_type = "gp2"
  }
  volume_tags = merge({ Name = "${var.instance_hostname == "" ? format(var.instance_name_format, count.index + 1) : var.instance_hostname} Disk"}, var.tags)
  tags        = merge({ Name = var.instance_hostname == "" ? format(var.instance_name_format, count.index + 1) : var.instance_hostname}, var.tags)
  lifecycle {
    ignore_changes = [ user_data, key_name ]
  }
}

resource "aws_route53_record" "record" {
  count   = var.instance_count
  zone_id = var.record_zone_id
  name    = var.instance_hostname == "" ? format(var.instance_name_format, count.index + 1) : var.instance_hostname
  type    = "A"
  ttl     = "300"
  records = [element(aws_instance.server.*.private_ip, count.index)]
}